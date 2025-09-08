# Cria a instância do banco de dados RDS
resource "aws_db_instance" "soat_rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.t3.micro"
  db_name                = "soat"
  username               = "admin"
  password               = aws_secretsmanager_secret_version.db_password_secret_version.secret_string
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}