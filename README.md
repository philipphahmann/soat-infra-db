# Infraestrutura do Banco de Dados - Tech Challenge SOAT

Este repositório é responsável por provisionar e gerenciar a infraestrutura do banco de dados para o projeto Tech Challenge da Pós-Graduação em Arquitetura de Software.

O projeto utiliza **Terraform** para automação da infraestrutura como código (IaC) e **GitHub Actions** para o fluxo de Integração e Entrega Contínua (CI/CD).

## 🚀 Recursos Gerenciados

Este repositório provisiona os seguintes recursos na AWS:

* **AWS RDS:** Uma instância de banco de dados PostgreSQL gerenciada.
* **AWS Security Group:** Regras de firewall para controlar o acesso à instância RDS.
* **AWS Secrets Manager:** Um segredo para armazenar de forma segura a senha do banco de dados.

## ✅ Pré-requisitos

Para que a automação funcione, é necessário configurar os seguintes segredos no repositório do GitHub:

1.  Acesse `Settings` > `Secrets and variables` > `Actions`.
2.  Adicione os seguintes `Repository secrets`:
    * `AWS_ACCESS_KEY_ID`: Sua chave de acesso da AWS.
    * `AWS_SECRET_ACCESS_KEY`: Sua chave secreta da AWS.
    * `AWS_SESSION_TOKEN`: O token de sessão temporário (necessário para o ambiente AWS Academy).
    * `DB_PASSWORD`: A senha que você deseja configurar para o usuário principal do banco de dados.

## ⚙️ Fluxo de CI/CD

O fluxo de trabalho foi desenhado para ser seguro e garantir que a infraestrutura só seja alterada de forma controlada, seguindo os requisitos do projeto de ter branches protegidas.

1.  **Branch `dev`:** Todo novo desenvolvimento ou alteração deve ser enviado para a branch `dev`. Um `push` nesta branch irá disparar a pipeline para validar o código e gerar um `terraform plan` (um preview das alterações), mas não aplicará nenhuma mudança.

2.  **Pull Request para a `main`:** Para aplicar as mudanças, um Pull Request (PR) deve ser aberto da branch `dev` para a `main`. A pipeline irá rodar novamente e exibir o `terraform plan` no PR para revisão da equipe.

3.  **Merge na `main`:** O `terraform apply` (que efetivamente altera a infraestrutura na AWS) é executado **automaticamente e somente** após o PR ser aprovado e o merge ser concluído na branch `main`.

## 📜 Outputs do Terraform

Após a execução bem-sucedida, este projeto Terraform expõe as seguintes saídas, que podem ser usadas para configurar outros serviços (como o cluster Kubernetes):

* `rds_endpoint`: O endereço de conexão (hostname) do banco de dados RDS.
* `rds_sg_id`: O ID do Security Group criado para o RDS.
* `db_password_secret_arn`: O ARN (Amazon Resource Name) do segredo criado no Secrets Manager.