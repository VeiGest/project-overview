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
2. `m241016_000002_create_drivers_profiles_table.php` - Perfis de condutores
3. `m241016_000003_create_vehicles_table.php` - Veículos
4. `m241016_000004_create_maintenances_table.php` - Manutenções
5. `m241016_000005_create_documents_table.php` - Documentos
6. `m241016_000006_create_fuel_logs_table.php` - Registos de combustível
7. `m241016_000007_create_routes_table.php` - Rotas e viagens
8. `m241016_000008_create_gps_points_table.php` - Pontos GPS
9. `m241016_000009_create_alerts_table.php` - Alertas
10. `m241016_000010_create_reports_table.php` - Relatórios
11. `m241016_000011_create_activity_logs_table.php` - Logs de atividade
12. `m241016_000012_create_settings_table.php` - Configurações
13. `m241016_000013_create_support_tickets_table.php` - Tickets de suporte
14. `m241016_000014_insert_initial_data.php` - Dados iniciais

## Reverter Migrations

Para reverter todas as migrations:

```bash
php yii migrate/down all
```

Para reverter uma migration específica:

```bash
php yii migrate/down 1
```
