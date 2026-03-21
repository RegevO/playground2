# 🚀 AWS Product Data Pipeline (Playground2)

This project demonstrates a fully automated, **One-Click** Infrastructure-as-Code (IaC) pipeline. It provisions a secure static content delivery network on AWS and populates it using a filtered data processor.

## 🏗️ Architecture Overview

The infrastructure consists of three main components orchestrated by **Terragrunt** and **Terraform**:

1.  **Storage (S3):** A private bucket (`regev-osher-products-bucket`) acts as the origin for the data.
2.  **CDN (CloudFront):** A global distribution that caches and serves the JSON data to users with low latency.
3.  **Security (OAC):** **Origin Access Control (OAC)** ensures the S3 bucket is *not* public. S3 only accepts traffic if it originates from the specific CloudFront Distribution ARN.



---

## 🔐 Security & Governance

* **Identity & Access Management (IAM):** A dynamic Bucket Policy is generated during deployment. It grants `s3:GetObject` permissions specifically to the CloudFront Service Principal, restricted by the `SourceArn` of the distribution.
* **Force Destroy:** The S3 bucket is configured with `force_destroy = true`, allowing for seamless automated teardown even when the bucket contains data.
* **Provider Tagging:** All resources are automatically tagged with `Owner: Regev Osher` and `Terraform: True` for cost tracking and resource management.

---

## 🔄 The "Dynamic Handshake" (Variable Transfer)

One of the key features of this pipeline is the **Dynamic Validation** between the Infrastructure and the Application layers:

1.  **Infra Layer:** Terragrunt provisions the CloudFront distribution and exports the generated `domain_name` as an output.
2.  **Orchestration Layer (GitHub Actions):** * Captures the `domain_name` using `terragrunt output -raw`.
    * Injects this domain as a command-line argument into the Python processor.
3.  **App Layer (Python):** * Downloads raw data from `dummyjson.com`.
    * Filters products (Price ≥ 100).
    * Uploads to S3.
    * **Verification:** Uses the injected domain to perform an end-to-end HTTPS check to ensure the data is live and reachable via the CDN.

---

## 💰 Cost Estimation (FinOps)

Based on current AWS pricing (us-east-1), this stack is highly cost-optimized for low-to-medium traffic:

| Service | Component | Estimated Monthly Cost (Free Tier) | Estimated Monthly Cost (Paid) |
| :--- | :--- | :--- | :--- |
| **S3** | 1GB Storage / 10k Requests | $0.00 | ~$0.05 |
| **CloudFront** | 10GB Data Transfer | $0.00 | ~$1.00 |
| **Data Transfer** | S3 to CloudFront | $0.00 (Free) | $0.00 (Free) |
| **Total** | | **$0.00** | **~$1.05** |

*Note: By using OAC and keeping data transfer within the AWS backbone, we eliminate egress costs between S3 and CloudFront.*

---

## 📊 DORA Metrics Alignment

This pipeline is designed to optimize the four key DORA metrics:

* **Deployment Frequency:** High. Fully automated "One-Click" deployment via GitHub Actions allows for multiple deployments per day.
* **Lead Time for Changes:** Low. Total time from code push to "Verified Live" is ~4-5 minutes (primarily CloudFront propagation).
* **Change Failure Rate:** Reduced. Infrastructure is validated via `terragrunt plan` and application logic is verified by the `processor.py` post-deployment check.
* **Failed Service Recovery (MTTR):** Fast. The "One-Click Destroy" and "Apply" workflow allows for a complete environment recreation in under 5 minutes in case of corruption.

---

## 🛠️ How to Use

### One-Click Deploy (GitHub Actions)
1.  Navigate to the **Actions** tab in GitHub.
2.  Select the **Infrastructure Lifecycle** workflow.
3.  Click **Run workflow** -> Select **apply**.
4.  Once finished, the output will provide the CloudFront URL.

### Local Development
To provision the entire stack locally with a single command:
```powershell
# From the infra/live directory
terragrunt run-all apply --terragrunt-non-interactive
```
To run the data processor and verify the deployment:
```powershell
# Pass the CloudFront domain output from the previous step
python ../../app/processor.py <generated-cloudfront-domain>
```

---

## ❓ FAQ (Architectural Decisions)

### Q: Why not just use a single monolithic Terraform file?
**A:** Scalability and Blast Radius. By using Terragrunt with decoupled modules (S3, CloudFront, IAM), we ensure that a failure in the CDN configuration doesn't necessarily require a teardown of the storage layer. It also keeps the code **DRY (Don't Repeat Yourself)**, allowing these modules to be reused across different environments (Dev, Staging, Prod) with simple input changes.

### Q: Why not use AWS Lambda for the JSON processing?
**A:** While Lambda is a valid choice for event-driven processing, this project uses a **Container/CLI-first approach**. This allows the processing logic to be completely platform-agnostic. By running the Python script within a GitHub Action runner, we avoid the overhead of managing Lambda layers, timeouts, and specific IAM execution roles, keeping the deployment "Zero-Infrastructure" until the final artifacts are ready for S3.

### Q: Why use Origin Access Control (OAC) instead of a Public S3 Bucket?
**A:** Security Best Practices. Making an S3 bucket public is a common source of data leaks. **OAC** ensures that the data is *only* accessible via the CloudFront CDN. This allows us to enforce HTTPS, utilize AWS Shield for DDoS protection, and cache content globally without exposing the "origin" bucket to the open internet.

### Q: How is "Dynamic Validation" achieved?
**A:** The pipeline uses a "Handshake" pattern. Instead of hardcoding a CloudFront URL (which changes if the distribution is recreated), the GitHub Action queries the Terraform state in real-time (`terragrunt output`) and passes that value to the Python script. This ensures the "Verification" step always tests the exact infrastructure that was just deployed.

### Q: Is this setup production-ready?
**A:** It is "Architecture-Ready." For a true production environment, we would add a **Web Application Firewall (WAF)** in front of CloudFront, implement **S3 Versioning**, and use a custom Route53 domain with an SSL certificate instead of the default `cloudfront.net` endpoint.

### Q: Why use the latest v0.99.x versions of Terragrunt?
**A:**  Version 0.99.x provides enhanced support for OpenTofu, improved handling of complex dependency graphs in run-all commands, and more robust state locking mechanisms. Using the latest stable release ensures the pipeline benefits from the most recent security patches and performance optimizations in the IaC ecosystem.