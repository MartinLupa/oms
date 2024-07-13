provider "aws" {
  access_key = var.use_localstack ? "mock_access_key" : var.aws_access_key_id
  secret_key = var.use_localstack ? "mock_secret_key" : var.aws_secret_access_key
  region     = "eu-central-1"

  s3_use_path_style           = true
  skip_credentials_validation = var.use_localstack ? true : false
  skip_metadata_api_check     = var.use_localstack ? true : false
  skip_requesting_account_id  = var.use_localstack ? true : false

  endpoints {
    eventbridge = "http://event-bridge.localhost.localstack.cloud:4566"
    s3          = "http://s3.localhost.localstack.cloud:4566"
    dynamodb    = "http://dynamodb.localhost.localstack.cloud:4566"
  }
}
