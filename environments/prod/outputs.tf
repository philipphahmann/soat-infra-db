output "rds_endpoint" {
  description = "Endpoint do banco de produtos"
  value       = module.rds_products.endpoint
}

output "rds_sg_id" {
  description = "ID do Security Group"
  value       = aws_security_group.rds_sg.id
}

output "rds_database_secret_container_arn" {
  description = "ARN do Segredo"
  value       = aws_secretsmanager_secret.rds_secret.arn
}

output "dynamodb_table_name" {
  value = module.dynamo_auth.table_name
}

output "dynamodb_table_arn" {
  value = module.dynamo_auth.table_arn
}

output "dynamodb_policy_arn" {
  value = module.dynamo_auth.policy_arn
}