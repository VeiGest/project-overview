# API RESTful - VeiGest (v1)# API RESTful - VeiGest (v1)



**Versão:** 1.0  Versão: 1.0

**Data:** 8 de novembro de 2025  Data: 7 de novembro de 2025

**Padrão:** Yii2 Advanced - API module (api/modules/v1)  Padrão: Yii2 Advanced - API module (api/modules/v1)

**Autenticação:** Bearer token (JWT ou Yii2 auth)  Autenticação: Bearer token (JWT ou Yii2 auth)

**Formato:** JSON (application/json)  Formato: JSON (application/json)



## Resumo das convençõesResumo das convenções

- Namespace controllers: `api\modules\v1\controllers`- Namespace controllers: api\modules\v1\controllers

- Controllers seguem `ActiveController` (ou controllers personalizados quando necessário)- Controllers seguem ActiveController (ou controllers personalizados quando necessário)

- Rotas base: `/api/v1/<resource>`- Rotas base: /api/v1/<resource>

- Paginação: padrão `?page=1&pageSize=20`- Paginação: padrão ?page=1&pageSize=20

- Filtros via query string (ex: `?company_id=1&status=ativo`)- Filtros via query string (ex: ?company_id=1&status=ativo)

- Ordenação: `?sort=-created_at` (prefixo - = desc)- Ordenação: ?sort=-created_at (prefixo - = desc)

- Datas: ISO 8601 (UTC)- Datas: ISO 8601 (UTC)

- Permissões: controladas por RBAC (auth_item/auth_assignment)- Permissões: controladas por RBAC (auth_item/auth_assignment)



## AutenticaçãoAutenticação

- Header: `Authorization: Bearer <token>`- Header: Authorization: Bearer <token>

- Endpoints de autenticação (auth): `/api/v1/auth/login`, `/api/v1/auth/logout`, `/api/v1/auth/refresh`- Endpoints de autenticação (auth): /api/v1/auth/login, /api/v1/auth/logout, /api/v1/auth/refresh



------



## 1️⃣ Companies (Empresas)## Endpoints por recurso



| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |Para cada endpoint incluímos: método, URI, parâmetros principais, corpo de request (quando aplicável), exemplo de response (sucesso) e permissões RBAC sugeridas.

|-----------|----------|-----------|------------|--------|-----------------|

| GET | `/api/v1/companies` | Lista todas as empresas | `?page=1&pageSize=20&search=texto&estado=ativa&plano=basico` | N/A | ```json<br>{"items": [{"id": 1, "nome": "VeiGest Demo", "nif": "123456789", "email": "admin@veigest.com", "estado": "ativa", "plano": "basico"}], "_meta": {"totalCount": 1, "pageCount": 1, "currentPage": 1}}``` |---

| GET | `/api/v1/companies/{id}` | Detalhes de uma empresa | `id` (path) | N/A | ```json<br>{"id": 1, "nome": "VeiGest Demo", "nif": "123456789", "email": "admin@veigest.com", "telefone": "+351912345678", "estado": "ativa", "plano": "basico", "configuracoes": {"moeda": "EUR", "timezone": "Europe/Lisbon"}}``` |# API RESTful - VeiGest (v1)

| POST | `/api/v1/companies` | Criar nova empresa | N/A | ```json<br>{"nome": "Nova Empresa", "nif": "987654321", "email": "empresa@exemplo.com", "telefone": "+351987654321", "configuracoes": {"moeda": "EUR"}}``` | ```json<br>{"id": 2, "nome": "Nova Empresa", "nif": "987654321", "email": "empresa@exemplo.com", "created_at": "2025-11-08T10:00:00Z"}``` |

| PUT | `/api/v1/companies/{id}` | Atualizar empresa | `id` (path) | ```json<br>{"nome": "Empresa Atualizada", "email": "novo@exemplo.com", "configuracoes": {"moeda": "USD"}}``` | ```json<br>{"id": 2, "nome": "Empresa Atualizada", "email": "novo@exemplo.com", "updated_at": "2025-11-08T10:30:00Z"}``` |Versão: 1.0

| DELETE | `/api/v1/companies/{id}` | Remover empresa | `id` (path) | N/A | ```json<br>{"message": "Empresa removida com sucesso"}``` |Data: 7 de novembro de 2025

Padrão: Yii2 Advanced - API module (api/modules/v1)

---Autenticação: Bearer token (JWT ou Yii2 auth)

Formato: JSON (application/json)

## 2️⃣ Users (Utilizadores)

Resumo das convenções

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |- Namespace controllers: api\modules\v1\controllers

|-----------|----------|-----------|------------|--------|-----------------|- Controllers seguem ActiveController (ou controllers personalizados quando necessário)

