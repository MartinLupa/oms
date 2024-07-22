provider "aws" {
  access_key = var.use_localstack ? "test" : var.aws_access_key
  secret_key = var.use_localstack ? "test" : var.aws_secret_key
  region     = "eu-central-1"

  # only required for non virtual hosted-style endpoint use case.
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#s3_use_path_style
  s3_use_path_style           = var.use_localstack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  endpoints {
    iam         = var.use_localstack ? "http://iam.localhost.localstack.cloud:4566" : null
    s3          = var.use_localstack ? "http://s3.localhost.localstack.cloud:4566" : null
    sqs         = var.use_localstack ? "http://sqs.localhost.localstack.cloud:4566" : null
    lambda      = var.use_localstack ? "http://lambda.localhost.localstack.cloud:4566" : null
    eventbridge = var.use_localstack ? "http://eventbridge.localhost.localstack.cloud:4566" : null
    dynamodb    = var.use_localstack ? "http://dynamodb.localhost.localstack.cloud:4566" : null
    apigateway  = var.use_localstack ? "http://apigateway.localhost.localstack.cloud:4566" : null
    logs        = var.use_localstack ? "http://logs.localhost.localstack.cloud:4566" : null
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  required_version = ">= 0.12"
}
