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
- Java 17 and Apache Tomcat installed through EC2 user data
- Amazon RDS MySQL in private database subnets
- AWS Secrets Manager for database credentials
- AWS Systems Manager for secure instance access
- Cloud-init and Tomcat journal logs for deployment troubleshooting
- Terraform for reproducible infrastructure

## Security Principles

- No AWS root access keys
- No passwords, Terraform state, or private keys committed to GitHub
- EC2 accepts application traffic only from the ALB
- RDS accepts MySQL traffic only from the application security group
- No public SSH access
- All AWS resources use project and environment tags

## Architecture flow

```text
User Browser -> Application Load Balancer -> EC2 Java/Tomcat Application -> Amazon RDS MySQL
```

Terraform provisions the VPC, security groups, RDS, EC2 application tier, IAM/Systems Manager access, Secrets Manager integration, and the load balancer. EC2 checks out a pinned Git commit, builds the Maven WAR, and deploys it to Tomcat.

## Documentation

- [Application tier design](docs/application-tier-design.md)
- [Database design](docs/database-design.md)
- [Load balancer design](docs/load-balancer-design.md)
- [Security model](docs/security-model.md)
- [Deployment and validation guide](docs/deployment-guide.md)
- [Development lab cleanup runbook](docs/cleanup-runbook.md)

## Current Status

- [x] GitHub repository created
- [x] Git repository initialized with secure .gitignore
- [x] AWS CLI and Terraform installed
- [x] AWS budget and IAM deployment user configured
- [x] VPC, least-privilege security groups, and private RDS created
- [x] Java application deployed and verified through Systems Manager
- [x] ALB endpoint and healthy target validated
- [x] Deployment and cleanup runbooks documented
- [ ] Latest MySQL JDBC-driver fix cleanly built and promoted through Terraform
- [ ] HTTPS/ACM, CloudWatch alarms, remote Terraform state, and tested restore procedure added before production use

## Cost Control

This is a learning environment. Resources are sized for development. The Application Load Balancer and running compute incur charges, so stop or destroy the environment after each lab session according to the cleanup runbook.
