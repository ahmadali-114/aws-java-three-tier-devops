# Development lab cleanup runbook

## Purpose

Use this runbook to control AWS cost while preserving a clear Terraform state. The environment contains billable resources, including the ALB, EC2, RDS storage, and data transfer.

## Short pause

For a short break, stop the EC2 instance and the RDS instance from the AWS Console. This reduces compute charges, but it does **not** eliminate charges for RDS storage, backups, or the Application Load Balancer.

Before resuming, start RDS first and wait until it is `Available`, then start or replace EC2 as needed.

## Full cleanup

Run this only when you accept deleting the lab infrastructure and its database data. Export any data you need first.

```powershell
cd C:\DevOps-Projects\aws-java-three-tier-devops\terraform\environments\dev
terraform plan -destroy
terraform destroy
```

Review the destroy plan carefully. This development configuration uses `skip_final_snapshot = true`; the RDS database can be permanently removed without a final snapshot.

## After cleanup

- Confirm the ALB, EC2 instance, RDS database, and related security groups are absent in the AWS Console.
- Keep `.tfstate` files private and never commit them.
- Review the AWS Billing console after cleanup because final charges can appear later.

## Recovery

To create a new lab environment, run `terraform init`, `terraform plan`, and `terraform apply` from the development environment directory. A fresh RDS database and new application credentials will be created.
