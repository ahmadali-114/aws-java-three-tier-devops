variable "aws_region" {
  description = "AWS Region where the development environment is deployed."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the development VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets."
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for the two private database subnets."
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}
