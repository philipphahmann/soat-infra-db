# Documentação do Banco de Dados - Tech Challenge SOAT

Este documento detalha a arquitetura, a modelagem e as justificativas técnicas para a estrutura do banco de dados utilizado no projeto de gestão para a rede de fast-food.

---

## 1. Justificativa da Escolha: PostgreSQL no AWS RDS

A escolha do **PostgreSQL** como sistema de gerenciamento de banco de dados (SGBD), hospedado no serviço **AWS RDS (Relational Database Service)**, é uma decisão estratégica que alinha robustez, flexibilidade e eficiência operacional para a aplicação.

### a. Natureza Relacional e Transacional dos Dados
O núcleo da aplicação envolve transações complexas e dados altamente interconectados: clientes realizam pedidos, que contêm itens e geram pagamentos.

* **Integridade e Consistência (ACID):** O PostgreSQL garante as propriedades ACID (Atomicidade, Consistência, Isolamento e Durabilidade), o que é indispensável para operações financeiras e de controle de pedidos.
* **Relacionamentos Claros:** A estrutura de tabelas com chaves estrangeiras (`customers`, `orders`, `order_items`) se beneficia diretamente do modelo relacional, assegurando que um pedido sempre pertença a um cliente válido.

### b. Flexibilidade e Recursos Avançados do PostgreSQL
O PostgreSQL é um sistema objeto-relacional que oferece suporte a tipos de dados avançados, adequados às necessidades da aplicação.

* **Suporte a JSONB:** A tabela `event_store`, utilizada para Event Sourcing, se beneficia do tipo de dado `JSONB`, que permite armazenar e consultar dados de `payload` de forma eficiente.
* **Tipos de Dados Customizáveis:** O uso de tipos `ENUM` para `order_status` e `payment_status` garante a consistência e a validação dos dados diretamente no banco.

### c. Vantagens do AWS RDS (Serviço Gerenciado)
Provisionar o PostgreSQL através do AWS RDS abstrai a complexidade da infraestrutura e oferece benefícios operacionais cruciais.

* **Gerenciamento Simplificado:** A AWS automatiza tarefas como provisionamento de infraestrutura, atualizações de S.O., backups e alta disponibilidade.
* **Escalabilidade:** O RDS facilita a escalabilidade vertical (alterando a `instance_class`) e de armazenamento, adaptando-se ao crescimento da demanda.
* **Segurança:** A infraestrutura é provisionada em sub-redes privadas e protegida por `Security Groups`, garantindo que o banco de dados не seja exposto à internet. A gestão de senhas com AWS Secrets Manager complementa a estratégia de segurança.

---

## 2. Modelagem e Documentação de Dados

A seguir, a documentação do banco de dados em seus três níveis de abstração.

### a. Modelo Conceitual
Este modelo foca nas entidades de negócio e seus relacionamentos de alto nível.

```mermaid
erDiagram
    CLIENTE ||--o{ PEDIDO : "realiza"
    PEDIDO ||--|{ "ITEM DO PEDIDO" : "contém"
    PRODUTO ||--o{ "ITEM DO PEDIDO" : "é um"
    PEDIDO ||--o{ PAGAMENTO : "é pago por"
    CLIENTE ||--o{ PAGAMENTO : "efetua"
```

### b. Modelo Lógico
Este modelo detalha as entidades com atributos e chaves, usando tipos de dados genéricos.

```mermaid
erDiagram
    customers {
        UUID id PK
        TEXT name
        TEXT email
        TEXT phone
        TEXT document_identifier
        DATETIME created_at
    }

    products {
        UUID id PK
        TEXT sku
        TEXT name
        TEXT category
        TEXT description
        NUMBER price
        BOOLEAN active
        TEXT image
        DATETIME created_at
        DATETIME updated_at
    }

    orders {
        UUID id PK
        UUID customer_id FK
        TEXT status
        NUMBER total_price
        NUMBER discount_amount
        TEXT observation
        DATETIME created_at
        DATETIME updated_at
    }

    order_items {
        UUID id PK
        UUID order_id FK
        UUID product_id FK
        TEXT product_name
        INTEGER product_quantity
        TEXT product_category
        NUMBER unit_price
        NUMBER discount_amount
        DATETIME created_at
        DATETIME updated_at
    }

    payments {
        UUID id PK
        UUID order_id
        UUID customer_id FK
        TEXT payment_method
        NUMBER amount
        TEXT status
        DATETIME created_at
        DATETIME processed_at
    }

    customers ||--o{ orders : "realiza"
    customers ||--o{ payments : "efetua"
    orders ||--|{ order_items : "contém"
    products ||--o{ order_items : "é item de"
    orders ||--o{ payments : "é pago por"
```

### c. Modelo Físico
Este modelo representa a implementação exata no PostgreSQL, conforme definido pelos scripts do Flyway.

```mermaid
erDiagram
    customers {
        UUID id PK
        VARCHAR name
        VARCHAR email
        VARCHAR phone
        VARCHAR document_identifier
        TIMESTAMPTZ created_at
    }

    products {
        UUID id PK
        VARCHAR sku
        VARCHAR name
        product_category category
        VARCHAR description
        DECIMAL price
        BOOLEAN active
        VARCHAR image
        TIMESTAMPTZ created_at
        TIMESTAMPTZ updated_at
    }

    orders {
        UUID id PK
        UUID customer_id FK
        order_status status
        DECIMAL total_price
        DECIMAL discount_amount
        VARCHAR observation
        TIMESTAMPTZ created_at
        TIMESTAMPTZ updated_at
    }

    order_items {
        UUID id PK
        UUID order_id FK
        UUID product_id FK
        VARCHAR product_name
        INTEGER product_quantity
        VARCHAR product_category
        DECIMAL unit_price
        DECIMAL discount_amount
        TIMESTAMPTZ created_at
        TIMESTAMPTZ updated_at
    }

    payments {
        UUID id PK
        UUID order_id
        UUID customer_id FK
        VARCHAR payment_method
        DECIMAL amount
        payment_status status
        TIMESTAMPTZ created_at
        TIMESTAMPTZ processed_at
    }

    event_store {
        UUID id PK
        UUID aggregate_id
        VARCHAR event_type
        TEXT payload
        TIMESTAMP occurred_on
        INTEGER version
        JSONB metadata
    }

    customers ||--o{ orders : "realiza"
    customers ||--o{ payments : "efetua"
    orders ||--|{ order_items : "contém"
    products ||--o{ order_items : "é item de"
    orders ||--o{ payments : "é pago por"
```