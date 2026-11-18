variable "name_prefix" {
  description = "Environment-specific resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment used for resource tags"
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the database"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the RDS subnet group"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "RDS requires private subnets in at least two availability zones."
  }
}

variable "node_security_group_id" {
  description = "EKS worker security group allowed to connect to PostgreSQL"
  type        = string
}

variable "database_name" {
  description = "Initial PostgreSQL database name"
  type        = string
}

variable "master_username" {
  description = "RDS master username"
  type        = string
}

variable "master_password" {
  description = "RDS master password supplied through TF_VAR_db_password"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "master_password_version" {
  description = "Increment when rotating the write-only RDS master password"
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "AWS-supported PostgreSQL engine version"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage_gb" {
  description = "Initial encrypted gp3 storage in GiB"
  type        = number

  validation {
    condition     = var.allocated_storage_gb >= 20
    error_message = "RDS PostgreSQL allocated storage must be at least 20 GiB."
  }
}

variable "backup_retention_days" {
  description = "Automated backup retention in days"
  type        = number

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "RDS backup retention must be between 1 and 35 days."
  }
}

variable "deletion_protection" {
  description = "Prevent accidental RDS deletion"
  type        = bool
}

variable "multi_az" {
  description = "Enable a synchronous standby in another availability zone"
  type        = bool
}
