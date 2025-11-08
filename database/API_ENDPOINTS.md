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
  - HTTP Verb: GET
  - Endpoint: /api/v1/companies
  - Descrição: Lista empresas (admin global / super-admin)
  - Parâmetros: ?page, ?pageSize, ?search, ?estado, ?plano
  - Pedido: N/A
  - Resposta (JSON):
    { "items": [{ "id":1, "nome":"ACME" }], "total": 1, "page":1, "pageSize":20 }

- GET /api/v1/companies/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/companies/{id}
  - Descrição: Detalhes da empresa
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":1, "nome":"ACME", "nif":"123456789", "email":"a@acme.com" }

- POST /api/v1/companies
  - HTTP Verb: POST
  - Endpoint: /api/v1/companies
  - Descrição: Criar empresa
  - Parâmetros: N/A
  - Pedido:
    { "nome":"Nova Empresa", "nif":"999999999", "email":"contato@nova.com" }
  - Resposta (JSON):
    { "id": 42, "nome":"Nova Empresa", "nif":"999999999" }

- PUT /api/v1/companies/{id}
  - HTTP Verb: PUT
  - Endpoint: /api/v1/companies/{id}
  - Descrição: Atualizar empresa
  - Parâmetros: path: id
  - Pedido:
    { "nome":"Empresa Atualizada", "configuracoes": { "timezone":"UTC" } }
  - Resposta (JSON):
    { "id":42, "nome":"Empresa Atualizada" }

- DELETE /api/v1/companies/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/companies/{id}
  - Descrição: Remover empresa
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

---

### 2) Users
Base: /api/v1/users

- GET /api/v1/users
  - HTTP Verb: GET
  - Endpoint: /api/v1/users
  - Descrição: Lista utilizadores (filtro por company_id)
  - Parâmetros: ?company_id, ?page, ?pageSize, ?search
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":1,"nome":"João"}], "total":1 }

- GET /api/v1/users/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/users/{id}
  - Descrição: Detalhes do utilizador
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":1, "nome":"João", "email":"joao@ex.com" }

- POST /api/v1/users
  - HTTP Verb: POST
  - Endpoint: /api/v1/users
  - Descrição: Criar utilizador
  - Parâmetros: N/A
  - Pedido:
    { "company_id":1, "nome":"Ana", "email":"ana@ex.com", "senha":"secret" }
  - Resposta (JSON):
    { "id":10, "company_id":1, "nome":"Ana" }

- PUT /api/v1/users/{id}
  - HTTP Verb: PUT
  - Endpoint: /api/v1/users/{id}
  - Descrição: Atualizar utilizador
  - Parâmetros: path: id
  - Pedido:
    { "nome":"Ana Silva", "telefone":"912345678" }
  - Resposta (JSON):
    { "id":10, "nome":"Ana Silva" }

- PATCH /api/v1/users/{id}/password
  - HTTP Verb: PATCH
  - Endpoint: /api/v1/users/{id}/password
  - Descrição: Atualizar senha
  - Parâmetros: path: id
  - Pedido:
    { "old_password":"old","new_password":"newsecret" }
  - Resposta (JSON):
    { "success": true }

- DELETE /api/v1/users/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/users/{id}
  - Descrição: Remover utilizador
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

- POST /api/v1/users/{id}/assign-role
  - HTTP Verb: POST
  - Endpoint: /api/v1/users/{id}/assign-role
  - Descrição: Atribuir role
  - Parâmetros: path: id
  - Pedido:
    { "role":"gestor" }
  - Resposta (JSON):
    { "user_id":1, "role":"gestor" }

---

### 3) Vehicles
Base: /api/v1/vehicles

- GET /api/v1/vehicles
  - HTTP Verb: GET
  - Endpoint: /api/v1/vehicles
  - Descrição: Lista veículos
  - Parâmetros: ?company_id, ?condutor_id, ?estado, ?page
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":5,"matricula":"00-AA-00"}], "total":1 }

- GET /api/v1/vehicles/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/vehicles/{id}
  - Descrição: Detalhes do veículo
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":5, "matricula":"00-AA-00", "marca":"Fiat" }

