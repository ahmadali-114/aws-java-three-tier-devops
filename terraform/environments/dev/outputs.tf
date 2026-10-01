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
