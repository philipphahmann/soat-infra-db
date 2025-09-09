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
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 para armazenar o estado do Terraform."
  type        = string
  default     = "soat-infra-db-tfstate-bucket"
}
