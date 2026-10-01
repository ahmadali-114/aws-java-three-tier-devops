# Security Model

This document defines the firewall rules for the development deployment. AWS security groups are stateful firewalls: return traffic for an allowed connection is automatically permitted.

## Allowed traffic

| Source | Destination | Port | Reason |
|---|---|---:|---|
| Internet | Application Load Balancer | TCP 80 | Users access the web application. |
| Application Load Balancer | Java application | TCP 8080 | ALB forwards requests to Tomcat. |
| Java application | RDS MySQL | TCP 3306 | Application reads and writes data. |
| Application Load Balancer | Java application | TCP 8080 | ALB forwards traffic to healthy targets. |
| Java application | Internet | TCP 443 | First-release package installation and AWS service APIs. |

## Denied by design

- No inbound SSH (TCP 22).
- No public inbound access to application instances.
- No public inbound access to the database.
- No database access from the ALB or the internet.
- No database egress rule; RDS does not need to initiate outbound connections for this project.

## Administration

The later EC2 instance will use an IAM role and AWS Systems Manager Session Manager for administration. This avoids a public SSH port and `.pem` key management.
