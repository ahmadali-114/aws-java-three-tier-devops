# Terraform Infrastructure

This directory contains this project's Terraform implementation. The copied `infrastructure/` directory at the repository root is reference material and is intentionally not used by this configuration.

## Layout

```text
terraform/
├── modules/vpc/       # Reusable VPC, subnets, and public routing
└── environments/dev/  # Development environment entry point
```

## State

The initial VPC deployment uses local Terraform state. State files are ignored by Git. Before adding shared or production infrastructure, this project will create an encrypted S3 remote-state backend with locking.

## Safety

Run `terraform plan` and review its output before every `terraform apply`. Do not add secrets to `.tf` or `.tfvars` files.
