resource "aws_cloudwatch_event_bus" "default" {
  name = "oms-event-bus"
}

resource "aws_cloudwatch_event_rule" "order_received_rule" {
  name           = "order-received"
  description    = "Event rule for received order events"
  event_bus_name = aws_cloudwatch_event_bus.default.name
  event_pattern = jsonencode({
    "source"      = ["com.mycompany.oms"]
    "detail-type" = ["order-created"]
  })
}

resource "aws_cloudwatch_event_target" "order_received_target" {
  rule      = aws_cloudwatch_event_rule.order_received_rule.name
  target_id = "orderQueueTarget"
  arn       = data.terraform_remote_state.order_processing.outputs.order_queue_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.order_processing.outputs.process_order_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.order_received_rule.arn
}

output "event_rule_arn" {
  value = aws_cloudwatch_event_rule.order_received_rule.arn
}
