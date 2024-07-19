provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "eu-central-1"

  # only required for non virtual hosted-style endpoint use case.
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#s3_use_path_style
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    iam         = "http://iam.localhost.localstack.cloud:4566"
    s3          = "http://s3.localhost.localstack.cloud:4566"
    sqs         = "http://sqs.localhost.localstack.cloud:4566"
    lambda      = "http://lambda.localhost.localstack.cloud:4566"
    eventbridge = "http://eventbridge.localhost.localstack.cloud:4566"
    dynamodb    = "http://dynamodb.localhost.localstack.cloud:4566"
    apigateway  = "http://apigateway.localhost.localstack.cloud:4566"
    logs        = "http://logs.localhost.localstack.cloud:4566"
  }
}

# EventBridge resource docs:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eventbridge_rule
resource "aws_cloudwatch_event_rule" "process_orders" {
  name        = "process-orders"
  description = "Rule to process orders"
  event_pattern = jsonencode({
    "source" : ["my.application"]
  })
}

resource "aws_cloudwatch_event_target" "process_orders_target" {
  rule = aws_cloudwatch_event_rule.process_orders.name
  arn  = aws_sqs_queue.test_queue.arn

  target_id = "process_orders_target"
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.process_orders.arn
}

# SQS resource docs:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
resource "aws_sqs_queue" "test_queue" {
  name = "test-queue"
  # fifo_queue                  = true
  # content_based_deduplication = true
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

# Lambda resource docs:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy"
  description = "IAM policy for Lambda execution"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:*",
          "dynamodb:*",
          "sqs:*",
          "s3:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../src/index.js"
  output_path = "${path.module}/../src/index.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${path.module}/../src/index.zip"
  function_name    = "test-lambda-function"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs20.x"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}

resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.test_queue.arn
  function_name    = aws_lambda_function.test_lambda.arn
  batch_size       = 10
  enabled          = true
}


# DynamoDB resource docs:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "test-table" {
  name           = "Orders"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "OrderId"
  range_key      = "OrderNr"

  attribute {
    name = "OrderNr"
    type = "S"
  }

  attribute {
    name = "CustomerEmail"
    type = "S"
  }

  attribute {
    name = "Total"
    type = "S"
  }

  global_secondary_index {
    name            = "ProductIndex"
    hash_key        = "Product"
    projection_type = "ALL"
    read_capacity   = 10
    write_capacity  = 10
  }

  tags = {
    Name        = "orders-table"
    Environment = "development"
  }
}

