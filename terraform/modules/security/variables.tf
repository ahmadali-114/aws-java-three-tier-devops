variable "name" {
  description = "Name prefix used for security groups."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that contains the security groups."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to security groups."
  type        = map(string)
  default     = {}
}
