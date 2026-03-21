variable "s3_bucket_domain" {
  description = "The regional domain name of the S3 bucket"
  type        = string 
}

variable "owner" { type = string }
variable "project_name" { type = string }
variable "terraform" { type = string }

variable "tags" {
  type = map(string)
  description = "Unique tags for the resource"
}