variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string  
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "cloudfront_arn" {
  description = "The ARN of the CloudFront distribution"
  type        = string
  default     = null
}

variable "owner" {
  type = string
}

variable "project_name" {
  type = string
}

variable "terraform" {
  type = string
}