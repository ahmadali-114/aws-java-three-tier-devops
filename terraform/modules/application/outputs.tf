output "instance_id" {
  description = "ID of the EC2 application instance."
  value       = aws_instance.application.id
}

output "application_database_secret_arn" {
  description = "ARN of the runtime-generated application database credential secret."
  value       = aws_secretsmanager_secret.application_database.arn
}