- POST /api/v1/vehicles
  - HTTP Verb: POST
  - Endpoint: /api/v1/vehicles
  - Descrição: Criar veículo
  - Parâmetros: N/A
  - Pedido:
    { "company_id":1, "matricula":"00-AA-00", "marca":"Fiat", "modelo":"Punto", "ano":2018 }
  - Resposta (JSON):
    { "id":77, "matricula":"00-AA-00" }

- PUT /api/v1/vehicles/{id}
  - HTTP Verb: PUT
  - Endpoint: /api/v1/vehicles/{id}
  - Descrição: Atualizar veículo
  - Parâmetros: path: id
  - Pedido:
    { "quilometragem": 123456 }
  - Resposta (JSON):
    { "id":77, "quilometragem":123456 }

- DELETE /api/v1/vehicles/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/vehicles/{id}
  - Descrição: Remover veículo
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

- POST /api/v1/vehicles/{id}/assign-driver
  - HTTP Verb: POST
  - Endpoint: /api/v1/vehicles/{id}/assign-driver
  - Descrição: Atribuir condutor
  - Parâmetros: path: id
  - Pedido:
    { "driver_id":3 }
  - Resposta (JSON):
    { "vehicle_id":5, "driver_id":3 }

---

### 4) Maintenances
Base: /api/v1/maintenances

- GET /api/v1/maintenances
  - HTTP Verb: GET
  - Endpoint: /api/v1/maintenances
  - Descrição: Lista manutenções
  - Parâmetros: ?vehicle_id, ?company_id, ?status, ?page
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":2,"tipo":"Troca de óleo"}], "total":1 }

- GET /api/v1/maintenances/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/maintenances/{id}
  - Descrição: Detalhes
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":2, "vehicle_id":5, "tipo":"Troca de óleo", "custo":50.0 }

- POST /api/v1/maintenances
  - HTTP Verb: POST
  - Endpoint: /api/v1/maintenances
  - Descrição: Criar manutenção
  - Parâmetros: N/A
  - Pedido:
    { "company_id":1, "vehicle_id":5, "tipo":"Inspeção", "data":"2025-11-07", "custo":120.0 }
  - Resposta (JSON):
    { "id":11, "tipo":"Inspeção" }

- PUT /api/v1/maintenances/{id}
  - HTTP Verb: PUT
  - Endpoint: /api/v1/maintenances/{id}
  - Descrição: Atualizar manutenção
  - Parâmetros: path: id
  - Pedido:
    { "status":"concluida", "custo":130.0 }
  - Resposta (JSON):
    { "id":11, "status":"concluida" }

- DELETE /api/v1/maintenances/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/maintenances/{id}
  - Descrição: Remover manutenção
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

---

### 5) Files
Base: /api/v1/files

- GET /api/v1/files
  - HTTP Verb: GET
  - Endpoint: /api/v1/files
  - Descrição: Lista ficheiros por company_id
  - Parâmetros: ?company_id, ?page
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":3,"filename":"doc.pdf"}], "total":1 }

- GET /api/v1/files/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/files/{id}
  - Descrição: Download/meta
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":3, "filename":"doc.pdf", "url":"/storage/doc.pdf" }

- POST /api/v1/files
  - HTTP Verb: POST (multipart/form-data)
  - Endpoint: /api/v1/files
  - Descrição: Upload
  - Parâmetros: form-data: file, company_id, uploaded_by
  - Pedido: multipart form com file binário
  - Resposta (JSON):
    { "id":45, "filename":"upload.jpg", "company_id":1 }

- DELETE /api/v1/files/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/files/{id}
  - Descrição: Remover ficheiro
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

---

### 6) Documents
Base: /api/v1/documents

- GET /api/v1/documents
  - HTTP Verb: GET
  - Endpoint: /api/v1/documents
  - Descrição: Lista documentos
  - Parâmetros: ?company_id, ?vehicle_id, ?driver_id, ?tipo, ?status
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":7,"tipo":"Seguro"}], "total":1 }

- GET /api/v1/documents/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/documents/{id}
  - Descrição: Detalhes
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":7, "tipo":"Seguro", "validade":"2026-01-01" }

