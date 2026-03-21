resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  force_destroy = true

  tags = var.tags
}



variable "cloudfront_distribution_arn" {
  type        = string
  description = "The ARN of the CloudFront distribution allowed to access this bucket"
  default     = ""
}
