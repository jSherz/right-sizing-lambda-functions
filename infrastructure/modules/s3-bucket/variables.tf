variable "name" {
  type        = string
  description = "Bucket name."
}

variable "events_enabled" {
  type        = bool
  default     = false
  description = "Send bucket events to EventBridge?"
}
