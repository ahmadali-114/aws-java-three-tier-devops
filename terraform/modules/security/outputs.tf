output "alb_security_group_id" {
  description = "Security group ID for the public application load balancer."
  value       = aws_security_group.alb.id
}

output "application_security_group_id" {
  description = "Security group ID for Java application instances."
  value       = aws_security_group.application.id
}

output "database_security_group_id" {
  description = "Security group ID for the RDS MySQL database."
  value       = aws_security_group.database.id
}