- POST /api/v1/documents
  - HTTP Verb: POST
  - Endpoint: /api/v1/documents
  - Descrição: Criar documento associado a ficheiro
  - Parâmetros: N/A
  - Pedido:
    { "company_id":1, "file_id":45, "tipo":"Seguro", "data_validade":"2026-01-01" }
  - Resposta (JSON):
    { "id":88, "tipo":"Seguro" }

- PUT /api/v1/documents/{id}
  - HTTP Verb: PUT
  - Endpoint: /api/v1/documents/{id}
  - Descrição: Atualizar documento
  - Parâmetros: path: id
  - Pedido:
    { "notas":"Renovado" }
  - Resposta (JSON):
    { "id":88, "notas":"Renovado" }

- DELETE /api/v1/documents/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/documents/{id}
  - Descrição: Remover documento
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

---

### 7) Fuel Logs
Base: /api/v1/fuel-logs

- GET /api/v1/fuel-logs
  - HTTP Verb: GET
  - Endpoint: /api/v1/fuel-logs
  - Descrição: Lista registos de combustível
  - Parâmetros: ?company_id, ?vehicle_id, ?driver_id, ?from, ?to
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":1,"litros":50}], "total":1 }

- GET /api/v1/fuel-logs/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/fuel-logs/{id}
  - Descrição: Detalhes
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":1, "litros":50, "valor":75.0 }

- POST /api/v1/fuel-logs
  - HTTP Verb: POST
  - Endpoint: /api/v1/fuel-logs
  - Descrição: Criar registo de combustível
  - Parâmetros: N/A
  - Pedido:
    { "company_id":1, "vehicle_id":5, "data":"2025-11-07", "litros":50, "valor":75.0 }
  - Resposta (JSON):
    { "id":200, "litros":50 }

- PUT /api/v1/fuel-logs/{id}
  - HTTP Verb: PUT
  - Endpoint: /api/v1/fuel-logs/{id}
  - Descrição: Atualizar registo
  - Parâmetros: path: id
  - Pedido:
    { "litros":52 }
  - Resposta (JSON):
    { "id":200, "litros":52 }

- DELETE /api/v1/fuel-logs/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/fuel-logs/{id}
  - Descrição: Remover registo
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

---

### 8) Alerts
Base: /api/v1/alerts

- GET /api/v1/alerts
  - HTTP Verb: GET
  - Endpoint: /api/v1/alerts
  - Descrição: Lista alertas
  - Parâmetros: ?company_id, ?tipo, ?status
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":3,"titulo":"Pneu baixo"}], "total":1 }

- GET /api/v1/alerts/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/alerts/{id}
  - Descrição: Detalhes
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":3, "titulo":"Pneu baixo", "prioridade":"alta" }

- POST /api/v1/alerts
  - HTTP Verb: POST
  - Endpoint: /api/v1/alerts
  - Descrição: Criar alerta manual
  - Parâmetros: N/A
  - Pedido:
    { "company_id":1, "tipo":"manutencao", "titulo":"Revisão" }
  - Resposta (JSON):
    { "id":55, "titulo":"Revisão" }

- PUT /api/v1/alerts/{id}
  - HTTP Verb: PUT
  - Endpoint: /api/v1/alerts/{id}
  - Descrição: Atualizar (ex: marcar resolvido)
  - Parâmetros: path: id
  - Pedido:
    { "status":"resolvido" }
  - Resposta (JSON):
    { "id":55, "status":"resolvido" }

- DELETE /api/v1/alerts/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/alerts/{id}
  - Descrição: Remover alerta
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

---

### 9) Activity Logs
Base: /api/v1/activity-logs

- GET /api/v1/activity-logs
  - HTTP Verb: GET
  - Endpoint: /api/v1/activity-logs
  - Descrição: Lista logs
  - Parâmetros: ?company_id, ?user_id, ?entidade
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":1,"action":"login"}], "total":1 }

- GET /api/v1/activity-logs/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/activity-logs/{id}
  - Descrição: Detalhes
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":1, "action":"login", "user_id":2, "timestamp":"2025-11-07T08:00:00Z" }

---

### 10) Routes (Rotas)
Base: /api/v1/routes

- GET /api/v1/routes
  - HTTP Verb: GET
  - Endpoint: /api/v1/routes
  - Descrição: Lista rotas
  - Parâmetros: ?company_id, ?vehicle_id, ?driver_id, ?status, ?periodo
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":10,"status":"ativa"}], "total":1 }

