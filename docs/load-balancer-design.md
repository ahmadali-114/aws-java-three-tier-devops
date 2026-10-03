# Public Application Load Balancer Design

The Application Load Balancer (ALB) is the public entry point for the Java web application. It spans both public subnets in separate Availability Zones, listens on HTTP port 80, and forwards traffic only to the application target group on port 8080.

## Traffic path

```text
Internet → ALB :80 → target group → Tomcat EC2 :8080 → RDS MySQL :3306
```

The ALB security group accepts public HTTP only. Its outbound rule permits TCP 8080 only to the application security group. The application security group accepts TCP 8080 only from the ALB security group, so the EC2 instance cannot be reached directly from the internet even though it is temporarily placed in a public subnet for this cost-conscious lab.

## Health checks

The ALB calls `GET /` on port 8080 every 30 seconds. Two successful HTTP 200 checks mark the target healthy; two failures mark it unhealthy. The root route is deliberately public and returns HTTP 200, making it suitable as a basic availability health check.

## Learning-environment trade-offs

The ALB is internet-facing and uses HTTP only. A production deployment would add an ACM certificate, HTTPS listener, HTTP-to-HTTPS redirect, access logs, WAF protections, private application subnets, at least two application instances, and Auto Scaling. An ALB has an hourly and LCU-based charge, so it should be removed when the lab is not being used.
