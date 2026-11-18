terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "IdeaBoard"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  name_prefix = "ideaboard-${var.environment}"
}

module "networking" {
  source = "../../modules/networking"

  name_prefix          = local.name_prefix
  region               = var.region
  environment          = var.environment
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
}

module "kubernetes" {
  source = "../../modules/kubernetes"

  name_prefix        = local.name_prefix
  environment        = var.environment
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.networking.vpc_id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = module.networking.private_subnet_ids
  node_instance_type = var.node_instance_type
  node_min_count     = var.node_min_count
  node_count         = var.node_count
  node_max_count     = var.node_max_count
}

module "database" {
  source = "../../modules/database"

  name_prefix            = local.name_prefix
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  node_security_group_id = module.kubernetes.node_security_group_id
  database_name          = var.db_name
  master_username        = var.db_username
  master_password        = var.db_password
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage_gb   = var.db_allocated_storage
  backup_retention_days  = var.db_backup_retention_period
  deletion_protection    = var.db_deletion_protection
  multi_az               = var.db_multi_az
}
