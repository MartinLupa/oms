module "aws_provider" {
  source         = "../../../../shared-modules"
  use_localstack = var.use_localstack
}

terraform {
  backend "s3" {
    bucket         = "order-processing-state"
    key            = "order-processing/infra/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "order-processing-state-lock"
  }
}
