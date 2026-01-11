# 1. Dados Compartilhados (Rede)
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "soat-ms-tfstate-bucket-1"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

# 2. Recursos Compartilhados (SG e Subnet Group)
resource "aws_db_subnet_group" "soat_subnet_group" {
  name       = "terraform-20260108123035079700000001"
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  tags       = { Name = "soat-rds-subnet-group" }
}

resource "aws_security_group" "rds_sg" {
  name        = "soat-rds-sg"
  description = "Permite acesso ao RDS a partir de recursos dentro da VPC"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Bancos de Dados (Chamada aos Módulos)
module "rds_products" {
  source = "../../modules/rds"

  identifier             = "soat-products"
  db_name                = "products"
  db_password            = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.soat_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

module "rds_customers" {
  source = "../../modules/rds"

  identifier             = "soat-customers"
  db_name                = "customers"
  db_password            = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.soat_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

module "rds_orders" {
  source = "../../modules/rds"

  identifier             = "soat-orders"
  db_name                = "orders"
  db_password            = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.soat_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

module "rds_payments" {
  source = "../../modules/rds"

  identifier             = "soat-payments"
  db_name                = "payments"
  db_password            = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.soat_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# 4. Secrets Manager (Específico para Products)
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "secret/rds-database"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    DB_URL      = "jdbc:postgresql://${module.rds_products.address}:${module.rds_products.port}/${module.rds_products.db_name}"
    DB_USER     = module.rds_products.username
    DB_PASSWORD = var.db_password
  })
}

# 5. DynamoDB
module "dynamo_auth" {
  source     = "../../modules/dynamo"
  table_name = "soat-ms-auth"
  tags = {
    Name      = "soat-ms-auth"
    ManagedBy = "Terraform"
  }
}