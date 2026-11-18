output "vpc_id" {
  description = "Application VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public load-balancer subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private EKS and RDS subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.kubernetes.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Private EKS API endpoint"
  value       = module.kubernetes.cluster_endpoint
}

output "eks_node_security_group_id" {
  description = "Worker security group used by the RDS ingress rule"
  value       = module.kubernetes.node_security_group_id
}

output "rds_endpoint" {
  description = "Private PostgreSQL endpoint"
  value       = module.database.endpoint
}

output "rds_port" {
  description = "PostgreSQL port"
  value       = module.database.port
}

output "rds_database_name" {
  description = "Initial database name"
  value       = module.database.database_name
}
