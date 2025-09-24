# Cria um Security Group (firewall) para o RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Permite acesso ao RDS a partir de recursos dentro da VPC"
  # Associa o Security Group à VPC criada pelo projeto de rede.
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  # Regra de entrada (ingress):
  # Permite que qualquer recurso DENTRO da mesma VPC (ex: cluster EKS, EC2)
  # acesse a porta 5432 (PostgreSQL).
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # Acesso restrito ao bloco CIDR da nossa VPC. MUITO mais seguro!
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block]
  }

  # Regra de saída (egress): 
  # Permite que o RDS se conecte a qualquer lugar (útil para atualizações, etc.).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
