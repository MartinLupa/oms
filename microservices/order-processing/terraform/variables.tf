variable "use_localstack" {
  description = "Flag to indicate if localstack should be used"
  type        = bool
  default     = false
}

# variable "service_sufix" {
#   description = "Sufix to be added to the service name"
#   type        = string
#   default     = ""
# }

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  default     = ""
}
