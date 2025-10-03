# Infraestrutura do Banco de Dados - Tech Challenge SOAT

Este repositório é responsável por provisionar e gerenciar a infraestrutura do banco de dados para o projeto, utilizando **Terraform** como ferramenta de Infraestrutura como Código (IaC).

A automação de deploy é gerenciada pelo **GitHub Actions**, garantindo um processo de CI/CD seguro e auditável.

## 🚀 Arquitetura e Recursos Provisionados

Este projeto provisiona os seguintes recursos na AWS:

* **AWS RDS:** Uma instância de banco de dados PostgreSQL (`db.t3.micro`) gerenciada, com o nome de instância `soat-rds-instance`.
* **AWS Secrets Manager:** Um segredo chamado `secret/rds-database` para armazenar de forma segura a senha, a url de acesso e o usuário do banco de dados, desacoplando-a do código.
* **AWS Security Group:** Um grupo de segurança (`soat-rds-sg`) que atua como um firewall, liberando o acesso à porta `5432` (PostgreSQL) para permitir a conexão futura de outras aplicações, como a do Kubernetes.

## 🏛️ Documentação do Banco de Dados

O esquema do banco de dados é gerenciado pela aplicação Spring Boot através do Flyway. A documentação detalhada sobre a escolha do banco, modelagem de dados e sugestões de melhoria pode ser encontrada no seguinte arquivo:

* **[📄 Documentação Completa do Banco de Dados](./docs/DATABASE.md)**

## ⚙️ Gerenciamento de Estado (State Management)

Para garantir a persistência, segurança e colaboração, o estado do Terraform é gerenciado remotamente.

* **Backend:** O arquivo `terraform.tfstate` é armazenado em um **AWS S3 Bucket**, chamado `soat-tfstate-bucket`.
* **Caminho do Estado:** O arquivo de estado está localizado no caminho `database/terraform.tfstate` dentro do bucket.

## 🔄 Fluxo de CI/CD com GitHub Actions

O deploy da infraestrutura é totalmente automatizado e segue um fluxo seguro, conforme definido em `.github/workflows/terraform.yml`:

1.  **Branch `dev`:** Todo novo desenvolvimento deve ser enviado para a branch `dev`. Um `push` nesta branch dispara a pipeline para executar validações (`fmt`, `validate`) e gerar um `terraform plan`, garantindo a integridade do código sem aplicar nenhuma mudança.
2.  **Pull Request para `main`:** Para aplicar as mudanças, um Pull Request (PR) deve ser aberto da `dev` para a `main`. A pipeline roda novamente, exibindo o plano no PR para revisão. A branch `main` é protegida e exige a passagem dos status checks.
3.  **Merge na `main`:** O `terraform apply`, que efetivamente cria ou altera a infraestrutura na AWS, é executado **automaticamente e somente** após o PR ser aprovado e o merge ser concluído na branch `main`.

## 🛡️ Segurança e Proteção da Branch `main`

Para garantir a integridade e a estabilidade da infraestrutura, a branch `main` é protegida com as seguintes regras:

* **Não permitir commit direto:** Todos os commits devem ser feitos em branches secundárias.
* **Permitir merge somente via Pull Request:** As alterações só podem ser integradas à `main` através de um PR.
* **Permitir merge somente com status OK das actions:** O PR só pode ser mesclado se a pipeline de CI/CD (`terraform plan`, `validate`, etc.) for executada com sucesso.
* **Permitir merge somente após aprovação:** É necessária a aprovação de pelo menos um revisor no Pull Request.

## ✅ Pré-requisitos para Execução

Para que a pipeline de CI/CD funcione, é necessário configurar os seguintes segredos no repositório do GitHub (`Settings` > `Secrets and variables` > `Actions`):

* `AWS_ACCESS_KEY_ID`: A chave de acesso da sua conta AWS.
* `AWS_SECRET_ACCESS_KEY`: A chave secreta da sua conta AWS.
* `AWS_SESSION_TOKEN`: O token de sessão temporário (obrigatório para o ambiente AWS Academy).
* `DB_PASSWORD`: A senha desejada para o usuário `soatadmin` do banco de dados.

## 📜 Outputs do Terraform

Após a aplicação, este módulo Terraform expõe as seguintes saídas (`outputs.tf`), que são essenciais para conectar outras partes da infraestrutura (como o Kubernetes) a este banco de dados:

* `rds_endpoint`: O endereço de conexão (hostname e porta) do banco de dados RDS.
* `rds_sg_id`: O ID do Security Group criado, útil para configurar regras de firewall em outros serviços.
* `rds_database_secret_container_arn`: O ARN (Amazon Resource Name) do segredo no Secrets Manager, usado para permitir que aplicações leiam a senha de forma segura.
