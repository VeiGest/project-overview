# API RESTful - VeiGest (v1)

Versão: 1.0
Data: 7 de novembro de 2025
Padrão: Yii2 Advanced - API module (api/modules/v1)
Autenticação: Bearer token (JWT ou Yii2 auth)
Formato: JSON (application/json)

Resumo das convenções
- Namespace controllers: api\modules\v1\controllers
- Controllers seguem ActiveController (ou controllers personalizados quando necessário)
- Rotas base: /api/v1/<resource>
- Paginação: padrão ?page=1&pageSize=20
- Filtros via query string (ex: ?company_id=1&status=ativo)
- Ordenação: ?sort=-created_at (prefixo - = desc)
- Datas: ISO 8601 (UTC)
- Permissões: controladas por RBAC (auth_item/auth_assignment)

Autenticação
- Header: Authorization: Bearer <token>
- Endpoints de autenticação (auth): /api/v1/auth/login, /api/v1/auth/logout, /api/v1/auth/refresh

---

## Endpoints por recurso

Para cada endpoint incluímos: método, URI, parâmetros principais, corpo de request (quando aplicável), exemplo de response (sucesso) e permissões RBAC sugeridas.

---
# API RESTful - VeiGest (v1)

Versão: 1.0
Data: 7 de novembro de 2025
Padrão: Yii2 Advanced - API module (api/modules/v1)
Autenticação: Bearer token (JWT ou Yii2 auth)
Formato: JSON (application/json)

Resumo das convenções
- Namespace controllers: api\modules\v1\controllers
- Controllers seguem ActiveController (ou controllers personalizados quando necessário)
- Rotas base: /api/v1/<resource>
- Paginação: padrão ?page=1&pageSize=20
- Filtros via query string (ex: ?company_id=1&status=ativo)
- Ordenação: ?sort=-created_at (prefixo - = desc)
- Datas: ISO 8601 (UTC)
- Permissões: controladas por RBAC (auth_item/auth_assignment)

Autenticação
- Header: Authorization: Bearer <token>
- Endpoints de autenticação (auth): /api/v1/auth/login, /api/v1/auth/logout, /api/v1/auth/refresh

---

## Endpoints por recurso

Para cada endpoint incluímos: método, URI, parâmetros principais, corpo de request (quando aplicável), exemplo de response (sucesso) e permissões RBAC sugeridas.

---

### 1) Companies
Base: /api/v1/companies

- GET /api/v1/companies
  - Descrição: Lista empresas (admin global / super-admin)
  - Query: ?page, ?pageSize, ?search, ?estado, ?plano
  - Permissão: companies.view

- GET /api/v1/companies/{id}
  - Descrição: Detalhes da empresa
  - Permissão: companies.view

- POST /api/v1/companies
  - Descrição: Criar empresa
  - Corpo: { nome, nif, email, telefone, configuracoes }
  - Permissão: companies.manage

- PUT /api/v1/companies/{id}
  - Descrição: Atualizar empresa
  - Corpo: { nome?, nif?, email?, configuracoes? }
  - Permissão: companies.manage

- DELETE /api/v1/companies/{id}
  - Descrição: Remover empresa
  - Permissão: companies.manage

---

### 2) Users
Base: /api/v1/users

- GET /api/v1/users
  - Lista utilizadores (filtro por company_id)
  - Permissão: users.view

- GET /api/v1/users/{id}
  - Detalhes do utilizador
  - Permissão: users.view

- POST /api/v1/users
  - Criar utilizador
  - Corpo: { company_id, nome, email, senha, telefone, numero_carta?, validade_carta? }
  - Permissão: users.create

- PUT /api/v1/users/{id}
  - Atualizar utilizador
  - Corpo: { nome?, email?, telefone?, numero_carta?, validade_carta?, estado? }
  - Permissão: users.update

- PATCH /api/v1/users/{id}/password
  - Atualizar senha (requere a senha antiga ou token de reset)
  - Corpo: { old_password?, new_password }
  - Permissão: users.update

- DELETE /api/v1/users/{id}
  - Remover utilizador
  - Permissão: users.delete

- POST /api/v1/users/{id}/assign-role
  - Atribuir role (admin only)
  - Corpo: { role: "gestor" }
  - Permissão: users.manage-roles

---

### 3) Vehicles
Base: /api/v1/vehicles

- GET /api/v1/vehicles
  - Lista veículos (filtros: company_id, condutor_id, estado)
  - Permissão: vehicles.view

- GET /api/v1/vehicles/{id}
  - Detalhes do veículo
  - Permissão: vehicles.view

- POST /api/v1/vehicles
  - Criar veículo
  - Corpo: { company_id, matricula, marca, modelo, ano, tipo_combustivel, quilometragem, condutor_id? }
  - Permissão: vehicles.create

- PUT /api/v1/vehicles/{id}
  - Atualizar
  - Permissão: vehicles.update

