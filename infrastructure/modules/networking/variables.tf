variable "name_prefix" {
  description = "Environment-specific resource name prefix"
  type        = string
}

variable "region" {
  description = "AWS region used to construct regional VPC endpoint service names"
  type        = string
}

variable "environment" {
  description = "Deployment environment used for resource tags"
  type        = string

  validation {
    condition     = contains(["development", "production"], var.environment)
    error_message = "Environment must be development or production."
  }
}

variable "cluster_name" {
  description = "EKS cluster name used for subnet discovery tags"
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR range."
  }
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per availability zone"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnet CIDRs are required for EKS."
  }
}

variable "private_subnet_cidrs" {
  description = "One private subnet CIDR per availability zone"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs are required for EKS."
  }
}

variable "availability_zones" {
  description = "AWS availability zones used for paired public and private subnets"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) == length(distinct(var.availability_zones))
    error_message = "Provide at least two unique availability zones."
  }

  validation {
    condition     = length(var.availability_zones) == length(var.public_subnet_cidrs) && length(var.availability_zones) == length(var.private_subnet_cidrs)
    error_message = "Public and private subnet CIDR counts must match the availability zone count."
  }
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for lower-cost environments; false creates one per AZ"
  type        = bool
}
