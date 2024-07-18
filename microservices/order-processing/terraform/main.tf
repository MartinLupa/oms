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
  }
}

# SQS resource docs:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
resource "aws_sqs_queue" "test-queue" {
  name = "test-queue"
}

resource "aws_api_gateway_rest_api" "example" {
  name = "example"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/orders" = {
        post = {
          responses = {
            "200" : {
              description = "200 response"
              content = {
                "application/json" = {
                  schema = {}
                }
              }
            }
          }
          x-amazon-apigateway-integration = {
            httpMethod            = "POST"
            type                  = "AWS_PROXY"
            uri                   = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/${aws_lambda_function.test_lambda.arn}/invocations"
            integrationHttpMethod = "POST"
            responses = {
              "default" : {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Content-Type" = "'application/json'"
                }
                responseTemplates = {
                  "application/json" = ""
                }
              }
            }
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "example"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example.execution_arn}/*/POST/orders"
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
  source_file = "../src/main.js"
  output_path = "../src/main.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../src/main.zip"
  function_name = "test-lambda-function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs20.x"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
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
    name = "OrderId"
    type = "S"
  }

  attribute {
    name = "OrderNr"
    type = "S"
  }

  attribute {
    name = "Product"
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

