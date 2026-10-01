# AWS Java Three-Tier DevOps Project

A production-style Java web application deployment on AWS, provisioned through Terraform.

## Project Goal

Deploy a Java login application using a secure three-tier AWS architecture:

User -> Application Load Balancer -> Java/Tomcat EC2 -> Amazon RDS MySQL

## Target Region

ap-south-1

## Development Environment Architecture

- One VPC
- Two public subnets across two Availability Zones
- Application Load Balancer
- One EC2 application server for the first deployment
- Java 11 and Apache Tomcat installed through EC2 user data
- Amazon RDS MySQL in private database subnets
- AWS Secrets Manager for database credentials
- AWS Systems Manager for secure instance access
- CloudWatch logs and alarms
- Terraform for reproducible infrastructure

## Security Principles

- No AWS root access keys
- No passwords, Terraform state, or private keys committed to GitHub
- EC2 accepts application traffic only from the ALB
- RDS accepts MySQL traffic only from the application security group
- No public SSH access
- All AWS resources use project and environment tags

## Current Status

- [x] GitHub repository created
- [x] Git repository initialized with secure .gitignore
- [x] AWS CLI and Terraform installed
- [x] AWS budget and IAM deployment user configured
- [ ] Terraform infrastructure created
- [ ] Java application deployed
- [ ] ALB endpoint validated
- [ ] Monitoring and cleanup runbook completed

## Cost Control

This is a learning environment. Resources will be sized for development and removed with `terraform destroy` after testing.
