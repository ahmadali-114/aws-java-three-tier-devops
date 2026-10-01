output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "database_subnet_ids" {
  description = "IDs of the private database subnets."
  value       = aws_subnet.database[*].id
}
