locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_security_group" "alb" {
  name_prefix            = "${var.name}-alb-"
  description            = "Allows public HTTP traffic to the application load balancer."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-alb-sg"
    Tier = "load-balancer"
  })
}

resource "aws_security_group" "application" {
  name_prefix            = "${var.name}-app-"
  description            = "Allows Java application traffic only from the load balancer."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-app-sg"
    Tier = "application"
  })
}

resource "aws_security_group" "database" {
  name_prefix            = "${var.name}-db-"
  description            = "Allows MySQL traffic only from the Java application tier."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-db-sg"
    Tier = "database"
  })
}

# Internet users can reach only the public ALB over HTTP in this first release.
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Public HTTP access to the application load balancer."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# The ALB forwards requests to Tomcat; the application is not open to the internet.
resource "aws_vpc_security_group_ingress_rule" "application_from_alb" {
  security_group_id            = aws_security_group.application.id
  description                  = "Tomcat traffic from the application load balancer only."
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

# RDS will accept traffic exclusively from application instances.
resource "aws_vpc_security_group_ingress_rule" "database_from_application" {
  security_group_id            = aws_security_group.database.id
  description                  = "MySQL traffic from the Java application tier only."
  referenced_security_group_id = aws_security_group.application.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "alb_to_application" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward requests from the ALB to Tomcat."
  referenced_security_group_id = aws_security_group.application.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

# The first app instance is in a public subnet to avoid NAT Gateway cost. It needs
# outbound HTTPS for package installation and AWS API access during bootstrap.
resource "aws_vpc_security_group_egress_rule" "application_https" {
  security_group_id = aws_security_group.application.id
  description       = "HTTPS for operating-system packages and AWS service APIs."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "application_to_database" {
  security_group_id            = aws_security_group.application.id
  description                  = "MySQL access to the private database tier."
  referenced_security_group_id = aws_security_group.database.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}
