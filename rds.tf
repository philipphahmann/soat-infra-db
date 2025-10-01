# Cria um "grupo de subnets" para o RDS.
# O RDS usa isso para saber em quais subnets privadas ele pode ser implantado.
resource "aws_db_subnet_group" "soat_subnet_group" {
  # As IDs das subnets são lidas do estado remoto do projeto de rede.
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

# Cria a instância do banco de dados RDS
resource "aws_db_instance" "soat_rds" {
  identifier        = "soat-rds-instance"
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "17.6"
  instance_class    = "db.t3.micro"
  db_name           = "soat"
  username          = "soatadmin"
  password          = var.db_password

  # Associa a instância ao grupo de subnets e ao security group corretos.
  db_subnet_group_name   = aws_db_subnet_group.soat_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Importante: para ser acessível apenas de dentro da VPC, e não da internet.
  publicly_accessible = false

  skip_final_snapshot = true
}