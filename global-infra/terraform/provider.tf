module "aws_provider" {
  source         = "../../shared-modules"
  use_localstack = var.use_localstack
}

terraform {
  backend "s3" {
    bucket         = "global-infra-state"
    key            = "global-infra/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "global-infra-state"
  }
}


