# API RESTful - VeiGest (v1)# API RESTful - VeiGest (v1)# API RESTful - VeiGest (v1)



**Versão:** 1.0  

**Data:** 8 de novembro de 2025  

**Padrão:** Yii2 Advanced - API module (api/modules/v1)  **Versão:** 1.0  **Versão:** 1.0  

**Autenticação:** Bearer token (JWT ou Yii2 auth)  

**Formato:** JSON (application/json)  **Data:** 8 de novembro de 2025  **Data:** 8 de novembro de 2025  

**Base de Dados:** VeiGest Ultra-Lean (12 tabelas principais + 4 RBAC + 4 views)

**Padrão:** Yii2 Advanced - API module (api/modules/v1)  **Padrão:** Yii2 Advanced - API module (api/modules/v1)  

## 📋 Resumo das convenções

- **Namespace controllers:** `api\modules\v1\controllers`**Autenticação:** Bearer token (JWT ou Yii2 auth)  **Autenticação:** Bearer token (JWT ou Yii2 auth)  

- **Controllers:** seguem `ActiveController` (ou controllers personalizados quando necessário)

- **Rotas base:** `/api/v1/<resource>`**Formato:** JSON (application/json)**Formato:** JSON (application/json)  

- **Paginação:** padrão `?page=1&pageSize=20`

- **Filtros:** via query string (ex: `?company_id=1&estado=ativa`)

- **Ordenação:** `?sort=-created_at` (prefixo - = desc)

- **Datas:** ISO 8601 (UTC)## Resumo das convenções## Resumo das convenções

- **Permissões:** controladas por RBAC nativo Yii2 (auth_item/auth_assignment)

- **Multi-empresa:** todos os recursos são filtrados por `company_id`- Namespace controllers: `api\modules\v1\controllers`- Namespace controllers: `api\modules\v1\controllers`



## 🔐 Autenticação e RBAC- Controllers seguem `ActiveController` (ou controllers personalizados quando necessário)- Controllers seguem `ActiveController` (ou controllers personalizados quando necessário)

- **Header:** `Authorization: Bearer <token>`

- **Endpoints:** `/api/v1/auth/login`, `/api/v1/auth/logout`, `/api/v1/auth/refresh`, `/api/v1/auth/me`- Rotas base: `/api/v1/<resource>`- Rotas base: `/api/v1/<resource>`

- **RBAC Roles:** super-admin, admin, gestor, gestor-manutencao, condutor-senior, condutor

- **Permissões:** 40+ permissões granulares por módulo (companies.view, vehicles.create, etc.)- Paginação: padrão `?page=1&pageSize=20`- Paginação: padrão `?page=1&pageSize=20`



---- Filtros via query string (ex: `?company_id=1&status=ativo`)- Filtros via query string (ex: `?company_id=1&status=ativo`)



# 📚 Endpoints por Recurso- Ordenação: `?sort=-created_at` (prefixo - = desc)- Ordenação: `?sort=-created_at` (prefixo - = desc)



## 1️⃣ Companies (Empresas)- Datas: ISO 8601 (UTC)- Datas: ISO 8601 (UTC)

*Base: tabela `companies` - gestão multi-empresa*

- Permissões: controladas por RBAC (auth_item/auth_assignment)- Permissões: controladas por RBAC (auth_item/auth_assignment)

### GET `/api/v1/companies`

- **Descrição:** Lista todas as empresas

- **Permissões:** `companies.view`

- **Parâmetros de query:**## Autenticação## Autenticação

  - `page` (int): Número da página (padrão: 1)

  - `pageSize` (int): Items por página (padrão: 20, max: 100)- Header: `Authorization: Bearer <token>`- Header: `Authorization: Bearer <token>`

  - `search` (string): Pesquisa por nome ou NIF

  - `estado` (enum): ativa, suspensa, inativa- Endpoints de autenticação (auth): `/api/v1/auth/login`, `/api/v1/auth/logout`, `/api/v1/auth/refresh`- Endpoints de autenticação (auth): `/api/v1/auth/login`, `/api/v1/auth/logout`, `/api/v1/auth/refresh`

  - `plano` (enum): basico, profissional, enterprise

- **Resposta de sucesso (200):**

```json

{------

  "items": [

    {

      "id": 1,

      "nome": "VeiGest - Empresa Demo",## 1️⃣ Companies (Empresas)## 1️⃣ Companies (Empresas)

      "nif": "999999990",

      "email": "admin@veigest.com",

      "telefone": null,

      "estado": "ativa",| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

      "plano": "enterprise",

      "configuracoes": {|-----------|----------|-----------|------------|--------|-----------------|

        "moeda": "EUR",

        "timezone": "Europe/Lisbon",| GET | `/api/v1/companies` | Lista todas as empresas | `?page=1&pageSize=20&search=texto&estado=ativa&plano=basico` | N/A | `{"items": [{"id": 1, "nome": "VeiGest Demo", "nif": "123456789", "email": "admin@veigest.com", "estado": "ativa", "plano": "basico"}], "_meta": {"totalCount": 1, "pageCount": 1, "currentPage": 1}}` || HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |Para cada endpoint incluímos: método, URI, parâmetros principais, corpo de request (quando aplicável), exemplo de response (sucesso) e permissões RBAC sugeridas.

        "idioma": "pt",

        "alertas_email": true,| GET | `/api/v1/companies/{id}` | Detalhes de uma empresa | `id` (path) | N/A | `{"id": 1, "nome": "VeiGest Demo", "nif": "123456789", "email": "admin@veigest.com", "telefone": "+351912345678", "estado": "ativa", "plano": "basico", "configuracoes": {"moeda": "EUR", "timezone": "Europe/Lisbon"}}` |

        "dias_alerta_documentos": 30

      },| POST | `/api/v1/companies` | Criar nova empresa | N/A | `{"nome": "Nova Empresa", "nif": "987654321", "email": "empresa@exemplo.com", "telefone": "+351987654321", "configuracoes": {"moeda": "EUR"}}` | `{"id": 2, "nome": "Nova Empresa", "nif": "987654321", "email": "empresa@exemplo.com", "created_at": "2025-11-08T10:00:00Z"}` ||-----------|----------|-----------|------------|--------|-----------------|

      "created_at": "2025-11-08T10:00:00Z",

      "updated_at": "2025-11-08T10:00:00Z"| PUT | `/api/v1/companies/{id}` | Atualizar empresa | `id` (path) | `{"nome": "Empresa Atualizada", "email": "novo@exemplo.com", "configuracoes": {"moeda": "USD"}}` | `{"id": 2, "nome": "Empresa Atualizada", "email": "novo@exemplo.com", "updated_at": "2025-11-08T10:30:00Z"}` |

    }

  ],| DELETE | `/api/v1/companies/{id}` | Remover empresa | `id` (path) | N/A | `{"message": "Empresa removida com sucesso"}` || GET | `/api/v1/companies` | Lista todas as empresas | `?page=1&pageSize=20&search=texto&estado=ativa&plano=basico` | N/A | ```json<br>{"items": [{"id": 1, "nome": "VeiGest Demo", "nif": "123456789", "email": "admin@veigest.com", "estado": "ativa", "plano": "basico"}], "_meta": {"totalCount": 1, "pageCount": 1, "currentPage": 1}}``` |---

  "_meta": {

    "totalCount": 1,

    "pageCount": 1,

    "currentPage": 1,---| GET | `/api/v1/companies/{id}` | Detalhes de uma empresa | `id` (path) | N/A | ```json<br>{"id": 1, "nome": "VeiGest Demo", "nif": "123456789", "email": "admin@veigest.com", "telefone": "+351912345678", "estado": "ativa", "plano": "basico", "configuracoes": {"moeda": "EUR", "timezone": "Europe/Lisbon"}}``` |# API RESTful - VeiGest (v1)

    "perPage": 20

  }

}

```## 2️⃣ Users (Utilizadores)| POST | `/api/v1/companies` | Criar nova empresa | N/A | ```json<br>{"nome": "Nova Empresa", "nif": "987654321", "email": "empresa@exemplo.com", "telefone": "+351987654321", "configuracoes": {"moeda": "EUR"}}``` | ```json<br>{"id": 2, "nome": "Nova Empresa", "nif": "987654321", "email": "empresa@exemplo.com", "created_at": "2025-11-08T10:00:00Z"}``` |



### GET `/api/v1/companies/{id}`

- **Descrição:** Detalhes de uma empresa específica

- **Permissões:** `companies.view`| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) || PUT | `/api/v1/companies/{id}` | Atualizar empresa | `id` (path) | ```json<br>{"nome": "Empresa Atualizada", "email": "novo@exemplo.com", "configuracoes": {"moeda": "USD"}}``` | ```json<br>{"id": 2, "nome": "Empresa Atualizada", "email": "novo@exemplo.com", "updated_at": "2025-11-08T10:30:00Z"}``` |Versão: 1.0

- **Parâmetros de rota:** `id` (int, obrigatório)

- **Resposta de sucesso (200):** Objeto company completo com estatísticas|-----------|----------|-----------|------------|--------|-----------------|

- **Resposta de erro (404):** Company not found

| GET | `/api/v1/users` | Lista utilizadores | `?company_id=1&page=1&pageSize=20&estado=ativo&search=nome` | N/A | `{"items": [{"id": 1, "nome": "João Silva", "email": "joao@veigest.com", "telefone": "+351912345678", "estado": "ativo", "numero_carta": "PT123456789", "validade_carta": "2026-12-31"}], "_meta": {"totalCount": 1}}` || DELETE | `/api/v1/companies/{id}` | Remover empresa | `id` (path) | N/A | ```json<br>{"message": "Empresa removida com sucesso"}``` |Data: 7 de novembro de 2025

### POST `/api/v1/companies`

- **Descrição:** Criar nova empresa| GET | `/api/v1/users/{id}` | Detalhes do utilizador | `id` (path) | N/A | `{"id": 1, "company_id": 1, "nome": "João Silva", "email": "joao@veigest.com", "telefone": "+351912345678", "estado": "ativo", "numero_carta": "PT123456789", "validade_carta": "2026-12-31", "foto": "uploads/users/joao.jpg", "created_at": "2025-01-01T00:00:00Z"}` |

- **Permissões:** `companies.manage` (apenas super-admin)

- **Corpo da requisição:**| POST | `/api/v1/users` | Criar utilizador | N/A | `{"company_id": 1, "nome": "Maria Santos", "email": "maria@veigest.com", "senha": "minhasenha123", "telefone": "+351987654321", "numero_carta": "PT987654321", "validade_carta": "2027-06-30"}` | `{"id": 2, "nome": "Maria Santos", "email": "maria@veigest.com", "estado": "ativo", "created_at": "2025-11-08T10:00:00Z"}` |Padrão: Yii2 Advanced - API module (api/modules/v1)

```json

{| PUT | `/api/v1/users/{id}` | Atualizar utilizador | `id` (path) | `{"nome": "Maria Santos Silva", "telefone": "+351999888777", "validade_carta": "2028-06-30"}` | `{"id": 2, "nome": "Maria Santos Silva", "telefone": "+351999888777", "updated_at": "2025-11-08T10:30:00Z"}` |

  "nome": "Nova Empresa Lda",

  "nif": "123456789",| PATCH | `/api/v1/users/{id}/password` | Alterar senha | `id` (path) | `{"old_password": "senhaantiga", "new_password": "novaSenha123"}` | `{"message": "Senha alterada com sucesso"}` |---Autenticação: Bearer token (JWT ou Yii2 auth)

  "email": "contato@novaempresa.com",

  "telefone": "+351912345678",| POST | `/api/v1/users/{id}/assign-role` | Atribuir role | `id` (path) | `{"role": "gestor"}` | `{"message": "Role 'gestor' atribuída ao utilizador"}` |

  "plano": "profissional",

  "configuracoes": {| DELETE | `/api/v1/users/{id}` | Remover utilizador | `id` (path) | N/A | `{"message": "Utilizador removido com sucesso"}` |Formato: JSON (application/json)

    "moeda": "EUR",

    "timezone": "Europe/Lisbon",

    "idioma": "pt"

  }---## 2️⃣ Users (Utilizadores)

}

```

- **Resposta de sucesso (201):** Objeto company criado

- **Validações:** NIF único, email válido, plano válido## 3️⃣ Vehicles (Veículos)Resumo das convenções



### PUT `/api/v1/companies/{id}`

- **Descrição:** Atualizar empresa existente

- **Permissões:** `companies.manage`| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) || HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |- Namespace controllers: api\modules\v1\controllers

- **Parâmetros de rota:** `id` (int)

- **Corpo da requisição:** Campos a atualizar (parcial)|-----------|----------|-----------|------------|--------|-----------------|

