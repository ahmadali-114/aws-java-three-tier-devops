variable "name" {
  description = "Name prefix used by load-balancer resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the application target."
  type        = string
}

variable "subnet_ids" {
  description = "Two public subnet IDs in separate Availability Zones for the ALB."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group permitting public HTTP traffic to the ALB."
  type        = string
}

variable "target_instance_id" {
  description = "EC2 application instance registered as the HTTP target."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to load-balancer resources."
  type        = map(string)
  default     = {}
}