| GET | `/api/v1/users` | Lista utilizadores | `?company_id=1&page=1&pageSize=20&estado=ativo&search=nome` | N/A | ```json<br>{"items": [{"id": 1, "nome": "João Silva", "email": "joao@veigest.com", "telefone": "+351912345678", "estado": "ativo", "numero_carta": "PT123456789", "validade_carta": "2026-12-31"}], "_meta": {"totalCount": 1}}``` |- Rotas base: /api/v1/<resource>

| GET | `/api/v1/users/{id}` | Detalhes do utilizador | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "nome": "João Silva", "email": "joao@veigest.com", "telefone": "+351912345678", "estado": "ativo", "numero_carta": "PT123456789", "validade_carta": "2026-12-31", "foto": "uploads/users/joao.jpg", "created_at": "2025-01-01T00:00:00Z"}``` |- Paginação: padrão ?page=1&pageSize=20

| POST | `/api/v1/users` | Criar utilizador | N/A | ```json<br>{"company_id": 1, "nome": "Maria Santos", "email": "maria@veigest.com", "senha": "minhasenha123", "telefone": "+351987654321", "numero_carta": "PT987654321", "validade_carta": "2027-06-30"}``` | ```json<br>{"id": 2, "nome": "Maria Santos", "email": "maria@veigest.com", "estado": "ativo", "created_at": "2025-11-08T10:00:00Z"}``` |- Filtros via query string (ex: ?company_id=1&status=ativo)

| PUT | `/api/v1/users/{id}` | Atualizar utilizador | `id` (path) | ```json<br>{"nome": "Maria Santos Silva", "telefone": "+351999888777", "validade_carta": "2028-06-30"}``` | ```json<br>{"id": 2, "nome": "Maria Santos Silva", "telefone": "+351999888777", "updated_at": "2025-11-08T10:30:00Z"}``` |- Ordenação: ?sort=-created_at (prefixo - = desc)

| PATCH | `/api/v1/users/{id}/password` | Alterar senha | `id` (path) | ```json<br>{"old_password": "senhaantiga", "new_password": "novaSenha123"}``` | ```json<br>{"message": "Senha alterada com sucesso"}``` |- Datas: ISO 8601 (UTC)

| POST | `/api/v1/users/{id}/assign-role` | Atribuir role | `id` (path) | ```json<br>{"role": "gestor"}``` | ```json<br>{"message": "Role 'gestor' atribuída ao utilizador"}``` |- Permissões: controladas por RBAC (auth_item/auth_assignment)

| DELETE | `/api/v1/users/{id}` | Remover utilizador | `id` (path) | N/A | ```json<br>{"message": "Utilizador removido com sucesso"}``` |

Autenticação

---- Header: Authorization: Bearer <token>

- Endpoints de autenticação (auth): /api/v1/auth/login, /api/v1/auth/logout, /api/v1/auth/refresh

## 3️⃣ Vehicles (Veículos)

---

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

|-----------|----------|-----------|------------|--------|-----------------|## Endpoints por recurso

| GET | `/api/v1/vehicles` | Lista veículos | `?company_id=1&condutor_id=2&estado=ativo&page=1` | N/A | ```json<br>{"items": [{"id": 1, "matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla", "ano": 2020, "tipo_combustivel": "gasolina", "quilometragem": 50000, "estado": "ativo", "condutor_id": 2}], "_meta": {"totalCount": 1}}``` |

| GET | `/api/v1/vehicles/{id}` | Detalhes do veículo | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla", "ano": 2020, "tipo_combustivel": "gasolina", "quilometragem": 50000, "estado": "ativo", "condutor_id": 2, "foto": "uploads/vehicles/aa11bb.jpg", "created_at": "2025-01-01T00:00:00Z"}``` |Para cada endpoint incluímos: método, URI, parâmetros principais, corpo de request (quando aplicável), exemplo de response (sucesso) e permissões RBAC sugeridas.

| POST | `/api/v1/vehicles` | Criar veículo | N/A | ```json<br>{"company_id": 1, "matricula": "CC-22-DD", "marca": "Honda", "modelo": "Civic", "ano": 2022, "tipo_combustivel": "hibrido", "quilometragem": 15000, "condutor_id": 3}``` | ```json<br>{"id": 2, "matricula": "CC-22-DD", "marca": "Honda", "modelo": "Civic", "estado": "ativo", "created_at": "2025-11-08T10:00:00Z"}``` |

| PUT | `/api/v1/vehicles/{id}` | Atualizar veículo | `id` (path) | ```json<br>{"quilometragem": 52000, "estado": "manutencao"}``` | ```json<br>{"id": 1, "quilometragem": 52000, "estado": "manutencao", "updated_at": "2025-11-08T10:30:00Z"}``` |---

| POST | `/api/v1/vehicles/{id}/assign-driver` | Atribuir condutor | `id` (path) | ```json<br>{"driver_id": 3}``` | ```json<br>{"message": "Condutor atribuído ao veículo com sucesso"}``` |

