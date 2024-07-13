resource "aws_s3_bucket" "global-infra-state" {
  bucket = "global-infra-state"
}

resource "aws_dynamodb_table" "global-infra-state" {
  name         = "global-infra-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
