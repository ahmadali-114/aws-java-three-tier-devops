output "dns_name" {
  description = "Public DNS name of the application load balancer."
  value       = aws_lb.this.dns_name
}

output "arn" {
  description = "ARN of the application load balancer."
  value       = aws_lb.this.arn
}

output "target_group_arn" {
  description = "ARN of the Tomcat target group."
  value       = aws_lb_target_group.application.arn
}
