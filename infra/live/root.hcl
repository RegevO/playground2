locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

# Inject the common variables into every child module automatically
inputs = local.common_vars

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket         = "regev-osher-terraform-state-playground2"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
    
    s3_bucket_tags = {
      Owner     = local.common_vars.owner
      Project   = local.common_vars.project_name
      Name      = "TerraformStateBucket"
      Terraform = "true"
    }

    skip_bucket_ssencryption           = true
    skip_bucket_public_access_blocking  = true
    skip_bucket_root_access             = true
  }
}

# keep providers consistent across all modules
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}