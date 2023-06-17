variable "company_identifier" {
  type        = string
  description = "Used to prefix resource names when they're global."
  default     = "jsherz-com"
}

variable "ref" {
  type        = string
  description = "Git branch name, e.g. 'main'."
  default     = "main"
}

variable "prefix" {
  type        = string
  description = "Used to form resource names."
  default     = "right-size-lambdas"
}
