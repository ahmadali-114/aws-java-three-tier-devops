# Deployment and validation guide

This guide describes the development-lab workflow. It does not authorize a production deployment.

## Prerequisites

- AWS CLI authenticated to the intended account and `ap-south-1` region.
- Terraform installed.
- Git installed.
- Java 17 and Maven installed if building on the workstation.

## Validate the source

From the repository root:

```powershell
cd C:\DevOps-Projects\aws-java-three-tier-devops\Java-Login-App
mvn clean test
mvn clean package -DskipTests
```

The expected artifact is `target/dptweb-1.0.war`.

## Release an application change

1. Commit and push the tested application code.
2. Copy the commit hash with `git log -1 --format="%H"`.
3. Set that value as `repository_revision` in `terraform/environments/dev/main.tf`.
4. Commit and push the Terraform release-pointer change.

This makes the EC2 deployment reproducible: the instance checks out the exact pinned commit before building the WAR.

## Plan and apply Terraform

```powershell
cd C:\DevOps-Projects\aws-java-three-tier-devops\terraform\environments\dev
terraform fmt -check -recursive ..\..
terraform init
terraform validate
terraform plan
```

Read the plan. Application release changes replace the EC2 instance because `user_data_replace_on_change` is enabled. Confirm that no unexpected VPC, RDS, or ALB resources will be replaced before running `terraform apply`.

## Validate the deployed application

Use AWS Systems Manager Session Manager to access the EC2 instance. Do not add public SSH access for this lab.

```bash
sudo cloud-init status --wait
sudo systemctl is-active tomcat9
sudo git -C /opt/java-3tier rev-parse HEAD
curl -s -o /dev/null -w "ROOT_HTTP_STATUS=%{http_code}\n" http://localhost:8080/
curl -s -o /dev/null -w "LOGIN_HTTP_STATUS=%{http_code}\n" http://localhost:8080/login
curl -s -o /dev/null -w "REGISTER_HTTP_STATUS=%{http_code}\n" http://localhost:8080/register
```

Expected values are `done`, `active`, the pinned release commit, and HTTP `200` for the three routes. Then open the ALB DNS name and confirm that the target group is `healthy`.

## Troubleshooting principles

- Use `journalctl -u tomcat9 --no-pager` for Tomcat logs.
- Use `/var/log/cloud-init-output.log` when cloud-init fails.
- Confirm the deployed Git revision before debugging source code.
- Never place secrets in terminal screenshots, Git commits, logs, Terraform variables, or documentation.
