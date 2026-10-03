locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Terraform creates the secret container only. The EC2 bootstrap script generates
# its value, keeping the application password out of Terraform state.
resource "aws_secretsmanager_secret" "application_database" {
  name                    = "${var.name}/application-db-credentials"
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    Name = "${var.name}-application-db-credentials"
  })
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "${var.name}-application-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json

  tags = merge(local.common_tags, {
    Name = "${var.name}-application-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "application_secrets" {
  statement {
    sid       = "ReadRdsMasterSecretForInitialization"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [var.rds_master_secret_arn]
  }

  statement {
    sid       = "ManageApplicationDatabaseSecret"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "secretsmanager:PutSecretValue"]
    resources = [aws_secretsmanager_secret.application_database.arn]
  }
}

resource "aws_iam_role_policy" "application_secrets" {
  name   = "${var.name}-application-secrets"
  role   = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.application_secrets.json
}

resource "aws_iam_instance_profile" "application" {
  name = "${var.name}-application-profile"
  role = aws_iam_role.instance.name
}

resource "aws_instance" "application" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.application.name
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    application_secret_arn = aws_secretsmanager_secret.application_database.arn
    aws_region             = split(":", var.rds_master_secret_arn)[3]
    rds_master_secret_arn  = var.rds_master_secret_arn
    rds_endpoint           = var.rds_endpoint
    rds_port               = var.rds_port
    repository_branch      = var.repository_branch
    repository_revision    = var.repository_revision
    repository_url         = var.repository_url
  })

  tags = merge(local.common_tags, {
    Name = "${var.name}-application"
    Tier = "application"
  })
}
