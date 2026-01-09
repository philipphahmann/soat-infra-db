# Documentação do Banco de Dados NoSQL - Tech Challenge SOAT

Este documento detalha as justificativas técnicas, a modelagem dos dados e as configurações de infraestrutura para o uso do **Amazon DynamoDB** como solução de cache e armazenamento de sessões de autenticação (JWT) no projeto.

---

## 1. Justificativa da Escolha: Amazon DynamoDB

A escolha do **Amazon DynamoDB** como banco de dados NoSQL (*Key-Value*), em complemento ao banco relacional (PostgreSQL), é uma decisão arquitetural focada em performance, escalabilidade automática e gerenciamento eficiente de dados efêmeros.

### a. Gerenciamento Automático de Ciclo de Vida (TTL)
O recurso nativo de **Time-to-Live (TTL)** é o principal motivador para o uso do DynamoDB no serviço de autenticação.
* **Problema:** Tokens JWT e sessões de usuário possuem validade temporária. Manter esses dados indefinidamente em um banco relacional exigiria *jobs* de limpeza (garbage collection) complexos e custosos.
* **Solução:** O DynamoDB remove automaticamente os itens cuja data/hora no atributo `expires_at` tenha passado, sem custo adicional de computação ou necessidade de manutenção.

### b. Alta Performance e Baixa Latência
O fluxo de autenticação é crítico e executado em cada requisição do usuário.
* **Desempenho:** O DynamoDB oferece latência de milissegundos de um dígito para operações de leitura e escrita por chave primária (`GetItem`, `PutItem`), garantindo que a validação de tokens não se torne um gargalo.

### c. Modelo Serverless e Custo-Eficiência (On-Demand)
A utilização do modo de capacidade **On-Demand (`PAY_PER_REQUEST`)** elimina a necessidade de provisionamento antecipado.
* **Escalabilidade:** O banco ajusta-se automaticamente a picos de tráfego (ex: horário de almoço na rede de fast-food) e reduz o custo a zero quando não há utilização.
* **Gerenciamento Zero:** Como um serviço totalmente gerenciado, elimina a sobrecarga operacional de manutenção de servidores ou clusters de cache tradicionais (como Redis gerenciado manualmente).

---

## 2. Modelagem de Dados

Diferente do modelo relacional, a modelagem no DynamoDB é orientada aos padrões de acesso (*Access Patterns*). Para a autenticação, o padrão principal é a validação de sessão por usuário.

### a. Estrutura da Tabela (`soat-ms-auth`)

A tabela foi projetada como um armazenamento Chave-Valor simples e eficiente.

| Elemento | Nome do Atributo | Tipo | Descrição |
| :--- | :--- | :--- | :--- |
| **Partition Key (PK)** | `cpf` | String (`S`) | Identificador único do usuário. Permite a busca direta O(1) da sessão. |
| **TTL Attribute** | `expires_at` | Number (`N`) | Timestamp (Unix Epoch) que define quando o registro deve ser expirado. |
| **Atributos Livres** | *payload* | Map/String | Armazena o token, claims ou metadados da sessão. |

### b. Representação Visual (Schema)

```mermaid
erDiagram
    soat_ms_auth {
        STRING cpf PK "Chave de Partição (Identificador do Usuário)"
        NUMBER expires_at "Timestamp de Expiração (TTL)"
        STRING token "Token JWT / Dados da Sessão"
    }