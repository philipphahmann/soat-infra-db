resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "cpf"

  attribute {
    name = "cpf"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = var.tags
}

resource "aws_iam_policy" "access_policy" {
  name        = "soat-dynamodb-auth-policy"
  description = "Política que permite leitura e escrita na tabela de cache de autenticação do DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem", "dynamodb:PutItem", 
        "dynamodb:UpdateItem", "dynamodb:DeleteItem", 
        "dynamodb:Query", "dynamodb:Scan"
      ]
      Resource = aws_dynamodb_table.this.arn
    }]
  })
}