- DELETE /api/v1/vehicles/{id}
  - Remover
  - Permissão: vehicles.delete

- POST /api/v1/vehicles/{id}/assign-driver
  - Atribuir condutor
  - Corpo: { driver_id }
  - Permissão: vehicles.assign

---

### 4) Maintenances
Base: /api/v1/maintenances

- GET /api/v1/maintenances
  - Lista manutenções (filtros: vehicle_id, company_id, status)
  - Permissão: maintenances.view

- GET /api/v1/maintenances/{id}
  - Detalhes
  - Permissão: maintenances.view

- POST /api/v1/maintenances
  - Criar
  - Corpo: { company_id, vehicle_id, tipo, descricao, data, custo, km_registro, proxima_data }
  - Permissão: maintenances.create

- PUT /api/v1/maintenances/{id}
  - Atualizar
  - Permissão: maintenances.update

- DELETE /api/v1/maintenances/{id}
  - Remover
  - Permissão: maintenances.delete

---

### 5) Files
Base: /api/v1/files

- GET /api/v1/files
  - Lista ficheiros por company_id
  - Permissão: files.view

- GET /api/v1/files/{id}
  - Download/meta
  - Permissão: files.view

- POST /api/v1/files (multipart/form-data)
  - Upload
  - Campos: file (binary), company_id, uploaded_by
  - Permissão: files.upload

- DELETE /api/v1/files/{id}
  - Permissão: files.delete

---

### 6) Documents
Base: /api/v1/documents

- GET /api/v1/documents
  - Lista (filtros: company_id, vehicle_id, driver_id, tipo, status)
  - Permissão: documents.view

- GET /api/v1/documents/{id}
  - Detalhes
  - Permissão: documents.view

- POST /api/v1/documents
  - Criar documento associado a ficheiro
  - Corpo: { company_id, file_id, vehicle_id?, driver_id?, tipo, data_validade?, notas }
  - Permissão: documents.create

- PUT /api/v1/documents/{id}
  - Atualizar
  - Permissão: documents.update

- DELETE /api/v1/documents/{id}
  - Permissão: documents.delete

---

### 7) Fuel Logs
Base: /api/v1/fuel-logs

- GET /api/v1/fuel-logs
  - Lista registos de combustível (filtros: company_id, vehicle_id, driver_id, date range)
  - Permissão: fuel.view

- GET /api/v1/fuel-logs/{id}
  - Detalhes
  - Permissão: fuel.view

- POST /api/v1/fuel-logs
  - Criar registo de combustível
  - Corpo: { company_id, vehicle_id, driver_id?, data, litros, valor, km_atual?, notas? }
  - Permissão: fuel.create

- PUT /api/v1/fuel-logs/{id}
  - Atualizar
  - Permissão: fuel.update

- DELETE /api/v1/fuel-logs/{id}
  - Permissão: fuel.delete

---

### 8) Alerts
Base: /api/v1/alerts

- GET /api/v1/alerts
  - Lista alertas (filtros: company_id, tipo, status)
  - Permissão: alerts.view

- GET /api/v1/alerts/{id}
  - Detalhes
  - Permissão: alerts.view

- POST /api/v1/alerts
  - Criar alerta manual
  - Corpo: { company_id, tipo, titulo, descricao?, detalhes?, prioridade? }
  - Permissão: alerts.create

- PUT /api/v1/alerts/{id}
  - Atualizar (ex: marcar resolvido)
  - Permissão: alerts.resolve

- DELETE /api/v1/alerts/{id}
  - Permissão: alerts.create

---

### 9) Activity Logs
Base: /api/v1/activity-logs

- GET /api/v1/activity-logs
  - Lista logs (filtros: company_id, user_id, entidade)
  - Permissão: system.logs

- GET /api/v1/activity-logs/{id}
  - Detalhes
  - Permissão: system.logs

---

### 10) Routes (Rotas)
Base: /api/v1/routes

- GET /api/v1/routes
  - Lista rotas (filtros: company_id, vehicle_id, driver_id, status, periodo)
  - Permissão: routes.view

- GET /api/v1/routes/{id}
  - Detalhes da rota (inclui resumo) — considerar retornar link para pontos GPS paginados
  - Permissão: routes.view

- POST /api/v1/routes
  - Iniciar nova rota
  - Corpo: { company_id, vehicle_id, driver_id, inicio (ISO), km_inicial, origem }
  - Retorno: { id: route_id }
  - Permissão: routes.create

- PUT /api/v1/routes/{id}
  - Atualizar informações da rota (ex: km_final, destino, fim, status)
  - Permissão: routes.update

- POST /api/v1/routes/{id}/finish
  - Encerrar rota (convenção útil)
  - Corpo: { km_final, destino, fim (ISO) }
  - Permissão: routes.update

