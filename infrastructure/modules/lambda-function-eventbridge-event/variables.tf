resource "null_resource" "validate_variables" {
  lifecycle {
    precondition {
      condition     = var.event_pattern == null || var.schedule_expression == null
      error_message = "You can set only one of event_pattern or schedule_expression - not both."
    }
  }
}

variable "name" {
  type        = string
  description = "Name of the EventBridge rule."
}

variable "schedule_expression" {
  type        = string
  description = "CRON-like schedule to trigger the Lambda function on."
  default     = null
}

variable "event_bus_name" {
  type        = string
  description = "Event bus to listen to events on."
  default     = null
}

variable "event_pattern" {
  type        = string
  description = "Match events based on this JSON pattern."
  default     = null
}

variable "description" {
  type        = string
  description = "A friendly description of this event rule."
}

variable "enabled" {
  type        = bool
  description = "Enable this event rule?"
  default     = true
}

variable "lambda_function_arn" {
  type        = string
  description = "Lambda function to trigger."
}
