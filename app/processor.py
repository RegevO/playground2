import json
import requests
import boto3
import sys

def process_and_verify(cf_domain):
    # --- Configuration ---
    SOURCE_URL = "https://dummyjson.com/products"
    BUCKET_NAME = "regev-osher-products-bucket"
    FILE_NAME = "products.json"
    
    # Construct the dynamic CloudFront URL
    CF_URL = f"https://{cf_domain}/{FILE_NAME}"
    PRICE_THRESHOLD = 100

    # A. Download JSON from dummyjson
    print(f"Step A: Downloading data from {SOURCE_URL}...")
    try:
        response = requests.get(SOURCE_URL)
        response.raise_for_status()
        raw_data = response.json()
    except Exception as e:
        print(f"Failed to download source data: {e}")
        sys.exit(1)

    # B. Parse and filter products (price >= 100)
    print(f"Step B: Filtering products with price >= {PRICE_THRESHOLD}...")
    filtered_products = [
        item for item in raw_data.get("products", []) 
        if item.get("price", 0) >= PRICE_THRESHOLD
    ]
    
    output_data = {
        "metadata": {
            "source": SOURCE_URL,
            "filter": f"price >= {PRICE_THRESHOLD}",
            "count": len(filtered_products)
        },
        "products": filtered_products
    }

    # C. Upload to S3
    print(f"Step C: Uploading filtered JSON to S3 bucket: {BUCKET_NAME}")
    try:
        # Note: In GitHub Actions, this uses the AWS credentials provided in the workflow
        s3 = boto3.client('s3')
        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=FILE_NAME,
            Body=json.dumps(output_data, indent=4),
            ContentType='application/json'
        )
        print("Upload successful.")
    except Exception as e:
        print(f"S3 Upload failed: {e}")
        sys.exit(1)

    # D. Download via CloudFront and Verify
    print(f"Step D: Verifying data via CloudFront: {CF_URL}")
    try:
        # Using a small timeout; CloudFront with OAC is usually very fast after upload
        cf_response = requests.get(CF_URL, timeout=15)
        cf_response.raise_for_status()
        final_data = cf_response.json()
        
        if "products" in final_data:
            print("--- SUCCESS ---")
            print(f"Verified: Found {len(final_data['products'])} products via CloudFront.")
        else:
            print("--- FAILURE ---")
            print("Downloaded file does not contain expected 'products' node.")
            sys.exit(1)
            
    except Exception as e:
        print(f"CloudFront verification failed: {e}")
        print("Tip: If this is a brand new distribution, DNS might still be propagating.")
        sys.exit(1)

if __name__ == "__main__":
    # Logic to capture the domain from GitHub Action argument
    # Usage: python processor.py d23ctcxd26c3t3.cloudfront.net
    if len(sys.argv) > 1:
        target_domain = sys.argv[1].replace("https://", "").replace("/", "")
    else:
        # Fallback for local testing - replace with your latest known good domain
        target_domain = "d23ctcxd26c3t3.cloudfront.net"
    
    process_and_verify(target_domain)