# --- BANCOS DE DADOS (Agora em Módulos) ---
moved {
  from = aws_db_instance.soat_rds_ms_products
  to   = module.rds_products.aws_db_instance.this
}

moved {
  from = aws_db_instance.soat_rds_ms_customers
  to   = module.rds_customers.aws_db_instance.this
}

# --- DYNAMODB & POLICY (Agora em Módulos) ---
moved {
  from = aws_dynamodb_table.auth_cache
  to   = module.dynamo_auth.aws_dynamodb_table.this
}

moved {
  from = aws_iam_policy.dynamodb_access_policy
  to   = module.dynamo_auth.aws_iam_policy.access_policy
}

# --- SECRETS MANAGER (Agora em Módulos) ---
moved {
  from = aws_secretsmanager_secret.rds_database_secret_container
  to   = aws_secretsmanager_secret.rds_secret
}

moved {
  from = aws_secretsmanager_secret_version.rds_database_secret
  to   = aws_secretsmanager_secret_version.rds_secret_version
}