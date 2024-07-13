resource "aws_sqs_queue" "order_queue" {
  name = "order-queue"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "process_order" {
  filename         = "path/to/your/lambda_function.zip"
  function_name    = "process_order"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256("path/to/your/lambda_function.zip")

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.order_queue.url
    }
  }
}

output "order_queue_arn" {
  value = aws_sqs_queue.order_queue.arn
}

output "process_order_lambda_arn" {
  value = aws_lambda_function.process_order.arn
}

output "process_order_lambda_name" {
  value = aws_lambda_function.process_order.function_name
}
