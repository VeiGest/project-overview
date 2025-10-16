# 📊 Diagrama ER - VeiGest

## Modelo Entidade-Relacionamento

```mermaid
erDiagram
    ROLES {
        int id PK
        varchar nome UK
        text descricao
        varchar slug UK
        int nivel_hierarquia
        boolean ativo
        datetime criado_em
        datetime atualizado_em
    }
    
    PERMISSIONS {
        int id PK
        varchar nome UK
        text descricao
        varchar modulo
        varchar acao
        varchar slug UK
        boolean ativo
        datetime criado_em
        datetime atualizado_em
    }
    
    ROLE_PERMISSIONS {
        int id PK
        int role_id FK
        int permission_id FK
        datetime criado_em
    }
    
    USERS {
        int id PK
        varchar nome
        varchar email UK
        varchar senha_hash
        varchar telefone
        int role_id FK
        enum role
        enum estado
        datetime data_criacao
        datetime ultimo_login
        datetime atualizado_em
    }
    
    DRIVERS_PROFILES {
        int id PK
        int user_id FK
        varchar numero_carta
        date validade_carta
        varchar nif
        varchar endereco
        varchar foto
        boolean ativo
        datetime criado_em
        datetime atualizado_em
    }
    
    VEHICLES {
        int id PK
        varchar matricula UK
        varchar marca
        varchar modelo
        int ano
        enum tipo_combustivel
        int quilometragem
        enum estado
        date data_aquisicao
        int condutor_id FK
        text notas
        varchar foto
        datetime criado_em
        datetime atualizado_em
    }
    
    MAINTENANCES {
        int id PK
        int vehicle_id FK
        varchar tipo
        text descricao
        date data
        decimal custo
        int km_registro
        date proxima_data
        varchar oficina
        text notas
        datetime criado_em
        datetime atualizado_em
    }
    
    DOCUMENTS {
        int id PK
        int vehicle_id FK
        int driver_id FK
        enum tipo
        varchar numero
        varchar emissor
        date data_emissao
        date validade
        varchar arquivo
        enum status
        text notas
        datetime criado_em
        datetime atualizado_em
    }
    
    FUEL_LOGS {
        int id PK
        int vehicle_id FK
        int driver_id FK
        date data
        decimal litros
        decimal valor
        decimal preco_litro
        varchar local
        int km_atual
        varchar recibo
        text notas
        datetime criado_em
    }
    
    ROUTES {
        int id PK
        int driver_id FK
        int vehicle_id FK
        datetime inicio
        datetime fim
        decimal distancia_km
        int tempo_total
        varchar origem
        varchar destino
        int km_inicial
        int km_final
        varchar proposito
        text observacoes
        enum status
        datetime criado_em
        datetime atualizado_em
    }
    
    GPS_POINTS {
        int id PK
        int route_id FK
        decimal latitude
        decimal longitude
        decimal velocidade
        decimal altitude
        datetime timestamp
    }
    
    ALERTS {
        int id PK
        enum tipo
        varchar titulo
        text descricao
        date data_limite
        enum prioridade
        enum status
        int user_id FK
        int vehicle_id FK
        int document_id FK
        boolean notificado
        datetime data_notificacao
        datetime criado_em
        datetime resolvido_em
    }
    
    REPORTS {
        int id PK
        enum tipo
        varchar titulo
        date periodo_inicio
        date periodo_fim
        json parametros
        int gerado_por FK
        varchar arquivo
        enum status
        datetime criado_em
        datetime concluido_em
    }
    
    ACTIVITY_LOGS {
        int id PK
        int user_id FK
        varchar acao
        varchar entidade
        int entidade_id
        json detalhes
        varchar ip
        text user_agent
        datetime criado_em
    }
    
    SETTINGS {
        int id PK
        varchar chave UK
        text valor
        enum tipo
        text descricao
        varchar categoria
        boolean editavel
        datetime criado_em
        datetime atualizado_em
    }
    
    SUPPORT_TICKETS {
        int id PK
        int user_id FK
        varchar assunto
        text mensagem
        enum prioridade
        enum status
        int atribuido_para FK
        text resposta
        datetime criado_em
        datetime atualizado_em
        datetime fechado_em
    }

    %% Relationships
    %% Roles and Permissions System
    ROLES ||--o{ ROLE_PERMISSIONS : "has"
    PERMISSIONS ||--o{ ROLE_PERMISSIONS : "belongs_to"
    ROLES ||--o{ USERS : "assigned_to"
    
    %% Original Relationships
    USERS ||--o{ DRIVERS_PROFILES : "has"
    USERS ||--o{ VEHICLES : "drives"
    USERS ||--o{ FUEL_LOGS : "registers"
    USERS ||--o{ ROUTES : "travels"
    USERS ||--o{ ALERTS : "receives"
    USERS ||--o{ REPORTS : "generates"
    USERS ||--o{ ACTIVITY_LOGS : "performs"
    USERS ||--o{ SUPPORT_TICKETS : "creates"
    USERS ||--o{ SUPPORT_TICKETS : "assigned_to"
    USERS ||--o{ DOCUMENTS : "owns"
    
    VEHICLES ||--o{ MAINTENANCES : "has"
    VEHICLES ||--o{ DOCUMENTS : "has"
    VEHICLES ||--o{ FUEL_LOGS : "consumes"
    VEHICLES ||--o{ ROUTES : "travels"
    VEHICLES ||--o{ ALERTS : "triggers"
    
    ROUTES ||--o{ GPS_POINTS : "tracks"
    
    DOCUMENTS ||--o{ ALERTS : "expires"
```

