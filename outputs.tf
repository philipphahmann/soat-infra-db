output "rds_endpoint" {
  description = "O endereço de conexão (endpoint) do banco de dados RDS."
  value       = aws_db_instance.soat_rds_ms_products.endpoint
}

output "rds_sg_id" {
  description = "O ID do Security Group criado para o RDS."
  value       = aws_security_group.rds_sg.id
}

output "rds_database_secret_container_arn" {
  description = "O ARN do segredo no Secrets Manager."
  value       = aws_secretsmanager_secret.rds_database_secret_container.arn
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB criada para cache de tokens."
  value       = aws_dynamodb_table.auth_cache.name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB."
  value       = aws_dynamodb_table.auth_cache.arn
}

output "dynamodb_policy_arn" {
  description = "ARN da política IAM para acesso à tabela DynamoDB."
  value       = aws_iam_policy.dynamodb_access_policy.arn
}