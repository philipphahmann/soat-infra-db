# Infraestrutura do Banco de Dados - Tech Challenge SOAT

Este repositório é responsável por provisionar e gerenciar a infraestrutura de dados para o projeto, utilizando **Terraform** como ferramenta de Infraestrutura como Código (IaC).

A automação de deploy é gerenciada pelo **GitHub Actions**, garantindo um processo de CI/CD seguro e auditável.

## 🚀 Arquitetura e Recursos Provisionados

Este projeto adota uma arquitetura modular e provisiona os seguintes recursos na AWS:

* **AWS RDS (PostgreSQL):** Duas instâncias de banco de dados (`db.t3.micro`) gerenciadas, isoladas por contexto de microsserviço:
    * `soat-rds-instance-ms-products`: Banco de dados para o domínio de produtos.
    * `soat-rds-instance-ms-customers`: Banco de dados para o domínio de clientes.
* **AWS DynamoDB:** Uma tabela NoSQL (`soat-ms-auth`) utilizada para cache de autenticação, configurada com:
    * Chave de partição: `cpf`.
    * Billing Mode: `PAY_PER_REQUEST` (On-Demand).
    * TTL (Time-to-Live): Ativado no atributo `expires_at`.
* **AWS Secrets Manager:** Um segredo chamado `secret/rds-database` para armazenar de forma segura as credenciais de conexão do banco de produtos.
* **AWS Security Group:** Um grupo de segurança (`soat-rds-sg`) que libera o acesso à porta `5432` (PostgreSQL) para recursos dentro da VPC.

## 🏛️ Documentação do Banco de Dados

A arquitetura de dados do projeto adota uma abordagem híbrida, combinando a robustez de um banco relacional com a velocidade de um banco NoSQL. As especificações técnicas, modelagem e justificativas estão detalhadas nos arquivos abaixo:

### PostgreSQL (SQL)
Responsável pelos dados transacionais e de negócio (Clientes, Produtos, Pedidos e Pagamentos), com esquema gerenciado via Flyway.
* **[📄 Documentação do Banco Relacional (PostgreSQL)](./docs/SQL_Database.md)**

### Amazon DynamoDB (NoSQL)
Responsável pelo cache de autenticação e gerenciamento de sessões de usuários (JWT), utilizando recursos nativos de TTL para alta performance.
* **[📄 Documentação do Banco NoSQL (DynamoDB)](./docs/NoSQL_Database.md)**

## ⚙️ Gerenciamento de Estado (State Management)

Para garantir a persistência, segurança e colaboração, o estado do Terraform é gerenciado remotamente.

* **Backend:** O arquivo `terraform.tfstate` é armazenado em um **AWS S3 Bucket**, chamado `soat-ms-tfstate-bucket-1`.
* **Caminho do Estado:** O arquivo de estado está localizado no caminho `database/terraform.tfstate` dentro do bucket.
* **Dependências:** Este projeto lê o estado remoto da infraestrutura de rede (`network`) para obter IDs de VPC e Subnets.

## 🔄 Fluxo de CI/CD com GitHub Actions

O deploy da infraestrutura é totalmente automatizado e segue um fluxo seguro, conforme definido em `.github/workflows/terraform.yml`:

1.  **Branch `dev`:** Todo novo desenvolvimento deve ser enviado para a branch `dev`. Um `push` nesta branch dispara a pipeline para executar validações (`fmt`, `validate`) e gerar um `terraform plan`.
2.  **Pull Request para `main`:** Para aplicar as mudanças, um Pull Request (PR) deve ser aberto da `dev` para a `main`. A pipeline roda novamente, exibindo o plano no PR para revisão.
3.  **Merge na `main`:** O `terraform apply` é executado **automaticamente e somente** após o PR ser aprovado e o merge ser concluído na branch `main`.

## 🛡️ Segurança e Proteção da Branch `main`

Para garantir a integridade da infraestrutura, a branch `main` é protegida com as seguintes regras:

* **Não permitir commit direto:** Todos os commits devem ser feitos em branches secundárias.
* **Permitir merge somente via Pull Request:** As alterações só podem ser integradas à `main` através de um PR.
* **Status Checks:** O PR só pode ser mesclado se a pipeline de CI/CD for executada com sucesso.
* **Revisão Obrigatória:** É necessária a aprovação de pelo menos um revisor no Pull Request.

## ✅ Pré-requisitos para Execução

Para que a pipeline de CI/CD funcione, configure os seguintes segredos no repositório (`Settings` > `Secrets and variables` > `Actions`):

* `AWS_ACCESS_KEY_ID`: Chave de acesso da conta AWS.
* `AWS_SECRET_ACCESS_KEY`: Chave secreta da conta AWS.
* `AWS_SESSION_TOKEN`: Token de sessão (obrigatório para AWS Academy).
* `DB_PASSWORD`: Senha mestre para os usuários `soatadmin` dos bancos de dados RDS.

## 📜 Outputs do Terraform

Após a aplicação, este módulo expõe saídas essenciais para a integração com outras aplicações (como Kubernetes):

* `rds_endpoint`: Endpoint de conexão do banco de dados de produtos.
* `rds_sg_id`: ID do Security Group dos bancos de dados.
* `rds_database_secret_container_arn`: ARN do segredo no Secrets Manager.
* `dynamodb_table_name`: Nome da tabela DynamoDB criada (`soat-ms-auth`).
* `dynamodb_table_arn`: ARN da tabela DynamoDB.
* `dynamodb_policy_arn`: ARN da política IAM para acesso à tabela DynamoDB.