# Application Tier Design

## First development instance

The first release uses one `t3.micro` Amazon Linux 2023 EC2 instance. It is placed in a public subnet only because this lab intentionally avoids a NAT Gateway. Its application security group allows **no public inbound traffic**; only the future ALB will reach Tomcat on TCP 8080.

The instance has a public IP solely for outbound package installation and GitHub source retrieval. It is not an administrative access path. There is no SSH security-group rule and no EC2 key pair.

## Administration

The instance role receives `AmazonSSMManagedInstanceCore`. Administration will use AWS Systems Manager Session Manager rather than SSH.

## Credentials

At first boot, the instance role reads the RDS-managed master secret only to initialize the schema and create a dedicated MySQL `javaapp` user. The bootstrap script generates that user's password on the instance and writes it directly to a separate Secrets Manager secret.

Terraform creates the empty application secret but never sees its value. The application user has only `SELECT`, `INSERT`, `UPDATE`, and `DELETE` privileges on the `javaapp` database. It does not use the RDS master credential at runtime.

## Deployment flow

```text
EC2 starts
  -> install Java 17, Tomcat, Git, and the MySQL client
  -> clone the public GitHub repository at main
  -> read RDS master credentials through the instance role
  -> create the schema and least-privilege application database user
  -> store app credentials in Secrets Manager
  -> build the WAR with Maven Wrapper
  -> configure Tomcat environment variables
  -> deploy ROOT.war and start Tomcat
```

## Trade-off for the learning environment

The application instance is in a public subnet for outbound HTTPS access. The production upgrade will move application instances to private subnets behind a NAT Gateway or use private VPC endpoints and a pre-built AMI/image.
