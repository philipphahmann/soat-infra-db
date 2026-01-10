variable "identifier" {}
variable "instance_class" { default = "db.t3.micro" }
variable "db_name" { default = "soat" }
variable "db_password" {}
variable "db_subnet_group_name" {}
variable "vpc_security_group_ids" { type = list(string) }