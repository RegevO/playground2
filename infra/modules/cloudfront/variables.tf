variable "s3_bucket_domain" {
  description = "The regional domain name of the S3 bucket"
  type        = string 
}

variable "tags" {
  description = "Tags to apply to the distribution"
  type        = map(string)
  default     = {}
}