# Este bloco de dados lê o arquivo de estado remoto (terraform.tfstate)
# do projeto de infraestrutura de rede, que está armazenado no S3.
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    # ATENÇÃO: Use o mesmo bucket do seu backend de rede.
    # Se você usou um nome diferente para o bucket da infra-base, ajuste aqui.
    bucket = "soat-tfstate-bucket"

    # O "key" deve apontar para o arquivo de estado da sua infra de REDE.
    # Ajuste se você usou um caminho diferente.
    key    = "infra/terraform.tfstate"
    region = var.aws_region
  }
}