| DELETE | `/api/v1/vehicles/{id}` | Remover veículo | `id` (path) | N/A | ```json<br>{"message": "Veículo removido com sucesso"}``` |### 1) Companies

Base: /api/v1/companies

---

- GET /api/v1/companies

## 4️⃣ Maintenances (Manutenções)  - Descrição: Lista empresas (admin global / super-admin)

  - Query: ?page, ?pageSize, ?search, ?estado, ?plano

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Permissão: companies.view

|-----------|----------|-----------|------------|--------|-----------------|

| GET | `/api/v1/maintenances` | Lista manutenções | `?vehicle_id=1&company_id=1&page=1` | N/A | ```json<br>{"items": [{"id": 1, "vehicle_id": 1, "tipo": "Revisão", "descricao": "Revisão dos 50.000 km", "data": "2025-11-01", "custo": 250.50, "km_registro": 50000, "proxima_data": "2026-11-01", "oficina": "AutoCenter Lisboa"}], "_meta": {"totalCount": 1}}``` |- GET /api/v1/companies/{id}

| GET | `/api/v1/maintenances/{id}` | Detalhes da manutenção | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "vehicle_id": 1, "tipo": "Revisão", "descricao": "Revisão dos 50.000 km", "data": "2025-11-01", "custo": 250.50, "km_registro": 50000, "proxima_data": "2026-11-01", "oficina": "AutoCenter Lisboa", "created_at": "2025-11-01T14:30:00Z"}``` |  - Descrição: Detalhes da empresa

| POST | `/api/v1/maintenances` | Criar manutenção | N/A | ```json<br>{"company_id": 1, "vehicle_id": 1, "tipo": "Mudança de óleo", "descricao": "Troca do óleo do motor", "data": "2025-11-08", "custo": 75.00, "km_registro": 52000, "proxima_data": "2026-05-08", "oficina": "Oficina Central"}``` | ```json<br>{"id": 2, "vehicle_id": 1, "tipo": "Mudança de óleo", "data": "2025-11-08", "custo": 75.00, "created_at": "2025-11-08T10:00:00Z"}``` |  - Permissão: companies.view

| PUT | `/api/v1/maintenances/{id}` | Atualizar manutenção | `id` (path) | ```json<br>{"custo": 280.00, "proxima_data": "2026-12-01"}``` | ```json<br>{"id": 1, "custo": 280.00, "proxima_data": "2026-12-01", "updated_at": "2025-11-08T10:30:00Z"}``` |

| DELETE | `/api/v1/maintenances/{id}` | Remover manutenção | `id` (path) | N/A | ```json<br>{"message": "Manutenção removida com sucesso"}``` |- POST /api/v1/companies

  - Descrição: Criar empresa

---  - Corpo: { nome, nif, email, telefone, configuracoes }

  - Permissão: companies.manage

## 5️⃣ Files (Ficheiros)

- PUT /api/v1/companies/{id}

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Descrição: Atualizar empresa

|-----------|----------|-----------|------------|--------|-----------------|  - Corpo: { nome?, nif?, email?, configuracoes? }

| GET | `/api/v1/files` | Lista ficheiros | `?company_id=1&page=1&pageSize=20` | N/A | ```json<br>{"items": [{"id": 1, "nome_original": "seguro_veiculo.pdf", "tamanho": 1024576, "caminho": "uploads/2025/11/seguro_veiculo.pdf", "uploaded_by": 1, "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}``` |  - Permissão: companies.manage

| GET | `/api/v1/files/{id}` | Download/metadados | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "nome_original": "seguro_veiculo.pdf", "tamanho": 1024576, "caminho": "uploads/2025/11/seguro_veiculo.pdf", "uploaded_by": 1, "download_url": "/api/v1/files/1/download", "created_at": "2025-11-08T10:00:00Z"}``` |

| POST | `/api/v1/files` | Upload ficheiro | `company_id` (form), `uploaded_by` (form) | **Multipart Form Data:**<br>`file` (binary)<br>`company_id=1`<br>`uploaded_by=1` | ```json<br>{"id": 2, "nome_original": "inspecao_2025.pdf", "tamanho": 2048576, "caminho": "uploads/2025/11/inspecao_2025.pdf", "created_at": "2025-11-08T10:30:00Z"}``` |- DELETE /api/v1/companies/{id}

| DELETE | `/api/v1/files/{id}` | Remover ficheiro | `id` (path) | N/A | ```json<br>{"message": "Ficheiro removido com sucesso"}``` |  - Descrição: Remover empresa

  - Permissão: companies.manage

---

---

## 6️⃣ Documents (Documentos)

### 2) Users

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |Base: /api/v1/users

|-----------|----------|-----------|------------|--------|-----------------|

| GET | `/api/v1/documents` | Lista documentos | `?company_id=1&vehicle_id=1&driver_id=2&tipo=seguro&status=valido` | N/A | ```json<br>{"items": [{"id": 1, "file_id": 1, "vehicle_id": 1, "driver_id": null, "tipo": "seguro", "data_validade": "2026-12-31", "status": "valido", "notas": "Seguro contra terceiros"}], "_meta": {"totalCount": 1}}``` |- GET /api/v1/users

| GET | `/api/v1/documents/{id}` | Detalhes do documento | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "file_id": 1, "vehicle_id": 1, "driver_id": null, "tipo": "seguro", "data_validade": "2026-12-31", "status": "valido", "notas": "Seguro contra terceiros", "file": {"nome_original": "seguro_veiculo.pdf", "download_url": "/api/v1/files/1/download"}, "created_at": "2025-11-08T10:00:00Z"}``` |  - Lista utilizadores (filtro por company_id)

| POST | `/api/v1/documents` | Criar documento | N/A | ```json<br>{"company_id": 1, "file_id": 2, "vehicle_id": 1, "tipo": "inspecao", "data_validade": "2026-11-08", "notas": "Inspeção periódica obrigatória"}``` | ```json<br>{"id": 2, "file_id": 2, "vehicle_id": 1, "tipo": "inspecao", "data_validade": "2026-11-08", "status": "valido", "created_at": "2025-11-08T10:30:00Z"}``` |  - Permissão: users.view

| PUT | `/api/v1/documents/{id}` | Atualizar documento | `id` (path) | ```json<br>{"data_validade": "2027-01-15", "notas": "Renovação antecipada"}``` | ```json<br>{"id": 2, "data_validade": "2027-01-15", "notas": "Renovação antecipada", "updated_at": "2025-11-08T11:00:00Z"}``` |

| DELETE | `/api/v1/documents/{id}` | Remover documento | `id` (path) | N/A | ```json<br>{"message": "Documento removido com sucesso"}``` |- GET /api/v1/users/{id}

  - Detalhes do utilizador

---  - Permissão: users.view



## 7️⃣ Fuel Logs (Registos de Combustível)- POST /api/v1/users

  - Criar utilizador

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Corpo: { company_id, nome, email, senha, telefone, numero_carta?, validade_carta? }

|-----------|----------|-----------|------------|--------|-----------------|  - Permissão: users.create

| GET | `/api/v1/fuel-logs` | Lista registos de combustível | `?company_id=1&vehicle_id=1&driver_id=2&data_inicio=2025-11-01&data_fim=2025-11-08` | N/A | ```json<br>{"items": [{"id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-05", "litros": 45.5, "valor": 68.25, "preco_litro": 1.50, "km_atual": 51500, "notas": "Posto Galp A1"}], "_meta": {"totalCount": 1}}``` |

| GET | `/api/v1/fuel-logs/{id}` | Detalhes do registo | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-05", "litros": 45.5, "valor": 68.25, "preco_litro": 1.50, "km_atual": 51500, "notas": "Posto Galp A1", "vehicle": {"matricula": "AA-11-BB"}, "driver": {"nome": "João Silva"}, "created_at": "2025-11-05T16:30:00Z"}``` |- PUT /api/v1/users/{id}

| POST | `/api/v1/fuel-logs` | Criar registo de combustível | N/A | ```json<br>{"company_id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-08", "litros": 50.0, "valor": 75.00, "km_atual": 52000, "notas": "Posto BP Cascais"}``` | ```json<br>{"id": 2, "vehicle_id": 1, "data": "2025-11-08", "litros": 50.0, "valor": 75.00, "preco_litro": 1.50, "created_at": "2025-11-08T11:00:00Z"}``` |  - Atualizar utilizador

| PUT | `/api/v1/fuel-logs/{id}` | Atualizar registo | `id` (path) | ```json<br>{"valor": 72.50, "notas": "Posto BP Cascais - Desconto cliente"}``` | ```json<br>{"id": 2, "valor": 72.50, "preco_litro": 1.45, "notas": "Posto BP Cascais - Desconto cliente", "updated_at": "2025-11-08T11:15:00Z"}``` |  - Corpo: { nome?, email?, telefone?, numero_carta?, validade_carta?, estado? }

| DELETE | `/api/v1/fuel-logs/{id}` | Remover registo | `id` (path) | N/A | ```json<br>{"message": "Registo de combustível removido com sucesso"}``` |  - Permissão: users.update



---- PATCH /api/v1/users/{id}/password

  - Atualizar senha (requere a senha antiga ou token de reset)

## 8️⃣ Alerts (Alertas)  - Corpo: { old_password?, new_password }

  - Permissão: users.update

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

|-----------|----------|-----------|------------|--------|-----------------|- DELETE /api/v1/users/{id}

| GET | `/api/v1/alerts` | Lista alertas | `?company_id=1&tipo=documento&status=ativo&prioridade=alta` | N/A | ```json<br>{"items": [{"id": 1, "tipo": "documento", "titulo": "Documento a expirar", "descricao": "Seguro do veículo AA-11-BB expira em 30 dias", "prioridade": "alta", "status": "ativo", "detalhes": {"vehicle_id": 1, "document_id": 1}, "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}``` |  - Remover utilizador

| GET | `/api/v1/alerts/{id}` | Detalhes do alerta | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "tipo": "documento", "titulo": "Documento a expirar", "descricao": "Seguro do veículo AA-11-BB expira em 30 dias", "prioridade": "alta", "status": "ativo", "detalhes": {"vehicle_id": 1, "document_id": 1, "data_validade": "2025-12-08"}, "created_at": "2025-11-08T10:00:00Z", "resolvido_em": null}``` |  - Permissão: users.delete

| POST | `/api/v1/alerts` | Criar alerta manual | N/A | ```json<br>{"company_id": 1, "tipo": "manutencao", "titulo": "Manutenção agendada", "descricao": "Revisão agendada para veículo CC-22-DD", "prioridade": "media", "detalhes": {"vehicle_id": 2, "data_agendada": "2025-11-15"}}``` | ```json<br>{"id": 2, "tipo": "manutencao", "titulo": "Manutenção agendada", "status": "ativo", "created_at": "2025-11-08T11:00:00Z"}``` |

| PUT | `/api/v1/alerts/{id}` | Atualizar alerta | `id` (path) | ```json<br>{"status": "resolvido", "resolvido_em": "2025-11-08T11:30:00Z"}``` | ```json<br>{"id": 1, "status": "resolvido", "resolvido_em": "2025-11-08T11:30:00Z", "updated_at": "2025-11-08T11:30:00Z"}``` |- POST /api/v1/users/{id}/assign-role

| DELETE | `/api/v1/alerts/{id}` | Remover alerta | `id` (path) | N/A | ```json<br>{"message": "Alerta removido com sucesso"}``` |  - Atribuir role (admin only)

  - Corpo: { role: "gestor" }

---  - Permissão: users.manage-roles



## 9️⃣ Activity Logs (Logs de Atividade)---



| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |### 3) Vehicles

|-----------|----------|-----------|------------|--------|-----------------|Base: /api/v1/vehicles

| GET | `/api/v1/activity-logs` | Lista logs de atividade | `?company_id=1&user_id=2&entidade=vehicle&page=1&pageSize=50` | N/A | ```json<br>{"items": [{"id": 1, "user_id": 2, "acao": "CREATE", "entidade": "vehicle", "entidade_id": 1, "detalhes": {"matricula": "AA-11-BB", "marca": "Toyota"}, "ip": "192.168.1.100", "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}``` |

| GET | `/api/v1/activity-logs/{id}` | Detalhes do log | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "user_id": 2, "acao": "CREATE", "entidade": "vehicle", "entidade_id": 1, "detalhes": {"matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla"}, "ip": "192.168.1.100", "user": {"nome": "João Silva"}, "created_at": "2025-11-08T10:00:00Z"}``` |- GET /api/v1/vehicles

  - Lista veículos (filtros: company_id, condutor_id, estado)

---  - Permissão: vehicles.view



## 🔟 Routes (Rotas)- GET /api/v1/vehicles/{id}

  - Detalhes do veículo

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Permissão: vehicles.view

|-----------|----------|-----------|------------|--------|-----------------|

| GET | `/api/v1/routes` | Lista rotas | `?company_id=1&vehicle_id=1&driver_id=2&status=em_andamento&data_inicio=2025-11-01` | N/A | ```json<br>{"items": [{"id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T08:00:00Z", "fim": "2025-11-08T10:30:00Z", "km_inicial": 52000, "km_final": 52150, "origem": "Lisboa", "destino": "Porto", "status": "concluida", "distancia_km": 150.5}], "_meta": {"totalCount": 1}}``` |- POST /api/v1/vehicles

| GET | `/api/v1/routes/{id}` | Detalhes da rota | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T08:00:00Z", "fim": "2025-11-08T10:30:00Z", "km_inicial": 52000, "km_final": 52150, "origem": "Lisboa", "destino": "Porto", "distancia_km": 150.5, "status": "concluida", "notas": "Viagem sem incidentes", "vehicle": {"matricula": "AA-11-BB"}, "driver": {"nome": "João Silva"}, "total_gps_points": 180, "created_at": "2025-11-08T08:00:00Z"}``` |  - Criar veículo

| POST | `/api/v1/routes` | Iniciar nova rota | N/A | ```json<br>{"company_id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T14:00:00Z", "km_inicial": 52150, "origem": "Porto"}``` | ```json<br>{"id": 2, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T14:00:00Z", "km_inicial": 52150, "origem": "Porto", "status": "em_andamento", "created_at": "2025-11-08T14:00:00Z"}``` |  - Corpo: { company_id, matricula, marca, modelo, ano, tipo_combustivel, quilometragem, condutor_id? }

| PUT | `/api/v1/routes/{id}` | Atualizar rota | `id` (path) | ```json<br>{"km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z", "status": "concluida"}``` | ```json<br>{"id": 2, "km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z", "status": "concluida", "updated_at": "2025-11-08T16:00:00Z"}``` |  - Permissão: vehicles.create

| POST | `/api/v1/routes/{id}/finish` | Encerrar rota | `id` (path) | ```json<br>{"km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z"}``` | ```json<br>{"message": "Rota encerrada com sucesso", "route": {"id": 2, "status": "concluida", "fim": "2025-11-08T16:00:00Z"}}``` |

| DELETE | `/api/v1/routes/{id}` | Remover rota | `id` (path) | N/A | ```json<br>{"message": "Rota removida com sucesso"}``` |- PUT /api/v1/vehicles/{id}

  - Atualizar

---  - Permissão: vehicles.update



## 1️⃣1️⃣ GPS Entries (Pontos GPS)- DELETE /api/v1/vehicles/{id}

  - Remover

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Permissão: vehicles.delete

|-----------|----------|-----------|------------|--------|-----------------|

| GET | `/api/v1/gps-entries` | Lista pontos GPS | `?route_id=1&timestamp_inicio=2025-11-08T08:00:00Z&timestamp_fim=2025-11-08T10:30:00Z&page=1&pageSize=100` | N/A | ```json<br>{"items": [{"id": 1, "route_id": 1, "latitude": 38.7223, "longitude": -9.1393, "timestamp": "2025-11-08T08:15:00Z", "velocidade": 60.5, "altitude": 150.2, "precisao": 5.0}], "_meta": {"totalCount": 180, "pageCount": 2}}``` |- POST /api/v1/vehicles/{id}/assign-driver

| GET | `/api/v1/gps-entries/{id}` | Detalhes do ponto GPS | `id` (path) | N/A | ```json<br>{"id": 1, "route_id": 1, "latitude": 38.7223, "longitude": -9.1393, "timestamp": "2025-11-08T08:15:00Z", "velocidade": 60.5, "altitude": 150.2, "precisao": 5.0, "route": {"id": 1, "vehicle_id": 1, "origem": "Lisboa"}}``` |  - Atribuir condutor

| POST | `/api/v1/gps-entries` | Inserir ponto GPS | N/A | ```json<br>{"route_id": 2, "latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0, "altitude": 200.5, "precisao": 3.0}``` | ```json<br>{"id": 181, "route_id": 2, "latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0}``` |  - Corpo: { driver_id }

| POST | `/api/v1/gps-entries/batch` | Inserir múltiplos pontos GPS | N/A | ```json<br>{"route_id": 2, "points": [{"latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0}, {"latitude": 40.2100, "longitude": -8.4200, "timestamp": "2025-11-08T14:31:00Z", "velocidade": 75.0}]}``` | ```json<br>{"message": "2 pontos GPS inseridos com sucesso", "inserted_ids": [182, 183]}``` |  - Permissão: vehicles.assign



------



## 1️⃣2️⃣ RBAC Management### 4) Maintenances

Base: /api/v1/maintenances

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

|-----------|----------|-----------|------------|--------|-----------------|- GET /api/v1/maintenances

| GET | `/api/v1/rbac/roles` | Lista roles | N/A | N/A | ```json<br>{"items": [{"name": "super-admin", "description": "Super Administrador - Acesso Total", "type": 1}, {"name": "admin", "description": "Administrador", "type": 1}, {"name": "gestor", "description": "Gestor de Frota", "type": 1}]}``` |  - Lista manutenções (filtros: vehicle_id, company_id, status)

| GET | `/api/v1/rbac/permissions` | Lista permissões | N/A | N/A | ```json<br>{"items": [{"name": "companies.view", "description": "Ver empresas", "type": 2}, {"name": "vehicles.create", "description": "Criar veículos", "type": 2}]}``` |  - Permissão: maintenances.view

| GET | `/api/v1/rbac/user-assignments/{user_id}` | Lista atribuições do utilizador | `user_id` (path) | N/A | ```json<br>{"user_id": "2", "assignments": [{"item_name": "gestor", "created_at": 1699459200}]}``` |

| POST | `/api/v1/rbac/roles` | Criar role | N/A | ```json<br>{"name": "tecnico", "description": "Técnico de Manutenção"}``` | ```json<br>{"name": "tecnico", "description": "Técnico de Manutenção", "type": 1, "created_at": 1699545600}``` |- GET /api/v1/maintenances/{id}

| POST | `/api/v1/rbac/assign` | Atribuir role/permission | N/A | ```json<br>{"item_name": "gestor", "user_id": "3"}``` | ```json<br>{"message": "Role 'gestor' atribuída ao utilizador 3 com sucesso"}``` |  - Detalhes

| DELETE | `/api/v1/rbac/revoke` | Revogar role/permission | N/A | ```json<br>{"item_name": "gestor", "user_id": "3"}``` | ```json<br>{"message": "Role 'gestor' revogada do utilizador 3 com sucesso"}``` |  - Permissão: maintenances.view



---- POST /api/v1/maintenances

  - Criar

## 1️⃣3️⃣ Authentication (Autenticação)  - Corpo: { company_id, vehicle_id, tipo, descricao, data, custo, km_registro, proxima_data }

  - Permissão: maintenances.create

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

|-----------|----------|-----------|------------|--------|-----------------|- PUT /api/v1/maintenances/{id}

| POST | `/api/v1/auth/login` | Login do utilizador | N/A | ```json<br>{"email": "joao@veigest.com", "password": "minhasenha123"}``` | ```json<br>{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...", "token_type": "Bearer", "expires_in": 3600, "user": {"id": 2, "nome": "João Silva", "email": "joao@veigest.com", "roles": ["gestor"]}}``` |  - Atualizar

| POST | `/api/v1/auth/logout` | Logout do utilizador | Header: `Authorization: Bearer <token>` | N/A | ```json<br>{"message": "Logout realizado com sucesso"}``` |  - Permissão: maintenances.update

| POST | `/api/v1/auth/refresh` | Renovar token | Header: `Authorization: Bearer <token>` | N/A | ```json<br>{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...", "token_type": "Bearer", "expires_in": 3600}``` |

| GET | `/api/v1/auth/me` | Perfil do utilizador autenticado | Header: `Authorization: Bearer <token>` | N/A | ```json<br>{"id": 2, "nome": "João Silva", "email": "joao@veigest.com", "company": {"id": 1, "nome": "VeiGest Demo"}, "roles": ["gestor"], "permissions": ["vehicles.view", "vehicles.create"]}``` |- DELETE /api/v1/maintenances/{id}

  - Remover

---  - Permissão: maintenances.delete



## 📋 Códigos de Estado HTTP---



| Código | Descrição | Exemplo de Uso |### 5) Files

|--------|-----------|----------------|Base: /api/v1/files

| 200 | OK | Sucesso em GET, PUT |

| 201 | Created | Sucesso em POST (criação) |- GET /api/v1/files

| 204 | No Content | Sucesso em DELETE |  - Lista ficheiros por company_id

| 400 | Bad Request | Dados inválidos no pedido |  - Permissão: files.view

| 401 | Unauthorized | Token ausente ou inválido |

| 403 | Forbidden | Sem permissão para o recurso |- GET /api/v1/files/{id}

| 404 | Not Found | Recurso não encontrado |  - Download/meta

| 409 | Conflict | Conflito (ex: email duplicado) |  - Permissão: files.view

| 422 | Unprocessable Entity | Erro de validação |

| 429 | Too Many Requests | Rate limiting |- POST /api/v1/files (multipart/form-data)

| 500 | Internal Server Error | Erro interno do servidor |  - Upload

  - Campos: file (binary), company_id, uploaded_by

---  - Permissão: files.upload



## 📚 Exemplos de Uso (curl)- DELETE /api/v1/files/{id}

  - Permissão: files.delete

### Login e obtenção de token

```bash---

curl -X POST https://api.veigest.com/api/v1/auth/login \

  -H "Content-Type: application/json" \### 6) Documents

  -d '{"email":"joao@veigest.com","password":"minhasenha123"}'Base: /api/v1/documents

```

- GET /api/v1/documents

### Listar veículos com paginação  - Lista (filtros: company_id, vehicle_id, driver_id, tipo, status)

```bash  - Permissão: documents.view

curl -H "Authorization: Bearer <TOKEN>" \

  "https://api.veigest.com/api/v1/vehicles?page=1&pageSize=10&company_id=1"- GET /api/v1/documents/{id}

```  - Detalhes

  - Permissão: documents.view

### Criar um novo veículo

```bash- POST /api/v1/documents

curl -X POST https://api.veigest.com/api/v1/vehicles \  - Criar documento associado a ficheiro

  -H "Authorization: Bearer <TOKEN>" \  - Corpo: { company_id, file_id, vehicle_id?, driver_id?, tipo, data_validade?, notas }

  -H "Content-Type: application/json" \  - Permissão: documents.create

  -d '{"company_id":1,"matricula":"EE-33-FF","marca":"BMW","modelo":"320d","ano":2023,"tipo_combustivel":"diesel","quilometragem":5000}'

```- PUT /api/v1/documents/{id}

  - Atualizar

### Upload de ficheiro (documento)  - Permissão: documents.update

```bash

curl -X POST https://api.veigest.com/api/v1/files \- DELETE /api/v1/documents/{id}

  -H "Authorization: Bearer <TOKEN>" \  - Permissão: documents.delete

  -F "file=@seguro_veiculo.pdf" \

  -F "company_id=1" \---

  -F "uploaded_by=2"

```### 7) Fuel Logs

Base: /api/v1/fuel-logs

### Iniciar uma rota

```bash- GET /api/v1/fuel-logs

curl -X POST https://api.veigest.com/api/v1/routes \  - Lista registos de combustível (filtros: company_id, vehicle_id, driver_id, date range)

  -H "Authorization: Bearer <TOKEN>" \  - Permissão: fuel.view

  -H "Content-Type: application/json" \

  -d '{"company_id":1,"vehicle_id":1,"driver_id":2,"inicio":"2025-11-08T08:00:00Z","km_inicial":52000,"origem":"Lisboa"}'- GET /api/v1/fuel-logs/{id}

```  - Detalhes

  - Permissão: fuel.view

### Inserir pontos GPS em lote

```bash- POST /api/v1/fuel-logs

curl -X POST https://api.veigest.com/api/v1/gps-entries/batch \  - Criar registo de combustível

  -H "Authorization: Bearer <TOKEN>" \  - Corpo: { company_id, vehicle_id, driver_id?, data, litros, valor, km_atual?, notas? }

  -H "Content-Type: application/json" \  - Permissão: fuel.create

  -d '{"route_id":1,"points":[{"latitude":38.7223,"longitude":-9.1393,"timestamp":"2025-11-08T08:15:00Z","velocidade":60.5},{"latitude":38.7300,"longitude":-9.1500,"timestamp":"2025-11-08T08:20:00Z","velocidade":65.0}]}'

```- PUT /api/v1/fuel-logs/{id}

  - Atualizar

---  - Permissão: fuel.update



## 🔧 Notas de Implementação (Yii2 Advanced)- DELETE /api/v1/fuel-logs/{id}

  - Permissão: fuel.delete

### Estrutura do Projeto

```---

api/

├── modules/### 8) Alerts

│   └── v1/Base: /api/v1/alerts

│       ├── controllers/

│       │   ├── CompanyController.php- GET /api/v1/alerts

│       │   ├── UserController.php  - Lista alertas (filtros: company_id, tipo, status)

│       │   ├── VehicleController.php  - Permissão: alerts.view

│       │   └── ...

│       ├── models/- GET /api/v1/alerts/{id}

│       └── Module.php  - Detalhes

├── config/  - Permissão: alerts.view

└── web/

```- POST /api/v1/alerts

  - Criar alerta manual

### Configuração Básica  - Corpo: { company_id, tipo, titulo, descricao?, detalhes?, prioridade? }

```php  - Permissão: alerts.create

// api/modules/v1/Module.php

public function init()- PUT /api/v1/alerts/{id}

{  - Atualizar (ex: marcar resolvido)

    parent::init();  - Permissão: alerts.resolve

    \Yii::$app->user->enableSession = false;

}- DELETE /api/v1/alerts/{id}

```  - Permissão: alerts.create



### Controller Exemplo (VehicleController)---

```php

class VehicleController extends ActiveController### 9) Activity Logs

{Base: /api/v1/activity-logs

    public $modelClass = 'common\models\Vehicle';

    - GET /api/v1/activity-logs

    public function behaviors()  - Lista logs (filtros: company_id, user_id, entidade)

    {  - Permissão: system.logs

        return ArrayHelper::merge(parent::behaviors(), [

            'authenticator' => [- GET /api/v1/activity-logs/{id}

                'class' => HttpBearerAuth::class,  - Detalhes

            ],  - Permissão: system.logs

            'rateLimiter' => [

                'class' => RateLimiter::class,---

            ],

        ]);### 10) Routes (Rotas)

    }Base: /api/v1/routes

    

    public function actions()- GET /api/v1/routes

    {  - Lista rotas (filtros: company_id, vehicle_id, driver_id, status, periodo)

        $actions = parent::actions();  - Permissão: routes.view

        $actions['index']['dataFilter'] = [

            'class' => ActiveDataFilter::class,- GET /api/v1/routes/{id}

            'searchModel' => VehicleSearch::class,  - Detalhes da rota (inclui resumo) — considerar retornar link para pontos GPS paginados

        ];  - Permissão: routes.view

        return $actions;

    }- POST /api/v1/routes

}  - Iniciar nova rota

```  - Corpo: { company_id, vehicle_id, driver_id, inicio (ISO), km_inicial, origem }

  - Retorno: { id: route_id }

---  - Permissão: routes.create



**Ficheiro completo:** API_ENDPOINTS.md  - PUT /api/v1/routes/{id}

**Última atualização:** 8 de novembro de 2025  - Atualizar informações da rota (ex: km_final, destino, fim, status)
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