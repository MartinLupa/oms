variable "use_localstack" {
  description = "Use LocalStack or AWS"
  type        = bool
  default     = true
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  default     = ""
}

