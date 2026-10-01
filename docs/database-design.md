# Database Design

## Service

The development environment uses Amazon RDS for MySQL. RDS operates the database host, storage, backups, and underlying operating-system patching so the project can focus on application and DevOps operations.

The project pins the engine to MySQL `8.4.9`, the default version returned by AWS for `ap-south-1` when this environment was prepared. Pinning the version makes Terraform plans reproducible; version upgrades will be deliberate changes rather than AWS defaults.

## Network placement

The database instance uses the existing private database subnets in two Availability Zones. `publicly_accessible = false` prevents RDS from receiving a public IP address.

Only the database security group is attached. Its only inbound rule is TCP 3306 from the application security group.

## Credentials

`manage_master_user_password = true` tells RDS to generate and store the master password in AWS Secrets Manager. No database password is written to Terraform code, `terraform.tfvars`, GitHub, or Terraform state.

The master username is `appadmin`. It is not a secret. The Java application will later use a separate, least-privilege database user instead of the master user.

## Development sizing and lifecycle

- Instance class: `db.t3.micro`
- Storage: 20 GiB encrypted `gp3`; automatic growth is capped at 25 GiB
- Multi-AZ: disabled for this first, cost-conscious lab release
- Backups: one-day retention
- Deletion protection: disabled so the lab can be removed with Terraform
- Final snapshot: skipped only for this disposable learning environment

## Cost warning

RDS can create costs. Review the Terraform plan before applying it. Remove the environment with `terraform destroy` when the lab is not actively needed.
