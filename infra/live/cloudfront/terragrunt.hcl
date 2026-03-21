include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/cloudfront"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    bucket_regional_domain_name = "mock.s3.us-east-1.amazonaws.com"
  }
}

inputs = {
  s3_bucket_domain = dependency.s3.outputs.bucket_regional_domain_name
  
  tags = {
    Owner     = "Regev Osher"
    Terraform = "True"
    Name      = "ProductCloudFront"
  }
}