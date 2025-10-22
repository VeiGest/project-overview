# Migrations para VeiGest - Yii2 Framework

Este diretório contém as migrations do banco de dados para o projeto VeiGest.

## Como usar

1. Copie os arquivos de migration para `console/migrations/` no seu projeto Yii2
2. Execute as migrations em ordem:

```bash
php yii migrate/up
```

## Ordem das Migrations

### Migrations Base
1. `m241016_000001_create_users_table.php` - Tabela de usuários
2. `m241016_000002_create_roles_permissions_tables.php` - ⭐ Sistema de Roles e Permissions
3. `m241016_000003_create_vehicles_table.php` - Veículos
4. `m241016_000004_create_drivers_profiles_table.php` - Perfis de condutores
5. `m241016_000005_create_maintenances_table.php` - Manutenções
6. `m241016_000006_create_documents_table.php` - Documentos (versão antiga)
7. `m241016_000007_create_fuel_logs_table.php` - Registos de combustível
8. `m241016_000008_create_routes_table.php` - Rotas e viagens
9. `m241016_000009_create_gps_points_table.php` - Pontos GPS
10. `m241016_000010_create_alerts_table.php` - Alertas
11. `m241016_000011_create_reports_table.php` - Relatórios
12. `m241016_000012_create_activity_logs_table.php` - Logs de atividade
13. `m241016_000013_create_settings_table.php` - Configurações
14. `m241016_000014_create_support_tickets_table.php` - Tickets de suporte
15. `m241016_000015_insert_initial_data.php` - Dados iniciais

### 🆕 Novas Migrations (Sistema Multi-Empresa e Ficheiros)
16. `m241022_000001_create_companies_table.php` - ⭐ **Tabela de Empresas**
17. `m241022_000002_add_company_to_settings.php` - ⭐ **Relacionar Settings por Empresa**
18. `m241022_000003_create_files_table.php` - ⭐ **Sistema de Ficheiros (CDN/FileStash)**
19. `m241022_000004_create_documents_table.php` - ⭐ **Nova Tabela de Documentos**
20. `m241022_000005_add_company_to_existing_tables.php` - ⭐ **Relacionar Tabelas Existentes com Empresas**

### ⭐ Nova Funcionalidade: Sistema de Roles e Permissions

A migration `m241016_000002_create_roles_permissions_tables.php` implementa um sistema robusto de controlo de acesso baseado em RBAC (Role-Based Access Control):

**Estrutura**: User → Role → Permission

**Tabelas Criadas**:
- `roles` - Definição de funções/papéis
- `permissions` - Permissões específicas do sistema  
- `role_permissions` - Relacionamento N:N entre roles e permissions
- Adiciona `role_id` à tabela `users`

**Roles Pré-definidos**:
- Super Administrador (nível 100)
- Administrador (nível 90)
- Gestor de Frota (nível 50)
- Gestor de Manutenção (nível 40)
- Condutor Senior (nível 20)
- Condutor (nível 10)
- Visualizador (nível 5)

**Permissions por Módulo**:
- users, vehicles, drivers, maintenances, documents
- fuel_logs, routes, alerts, reports, system, dashboard

Ver documentação completa em `database/ROLES_PERMISSIONS.md`

### 🆕 Novas Funcionalidades: Sistema Multi-Empresa e Gestão de Ficheiros

#### 🏢 Sistema Multi-Empresa
O VeiGest agora suporta múltiplas empresas numa única instalação:

**Funcionalidades**:
- **Isolamento de Dados**: Cada empresa tem os seus próprios dados
- **Configurações por Empresa**: Settings específicos por organização
- **Planos de Subscrição**: Diferentes planos (básico, profissional, enterprise)
- **Limites Configuráveis**: Controlo de número de veículos e condutores
- **Gestão Centralizada**: Administração de múltiplas empresas

**Tabelas Afetadas**:
- `companies` - Dados das empresas
- `users` - Relacionados com empresa
- `vehicles` - Relacionados com empresa
- `settings` - Configurações por empresa
- Todas as tabelas principais agora têm `company_id`

#### 📁 Sistema de Gestão de Ficheiros
Sistema robusto para gestão de ficheiros com suporte a CDN/FileStash:

**Funcionalidades**:
- **Multi-Servidor**: Suporte a FileStash, AWS S3, Google Cloud, Azure
- **Integridade**: Verificação MD5 e SHA256
- **Metadados**: Tags, categorias e metadados personalizados
- **Controlo de Acesso**: Ficheiros públicos, privados ou restritos
- **Versionamento**: Histórico de versões de ficheiros
- **Expiração**: Controlo de validade de ficheiros

**Estrutura**:
- `files` - Gestão de ficheiros físicos
- `documents` - Documentos do negócio que referenciam ficheiros
- Separação clara entre ficheiro físico e documento lógico

#### 📄 Novo Sistema de Documentos
Sistema avançado de documentos com versionamento e workflow:

**Funcionalidades**:
- **Tipos Específicos**: DUA, seguros, inspeções, cartas de condução, etc.
- **Controlo de Validade**: Alertas automáticos antes da expiração
- **Versionamento**: Histórico completo de versões
- **Workflow**: Estados (válido, expirado, por renovar, etc.)
- **Auditoria**: Controlo completo de quem criou/modificou
- **Classificação**: Categorias, prioridades e tags

**Melhorias**:
- Substituição da tabela `documents` antiga
- Integração com sistema de ficheiros
- Notificações inteligentes
- Renovação automática configurável

## Reverter Migrations

Para reverter todas as migrations:

```bash
php yii migrate/down all
```

Para reverter uma migration específica:

```bash
php yii migrate/down 1
```
