# Cria o container do segredo no Secrets Manager.
resource "aws_secretsmanager_secret" "rds_database_secret_container" {
  name = "secret/rds-database"
}

# Cria a versão do segredo com os dados do banco de dados.
resource "aws_secretsmanager_secret_version" "rds_database_secret" {
  secret_id = aws_secretsmanager_secret.rds_database_secret_container.id

  # A função jsonencode() cria a estrutura de chave-valor que o Spring Cloud AWS espera.
  # Ela usa os atributos do recurso RDS e as variáveis para montar a string dinamicamente.
  secret_string = jsonencode({
    DB_URL      = "jdbc:postgresql://${aws_db_instance.soat_rds.address}:${aws_db_instance.soat_rds.port}/${aws_db_instance.soat_rds.db_name}"
    DB_USER     = aws_db_instance.soat_rds.username
    DB_PASSWORD = aws_db_instance.soat_rds.password
  })
}