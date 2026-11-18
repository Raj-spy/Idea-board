variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = var.environment == "production"
    error_message = "The production root must use environment = production."
  }
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version supported in the selected region"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
}

variable "node_min_count" {
  description = "Minimum managed worker count"
  type        = number
  default     = 3
}

variable "node_count" {
  description = "Desired managed worker count"
  type        = number

  validation {
    condition     = var.node_count >= var.node_min_count && var.node_count <= var.node_max_count
    error_message = "node_count must be between node_min_count and node_max_count."
  }
}

variable "node_max_count" {
  description = "Maximum managed worker count"
  type        = number
  default     = 6
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR range"
  type        = string
}

variable "availability_zones" {
  description = "At least two AWS availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per availability zone"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "One private subnet CIDR per availability zone"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway to reduce costs; false creates one per AZ"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
}

variable "db_engine_version" {
  description = "Exact AWS-supported PostgreSQL engine version"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password; supply through TF_VAR_db_password, never a tfvars file"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial encrypted gp3 storage in GiB"
  type        = number
}

variable "db_backup_retention_period" {
  description = "Automated RDS backup retention in days"
  type        = number
}

variable "db_deletion_protection" {
  description = "Protect the database against deletion"
  type        = bool
  default     = true
}

variable "db_multi_az" {
  description = "Enable RDS Multi-AZ standby"
  type        = bool
  default     = true
}
