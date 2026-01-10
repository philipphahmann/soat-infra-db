resource "aws_db_instance" "this" {
  identifier        = var.identifier
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "17.6"
  instance_class    = var.instance_class
  db_name           = var.db_name
  username          = "soatadmin"
  password          = var.db_password

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = false
  
  performance_insights_enabled = true
  skip_final_snapshot          = true
}