- DELETE /api/v1/routes/{id}
  - Permissão: routes.delete

---

### 11) GPS Entries
Base: /api/v1/gps-entries

- GET /api/v1/gps-entries
  - Lista pontos GPS (filtros: route_id, time range)
  - Paginação obrigatória (muito volume)
  - Permissão: routes.view

- GET /api/v1/gps-entries/{id}
  - Detalhes
  - Permissão: routes.view

- POST /api/v1/gps-entries
  - Inserir ponto GPS (expectativa: usado por mobile/device)
  - Corpo: { route_id, latitude, longitude, timestamp (ISO), velocidade?, altitude?, precisao? }
  - Permissão: routes.create (condutor) ou routes.ingest (device)

---

### 12) RBAC Management (roles / permissions / assignments)
Base: /api/v1/rbac

- GET /api/v1/rbac/roles
  - Lista roles
  - Permissão: system.config

- POST /api/v1/rbac/roles
  - Criar role
  - Corpo: { name, description }
  - Permissão: system.config

- GET /api/v1/rbac/permissions
  - Lista permissões
  - Permissão: system.config

- POST /api/v1/rbac/assign
  - Atribuir role/permission a user
  - Corpo: { item_name, user_id }
  - Permissão: system.config

---

### 13) Auth (Login / Logout / Refresh)
Base: /api/v1/auth

- POST /api/v1/auth/login
  - Corpo: { email, password }
  - Retorno: { access_token, expires_in, token_type }

- POST /api/v1/auth/logout
  - Header Authorization required

- POST /api/v1/auth/refresh
  - Refresh token flow (se implementado)

---

## Exemplos (curl)

- Login (obter token)

```bash
curl -X POST https://api.example.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@veigest.com","password":"secret"}'
```

- Listar veículos (com token)

```bash
curl -H "Authorization: Bearer <TOKEN>" \
  "https://api.example.com/api/v1/vehicles?page=1&pageSize=20"
```

- Iniciar rota

```bash
curl -X POST https://api.example.com/api/v1/routes \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"company_id":1,"vehicle_id":5,"driver_id":3,"inicio":"2025-11-07T08:00:00Z","km_inicial":120000,"origem":"Lisboa"}'
```

- Inserir ponto GPS (device/mobile)

```bash
curl -X POST https://api.example.com/api/v1/gps-entries \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"route_id":10,"latitude":38.7223,"longitude":-9.1393,"timestamp":"2025-11-07T08:05:10Z","velocidade":60.5}'
```

- Finalizar rota

```bash
curl -X POST https://api.example.com/api/v1/routes/10/finish \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"km_final":120050,"destino":"Porto","fim":"2025-11-07T10:30:00Z"}'
```

---

## Notas de Implementação (Yii2 Advanced)

- Organização
  - Criar módulo API: `api/modules/v1`
  - Controllers em `api/modules/v1/controllers`
  - Models podem reutilizar os ActiveRecord existentes ou criar DTOs/serializers

- Controllers
  - Para recursos simples: estender `yii\\rest\\ActiveController`
  - Para actions custom (ex: /routes/{id}/finish, upload): usar `actions()` e implementar `actionFinish()`

- Behaviors
  - Autenticação: `HttpBearerAuth` ou `CompositeAuth` (Bearer + QueryParam durante debug)
  - Rate limiter: `RateLimiter`
  - ContentNegotiator: garantir JSON
  - CORS: `Cors` behavior para mobile clients

- Filtragem, Ordenação, Paginação
  - Usar `yii\\data\\ActiveDataProvider` com `search` models (ex: RouteSearch)
  - Aceitar parâmetros: page, pageSize, sort, filters

- Uploads & Files
  - Endpoints de upload devem aceitar `multipart/form-data`
  - Usar `yii\\validators\\FileValidator` com limites (size, extensions)
  - Salvar ficheiros em storage (disk/local/S3) e registar em `files` com caminho e metadados mínimos

- GPS ingestion
  - Endpoint `/gps-entries` deve ser otimizado para alto volume
  - Aceitar batch insert (ex: array de pontos) para reduzir overhead
  - Validar e persistir com transações em lote

- RBAC
  - Usar `yii\\rbac\\DbManager` (tabelas já no schema)
  - Mapear controllers/actions para permissions (ex: `routes.create`)
  - Proteger endpoints com `AccessControl` ou checagens via `Yii::$app->user->can()`

- Migrations
  - Criar migrations para `routes` e `gps_entries` (se já não existirem)
  - Incluir índices (route_id, timestamp, company_id)

---

## Resumo e próximos passos

- Endpoints criados para todos os recursos principais da base de dados
- Sugerir implementação inicial com `ActiveController` e `search` models
- Recommendo criar testes de integração para: auth flows, upload, start/finish route, batch GPS ingestion

---

**Ficheiro gerado:** API_ENDPOINTS.md
