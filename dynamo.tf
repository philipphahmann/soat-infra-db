resource "aws_dynamodb_table" "auth_cache" {
  # O nome final será algo como "soat-auth-tokens"
  name = "${var.project_name}-ms-auth"

  # PAY_PER_REQUEST é ideal para cargas variáveis e evita custos fixos de provisionamento
  billing_mode = "PAY_PER_REQUEST"

  # Definimos a chave primária (Partition Key)
  hash_key = "cpf"

  attribute {
    name = "cpf"
    type = "S" # S = String
  }

  # Configuração do TTL para expiração automática dos itens
  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = {
    Name        = "${var.project_name}-ms-auth"
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}

# (Opcional) Cria uma política IAM para facilitar a permissão de acesso pela aplicação depois
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "${var.project_name}-dynamodb-auth-policy"
  description = "Política que permite leitura e escrita na tabela de cache de auth"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.auth_cache.arn
      }
    ]
  })
}