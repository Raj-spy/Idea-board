output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Private Kubernetes API endpoint; reachable only from the VPC or connected network"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Provisioned EKS Kubernetes version"
  value       = aws_eks_cluster.main.version
}

output "node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.main.node_group_name
}

output "node_security_group_id" {
  description = "Worker security group ID used as the sole RDS ingress source"
  value       = aws_security_group.nodes.id
}

output "node_role_arn" {
  description = "IAM role assigned to worker EC2 instances"
  value       = aws_iam_role.nodes.arn
}
