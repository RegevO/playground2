include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/s3-policy"
}

dependency "s3" {
  config_path = "../s3"
}

dependency "cloudfront" {
  config_path = "../cloudfront"
}

inputs = {
  bucket_id                   = dependency.s3.outputs.bucket_id
  bucket_arn                  = dependency.s3.outputs.bucket_arn
  cloudfront_distribution_arn = dependency.cloudfront.outputs.distribution_arn
}