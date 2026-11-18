variable "name_prefix" {
  description = "Environment-specific resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment used for resource tags"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS control plane version supported in the selected AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the cluster and worker security group are created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR used to restrict worker egress to internal services"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for EKS control plane ENIs and worker nodes"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "EKS requires private subnets in at least two availability zones."
  }
}

variable "node_instance_type" {
  description = "EC2 instance type for managed worker nodes"
  type        = string
}

variable "node_min_count" {
  description = "Minimum managed worker count"
  type        = number
}

variable "node_count" {
  description = "Desired managed worker count"
  type        = number
}

variable "node_max_count" {
  description = "Maximum managed worker count"
  type        = number
}
