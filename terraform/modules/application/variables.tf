variable "name" {
  description = "Name prefix used for application-tier resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID for the EC2 instance."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID used by the first cost-conscious application instance."
  type        = string
}

variable "security_group_id" {
  description = "Application security group ID."
  type        = string
}

variable "rds_master_secret_arn" {
  description = "ARN of the RDS-managed master credential secret."
  type        = string
}

variable "rds_endpoint" {
  description = "Private RDS endpoint used to build the application JDBC URL."
  type        = string
}

variable "rds_port" {
  description = "MySQL listener port."
  type        = number
}

variable "repository_url" {
  description = "Public GitHub repository URL containing the application source."
  type        = string
}

variable "repository_branch" {
  description = "Git branch deployed by the first EC2 instance."
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Additional tags applied to application-tier resources."
  type        = map(string)
  default     = {}
}
