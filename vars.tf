variable "aws_region" {
  description = "Região da AWS para criar os recursos."
  type        = string
  default     = "us-east-1" 
}

variable "project_name" {
  description = "Nome do projeto, usado para nomear recursos."
  type        = string
  default     = "soat"
}

variable "db_password" {
  description = "Senha para o banco de dados RDS. Será armazenada no Secrets Manager."
  type        = string
  sensitive   = true # Marca a variável como sensível para não aparecer nos logs.
}