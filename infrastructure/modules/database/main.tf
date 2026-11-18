terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  common_tags = {
    Project     = "IdeaBoard"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-postgres"
  description = "PostgreSQL ingress from IdeaBoard EKS worker nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from the EKS worker security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-postgres"
  })
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.name_prefix}-postgres"
  description = "Private subnets for IdeaBoard RDS"
  subnet_ids  = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-postgres"
  })
}

resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.master_username

  password_wo         = var.master_password
  password_wo_version = var.master_password_version

  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.allocated_storage_gb * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  port                   = 5432
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period    = var.backup_retention_days
  auto_minor_version_upgrade = true
  deletion_protection        = var.deletion_protection
  copy_tags_to_snapshot      = true
  skip_final_snapshot        = false
  final_snapshot_identifier  = "${var.name_prefix}-final"

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-postgres"
  })
}
