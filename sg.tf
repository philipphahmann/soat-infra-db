# Cria um Security Group (firewall) para o RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Permite acesso ao RDS a partir do EKS"
  # O ideal é associar a uma VPC específica, mas por enquanto vamos manter simples.

  # Regra de entrada: permite que qualquer recurso DENTRO da mesma VPC
  # acesse a porta 5432 (PostgreSQL). Futuramente, o cluster EKS estará
  # nesta VPC e poderá se conectar.
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ATENÇÃO: Para produção, restrinja este IP. Por agora, facilita a conexão.
  }

  # Regra de saída: permite que o RDS se conecte a qualquer lugar
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
