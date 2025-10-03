output "rds_endpoint" {
  description = "O endereço de conexão (endpoint) do banco de dados RDS."
  value       = aws_db_instance.soat_rds.endpoint
}

output "rds_sg_id" {
  description = "O ID do Security Group criado para o RDS."
  value       = aws_security_group.rds_sg.id
}

output "rds_database_secret_container_arn" {
  description = "O ARN do segredo no Secrets Manager."
  value       = aws_secretsmanager_secret.rds_database_secret_container.arn
}