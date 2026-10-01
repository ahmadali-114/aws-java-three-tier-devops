output "address" {
  description = "Private DNS address of the MySQL instance."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "MySQL listener port."
  value       = aws_db_instance.this.port
}

output "master_user_secret_arn" {
  description = "ARN of the AWS-managed Secrets Manager secret for the master password."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
