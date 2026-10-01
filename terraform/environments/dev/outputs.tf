output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets for the future ALB."
  value       = module.vpc.public_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of private database subnets for the future RDS instance."
  value       = module.vpc.database_subnet_ids
}

output "security_group_ids" {
  description = "Security groups for the load balancer, application, and database tiers."
  value = {
    alb         = module.security.alb_security_group_id
    application = module.security.application_security_group_id
    database    = module.security.database_security_group_id
  }
}