## Relacionamentos Principais

### 🔐 Sistema de Roles e Permissions

#### 1:N (Um para Muitos)
- `ROLES` → `USERS` (Um role pode ser atribuído a vários usuários)
- `ROLES` → `ROLE_PERMISSIONS` (Um role pode ter várias permissões)
- `PERMISSIONS` → `ROLE_PERMISSIONS` (Uma permissão pode pertencer a vários roles)

#### M:N (Muitos para Muitos) - Tabela Intermediária
- `ROLES` ←→ `PERMISSIONS` através de `ROLE_PERMISSIONS` (Roles têm múltiplas permissões e permissões podem ser atribuídas a múltiplos roles)

### 👥 Relacionamentos Tradicionais

#### 1:1 (Um para Um)
- `USERS` ←→ `DRIVERS_PROFILES` (Um usuário condutor tem um perfil)

#### 1:N (Um para Muitos)
- `USERS` → `VEHICLES` (Um condutor pode ter vários veículos atribuídos)
- `VEHICLES` → `MAINTENANCES` (Um veículo tem várias manutenções)
- `VEHICLES` → `DOCUMENTS` (Um veículo tem vários documentos)
- `VEHICLES` → `FUEL_LOGS` (Um veículo tem vários abastecimentos)
- `VEHICLES` → `ROUTES` (Um veículo faz várias viagens)
- `ROUTES` → `GPS_POINTS` (Uma rota tem vários pontos GPS)
- `USERS` → `FUEL_LOGS` (Um condutor registra vários abastecimentos)
- `USERS` → `ROUTES` (Um condutor faz várias viagens)
- `USERS` → `ALERTS` (Um usuário recebe vários alertas)
- `USERS` → `REPORTS` (Um gestor gera vários relatórios)
- `USERS` → `ACTIVITY_LOGS` (Um usuário gera várias atividades)
- `USERS` → `SUPPORT_TICKETS` (Um usuário cria vários tickets)

#### M:N (Muitos para Muitos) - Através de tabelas intermediárias
- `VEHICLES` ←→ `USERS` através de histórico em `ROUTES` (Vários condutores podem usar o mesmo veículo ao longo do tempo)

## Índices Recomendados

### Índices Únicos
- `users.email`
- `vehicles.matricula`
- `settings.chave`
- `roles.nome`
- `roles.slug`
- `permissions.nome`
- `permissions.slug`
- `role_permissions(role_id, permission_id)` - Evitar duplicatas

### Índices de Performance
- `fuel_logs(data, vehicle_id)` - Para relatórios de consumo
- `routes(driver_id, inicio)` - Para histórico de condutores
- `alerts(status, data_limite)` - Para alertas ativos
- `activity_logs(user_id, criado_em)` - Para auditoria
- `documents(validade, status)` - Para documentos expirados
- `users(role_id)` - Para consultas por role
- `permissions(modulo, acao)` - Para consultas por módulo e ação
- `roles(nivel_hierarquia)` - Para ordenação hierárquica

## Constraints e Regras de Negócio

### Check Constraints
- `documents`: Deve ter pelo menos `vehicle_id` OU `driver_id`
- `fuel_logs`: `litros > 0` e `valor > 0`
- `routes`: `fim >= inicio` (quando preenchido)
- `vehicles`: `ano >= 1900` e `ano <= YEAR(CURDATE())`

### Triggers Sugeridas
- **Auto-alertas**: Criar alertas automáticos quando documentos estão próximos do vencimento
- **Update quilometragem**: Atualizar quilometragem do veículo quando rota é finalizada
- **Activity logging**: Registrar automaticamente ações importantes

### Procedimentos Armazenados Sugeridos
- `CalcularCustoTotalVeiculo(vehicle_id, data_inicio, data_fim)`
- `GerarRelatorioConsumo(vehicle_id, periodo)`
- `VerificarDocumentosVencidos(dias_antecedencia)`
