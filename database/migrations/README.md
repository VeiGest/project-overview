# Migrations para VeiGest - Yii2 Framework

Este diretório contém as migrations do banco de dados para o projeto VeiGest.

## Como usar

1. Copie os arquivos de migration para `console/migrations/` no seu projeto Yii2
2. Execute as migrations em ordem:

```bash
php yii migrate/up
```

## Ordem das Migrations

1. `m241016_000001_create_users_table.php` - Tabela de usuários
2. `m241016_000002_create_roles_permissions_tables.php` - ⭐ Sistema de Roles e Permissions
3. `m241016_000003_create_vehicles_table.php` - Veículos
4. `m241016_000004_create_drivers_profiles_table.php` - Perfis de condutores
5. `m241016_000005_create_maintenances_table.php` - Manutenções
6. `m241016_000006_create_documents_table.php` - Documentos
7. `m241016_000007_create_fuel_logs_table.php` - Registos de combustível
8. `m241016_000008_create_routes_table.php` - Rotas e viagens
9. `m241016_000009_create_gps_points_table.php` - Pontos GPS
10. `m241016_000010_create_alerts_table.php` - Alertas
11. `m241016_000011_create_reports_table.php` - Relatórios
12. `m241016_000012_create_activity_logs_table.php` - Logs de atividade
13. `m241016_000013_create_settings_table.php` - Configurações
14. `m241016_000014_create_support_tickets_table.php` - Tickets de suporte
15. `m241016_000015_insert_initial_data.php` - Dados iniciais

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

## Reverter Migrations

Para reverter todas as migrations:

```bash
php yii migrate/down all
```

Para reverter uma migration específica:

```bash
php yii migrate/down 1
```