- GET /api/v1/routes/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/routes/{id}
  - Descrição: Detalhes da rota
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":10, "vehicle_id":5, "resumo":{ "km":50 } }

- POST /api/v1/routes
  - HTTP Verb: POST
  - Endpoint: /api/v1/routes
  - Descrição: Iniciar nova rota
  - Parâmetros: N/A
  - Pedido:
    { "company_id":1, "vehicle_id":5, "driver_id":3, "inicio":"2025-11-07T08:00:00Z", "km_inicial":120000, "origem":"Lisboa" }
  - Resposta (JSON):
    { "id":10 }

- PUT /api/v1/routes/{id}
  - HTTP Verb: PUT
  - Endpoint: /api/v1/routes/{id}
  - Descrição: Atualizar informações da rota
  - Parâmetros: path: id
  - Pedido:
    { "km_final":120050, "destino":"Porto" }
  - Resposta (JSON):
    { "id":10, "km_final":120050 }

- POST /api/v1/routes/{id}/finish
  - HTTP Verb: POST
  - Endpoint: /api/v1/routes/{id}/finish
  - Descrição: Encerrar rota
  - Parâmetros: path: id
  - Pedido:
    { "km_final":120050, "destino":"Porto", "fim":"2025-11-07T10:30:00Z" }
  - Resposta (JSON):
    { "id":10, "status":"fechada" }

- DELETE /api/v1/routes/{id}
  - HTTP Verb: DELETE
  - Endpoint: /api/v1/routes/{id}
  - Descrição: Remover rota
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "success": true }

---

### 11) GPS Entries
Base: /api/v1/gps-entries

- GET /api/v1/gps-entries
  - HTTP Verb: GET
  - Endpoint: /api/v1/gps-entries
  - Descrição: Lista pontos GPS (paginação obrigatória)
  - Parâmetros: ?route_id, ?from, ?to, ?page, ?pageSize
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"id":100,"latitude":38.7223,"longitude":-9.1393,"timestamp":"2025-11-07T08:05:10Z"}], "total":1 }

- GET /api/v1/gps-entries/{id}
  - HTTP Verb: GET
  - Endpoint: /api/v1/gps-entries/{id}
  - Descrição: Detalhes
  - Parâmetros: path: id
  - Pedido: N/A
  - Resposta (JSON):
    { "id":100, "latitude":38.7223, "longitude":-9.1393, "timestamp":"2025-11-07T08:05:10Z" }

- POST /api/v1/gps-entries
  - HTTP Verb: POST
  - Endpoint: /api/v1/gps-entries
  - Descrição: Inserir ponto GPS (aceita batch)
  - Parâmetros: N/A
  - Pedido (single ou array):
    { "route_id":10, "latitude":38.7223, "longitude":-9.1393, "timestamp":"2025-11-07T08:05:10Z", "velocidade":60.5 }
  - Resposta (JSON):
    { "inserted": 1 }

---

### 12) RBAC Management (roles / permissions / assignments)
Base: /api/v1/rbac

- GET /api/v1/rbac/roles
  - HTTP Verb: GET
  - Endpoint: /api/v1/rbac/roles
  - Descrição: Lista roles
  - Parâmetros: ?page
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"name":"admin"}], "total":1 }

- POST /api/v1/rbac/roles
  - HTTP Verb: POST
  - Endpoint: /api/v1/rbac/roles
  - Descrição: Criar role
  - Parâmetros: N/A
  - Pedido:
    { "name":"gestor", "description":"Gestor de frota" }
  - Resposta (JSON):
    { "name":"gestor" }

- GET /api/v1/rbac/permissions
  - HTTP Verb: GET
  - Endpoint: /api/v1/rbac/permissions
  - Descrição: Lista permissões
  - Parâmetros: ?page
  - Pedido: N/A
  - Resposta (JSON):
    { "items":[{"name":"vehicles.view"}], "total":1 }

- POST /api/v1/rbac/assign
  - HTTP Verb: POST
  - Endpoint: /api/v1/rbac/assign
  - Descrição: Atribuir role/permission a user
  - Parâmetros: N