- **Resposta de sucesso (200):** Objeto company atualizado

| GET | `/api/v1/vehicles` | Lista veículos | `?company_id=1&condutor_id=2&estado=ativo&page=1` | N/A | `{"items": [{"id": 1, "matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla", "ano": 2020, "tipo_combustivel": "gasolina", "quilometragem": 50000, "estado": "ativo", "condutor_id": 2}], "_meta": {"totalCount": 1}}` ||-----------|----------|-----------|------------|--------|-----------------|- Controllers seguem ActiveController (ou controllers personalizados quando necessário)

### DELETE `/api/v1/companies/{id}`

- **Descrição:** Remover empresa (soft delete - marca como inativa)| GET | `/api/v1/vehicles/{id}` | Detalhes do veículo | `id` (path) | N/A | `{"id": 1, "company_id": 1, "matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla", "ano": 2020, "tipo_combustivel": "gasolina", "quilometragem": 50000, "estado": "ativo", "condutor_id": 2, "foto": "uploads/vehicles/aa11bb.jpg", "created_at": "2025-01-01T00:00:00Z"}` |

- **Permissões:** `companies.manage` (apenas super-admin)

- **Parâmetros de rota:** `id` (int)| POST | `/api/v1/vehicles` | Criar veículo | N/A | `{"company_id": 1, "matricula": "CC-22-DD", "marca": "Honda", "modelo": "Civic", "ano": 2022, "tipo_combustivel": "hibrido", "quilometragem": 15000, "condutor_id": 3}` | `{"id": 2, "matricula": "CC-22-DD", "marca": "Honda", "modelo": "Civic", "estado": "ativo", "created_at": "2025-11-08T10:00:00Z"}` || GET | `/api/v1/users` | Lista utilizadores | `?company_id=1&page=1&pageSize=20&estado=ativo&search=nome` | N/A | ```json<br>{"items": [{"id": 1, "nome": "João Silva", "email": "joao@veigest.com", "telefone": "+351912345678", "estado": "ativo", "numero_carta": "PT123456789", "validade_carta": "2026-12-31"}], "_meta": {"totalCount": 1}}``` |- Rotas base: /api/v1/<resource>

- **Resposta de sucesso (204):** No content

| PUT | `/api/v1/vehicles/{id}` | Atualizar veículo | `id` (path) | `{"quilometragem": 52000, "estado": "manutencao"}` | `{"id": 1, "quilometragem": 52000, "estado": "manutencao", "updated_at": "2025-11-08T10:30:00Z"}` |

---

| POST | `/api/v1/vehicles/{id}/assign-driver` | Atribuir condutor | `id` (path) | `{"driver_id": 3}` | `{"message": "Condutor atribuído ao veículo com sucesso"}` || GET | `/api/v1/users/{id}` | Detalhes do utilizador | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "nome": "João Silva", "email": "joao@veigest.com", "telefone": "+351912345678", "estado": "ativo", "numero_carta": "PT123456789", "validade_carta": "2026-12-31", "foto": "uploads/users/joao.jpg", "created_at": "2025-01-01T00:00:00Z"}``` |- Paginação: padrão ?page=1&pageSize=20

## 2️⃣ Users (Utilizadores)

*Base: tabela `users` - utilizadores com perfil condutor integrado*| DELETE | `/api/v1/vehicles/{id}` | Remover veículo | `id` (path) | N/A | `{"message": "Veículo removido com sucesso"}` |



### GET `/api/v1/users`| POST | `/api/v1/users` | Criar utilizador | N/A | ```json<br>{"company_id": 1, "nome": "Maria Santos", "email": "maria@veigest.com", "senha": "minhasenha123", "telefone": "+351987654321", "numero_carta": "PT987654321", "validade_carta": "2027-06-30"}``` | ```json<br>{"id": 2, "nome": "Maria Santos", "email": "maria@veigest.com", "estado": "ativo", "created_at": "2025-11-08T10:00:00Z"}``` |- Filtros via query string (ex: ?company_id=1&status=ativo)

- **Descrição:** Lista utilizadores da empresa

- **Permissões:** `users.view`---

- **Parâmetros de query:**

  - `company_id` (int): ID da empresa (obrigatório se não super-admin)| PUT | `/api/v1/users/{id}` | Atualizar utilizador | `id` (path) | ```json<br>{"nome": "Maria Santos Silva", "telefone": "+351999888777", "validade_carta": "2028-06-30"}``` | ```json<br>{"id": 2, "nome": "Maria Santos Silva", "telefone": "+351999888777", "updated_at": "2025-11-08T10:30:00Z"}``` |- Ordenação: ?sort=-created_at (prefixo - = desc)

  - `page`, `pageSize`: Paginação

  - `search` (string): Pesquisa por nome ou email## 4️⃣ Maintenances (Manutenções)

  - `estado` (enum): ativo, inativo

  - `is_driver` (bool): Filtrar apenas condutores (com numero_carta)| PATCH | `/api/v1/users/{id}/password` | Alterar senha | `id` (path) | ```json<br>{"old_password": "senhaantiga", "new_password": "novaSenha123"}``` | ```json<br>{"message": "Senha alterada com sucesso"}``` |- Datas: ISO 8601 (UTC)

  - `carta_expiring` (int): Condutores com carta a expirar em X dias

- **Resposta de sucesso (200):** Lista de utilizadores com informações de condutor| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |



### GET `/api/v1/users/{id}`|-----------|----------|-----------|------------|--------|-----------------|| POST | `/api/v1/users/{id}/assign-role` | Atribuir role | `id` (path) | ```json<br>{"role": "gestor"}``` | ```json<br>{"message": "Role 'gestor' atribuída ao utilizador"}``` |- Permissões: controladas por RBAC (auth_item/auth_assignment)

- **Descrição:** Detalhes do utilizador

- **Permissões:** `users.view` + same company| GET | `/api/v1/maintenances` | Lista manutenções | `?vehicle_id=1&company_id=1&page=1` | N/A | `{"items": [{"id": 1, "vehicle_id": 1, "tipo": "Revisão", "descricao": "Revisão dos 50.000 km", "data": "2025-11-01", "custo": 250.50, "km_registro": 50000, "proxima_data": "2026-11-01", "oficina": "AutoCenter Lisboa"}], "_meta": {"totalCount": 1}}` |

- **Parâmetros de rota:** `id` (int)

- **Resposta inclui:** Dados pessoais, perfil condutor, roles RBAC, empresa| GET | `/api/v1/maintenances/{id}` | Detalhes da manutenção | `id` (path) | N/A | `{"id": 1, "company_id": 1, "vehicle_id": 1, "tipo": "Revisão", "descricao": "Revisão dos 50.000 km", "data": "2025-11-01", "custo": 250.50, "km_registro": 50000, "proxima_data": "2026-11-01", "oficina": "AutoCenter Lisboa", "created_at": "2025-11-01T14:30:00Z"}` || DELETE | `/api/v1/users/{id}` | Remover utilizador | `id` (path) | N/A | ```json<br>{"message": "Utilizador removido com sucesso"}``` |



### POST `/api/v1/users`| POST | `/api/v1/maintenances` | Criar manutenção | N/A | `{"company_id": 1, "vehicle_id": 1, "tipo": "Mudança de óleo", "descricao": "Troca do óleo do motor", "data": "2025-11-08", "custo": 75.00, "km_registro": 52000, "proxima_data": "2026-05-08", "oficina": "Oficina Central"}` | `{"id": 2, "vehicle_id": 1, "tipo": "Mudança de óleo", "data": "2025-11-08", "custo": 75.00, "created_at": "2025-11-08T10:00:00Z"}` |

- **Descrição:** Criar novo utilizador

- **Permissões:** `users.create`| PUT | `/api/v1/maintenances/{id}` | Atualizar manutenção | `id` (path) | `{"custo": 280.00, "proxima_data": "2026-12-01"}` | `{"id": 1, "custo": 280.00, "proxima_data": "2026-12-01", "updated_at": "2025-11-08T10:30:00Z"}` |Autenticação

- **Corpo da requisição:**

```json| DELETE | `/api/v1/maintenances/{id}` | Remover manutenção | `id` (path) | N/A | `{"message": "Manutenção removida com sucesso"}` |

{

  "company_id": 1,---- Header: Authorization: Bearer <token>

  "nome": "João Silva",

  "email": "joao.silva@empresa.com",---

  "senha": "minhasenha123",

  "telefone": "+351912345678",- Endpoints de autenticação (auth): /api/v1/auth/login, /api/v1/auth/logout, /api/v1/auth/refresh

  "estado": "ativo",

  "numero_carta": "PT123456789",## 5️⃣ Files (Ficheiros)

  "validade_carta": "2026-12-31",

  "foto": "path/to/photo.jpg"## 3️⃣ Vehicles (Veículos)

}

```| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

- **Validações:** Email único por empresa, senha forte, carta válida se condutor

|-----------|----------|-----------|------------|--------|-----------------|---

### PUT `/api/v1/users/{id}`

- **Descrição:** Atualizar utilizador| GET | `/api/v1/files` | Lista ficheiros | `?company_id=1&page=1&pageSize=20` | N/A | `{"items": [{"id": 1, "nome_original": "seguro_veiculo.pdf", "tamanho": 1024576, "caminho": "uploads/2025/11/seguro_veiculo.pdf", "uploaded_by": 1, "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}` |

- **Permissões:** `users.update` + same company

- **Validações:** Não permite alterar company_id, email deve ser único| GET | `/api/v1/files/{id}` | Download/metadados | `id` (path) | N/A | `{"id": 1, "company_id": 1, "nome_original": "seguro_veiculo.pdf", "tamanho": 1024576, "caminho": "uploads/2025/11/seguro_veiculo.pdf", "uploaded_by": 1, "download_url": "/api/v1/files/1/download", "created_at": "2025-11-08T10:00:00Z"}` || HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |



### PATCH `/api/v1/users/{id}/password`| POST | `/api/v1/files` | Upload ficheiro | `company_id` (form), `uploaded_by` (form) | Multipart Form: `file` (binary), `company_id=1`, `uploaded_by=1` | `{"id": 2, "nome_original": "inspecao_2025.pdf", "tamanho": 2048576, "caminho": "uploads/2025/11/inspecao_2025.pdf", "created_at": "2025-11-08T10:30:00Z"}` |

- **Descrição:** Alterar senha do utilizador

- **Permissões:** Próprio utilizador ou `users.update`| DELETE | `/api/v1/files/{id}` | Remover ficheiro | `id` (path) | N/A | `{"message": "Ficheiro removido com sucesso"}` ||-----------|----------|-----------|------------|--------|-----------------|## Endpoints por recurso

- **Corpo da requisição:**

```json

{

  "old_password": "senhaantiga",---| GET | `/api/v1/vehicles` | Lista veículos | `?company_id=1&condutor_id=2&estado=ativo&page=1` | N/A | ```json<br>{"items": [{"id": 1, "matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla", "ano": 2020, "tipo_combustivel": "gasolina", "quilometragem": 50000, "estado": "ativo", "condutor_id": 2}], "_meta": {"totalCount": 1}}``` |

  "new_password": "novasenha123"

}

```

## 6️⃣ Documents (Documentos)| GET | `/api/v1/vehicles/{id}` | Detalhes do veículo | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla", "ano": 2020, "tipo_combustivel": "gasolina", "quilometragem": 50000, "estado": "ativo", "condutor_id": 2, "foto": "uploads/vehicles/aa11bb.jpg", "created_at": "2025-01-01T00:00:00Z"}``` |Para cada endpoint incluímos: método, URI, parâmetros principais, corpo de request (quando aplicável), exemplo de response (sucesso) e permissões RBAC sugeridas.

### POST `/api/v1/users/{id}/assign-role`

- **Descrição:** Atribuir role RBAC ao utilizador

- **Permissões:** `users.manage-roles`

- **Corpo da requisição:**| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) || POST | `/api/v1/vehicles` | Criar veículo | N/A | ```json<br>{"company_id": 1, "matricula": "CC-22-DD", "marca": "Honda", "modelo": "Civic", "ano": 2022, "tipo_combustivel": "hibrido", "quilometragem": 15000, "condutor_id": 3}``` | ```json<br>{"id": 2, "matricula": "CC-22-DD", "marca": "Honda", "modelo": "Civic", "estado": "ativo", "created_at": "2025-11-08T10:00:00Z"}``` |

```json

{|-----------|----------|-----------|------------|--------|-----------------|

  "role": "gestor"

}| GET | `/api/v1/documents` | Lista documentos | `?company_id=1&vehicle_id=1&driver_id=2&tipo=seguro&status=valido` | N/A | `{"items": [{"id": 1, "file_id": 1, "vehicle_id": 1, "driver_id": null, "tipo": "seguro", "data_validade": "2026-12-31", "status": "valido", "notas": "Seguro contra terceiros"}], "_meta": {"totalCount": 1}}` || PUT | `/api/v1/vehicles/{id}` | Atualizar veículo | `id` (path) | ```json<br>{"quilometragem": 52000, "estado": "manutencao"}``` | ```json<br>{"id": 1, "quilometragem": 52000, "estado": "manutencao", "updated_at": "2025-11-08T10:30:00Z"}``` |---

```

| GET | `/api/v1/documents/{id}` | Detalhes do documento | `id` (path) | N/A | `{"id": 1, "company_id": 1, "file_id": 1, "vehicle_id": 1, "driver_id": null, "tipo": "seguro", "data_validade": "2026-12-31", "status": "valido", "notas": "Seguro contra terceiros", "file": {"nome_original": "seguro_veiculo.pdf", "download_url": "/api/v1/files/1/download"}, "created_at": "2025-11-08T10:00:00Z"}` |

### DELETE `/api/v1/users/{id}`

- **Descrição:** Desativar utilizador| POST | `/api/v1/documents` | Criar documento | N/A | `{"company_id": 1, "file_id": 2, "vehicle_id": 1, "tipo": "inspecao", "data_validade": "2026-11-08", "notas": "Inspeção periódica obrigatória"}` | `{"id": 2, "file_id": 2, "vehicle_id": 1, "tipo": "inspecao", "data_validade": "2026-11-08", "status": "valido", "created_at": "2025-11-08T10:30:00Z"}` || POST | `/api/v1/vehicles/{id}/assign-driver` | Atribuir condutor | `id` (path) | ```json<br>{"driver_id": 3}``` | ```json<br>{"message": "Condutor atribuído ao veículo com sucesso"}``` |

- **Permissões:** `users.delete`

- **Nota:** Soft delete - marca estado como 'inativo'| PUT | `/api/v1/documents/{id}` | Atualizar documento | `id` (path) | `{"data_validade": "2027-01-15", "notas": "Renovação antecipada"}` | `{"id": 2, "data_validade": "2027-01-15", "notas": "Renovação antecipada", "updated_at": "2025-11-08T11:00:00Z"}` |



---| DELETE | `/api/v1/documents/{id}` | Remover documento | `id` (path) | N/A | `{"message": "Documento removido com sucesso"}` || DELETE | `/api/v1/vehicles/{id}` | Remover veículo | `id` (path) | N/A | ```json<br>{"message": "Veículo removido com sucesso"}``` |### 1) Companies



## 3️⃣ Vehicles (Veículos)

*Base: tabela `vehicles` - gestão da frota*

---Base: /api/v1/companies

### GET `/api/v1/vehicles`

- **Descrição:** Lista veículos da empresa

- **Permissões:** `vehicles.view`

- **Parâmetros de query:**## 7️⃣ Fuel Logs (Registos de Combustível)---

  - `company_id` (int): Filtro por empresa

  - `condutor_id` (int): Veículos atribuídos ao condutor

  - `estado` (enum): ativo, manutencao, inativo

  - `marca` (string): Filtro por marca| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |- GET /api/v1/companies

  - `tipo_combustivel` (enum): gasolina, diesel, eletrico, hibrido, outro

  - `ano_min`, `ano_max` (int): Filtro por ano|-----------|----------|-----------|------------|--------|-----------------|

- **Resposta inclui:** Dados do veículo, condutor atribuído, estatísticas básicas

| GET | `/api/v1/fuel-logs` | Lista registos de combustível | `?company_id=1&vehicle_id=1&driver_id=2&data_inicio=2025-11-01&data_fim=2025-11-08` | N/A | `{"items": [{"id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-05", "litros": 45.5, "valor": 68.25, "preco_litro": 1.50, "km_atual": 51500, "notas": "Posto Galp A1"}], "_meta": {"totalCount": 1}}` |## 4️⃣ Maintenances (Manutenções)  - Descrição: Lista empresas (admin global / super-admin)

### GET `/api/v1/vehicles/{id}`

- **Descrição:** Detalhes completos do veículo| GET | `/api/v1/fuel-logs/{id}` | Detalhes do registo | `id` (path) | N/A | `{"id": 1, "company_id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-05", "litros": 45.5, "valor": 68.25, "preco_litro": 1.50, "km_atual": 51500, "notas": "Posto Galp A1", "vehicle": {"matricula": "AA-11-BB"}, "driver": {"nome": "João Silva"}, "created_at": "2025-11-05T16:30:00Z"}` |

- **Permissões:** `vehicles.view`

- **Resposta inclui:** | POST | `/api/v1/fuel-logs` | Criar registo de combustível | N/A | `{"company_id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-08", "litros": 50.0, "valor": 75.00, "km_atual": 52000, "notas": "Posto BP Cascais"}` | `{"id": 2, "vehicle_id": 1, "data": "2025-11-08", "litros": 50.0, "valor": 75.00, "preco_litro": 1.50, "created_at": "2025-11-08T11:00:00Z"}` |  - Query: ?page, ?pageSize, ?search, ?estado, ?plano

  - Dados completos do veículo

  - Condutor atual| PUT | `/api/v1/fuel-logs/{id}` | Atualizar registo | `id` (path) | `{"valor": 72.50, "notas": "Posto BP Cascais - Desconto cliente"}` | `{"id": 2, "valor": 72.50, "preco_litro": 1.45, "notas": "Posto BP Cascais - Desconto cliente", "updated_at": "2025-11-08T11:15:00Z"}` |

  - Histórico de manutenções recentes

  - Documentos associados| DELETE | `/api/v1/fuel-logs/{id}` | Remover registo | `id` (path) | N/A | `{"message": "Registo de combustível removido com sucesso"}` || HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Permissão: companies.view

  - Custos totais (via view v_vehicle_costs)



### POST `/api/v1/vehicles`

- **Descrição:** Registar novo veículo---|-----------|----------|-----------|------------|--------|-----------------|

- **Permissões:** `vehicles.create`

- **Corpo da requisição:**

```json

{## 8️⃣ Alerts (Alertas)| GET | `/api/v1/maintenances` | Lista manutenções | `?vehicle_id=1&company_id=1&page=1` | N/A | ```json<br>{"items": [{"id": 1, "vehicle_id": 1, "tipo": "Revisão", "descricao": "Revisão dos 50.000 km", "data": "2025-11-01", "custo": 250.50, "km_registro": 50000, "proxima_data": "2026-11-01", "oficina": "AutoCenter Lisboa"}], "_meta": {"totalCount": 1}}``` |- GET /api/v1/companies/{id}

  "company_id": 1,

  "matricula": "AA-11-BB",

  "marca": "Toyota",

  "modelo": "Corolla",| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) || GET | `/api/v1/maintenances/{id}` | Detalhes da manutenção | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "vehicle_id": 1, "tipo": "Revisão", "descricao": "Revisão dos 50.000 km", "data": "2025-11-01", "custo": 250.50, "km_registro": 50000, "proxima_data": "2026-11-01", "oficina": "AutoCenter Lisboa", "created_at": "2025-11-01T14:30:00Z"}``` |  - Descrição: Detalhes da empresa

  "ano": 2020,

  "tipo_combustivel": "gasolina",|-----------|----------|-----------|------------|--------|-----------------|

  "quilometragem": 50000,

  "condutor_id": 2,| GET | `/api/v1/alerts` | Lista alertas | `?company_id=1&tipo=documento&status=ativo&prioridade=alta` | N/A | `{"items": [{"id": 1, "tipo": "documento", "titulo": "Documento a expirar", "descricao": "Seguro do veículo AA-11-BB expira em 30 dias", "prioridade": "alta", "status": "ativo", "detalhes": {"vehicle_id": 1, "document_id": 1}, "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}` || POST | `/api/v1/maintenances` | Criar manutenção | N/A | ```json<br>{"company_id": 1, "vehicle_id": 1, "tipo": "Mudança de óleo", "descricao": "Troca do óleo do motor", "data": "2025-11-08", "custo": 75.00, "km_registro": 52000, "proxima_data": "2026-05-08", "oficina": "Oficina Central"}``` | ```json<br>{"id": 2, "vehicle_id": 1, "tipo": "Mudança de óleo", "data": "2025-11-08", "custo": 75.00, "created_at": "2025-11-08T10:00:00Z"}``` |  - Permissão: companies.view

  "foto": "uploads/vehicles/aa11bb.jpg"

}| GET | `/api/v1/alerts/{id}` | Detalhes do alerta | `id` (path) | N/A | `{"id": 1, "company_id": 1, "tipo": "documento", "titulo": "Documento a expirar", "descricao": "Seguro do veículo AA-11-BB expira em 30 dias", "prioridade": "alta", "status": "ativo", "detalhes": {"vehicle_id": 1, "document_id": 1, "data_validade": "2025-12-08"}, "created_at": "2025-11-08T10:00:00Z", "resolvido_em": null}` |

```

- **Validações:** Matrícula única por empresa, ano válido, quilometragem >= 0| POST | `/api/v1/alerts` | Criar alerta manual | N/A | `{"company_id": 1, "tipo": "manutencao", "titulo": "Manutenção agendada", "descricao": "Revisão agendada para veículo CC-22-DD", "prioridade": "media", "detalhes": {"vehicle_id": 2, "data_agendada": "2025-11-15"}}` | `{"id": 2, "tipo": "manutencao", "titulo": "Manutenção agendada", "status": "ativo", "created_at": "2025-11-08T11:00:00Z"}` || PUT | `/api/v1/maintenances/{id}` | Atualizar manutenção | `id` (path) | ```json<br>{"custo": 280.00, "proxima_data": "2026-12-01"}``` | ```json<br>{"id": 1, "custo": 280.00, "proxima_data": "2026-12-01", "updated_at": "2025-11-08T10:30:00Z"}``` |



### PUT `/api/v1/vehicles/{id}`| PUT | `/api/v1/alerts/{id}` | Atualizar alerta | `id` (path) | `{"status": "resolvido", "resolvido_em": "2025-11-08T11:30:00Z"}` | `{"id": 1, "status": "resolvido", "resolvido_em": "2025-11-08T11:30:00Z", "updated_at": "2025-11-08T11:30:00Z"}` |

- **Descrição:** Atualizar dados do veículo

- **Permissões:** `vehicles.update`| DELETE | `/api/v1/alerts/{id}` | Remover alerta | `id` (path) | N/A | `{"message": "Alerta removido com sucesso"}` || DELETE | `/api/v1/maintenances/{id}` | Remover manutenção | `id` (path) | N/A | ```json<br>{"message": "Manutenção removida com sucesso"}``` |- POST /api/v1/companies

- **Campos atualizáveis:** Todos exceto company_id e matricula



### POST `/api/v1/vehicles/{id}/assign-driver`

- **Descrição:** Atribuir/desatribuir condutor---  - Descrição: Criar empresa

- **Permissões:** `vehicles.assign`

- **Corpo da requisição:**

```json

{## 9️⃣ Activity Logs (Logs de Atividade)---  - Corpo: { nome, nif, email, telefone, configuracoes }

  "driver_id": 3

}

```

- **Nota:** driver_id = null remove atribuição| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Permissão: companies.manage



### DELETE `/api/v1/vehicles/{id}`|-----------|----------|-----------|------------|--------|-----------------|

- **Descrição:** Desativar veículo

- **Permissões:** `vehicles.delete`| GET | `/api/v1/activity-logs` | Lista logs de atividade | `?company_id=1&user_id=2&entidade=vehicle&page=1&pageSize=50` | N/A | `{"items": [{"id": 1, "user_id": 2, "acao": "CREATE", "entidade": "vehicle", "entidade_id": 1, "detalhes": {"matricula": "AA-11-BB", "marca": "Toyota"}, "ip": "192.168.1.100", "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}` |## 5️⃣ Files (Ficheiros)

- **Nota:** Marca estado como 'inativo'

| GET | `/api/v1/activity-logs/{id}` | Detalhes do log | `id` (path) | N/A | `{"id": 1, "company_id": 1, "user_id": 2, "acao": "CREATE", "entidade": "vehicle", "entidade_id": 1, "detalhes": {"matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla"}, "ip": "192.168.1.100", "user": {"nome": "João Silva"}, "created_at": "2025-11-08T10:00:00Z"}` |

---

- PUT /api/v1/companies/{id}

## 4️⃣ Maintenances (Manutenções)

*Base: tabela `maintenances` - histórico e agendamento*---



### GET `/api/v1/maintenances`| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Descrição: Atualizar empresa

- **Descrição:** Lista manutenções

- **Permissões:** `maintenances.view`## 🔟 Routes (Rotas)

- **Parâmetros de query:**

  - `vehicle_id` (int): Filtro por veículo|-----------|----------|-----------|------------|--------|-----------------|  - Corpo: { nome?, nif?, email?, configuracoes? }

  - `data_inicio`, `data_fim` (date): Período

  - `tipo` (string): Tipo de manutenção| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

  - `proxima_data_ate` (date): Manutenções agendadas até data

- **Resposta inclui:** Dados da manutenção, info do veículo|-----------|----------|-----------|------------|--------|-----------------|| GET | `/api/v1/files` | Lista ficheiros | `?company_id=1&page=1&pageSize=20` | N/A | ```json<br>{"items": [{"id": 1, "nome_original": "seguro_veiculo.pdf", "tamanho": 1024576, "caminho": "uploads/2025/11/seguro_veiculo.pdf", "uploaded_by": 1, "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}``` |  - Permissão: companies.manage



### GET `/api/v1/maintenances/{id}`| GET | `/api/v1/routes` | Lista rotas | `?company_id=1&vehicle_id=1&driver_id=2&status=em_andamento&data_inicio=2025-11-01` | N/A | `{"items": [{"id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T08:00:00Z", "fim": "2025-11-08T10:30:00Z", "km_inicial": 52000, "km_final": 52150, "origem": "Lisboa", "destino": "Porto", "status": "concluida", "distancia_km": 150.5}], "_meta": {"totalCount": 1}}` |

- **Descrição:** Detalhes da manutenção

- **Permissões:** `maintenances.view`| GET | `/api/v1/routes/{id}` | Detalhes da rota | `id` (path) | N/A | `{"id": 1, "company_id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T08:00:00Z", "fim": "2025-11-08T10:30:00Z", "km_inicial": 52000, "km_final": 52150, "origem": "Lisboa", "destino": "Porto", "distancia_km": 150.5, "status": "concluida", "notas": "Viagem sem incidentes", "vehicle": {"matricula": "AA-11-BB"}, "driver": {"nome": "João Silva"}, "total_gps_points": 180, "created_at": "2025-11-08T08:00:00Z"}` || GET | `/api/v1/files/{id}` | Download/metadados | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "nome_original": "seguro_veiculo.pdf", "tamanho": 1024576, "caminho": "uploads/2025/11/seguro_veiculo.pdf", "uploaded_by": 1, "download_url": "/api/v1/files/1/download", "created_at": "2025-11-08T10:00:00Z"}``` |

- **Resposta inclui:** Dados completos, veículo, histórico

| POST | `/api/v1/routes` | Iniciar nova rota | N/A | `{"company_id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T14:00:00Z", "km_inicial": 52150, "origem": "Porto"}` | `{"id": 2, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T14:00:00Z", "km_inicial": 52150, "origem": "Porto", "status": "em_andamento", "created_at": "2025-11-08T14:00:00Z"}` |

### POST `/api/v1/maintenances`

- **Descrição:** Registar nova manutenção| PUT | `/api/v1/routes/{id}` | Atualizar rota | `id` (path) | `{"km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z", "status": "concluida"}` | `{"id": 2, "km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z", "status": "concluida", "updated_at": "2025-11-08T16:00:00Z"}` || POST | `/api/v1/files` | Upload ficheiro | `company_id` (form), `uploaded_by` (form) | **Multipart Form Data:**<br>`file` (binary)<br>`company_id=1`<br>`uploaded_by=1` | ```json<br>{"id": 2, "nome_original": "inspecao_2025.pdf", "tamanho": 2048576, "caminho": "uploads/2025/11/inspecao_2025.pdf", "created_at": "2025-11-08T10:30:00Z"}``` |- DELETE /api/v1/companies/{id}

- **Permissões:** `maintenances.create`

- **Corpo da requisição:**| POST | `/api/v1/routes/{id}/finish` | Encerrar rota | `id` (path) | `{"km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z"}` | `{"message": "Rota encerrada com sucesso", "route": {"id": 2, "status": "concluida", "fim": "2025-11-08T16:00:00Z"}}` |

```json

{| DELETE | `/api/v1/routes/{id}` | Remover rota | `id` (path) | N/A | `{"message": "Rota removida com sucesso"}` || DELETE | `/api/v1/files/{id}` | Remover ficheiro | `id` (path) | N/A | ```json<br>{"message": "Ficheiro removido com sucesso"}``` |  - Descrição: Remover empresa

  "company_id": 1,

  "vehicle_id": 1,

  "tipo": "Revisão",

  "descricao": "Revisão dos 50.000 km",---  - Permissão: companies.manage

  "data": "2025-11-08",

  "custo": 250.50,

  "km_registro": 50000,

  "proxima_data": "2026-11-08",## 1️⃣1️⃣ GPS Entries (Pontos GPS)---

  "oficina": "AutoCenter Lisboa"

}

```

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |---

### PUT `/api/v1/maintenances/{id}`

- **Descrição:** Atualizar manutenção|-----------|----------|-----------|------------|--------|-----------------|

- **Permissões:** `maintenances.update`

| GET | `/api/v1/gps-entries` | Lista pontos GPS | `?route_id=1&timestamp_inicio=2025-11-08T08:00:00Z&timestamp_fim=2025-11-08T10:30:00Z&page=1&pageSize=100` | N/A | `{"items": [{"id": 1, "route_id": 1, "latitude": 38.7223, "longitude": -9.1393, "timestamp": "2025-11-08T08:15:00Z", "velocidade": 60.5, "altitude": 150.2, "precisao": 5.0}], "_meta": {"totalCount": 180, "pageCount": 2}}` |## 6️⃣ Documents (Documentos)

### DELETE `/api/v1/maintenances/{id}`

- **Descrição:** Remover registo de manutenção| GET | `/api/v1/gps-entries/{id}` | Detalhes do ponto GPS | `id` (path) | N/A | `{"id": 1, "route_id": 1, "latitude": 38.7223, "longitude": -9.1393, "timestamp": "2025-11-08T08:15:00Z", "velocidade": 60.5, "altitude": 150.2, "precisao": 5.0, "route": {"id": 1, "vehicle_id": 1, "origem": "Lisboa"}}` |

- **Permissões:** `maintenances.delete`

| POST | `/api/v1/gps-entries` | Inserir ponto GPS | N/A | `{"route_id": 2, "latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0, "altitude": 200.5, "precisao": 3.0}` | `{"id": 181, "route_id": 2, "latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0}` |### 2) Users

---

| POST | `/api/v1/gps-entries/batch` | Inserir múltiplos pontos GPS | N/A | `{"route_id": 2, "points": [{"latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0}, {"latitude": 40.2100, "longitude": -8.4200, "timestamp": "2025-11-08T14:31:00Z", "velocidade": 75.0}]}` | `{"message": "2 pontos GPS inseridos com sucesso", "inserted_ids": [182, 183]}` |

## 5️⃣ Files (Ficheiros)

*Base: tabela `files` - gestão de uploads*| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |Base: /api/v1/users



### GET `/api/v1/files`---

- **Descrição:** Lista ficheiros da empresa

- **Permissões:** `files.view`|-----------|----------|-----------|------------|--------|-----------------|

- **Parâmetros de query:**

  - `company_id` (int): Filtro por empresa## 1️⃣2️⃣ RBAC Management

  - `uploaded_by` (int): Ficheiros do utilizador

  - `size_min`, `size_max` (int): Filtro por tamanho| GET | `/api/v1/documents` | Lista documentos | `?company_id=1&vehicle_id=1&driver_id=2&tipo=seguro&status=valido` | N/A | ```json<br>{"items": [{"id": 1, "file_id": 1, "vehicle_id": 1, "driver_id": null, "tipo": "seguro", "data_validade": "2026-12-31", "status": "valido", "notas": "Seguro contra terceiros"}], "_meta": {"totalCount": 1}}``` |- GET /api/v1/users

- **Resposta inclui:** Metadados, info do uploader

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

### GET `/api/v1/files/{id}`

- **Descrição:** Detalhes/download do ficheiro|-----------|----------|-----------|------------|--------|-----------------|| GET | `/api/v1/documents/{id}` | Detalhes do documento | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "file_id": 1, "vehicle_id": 1, "driver_id": null, "tipo": "seguro", "data_validade": "2026-12-31", "status": "valido", "notas": "Seguro contra terceiros", "file": {"nome_original": "seguro_veiculo.pdf", "download_url": "/api/v1/files/1/download"}, "created_at": "2025-11-08T10:00:00Z"}``` |  - Lista utilizadores (filtro por company_id)

- **Permissões:** `files.view`

- **Resposta:** | GET | `/api/v1/rbac/roles` | Lista roles | N/A | N/A | `{"items": [{"name": "super-admin", "description": "Super Administrador - Acesso Total", "type": 1}, {"name": "admin", "description": "Administrador", "type": 1}, {"name": "gestor", "description": "Gestor de Frota", "type": 1}]}` |

  - Content-Type: application/json (metadados)

  - Content-Type: file mime-type (download direto com ?download=1)| GET | `/api/v1/rbac/permissions` | Lista permissões | N/A | N/A | `{"items": [{"name": "companies.view", "description": "Ver empresas", "type": 2}, {"name": "vehicles.create", "description": "Criar veículos", "type": 2}]}` || POST | `/api/v1/documents` | Criar documento | N/A | ```json<br>{"company_id": 1, "file_id": 2, "vehicle_id": 1, "tipo": "inspecao", "data_validade": "2026-11-08", "notas": "Inspeção periódica obrigatória"}``` | ```json<br>{"id": 2, "file_id": 2, "vehicle_id": 1, "tipo": "inspecao", "data_validade": "2026-11-08", "status": "valido", "created_at": "2025-11-08T10:30:00Z"}``` |  - Permissão: users.view



### POST `/api/v1/files`| GET | `/api/v1/rbac/user-assignments/{user_id}` | Lista atribuições do utilizador | `user_id` (path) | N/A | `{"user_id": "2", "assignments": [{"item_name": "gestor", "created_at": 1699459200}]}` |

- **Descrição:** Upload de ficheiro

- **Permissões:** `files.upload`| POST | `/api/v1/rbac/roles` | Criar role | N/A | `{"name": "tecnico", "description": "Técnico de Manutenção"}` | `{"name": "tecnico", "description": "Técnico de Manutenção", "type": 1, "created_at": 1699545600}` || PUT | `/api/v1/documents/{id}` | Atualizar documento | `id` (path) | ```json<br>{"data_validade": "2027-01-15", "notas": "Renovação antecipada"}``` | ```json<br>{"id": 2, "data_validade": "2027-01-15", "notas": "Renovação antecipada", "updated_at": "2025-11-08T11:00:00Z"}``` |

- **Content-Type:** `multipart/form-data`

- **Campos do form:**| POST | `/api/v1/rbac/assign` | Atribuir role/permission | N/A | `{"item_name": "gestor", "user_id": "3"}` | `{"message": "Role 'gestor' atribuída ao utilizador 3 com sucesso"}` |

  - `file` (binary): Ficheiro a fazer upload

  - `company_id` (int): ID da empresa| DELETE | `/api/v1/rbac/revoke` | Revogar role/permission | N/A | `{"item_name": "gestor", "user_id": "3"}` | `{"message": "Role 'gestor' revogada do utilizador 3 com sucesso"}` || DELETE | `/api/v1/documents/{id}` | Remover documento | `id` (path) | N/A | ```json<br>{"message": "Documento removido com sucesso"}``` |- GET /api/v1/users/{id}

  - `uploaded_by` (int): ID do utilizador (auto se omitido)

- **Validações:** Tamanho máximo, tipos permitidos, empresa válida



### DELETE `/api/v1/files/{id}`---  - Detalhes do utilizador

- **Descrição:** Remover ficheiro

- **Permissões:** `files.delete`

- **Nota:** Remove ficheiro físico e registo da BD

## 1️⃣3️⃣ Authentication (Autenticação)---  - Permissão: users.view

---



## 6️⃣ Documents (Documentos)

*Base: tabela `documents` - documentos ligados a veículos/condutores*| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |



### GET `/api/v1/documents`|-----------|----------|-----------|------------|--------|-----------------|

- **Descrição:** Lista documentos

- **Permissões:** `documents.view`| POST | `/api/v1/auth/login` | Login do utilizador | N/A | `{"email": "joao@veigest.com", "password": "minhasenha123"}` | `{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...", "token_type": "Bearer", "expires_in": 3600, "user": {"id": 2, "nome": "João Silva", "email": "joao@veigest.com", "roles": ["gestor"]}}` |## 7️⃣ Fuel Logs (Registos de Combustível)- POST /api/v1/users

- **Parâmetros de query:**

  - `vehicle_id` (int): Documentos do veículo| POST | `/api/v1/auth/logout` | Logout do utilizador | Header: `Authorization: Bearer <token>` | N/A | `{"message": "Logout realizado com sucesso"}` |

  - `driver_id` (int): Documentos do condutor

  - `tipo` (enum): dua, seguro, inspecao, carta_conducao, outro| POST | `/api/v1/auth/refresh` | Renovar token | Header: `Authorization: Bearer <token>` | N/A | `{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...", "token_type": "Bearer", "expires_in": 3600}` |  - Criar utilizador

  - `status` (enum): valido, expirado

  - `expiring_days` (int): Documentos a expirar em X dias| GET | `/api/v1/auth/me` | Perfil do utilizador autenticado | Header: `Authorization: Bearer <token>` | N/A | `{"id": 2, "nome": "João Silva", "email": "joao@veigest.com", "company": {"id": 1, "nome": "VeiGest Demo"}, "roles": ["gestor"], "permissions": ["vehicles.view", "vehicles.create"]}` |

- **Resposta inclui:** Dados do documento, ficheiro associado, entidade (veículo/condutor)

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Corpo: { company_id, nome, email, senha, telefone, numero_carta?, validade_carta? }

### GET `/api/v1/documents/{id}`

- **Descrição:** Detalhes do documento---

- **Permissões:** `documents.view`

- **Resposta inclui:** Documento completo, ficheiro, entidade associada|-----------|----------|-----------|------------|--------|-----------------|  - Permissão: users.create



### POST `/api/v1/documents`## 📋 Códigos de Estado HTTP

- **Descrição:** Associar documento a veículo/condutor

- **Permissões:** `documents.create`| GET | `/api/v1/fuel-logs` | Lista registos de combustível | `?company_id=1&vehicle_id=1&driver_id=2&data_inicio=2025-11-01&data_fim=2025-11-08` | N/A | ```json<br>{"items": [{"id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-05", "litros": 45.5, "valor": 68.25, "preco_litro": 1.50, "km_atual": 51500, "notas": "Posto Galp A1"}], "_meta": {"totalCount": 1}}``` |

- **Corpo da requisição:**

```json| Código | Descrição | Exemplo de Uso |

{

  "company_id": 1,|--------|-----------|----------------|| GET | `/api/v1/fuel-logs/{id}` | Detalhes do registo | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-05", "litros": 45.5, "valor": 68.25, "preco_litro": 1.50, "km_atual": 51500, "notas": "Posto Galp A1", "vehicle": {"matricula": "AA-11-BB"}, "driver": {"nome": "João Silva"}, "created_at": "2025-11-05T16:30:00Z"}``` |- PUT /api/v1/users/{id}

  "file_id": 1,

  "vehicle_id": 1,| 200 | OK | Sucesso em GET, PUT |

  "driver_id": null,

  "tipo": "seguro",| 201 | Created | Sucesso em POST (criação) || POST | `/api/v1/fuel-logs` | Criar registo de combustível | N/A | ```json<br>{"company_id": 1, "vehicle_id": 1, "driver_id": 2, "data": "2025-11-08", "litros": 50.0, "valor": 75.00, "km_atual": 52000, "notas": "Posto BP Cascais"}``` | ```json<br>{"id": 2, "vehicle_id": 1, "data": "2025-11-08", "litros": 50.0, "valor": 75.00, "preco_litro": 1.50, "created_at": "2025-11-08T11:00:00Z"}``` |  - Atualizar utilizador

  "data_validade": "2026-12-31",

  "notas": "Seguro contra terceiros"| 204 | No Content | Sucesso em DELETE |

}

```| 400 | Bad Request | Dados inválidos no pedido || PUT | `/api/v1/fuel-logs/{id}` | Atualizar registo | `id` (path) | ```json<br>{"valor": 72.50, "notas": "Posto BP Cascais - Desconto cliente"}``` | ```json<br>{"id": 2, "valor": 72.50, "preco_litro": 1.45, "notas": "Posto BP Cascais - Desconto cliente", "updated_at": "2025-11-08T11:15:00Z"}``` |  - Corpo: { nome?, email?, telefone?, numero_carta?, validade_carta?, estado? }

- **Validação:** Deve ter vehicle_id OU driver_id (não ambos)

| 401 | Unauthorized | Token ausente ou inválido |

### PUT `/api/v1/documents/{id}`

- **Descrição:** Atualizar documento| 403 | Forbidden | Sem permissão para o recurso || DELETE | `/api/v1/fuel-logs/{id}` | Remover registo | `id` (path) | N/A | ```json<br>{"message": "Registo de combustível removido com sucesso"}``` |  - Permissão: users.update

- **Permissões:** `documents.update`

| 404 | Not Found | Recurso não encontrado |

### DELETE `/api/v1/documents/{id}`

- **Descrição:** Remover documento| 409 | Conflict | Conflito (ex: email duplicado) |

- **Permissões:** `documents.delete`

| 422 | Unprocessable Entity | Erro de validação |

---

| 429 | Too Many Requests | Rate limiting |---- PATCH /api/v1/users/{id}/password

## 7️⃣ Fuel Logs (Registos de Combustível)

*Base: tabela `fuel_logs` - controlo de abastecimentos*| 500 | Internal Server Error | Erro interno do servidor |



### GET `/api/v1/fuel-logs`  - Atualizar senha (requere a senha antiga ou token de reset)

- **Descrição:** Lista registos de combustível

- **Permissões:** `fuel.view`---

- **Parâmetros de query:**

  - `vehicle_id` (int): Filtro por veículo## 8️⃣ Alerts (Alertas)  - Corpo: { old_password?, new_password }

  - `driver_id` (int): Filtro por condutor

  - `data_inicio`, `data_fim` (date): Período## 📚 Exemplos de Uso (curl)

  - `valor_min`, `valor_max` (decimal): Filtro por valor

- **Resposta inclui:** Registo, cálculo automático preco_litro, veículo, condutor  - Permissão: users.update



### GET `/api/v1/fuel-logs/{id}`### Login e obtenção de token

- **Descrição:** Detalhes do registo

- **Permissões:** `fuel.view````bash| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |



### POST `/api/v1/fuel-logs`curl -X POST https://api.veigest.com/api/v1/auth/login \

- **Descrição:** Registar abastecimento

- **Permissões:** `fuel.create`  -H "Content-Type: application/json" \|-----------|----------|-----------|------------|--------|-----------------|- DELETE /api/v1/users/{id}

- **Corpo da requisição:**

```json  -d '{"email":"joao@veigest.com","password":"minhasenha123"}'

{

  "company_id": 1,```| GET | `/api/v1/alerts` | Lista alertas | `?company_id=1&tipo=documento&status=ativo&prioridade=alta` | N/A | ```json<br>{"items": [{"id": 1, "tipo": "documento", "titulo": "Documento a expirar", "descricao": "Seguro do veículo AA-11-BB expira em 30 dias", "prioridade": "alta", "status": "ativo", "detalhes": {"vehicle_id": 1, "document_id": 1}, "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}``` |  - Remover utilizador

  "vehicle_id": 1,

  "driver_id": 2,

  "data": "2025-11-08",

  "litros": 45.5,### Listar veículos com paginação| GET | `/api/v1/alerts/{id}` | Detalhes do alerta | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "tipo": "documento", "titulo": "Documento a expirar", "descricao": "Seguro do veículo AA-11-BB expira em 30 dias", "prioridade": "alta", "status": "ativo", "detalhes": {"vehicle_id": 1, "document_id": 1, "data_validade": "2025-12-08"}, "created_at": "2025-11-08T10:00:00Z", "resolvido_em": null}``` |  - Permissão: users.delete

  "valor": 68.25,

  "km_atual": 51500,```bash

  "notas": "Posto Galp A1"

}curl -H "Authorization: Bearer <TOKEN>" \| POST | `/api/v1/alerts` | Criar alerta manual | N/A | ```json<br>{"company_id": 1, "tipo": "manutencao", "titulo": "Manutenção agendada", "descricao": "Revisão agendada para veículo CC-22-DD", "prioridade": "media", "detalhes": {"vehicle_id": 2, "data_agendada": "2025-11-15"}}``` | ```json<br>{"id": 2, "tipo": "manutencao", "titulo": "Manutenção agendada", "status": "ativo", "created_at": "2025-11-08T11:00:00Z"}``` |

```

- **Nota:** Campo `preco_litro` é calculado automaticamente (valor/litros)  "https://api.veigest.com/api/v1/vehicles?page=1&pageSize=10&company_id=1"



### PUT `/api/v1/fuel-logs/{id}````| PUT | `/api/v1/alerts/{id}` | Atualizar alerta | `id` (path) | ```json<br>{"status": "resolvido", "resolvido_em": "2025-11-08T11:30:00Z"}``` | ```json<br>{"id": 1, "status": "resolvido", "resolvido_em": "2025-11-08T11:30:00Z", "updated_at": "2025-11-08T11:30:00Z"}``` |- POST /api/v1/users/{id}/assign-role

- **Descrição:** Atualizar registo

- **Permissões:** `fuel.update`



### DELETE `/api/v1/fuel-logs/{id}`### Criar um novo veículo| DELETE | `/api/v1/alerts/{id}` | Remover alerta | `id` (path) | N/A | ```json<br>{"message": "Alerta removido com sucesso"}``` |  - Atribuir role (admin only)

- **Descrição:** Remover registo

- **Permissões:** `fuel.delete````bash



---curl -X POST https://api.veigest.com/api/v1/vehicles \  - Corpo: { role: "gestor" }



## 8️⃣ Alerts (Alertas)  -H "Authorization: Bearer <TOKEN>" \

*Base: tabela `alerts` - sistema de notificações*

  -H "Content-Type: application/json" \---  - Permissão: users.manage-roles

### GET `/api/v1/alerts`

- **Descrição:** Lista alertas da empresa  -d '{"company_id":1,"matricula":"EE-33-FF","marca":"BMW","modelo":"320d","ano":2023,"tipo_combustivel":"diesel","quilometragem":5000}'

- **Permissões:** `alerts.view`

- **Parâmetros de query:**```

  - `tipo` (enum): manutencao, documento, combustivel, outro

  - `status` (enum): ativo, resolvido, ignorado

  - `prioridade` (enum): baixa, media, alta, critica

  - `created_since` (datetime): Alertas desde data### Upload de ficheiro (documento)## 9️⃣ Activity Logs (Logs de Atividade)---

- **Resposta inclui:** Alerta, detalhes JSON estruturados

```bash

### GET `/api/v1/alerts/{id}`

- **Descrição:** Detalhes do alertacurl -X POST https://api.veigest.com/api/v1/files \

- **Permissões:** `alerts.view`

  -H "Authorization: Bearer <TOKEN>" \

### POST `/api/v1/alerts`

- **Descrição:** Criar alerta manual  -F "file=@seguro_veiculo.pdf" \| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |### 3) Vehicles

- **Permissões:** `alerts.create`

- **Corpo da requisição:**  -F "company_id=1" \

```json

{  -F "uploaded_by=2"|-----------|----------|-----------|------------|--------|-----------------|Base: /api/v1/vehicles

  "company_id": 1,

  "tipo": "manutencao",```

  "titulo": "Manutenção em atraso",

  "descricao": "Revisão do veículo AA-11-BB está em atraso",| GET | `/api/v1/activity-logs` | Lista logs de atividade | `?company_id=1&user_id=2&entidade=vehicle&page=1&pageSize=50` | N/A | ```json<br>{"items": [{"id": 1, "user_id": 2, "acao": "CREATE", "entidade": "vehicle", "entidade_id": 1, "detalhes": {"matricula": "AA-11-BB", "marca": "Toyota"}, "ip": "192.168.1.100", "created_at": "2025-11-08T10:00:00Z"}], "_meta": {"totalCount": 1}}``` |

  "prioridade": "alta",

  "detalhes": {### Iniciar uma rota

    "vehicle_id": 1,

    "maintenance_id": 5,```bash| GET | `/api/v1/activity-logs/{id}` | Detalhes do log | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "user_id": 2, "acao": "CREATE", "entidade": "vehicle", "entidade_id": 1, "detalhes": {"matricula": "AA-11-BB", "marca": "Toyota", "modelo": "Corolla"}, "ip": "192.168.1.100", "user": {"nome": "João Silva"}, "created_at": "2025-11-08T10:00:00Z"}``` |- GET /api/v1/vehicles

    "dias_atraso": 15

  }curl -X POST https://api.veigest.com/api/v1/routes \

}

```  -H "Authorization: Bearer <TOKEN>" \  - Lista veículos (filtros: company_id, condutor_id, estado)



### PUT `/api/v1/alerts/{id}`  -H "Content-Type: application/json" \

- **Descrição:** Atualizar/resolver alerta

- **Permissões:** `alerts.resolve`  -d '{"company_id":1,"vehicle_id":1,"driver_id":2,"inicio":"2025-11-08T08:00:00Z","km_inicial":52000,"origem":"Lisboa"}'---  - Permissão: vehicles.view

- **Corpo comum:**

```json```

{

  "status": "resolvido",

  "resolvido_em": "2025-11-08T14:30:00Z"

}### Inserir pontos GPS em lote

```

```bash## 🔟 Routes (Rotas)- GET /api/v1/vehicles/{id}

### DELETE `/api/v1/alerts/{id}`

- **Descrição:** Remover alertacurl -X POST https://api.veigest.com/api/v1/gps-entries/batch \

- **Permissões:** `alerts.resolve`

  -H "Authorization: Bearer <TOKEN>" \  - Detalhes do veículo

---

  -H "Content-Type: application/json" \

## 9️⃣ Activity Logs (Logs de Atividade)

*Base: tabela `activity_logs` - auditoria de ações*  -d '{"route_id":1,"points":[{"latitude":38.7223,"longitude":-9.1393,"timestamp":"2025-11-08T08:15:00Z","velocidade":60.5},{"latitude":38.7300,"longitude":-9.1500,"timestamp":"2025-11-08T08:20:00Z","velocidade":65.0}]}'| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Permissão: vehicles.view



### GET `/api/v1/activity-logs````

- **Descrição:** Lista logs de atividade

- **Permissões:** `system.logs` (apenas admin+)|-----------|----------|-----------|------------|--------|-----------------|

- **Parâmetros de query:**

  - `user_id` (int): Filtro por utilizador---

  - `entidade` (string): Filtro por tipo de entidade

  - `entidade_id` (int): Filtro por ID específico| GET | `/api/v1/routes` | Lista rotas | `?company_id=1&vehicle_id=1&driver_id=2&status=em_andamento&data_inicio=2025-11-01` | N/A | ```json<br>{"items": [{"id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T08:00:00Z", "fim": "2025-11-08T10:30:00Z", "km_inicial": 52000, "km_final": 52150, "origem": "Lisboa", "destino": "Porto", "status": "concluida", "distancia_km": 150.5}], "_meta": {"totalCount": 1}}``` |- POST /api/v1/vehicles

  - `acao` (string): CREATE, UPDATE, DELETE, etc.

  - `date_from`, `date_to` (datetime): Período## 🔧 Notas de Implementação (Yii2 Advanced)

- **Resposta inclui:** Log, utilizador, detalhes JSON da ação

| GET | `/api/v1/routes/{id}` | Detalhes da rota | `id` (path) | N/A | ```json<br>{"id": 1, "company_id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T08:00:00Z", "fim": "2025-11-08T10:30:00Z", "km_inicial": 52000, "km_final": 52150, "origem": "Lisboa", "destino": "Porto", "distancia_km": 150.5, "status": "concluida", "notas": "Viagem sem incidentes", "vehicle": {"matricula": "AA-11-BB"}, "driver": {"nome": "João Silva"}, "total_gps_points": 180, "created_at": "2025-11-08T08:00:00Z"}``` |  - Criar veículo

### GET `/api/v1/activity-logs/{id}`

- **Descrição:** Detalhes do log### Estrutura do Projeto

- **Permissões:** `system.logs`

- **Resposta inclui:** Log completo, utilizador, contexto da ação```| POST | `/api/v1/routes` | Iniciar nova rota | N/A | ```json<br>{"company_id": 1, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T14:00:00Z", "km_inicial": 52150, "origem": "Porto"}``` | ```json<br>{"id": 2, "vehicle_id": 1, "driver_id": 2, "inicio": "2025-11-08T14:00:00Z", "km_inicial": 52150, "origem": "Porto", "status": "em_andamento", "created_at": "2025-11-08T14:00:00Z"}``` |  - Corpo: { company_id, matricula, marca, modelo, ano, tipo_combustivel, quilometragem, condutor_id? }



**Nota:** Activity logs são apenas leitura - criados automaticamente pelo sistemaapi/



---├── modules/| PUT | `/api/v1/routes/{id}` | Atualizar rota | `id` (path) | ```json<br>{"km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z", "status": "concluida"}``` | ```json<br>{"id": 2, "km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z", "status": "concluida", "updated_at": "2025-11-08T16:00:00Z"}``` |  - Permissão: vehicles.create



## 🔟 Routes (Rotas)│   └── v1/

*Base: tabela `routes` - gestão de viagens*

│       ├── controllers/| POST | `/api/v1/routes/{id}/finish` | Encerrar rota | `id` (path) | ```json<br>{"km_final": 52300, "destino": "Coimbra", "fim": "2025-11-08T16:00:00Z"}``` | ```json<br>{"message": "Rota encerrada com sucesso", "route": {"id": 2, "status": "concluida", "fim": "2025-11-08T16:00:00Z"}}``` |

### GET `/api/v1/routes`

- **Descrição:** Lista rotas/viagens│       │   ├── CompanyController.php

- **Permissões:** `routes.view`

- **Parâmetros de query:**│       │   ├── UserController.php| DELETE | `/api/v1/routes/{id}` | Remover rota | `id` (path) | N/A | ```json<br>{"message": "Rota removida com sucesso"}``` |- PUT /api/v1/vehicles/{id}

  - `vehicle_id` (int): Filtro por veículo

  - `driver_id` (int): Filtro por condutor│       │   ├── VehicleController.php

  - `status` (enum): em_andamento, concluida, cancelada

  - `data_inicio`, `data_fim` (date): Período│       │   └── ...  - Atualizar

- **Resposta inclui:** Rota, veículo, condutor, estatísticas GPS

│       ├── models/

### GET `/api/v1/routes/{id}`

- **Descrição:** Detalhes da rota│       └── Module.php---  - Permissão: vehicles.update

- **Permissões:** `routes.view`

- **Resposta inclui:** Rota completa, total de pontos GPS, duração, distância├── config/



### POST `/api/v1/routes`└── web/

- **Descrição:** Iniciar nova rota

- **Permissões:** `routes.create````

- **Corpo da requisição:**

```json## 1️⃣1️⃣ GPS Entries (Pontos GPS)- DELETE /api/v1/vehicles/{id}

{

  "company_id": 1,### Configuração Básica

  "vehicle_id": 1,

  "driver_id": 2,```php  - Remover

  "inicio": "2025-11-08T08:00:00Z",

  "km_inicial": 52000,// api/modules/v1/Module.php

  "origem": "Lisboa"

}public function init()| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |  - Permissão: vehicles.delete

```

- **Nota:** Status automaticamente definido como 'em_andamento'{



### PUT `/api/v1/routes/{id}`    parent::init();|-----------|----------|-----------|------------|--------|-----------------|

- **Descrição:** Atualizar/encerrar rota

- **Permissões:** `routes.update`    \Yii::$app->user->enableSession = false;

- **Corpo para encerrar:**

```json}| GET | `/api/v1/gps-entries` | Lista pontos GPS | `?route_id=1&timestamp_inicio=2025-11-08T08:00:00Z&timestamp_fim=2025-11-08T10:30:00Z&page=1&pageSize=100` | N/A | ```json<br>{"items": [{"id": 1, "route_id": 1, "latitude": 38.7223, "longitude": -9.1393, "timestamp": "2025-11-08T08:15:00Z", "velocidade": 60.5, "altitude": 150.2, "precisao": 5.0}], "_meta": {"totalCount": 180, "pageCount": 2}}``` |- POST /api/v1/vehicles/{id}/assign-driver

{

  "fim": "2025-11-08T16:00:00Z",```

  "km_final": 52300,

  "destino": "Porto",| GET | `/api/v1/gps-entries/{id}` | Detalhes do ponto GPS | `id` (path) | N/A | ```json<br>{"id": 1, "route_id": 1, "latitude": 38.7223, "longitude": -9.1393, "timestamp": "2025-11-08T08:15:00Z", "velocidade": 60.5, "altitude": 150.2, "precisao": 5.0, "route": {"id": 1, "vehicle_id": 1, "origem": "Lisboa"}}``` |  - Atribuir condutor

  "status": "concluida"

}### Controller Exemplo (VehicleController)

```

```php| POST | `/api/v1/gps-entries` | Inserir ponto GPS | N/A | ```json<br>{"route_id": 2, "latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0, "altitude": 200.5, "precisao": 3.0}``` | ```json<br>{"id": 181, "route_id": 2, "latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0}``` |  - Corpo: { driver_id }

### POST `/api/v1/routes/{id}/finish`

- **Descrição:** Endpoint específico para encerrar rotaclass VehicleController extends ActiveController

- **Permissões:** `routes.update`

- **Conveniência:** Automaticamente calcula duração e distância{| POST | `/api/v1/gps-entries/batch` | Inserir múltiplos pontos GPS | N/A | ```json<br>{"route_id": 2, "points": [{"latitude": 40.2033, "longitude": -8.4103, "timestamp": "2025-11-08T14:30:00Z", "velocidade": 80.0}, {"latitude": 40.2100, "longitude": -8.4200, "timestamp": "2025-11-08T14:31:00Z", "velocidade": 75.0}]}``` | ```json<br>{"message": "2 pontos GPS inseridos com sucesso", "inserted_ids": [182, 183]}``` |  - Permissão: vehicles.assign



### DELETE `/api/v1/routes/{id}`    public $modelClass = 'common\models\Vehicle';

- **Descrição:** Cancelar/remover rota

- **Permissões:** `routes.delete`    



---    public function behaviors()



## 1️⃣1️⃣ GPS Entries (Pontos GPS)    {------

*Base: tabela `gps_entries` - rastreamento detalhado*

        return ArrayHelper::merge(parent::behaviors(), [

### GET `/api/v1/gps-entries`

- **Descrição:** Lista pontos GPS            'authenticator' => [

- **Permissões:** `routes.view`

- **Parâmetros de query:**                'class' => HttpBearerAuth::class,

  - `route_id` (int): Filtro por rota (obrigatório)

  - `timestamp_from`, `timestamp_to` (datetime): Período            ],## 1️⃣2️⃣ RBAC Management### 4) Maintenances

  - `limit` (int): Limite de registos (max 1000)

- **Resposta:** Lista paginada de pontos GPS com metadados            'rateLimiter' => [



### GET `/api/v1/gps-entries/{id}`                'class' => RateLimiter::class,Base: /api/v1/maintenances

- **Descrição:** Detalhes do ponto GPS

- **Permissões:** `routes.view`            ],



### POST `/api/v1/gps-entries`        ]);| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

- **Descrição:** Inserir ponto GPS individual

- **Permissões:** `routes.create`    }

- **Corpo da requisição:**

```json    |-----------|----------|-----------|------------|--------|-----------------|- GET /api/v1/maintenances

{

  "route_id": 1,    public function actions()

  "latitude": 38.7223,

  "longitude": -9.1393,    {| GET | `/api/v1/rbac/roles` | Lista roles | N/A | N/A | ```json<br>{"items": [{"name": "super-admin", "description": "Super Administrador - Acesso Total", "type": 1}, {"name": "admin", "description": "Administrador", "type": 1}, {"name": "gestor", "description": "Gestor de Frota", "type": 1}]}``` |  - Lista manutenções (filtros: vehicle_id, company_id, status)

  "timestamp": "2025-11-08T08:15:00Z",

  "velocidade": 60.5,        $actions = parent::actions();

  "altitude": 150.2,

  "precisao": 5.0        $actions['index']['dataFilter'] = [| GET | `/api/v1/rbac/permissions` | Lista permissões | N/A | N/A | ```json<br>{"items": [{"name": "companies.view", "description": "Ver empresas", "type": 2}, {"name": "vehicles.create", "description": "Criar veículos", "type": 2}]}``` |  - Permissão: maintenances.view

}

```            'class' => ActiveDataFilter::class,



### POST `/api/v1/gps-entries/batch`            'searchModel' => VehicleSearch::class,| GET | `/api/v1/rbac/user-assignments/{user_id}` | Lista atribuições do utilizador | `user_id` (path) | N/A | ```json<br>{"user_id": "2", "assignments": [{"item_name": "gestor", "created_at": 1699459200}]}``` |

- **Descrição:** Inserir múltiplos pontos GPS (otimizado)

- **Permissões:** `routes.create`        ];

- **Corpo da requisição:**

```json        return $actions;| POST | `/api/v1/rbac/roles` | Criar role | N/A | ```json<br>{"name": "tecnico", "description": "Técnico de Manutenção"}``` | ```json<br>{"name": "tecnico", "description": "Técnico de Manutenção", "type": 1, "created_at": 1699545600}``` |- GET /api/v1/maintenances/{id}

{

  "route_id": 1,    }

  "points": [

    {}| POST | `/api/v1/rbac/assign` | Atribuir role/permission | N/A | ```json<br>{"item_name": "gestor", "user_id": "3"}``` | ```json<br>{"message": "Role 'gestor' atribuída ao utilizador 3 com sucesso"}``` |  - Detalhes

      "latitude": 38.7223,

      "longitude": -9.1393,```

      "timestamp": "2025-11-08T08:15:00Z",

      "velocidade": 60.5,| DELETE | `/api/v1/rbac/revoke` | Revogar role/permission | N/A | ```json<br>{"item_name": "gestor", "user_id": "3"}``` | ```json<br>{"message": "Role 'gestor' revogada do utilizador 3 com sucesso"}``` |  - Permissão: maintenances.view

      "altitude": 150.2,

      "precisao": 5.0---

    },

    {

      "latitude": 38.7300,

      "longitude": -9.1500,**Ficheiro:** API_ENDPOINTS.md  

      "timestamp": "2025-11-08T08:16:00Z",

      "velocidade": 65.0**Última atualização:** 8 de novembro de 2025---- POST /api/v1/maintenances

    }

  ]  - Criar

}

```## 1️⃣3️⃣ Authentication (Autenticação)  - Corpo: { company_id, vehicle_id, tipo, descricao, data, custo, km_registro, proxima_data }

- **Resposta:** IDs dos pontos inseridos e contagem

  - Permissão: maintenances.create

**Nota:** GPS entries são apenas criação - não permite UPDATE/DELETE por motivos de auditoria

| HTTP Verb | Endpoint | Descrição | Parâmetros | Pedido | Resposta (JSON) |

---

|-----------|----------|-----------|------------|--------|-----------------|- PUT /api/v1/maintenances/{id}

## 1️⃣2️⃣ RBAC Management

*Base: tabelas `auth_*` - gestão de roles e permissões*| POST | `/api/v1/auth/login` | Login do utilizador | N/A | ```json<br>{"email": "joao@veigest.com", "password": "minhasenha123"}``` | ```json<br>{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...", "token_type": "Bearer", "expires_in": 3600, "user": {"id": 2, "nome": "João Silva", "email": "joao@veigest.com", "roles": ["gestor"]}}``` |  - Atualizar



### GET `/api/v1/rbac/roles`| POST | `/api/v1/auth/logout` | Logout do utilizador | Header: `Authorization: Bearer <token>` | N/A | ```json<br>{"message": "Logout realizado com sucesso"}``` |  - Permissão: maintenances.update

- **Descrição:** Lista todos os roles disponíveis

- **Permissões:** `users.manage-roles`| POST | `/api/v1/auth/refresh` | Renovar token | Header: `Authorization: Bearer <token>` | N/A | ```json<br>{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...", "token_type": "Bearer", "expires_in": 3600}``` |

- **Resposta:** Lista de roles com descrições

| GET | `/api/v1/auth/me` | Perfil do utilizador autenticado | Header: `Authorization: Bearer <token>` | N/A | ```json<br>{"id": 2, "nome": "João Silva", "email": "joao@veigest.com", "company": {"id": 1, "nome": "VeiGest Demo"}, "roles": ["gestor"], "permissions": ["vehicles.view", "vehicles.create"]}``` |- DELETE /api/v1/maintenances/{id}

### GET `/api/v1/rbac/permissions`

- **Descrição:** Lista todas as permissões disponíveis  - Remover

- **Permissões:** `users.manage-roles`

- **Parâmetros de query:**---  - Permissão: maintenances.delete

  - `module` (string): Filtro por módulo (companies, users, vehicles, etc.)

- **Resposta:** Lista de permissões agrupadas por módulo



### GET `/api/v1/rbac/user-assignments/{user_id}`## 📋 Códigos de Estado HTTP---

- **Descrição:** Lista roles atribuídos ao utilizador

- **Permissões:** `users.view` (próprio) ou `users.manage-roles`

- **Resposta:** Roles e permissões efetivas do utilizador

| Código | Descrição | Exemplo de Uso |### 5) Files

### POST `/api/v1/rbac/roles`

- **Descrição:** Criar novo role (apenas super-admin)|--------|-----------|----------------|Base: /api/v1/files

- **Permissões:** `system.config`

- **Corpo da requisição:**| 200 | OK | Sucesso em GET, PUT |

```json

{| 201 | Created | Sucesso em POST (criação) |- GET /api/v1/files

  "name": "tecnico",

  "description": "Técnico de Manutenção",| 204 | No Content | Sucesso em DELETE |  - Lista ficheiros por company_id

  "permissions": ["maintenances.view", "maintenances.create"]

}| 400 | Bad Request | Dados inválidos no pedido |  - Permissão: files.view

```

| 401 | Unauthorized | Token ausente ou inválido |

### POST `/api/v1/rbac/assign`

- **Descrição:** Atribuir role ao utilizador| 403 | Forbidden | Sem permissão para o recurso |- GET /api/v1/files/{id}

- **Permissões:** `users.manage-roles`

- **Corpo da requisição:**| 404 | Not Found | Recurso não encontrado |  - Download/meta

```json

{| 409 | Conflict | Conflito (ex: email duplicado) |  - Permissão: files.view

  "item_name": "gestor",

  "user_id": "3"| 422 | Unprocessable Entity | Erro de validação |

}

```| 429 | Too Many Requests | Rate limiting |- POST /api/v1/files (multipart/form-data)



### DELETE `/api/v1/rbac/revoke`| 500 | Internal Server Error | Erro interno do servidor |  - Upload

- **Descrição:** Revogar role do utilizador

- **Permissões:** `users.manage-roles`  - Campos: file (binary), company_id, uploaded_by

- **Corpo da requisição:**

```json---  - Permissão: files.upload

{

  "item_name": "gestor",

  "user_id": "3"

}## 📚 Exemplos de Uso (curl)- DELETE /api/v1/files/{id}

```

  - Permissão: files.delete

---

### Login e obtenção de token

## 1️⃣3️⃣ Authentication (Autenticação)

*Gestão de sessões e tokens JWT*```bash---



### POST `/api/v1/auth/login`curl -X POST https://api.veigest.com/api/v1/auth/login \

- **Descrição:** Autenticar utilizador

- **Permissões:** Público  -H "Content-Type: application/json" \### 6) Documents

- **Corpo da requisição:**

```json  -d '{"email":"joao@veigest.com","password":"minhasenha123"}'Base: /api/v1/documents

{

  "email": "joao@veigest.com",```

  "password": "minhasenha123"

}- GET /api/v1/documents

```

- **Resposta de sucesso (200):**### Listar veículos com paginação  - Lista (filtros: company_id, vehicle_id, driver_id, tipo, status)

```json

{```bash  - Permissão: documents.view

  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",

  "token_type": "Bearer",curl -H "Authorization: Bearer <TOKEN>" \

  "expires_in": 3600,

  "user": {  "https://api.veigest.com/api/v1/vehicles?page=1&pageSize=10&company_id=1"- GET /api/v1/documents/{id}

    "id": 2,

    "nome": "João Silva",```  - Detalhes

    "email": "joao@veigest.com",

    "company": {  - Permissão: documents.view

      "id": 1,

      "nome": "VeiGest Demo"### Criar um novo veículo

    },

    "roles": ["gestor"],```bash- POST /api/v1/documents

    "permissions": ["vehicles.view", "vehicles.create", "users.view"]

  }curl -X POST https://api.veigest.com/api/v1/vehicles \  - Criar documento associado a ficheiro

}

```  -H "Authorization: Bearer <TOKEN>" \  - Corpo: { company_id, file_id, vehicle_id?, driver_id?, tipo, data_validade?, notas }



### POST `/api/v1/auth/logout`  -H "Content-Type: application/json" \  - Permissão: documents.create

- **Descrição:** Terminar sessão

- **Permissões:** Utilizador autenticado  -d '{"company_id":1,"matricula":"EE-33-FF","marca":"BMW","modelo":"320d","ano":2023,"tipo_combustivel":"diesel","quilometragem":5000}'

- **Header obrigatório:** `Authorization: Bearer <token>`

- **Resposta (200):** `{"message": "Logout realizado com sucesso"}````- PUT /api/v1/documents/{id}



### POST `/api/v1/auth/refresh`  - Atualizar

- **Descrição:** Renovar token JWT

- **Permissões:** Token válido### Upload de ficheiro (documento)  - Permissão: documents.update

- **Resposta:** Novo token com tempo renovado

```bash

### GET `/api/v1/auth/me`

- **Descrição:** Perfil do utilizador autenticadocurl -X POST https://api.veigest.com/api/v1/files \- DELETE /api/v1/documents/{id}

- **Permissões:** Utilizador autenticado

- **Resposta:** Dados completos do utilizador, empresa, roles, permissões  -H "Authorization: Bearer <TOKEN>" \  - Permissão: documents.delete



---  -F "file=@seguro_veiculo.pdf" \



# 📊 Views e Relatórios  -F "company_id=1" \---



## Views Disponíveis  -F "uploaded_by=2"

*Base: 4 views pré-definidas para consultas otimizadas*

```### 7) Fuel Logs

### GET `/api/v1/reports/documents-expiring`

- **Fonte:** View `v_documents_expiring`Base: /api/v1/fuel-logs

- **Descrição:** Documentos a expirar nos próximos 30 dias

- **Permissões:** `reports.view`### Iniciar uma rota

- **Parâmetros:**

  - `days` (int): Dias de antecedência (padrão: 30)```bash- GET /api/v1/fuel-logs

  - `tipo` (enum): Filtro por tipo de documento

curl -X POST https://api.veigest.com/api/v1/routes \  - Lista registos de combustível (filtros: company_id, vehicle_id, driver_id, date range)

### GET `/api/v1/reports/company-stats`

- **Fonte:** View `v_company_stats`  -H "Authorization: Bearer <TOKEN>" \  - Permissão: fuel.view

- **Descrição:** Estatísticas agregadas por empresa

- **Permissões:** `reports.view`  -H "Content-Type: application/json" \

- **Resposta inclui:** Total users, vehicles, drivers, storage usado

  -d '{"company_id":1,"vehicle_id":1,"driver_id":2,"inicio":"2025-11-08T08:00:00Z","km_inicial":52000,"origem":"Lisboa"}'- GET /api/v1/fuel-logs/{id}

### GET `/api/v1/reports/vehicle-costs`

- **Fonte:** View `v_vehicle_costs` ```  - Detalhes

- **Descrição:** Custos por veículo (manutenção + combustível)

- **Permissões:** `reports.view`  - Permissão: fuel.view

- **Parâmetros:**

  - `vehicle_id` (int): Filtro por veículo específico### Inserir pontos GPS em lote

  - `period` (string): Período de análise

```bash- POST /api/v1/fuel-logs

### GET `/api/v1/reports/routes-summary`

- **Fonte:** View `v_routes_summary`curl -X POST https://api.veigest.com/api/v1/gps-entries/batch \  - Criar registo de combustível

- **Descrição:** Resumo de rotas com estatísticas GPS

- **Permissões:** `reports.view`  -H "Authorization: Bearer <TOKEN>" \  - Corpo: { company_id, vehicle_id, driver_id?, data, litros, valor, km_atual?, notas? }

- **Parâmetros:**

  - `vehicle_id`, `driver_id`: Filtros opcionais  -H "Content-Type: application/json" \  - Permissão: fuel.create

  - `date_from`, `date_to`: Período

  -d '{"route_id":1,"points":[{"latitude":38.7223,"longitude":-9.1393,"timestamp":"2025-11-08T08:15:00Z","velocidade":60.5},{"latitude":38.7300,"longitude":-9.1500,"timestamp":"2025-11-08T08:20:00Z","velocidade":65.0}]}'

---

```- PUT /api/v1/fuel-logs/{id}

# 🔧 Códigos de Estado HTTP

  - Atualizar

## Códigos de Sucesso

- **200 OK:** Operação bem-sucedida (GET, PUT)---  - Permissão: fuel.update

- **201 Created:** Recurso criado com sucesso (POST)

- **204 No Content:** Operação bem-sucedida sem resposta (DELETE)



## Códigos de Erro Cliente## 🔧 Notas de Implementação (Yii2 Advanced)- DELETE /api/v1/fuel-logs/{id}

- **400 Bad Request:** Dados inválidos no pedido

- **401 Unauthorized:** Token ausente, inválido ou expirado  - Permissão: fuel.delete

- **403 Forbidden:** Sem permissão RBAC para a operação

- **404 Not Found:** Recurso não encontrado### Estrutura do Projeto

- **409 Conflict:** Conflito de dados (email duplicado, matrícula existente)

- **422 Unprocessable Entity:** Erro de validação de campos```---

- **429 Too Many Requests:** Rate limiting atingido

api/

## Códigos de Erro Servidor

- **500 Internal Server Error:** Erro interno não tratado├── modules/### 8) Alerts

- **503 Service Unavailable:** Serviço temporariamente indisponível

│   └── v1/Base: /api/v1/alerts

---

│       ├── controllers/

# 📝 Exemplos de Uso (curl)

│       │   ├── CompanyController.php- GET /api/v1/alerts

## Autenticação

```bash│       │   ├── UserController.php  - Lista alertas (filtros: company_id, tipo, status)

# Login

curl -X POST https://api.veigest.com/api/v1/auth/login \│       │   ├── VehicleController.php  - Permissão: alerts.view

  -H "Content-Type: application/json" \

  -d '{"email":"admin@veigest.com","password":"senha123"}'│       │   └── ...



# Usar token em requests subsequentes│       ├── models/- GET /api/v1/alerts/{id}

TOKEN="eyJ0eXAiOiJKV1..."

```│       └── Module.php  - Detalhes



## Gestão de Veículos├── config/  - Permissão: alerts.view

```bash

# Listar veículos da empresa 1└── web/

curl -H "Authorization: Bearer $TOKEN" \

  "https://api.veigest.com/api/v1/vehicles?company_id=1&estado=ativo"```- POST /api/v1/alerts



# Criar novo veículo  - Criar alerta manual

curl -X POST https://api.veigest.com/api/v1/vehicles \

  -H "Authorization: Bearer $TOKEN" \### Configuração Básica  - Corpo: { company_id, tipo, titulo, descricao?, detalhes?, prioridade? }

  -H "Content-Type: application/json" \

  -d '{```php  - Permissão: alerts.create

    "company_id": 1,

    "matricula": "BB-22-CC",// api/modules/v1/Module.php

    "marca": "BMW",

    "modelo": "320d",public function init()- PUT /api/v1/alerts/{id}

    "ano": 2023,

    "tipo_combustivel": "diesel",{  - Atualizar (ex: marcar resolvido)

    "quilometragem": 5000

  }'    parent::init();  - Permissão: alerts.resolve

```

    \Yii::$app->user->enableSession = false;

## Upload de Ficheiros

```bash}- DELETE /api/v1/alerts/{id}

# Upload de documento

curl -X POST https://api.veigest.com/api/v1/files \```  - Permissão: alerts.create

  -H "Authorization: Bearer $TOKEN" \

  -F "file=@seguro_veiculo.pdf" \

  -F "company_id=1"

### Controller Exemplo (VehicleController)---

# Associar ficheiro como documento

curl -X POST https://api.veigest.com/api/v1/documents \```php

  -H "Authorization: Bearer $TOKEN" \

  -H "Content-Type: application/json" \class VehicleController extends ActiveController### 9) Activity Logs

  -d '{

    "company_id": 1,{Base: /api/v1/activity-logs

    "file_id": 1,

    "vehicle_id": 1,    public $modelClass = 'common\models\Vehicle';

    "tipo": "seguro",

    "data_validade": "2026-12-31"    - GET /api/v1/activity-logs

  }'

```    public function behaviors()  - Lista logs (filtros: company_id, user_id, entidade)



## Rastreamento GPS    {  - Permissão: system.logs

```bash

# Iniciar nova rota        return ArrayHelper::merge(parent::behaviors(), [

curl -X POST https://api.veigest.com/api/v1/routes \

  -H "Authorization: Bearer $TOKEN" \            'authenticator' => [- GET /api/v1/activity-logs/{id}

  -H "Content-Type: application/json" \

  -d '{                'class' => HttpBearerAuth::class,  - Detalhes

    "company_id": 1,

    "vehicle_id": 1,            ],  - Permissão: system.logs

    "driver_id": 2,

    "inicio": "2025-11-08T08:00:00Z",            'rateLimiter' => [

    "km_inicial": 50000,

    "origem": "Lisboa"                'class' => RateLimiter::class,---

  }'

            ],

# Inserir pontos GPS em lote

curl -X POST https://api.veigest.com/api/v1/gps-entries/batch \        ]);### 10) Routes (Rotas)

  -H "Authorization: Bearer $TOKEN" \

  -H "Content-Type: application/json" \    }Base: /api/v1/routes

  -d '{

    "route_id": 1,    

    "points": [

      {    public function actions()- GET /api/v1/routes

        "latitude": 38.7223,

        "longitude": -9.1393,    {  - Lista rotas (filtros: company_id, vehicle_id, driver_id, status, periodo)

        "timestamp": "2025-11-08T08:15:00Z",

        "velocidade": 60.5        $actions = parent::actions();  - Permissão: routes.view

      },

      {        $actions['index']['dataFilter'] = [

        "latitude": 38.7300,

        "longitude": -9.1500,            'class' => ActiveDataFilter::class,- GET /api/v1/routes/{id}

        "timestamp": "2025-11-08T08:16:00Z",

        "velocidade": 65.0            'searchModel' => VehicleSearch::class,  - Detalhes da rota (inclui resumo) — considerar retornar link para pontos GPS paginados

      }

    ]        ];  - Permissão: routes.view

  }'

```        return $actions;



---    }- POST /api/v1/routes



# ⚙️ Notas de Implementação Yii2}  - Iniciar nova rota



## Estrutura do Projeto```  - Corpo: { company_id, vehicle_id, driver_id, inicio (ISO), km_inicial, origem }

```

api/  - Retorno: { id: route_id }

├── modules/

│   └── v1/---  - Permissão: routes.create

│       ├── controllers/

│       │   ├── CompanyController.php

│       │   ├── UserController.php

│       │   ├── VehicleController.php**Ficheiro completo:** API_ENDPOINTS.md  - PUT /api/v1/routes/{id}

│       │   ├── MaintenanceController.php

│       │   ├── FileController.php**Última atualização:** 8 de novembro de 2025  - Atualizar informações da rota (ex: km_final, destino, fim, status)

│       │   ├── DocumentController.php  - Permissão: routes.update

│       │   ├── FuelLogController.php

│       │   ├── AlertController.php- POST /api/v1/routes/{id}/finish

│       │   ├── ActivityLogController.php  - HTTP Verb: POST

│       │   ├── RouteController.php  - Endpoint: /api/v1/routes/{id}/finish

│       │   ├── GpsEntryController.php  - Descrição: Encerrar rota

│       │   ├── RbacController.php  - Parâmetros: path: id

│       │   └── AuthController.php  - Pedido:

│       ├── models/    { "km_final":120050, "destino":"Porto", "fim":"2025-11-07T10:30:00Z" }

│       └── Module.php  - Resposta (JSON):

├── config/    { "id":10, "status":"fechada" }

│   ├── main.php

│   └── params.php- DELETE /api/v1/routes/{id}

└── web/  - HTTP Verb: DELETE

    └── index.php  - Endpoint: /api/v1/routes/{id}

```  - Descrição: Remover rota

  - Parâmetros: path: id

## Configuração Base (api/config/main.php)  - Pedido: N/A

```php  - Resposta (JSON):

return [    { "success": true }

    'id' => 'app-api',

    'basePath' => dirname(__DIR__),---

    'bootstrap' => ['log'],

    'modules' => [### 11) GPS Entries

        'v1' => [Base: /api/v1/gps-entries

            'class' => 'api\modules\v1\Module',

        ],- GET /api/v1/gps-entries

    ],  - HTTP Verb: GET

    'components' => [  - Endpoint: /api/v1/gps-entries

        'user' => [  - Descrição: Lista pontos GPS (paginação obrigatória)

            'identityClass' => 'common\models\User',  - Parâmetros: ?route_id, ?from, ?to, ?page, ?pageSize

            'enableAutoLogin' => false,  - Pedido: N/A

            'enableSession' => false,  - Resposta (JSON):

            'loginUrl' => null,    { "items":[{"id":100,"latitude":38.7223,"longitude":-9.1393,"timestamp":"2025-11-07T08:05:10Z"}], "total":1 }

        ],

        'request' => [- GET /api/v1/gps-entries/{id}

            'parsers' => [  - HTTP Verb: GET

                'application/json' => 'yii\web\JsonParser',  - Endpoint: /api/v1/gps-entries/{id}

            ]  - Descrição: Detalhes

        ],  - Parâmetros: path: id

        'response' => [  - Pedido: N/A

            'format' => \yii\web\Response::FORMAT_JSON,  - Resposta (JSON):

        ],    { "id":100, "latitude":38.7223, "longitude":-9.1393, "timestamp":"2025-11-07T08:05:10Z" }

        'urlManager' => [

            'enablePrettyUrl' => true,- POST /api/v1/gps-entries

            'showScriptName' => false,  - HTTP Verb: POST

            'rules' => [  - Endpoint: /api/v1/gps-entries

                'api/v1/<controller:\w+>/<action:\w+>' => 'v1/<controller>/<action>',  - Descrição: Inserir ponto GPS (aceita batch)

                'api/v1/<controller:\w+>' => 'v1/<controller>',  - Parâmetros: N/A

            ],  - Pedido (single ou array):

        ],    { "route_id":10, "latitude":38.7223, "longitude":-9.1393, "timestamp":"2025-11-07T08:05:10Z", "velocidade":60.5 }

    ],  - Resposta (JSON):

];    { "inserted": 1 }

```

---

## Controller Base Exemplo

```php### 12) RBAC Management (roles / permissions / assignments)

namespace api\modules\v1\controllers;Base: /api/v1/rbac



use yii\rest\ActiveController;- GET /api/v1/rbac/roles

use yii\filters\auth\HttpBearerAuth;  - HTTP Verb: GET

use yii\filters\RateLimiter;  - Endpoint: /api/v1/rbac/roles

  - Descrição: Lista roles

class BaseController extends ActiveController  - Parâmetros: ?page

{  - Pedido: N/A

    public function behaviors()  - Resposta (JSON):

    {    { "items":[{"name":"admin"}], "total":1 }

        $behaviors = parent::behaviors();

        - POST /api/v1/rbac/roles

        $behaviors['authenticator'] = [  - HTTP Verb: POST

            'class' => HttpBearerAuth::class,  - Endpoint: /api/v1/rbac/roles

            'except' => ['options'], // CORS preflight  - Descrição: Criar role

        ];  - Parâmetros: N/A

          - Pedido:

        $behaviors['rateLimiter'] = [    { "name":"gestor", "description":"Gestor de frota" }

            'class' => RateLimiter::class,  - Resposta (JSON):

        ];    { "name":"gestor" }

        

        return $behaviors;- GET /api/v1/rbac/permissions

    }  - HTTP Verb: GET

      - Endpoint: /api/v1/rbac/permissions

    protected function checkCompanyAccess($companyId)  - Descrição: Lista permissões

    {  - Parâmetros: ?page

        $user = \Yii::$app->user->identity;  - Pedido: N/A

        if (!$user->canAccessCompany($companyId)) {  - Resposta (JSON):

            throw new ForbiddenHttpException('Access denied to company resources');    { "items":[{"name":"vehicles.view"}], "total":1 }

        }

    }- POST /api/v1/rbac/assign

}  - Atribuir role/permission a user

```  - Corpo: { item_name, user_id }

  - Permissão: system.config

## RBAC Integration

```php---

// Em cada controller action

if (!\Yii::$app->user->can('vehicles.view')) {### 13) Auth (Login / Logout / Refresh)

    throw new ForbiddenHttpException('Insufficient permissions');Base: /api/v1/auth

}

- POST /api/v1/auth/login

// Filtro automático por empresa  - Corpo: { email, password }

$query = Vehicle::find()->where(['company_id' => $user->company_id]);  - Retorno: { access_token, expires_in, token_type }

```

- POST /api/v1/auth/logout

## Validações Específicas  - Header Authorization required

- **Multi-empresa:** Todos os recursos devem validar `company_id`

- **RBAC:** Verificar permissões antes de cada operação- POST /api/v1/auth/refresh

- **Soft Delete:** Usar `estado` em vez de DELETE físico  - Refresh token flow (se implementado)

- **Auditoria:** Log automático de ações em `activity_logs`

- **Rate Limiting:** Por utilizador e por endpoint---



---## Exemplos (curl)



**Documentação Completa:** VeiGest API v1  - Login (obter token)

**Última atualização:** 8 de novembro de 2025  

**Schema:** Ultra-Lean (12 tabelas + 4 RBAC + 4 views)  ```bash

**RBAC:** 6 roles, 40+ permissões granularescurl -X POST https://api.example.com/api/v1/auth/login \
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