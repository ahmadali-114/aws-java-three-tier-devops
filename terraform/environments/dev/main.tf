data "aws_availability_zones" "available" {
  state = "available"
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
