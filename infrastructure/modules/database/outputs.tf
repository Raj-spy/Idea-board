output "endpoint" {
  description = "Private PostgreSQL endpoint"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "PostgreSQL listener port"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Initial application database name"
  value       = aws_db_instance.main.db_name
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.database.id
}
