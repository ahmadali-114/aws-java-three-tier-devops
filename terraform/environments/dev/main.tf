data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  name = "java-3tier-${var.environment}"

  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source = "../../modules/vpc"

  name                  = local.name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  availability_zones    = local.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  tags = {
    Owner = "Ahmad Ali"
  }
}

module "security" {
  source = "../../modules/security"

  name        = local.name
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  tags = {
    Owner = "Ahmad Ali"
  }
}

module "rds" {
  source = "../../modules/rds"

  name              = local.name
  environment       = var.environment
  subnet_ids        = module.vpc.database_subnet_ids
  security_group_id = module.security.database_security_group_id
  tags = {
    Owner = "Ahmad Ali"
  }
}

module "application" {
  source = "../../modules/application"

  name                  = local.name
  environment           = var.environment
  ami_id                = data.aws_ssm_parameter.amazon_linux_2023.value
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_id     = module.security.application_security_group_id
  rds_master_secret_arn = module.rds.master_user_secret_arn
  rds_endpoint          = module.rds.address
  rds_port              = module.rds.port
  repository_url        = "https://github.com/ahmadali-114/aws-java-three-tier-devops.git"
  repository_revision   = "81a460676442e75b78dbfcd16da5af3028aa335d"
  tags = {
    Owner = "Ahmad Ali"
  }
}
