variable "name" {
  description = "Name prefix used for RDS resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID that permits MySQL only from the application tier."
  type        = string
}

variable "database_name" {
  description = "Name of the initial MySQL database."
  type        = string
  default     = "javaapp"
}

variable "master_username" {
  description = "Non-secret administrator username for the RDS instance."
  type        = string
  default     = "appadmin"
}

variable "tags" {
  description = "Additional tags applied to RDS resources."
  type        = map(string)
  default     = {}
}
