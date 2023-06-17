resource "aws_cloudwatch_event_rule" "this" {
  name                = var.name
  schedule_expression = var.schedule_expression
  event_bus_name      = var.event_bus_name
  event_pattern       = var.event_pattern
  description         = var.description
  is_enabled          = var.enabled
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = var.lambda_function_arn
}
