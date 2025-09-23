resource "aws_secretsmanager_secret" "db_password_secret" {
  name = "soat-db-password-secret"
}

resource "aws_secretsmanager_secret_version" "db_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = var.db_password
}