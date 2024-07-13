resource "aws_s3_bucket" "order-processing-state" {
  bucket = "order-processing-state"
}

resource "aws_dynamodb_table" "order-processing-state" {
  name         = "order-processing-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
