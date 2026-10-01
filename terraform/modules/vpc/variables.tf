variable "name" {
  description = "Name prefix used for VPC resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones are required for the ALB and RDS subnet groups."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDR blocks are required."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)

  validation {
    condition     = length(var.database_subnet_cidrs) == 2
    error_message = "Exactly two database subnet CIDR blocks are required."
  }
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
