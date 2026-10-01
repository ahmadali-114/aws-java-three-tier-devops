# Architecture Decision: Direct AWS Deployment

## Context

The project is intended to improve practical AWS and DevOps skills. The application will be deployed directly to AWS instead of being run locally first.

## Decision

Use Terraform to provision a development environment in `ap-south-1` with an Application Load Balancer, an EC2 Java application tier, and an Amazon RDS MySQL database tier.

## Initial request flow

```text
Internet
  |
Application Load Balancer
  |
EC2: Java 11 + Tomcat + Java Login Application
  |
Amazon RDS MySQL
```

## Network and security boundaries

- The ALB is internet-facing and deployed to two public subnets.
- The EC2 application instance receives application traffic only from the ALB security group.
- RDS uses private database subnets and accepts port 3306 only from the application security group.
- Administration uses AWS Systems Manager; inbound SSH is not required.
- AWS Secrets Manager stores database credentials.

## Cost-conscious first release

The first release will use one application instance and single-AZ RDS. It intentionally excludes NAT Gateways, Multi-AZ RDS, multiple application instances, a custom domain, and HTTPS. These production features are planned only after the initial deployment is verified.

## Success criteria

- Terraform can create the development infrastructure reproducibly.
- The application is reachable through the ALB DNS name.
- The application can connect to the private RDS database.
- No secrets or Terraform state are committed to GitHub.
- Logs and one actionable alarm are available in CloudWatch.
- The environment can be removed through a documented `terraform destroy` process.
