remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }



  config = {
    bucket         = "regev-osher-terraform-state-playground2"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
    
    s3_bucket_tags = {
      Owner     = "Regev Osher"
      Terraform = "True"
      Name      = "TerraformStateBucket"
    }

    skip_bucket_ssencryption           = true
    skip_bucket_public_access_blocking  = true
    skip_bucket_root_access            = true
  }
}