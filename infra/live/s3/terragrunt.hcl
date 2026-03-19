include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/s3"
}

# Comment out the dependency for the first run to break the cycle
# dependency "cloudfront" {
#   config_path = "../cloudfront"
# }

inputs = {
  bucket_name    = "regev-osher-products-bucket"
  cloudfront_arn = null 
  
  # Ensure these are passed to the 'tags' variable in your module
  tags = {
    Owner     = "Regev Osher"
    Terraform = "True"
    Name      = "ProductS3Bucket"
  }
}