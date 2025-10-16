<?php

use yii\db\Migration;

/**
 * Handles the creation of roles and permissions system tables.
 * Implements User -> Role -> Permission relationship
 */
class m241016_000002_create_roles_permissions_tables extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        // 1. Criar tabela de roles
        $this->createTable('{{%roles}}', [
            'id' => $this->primaryKey(),
            'nome' => $this->string(100)->notNull()->unique(),
            'descricao' => $this->text(),
            'slug' => $this->string(100)->notNull()->unique(),
            'nivel_hierarquia' => $this->integer()->notNull()->defaultValue(1), // Para ordenação hierárquica
            'ativo' => $this->boolean()->notNull()->defaultValue(true),
            'criado_em' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            'atualizado_em' => $this->dateTime()->defaultExpression('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
        ]);

        // 2. Criar tabela de permissions
        $this->createTable('{{%permissions}}', [
            'id' => $this->primaryKey(),
            'nome' => $this->string(100)->notNull()->unique(),
            'descricao' => $this->text(),
            'modulo' => $this->string(50)->notNull(), // Ex: vehicles, users, reports
            'acao' => $this->string(50)->notNull(), // Ex: create, read, update, delete
            'slug' => $this->string(100)->notNull()->unique(),
            'ativo' => $this->boolean()->notNull()->defaultValue(true),
            'criado_em' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            'atualizado_em' => $this->dateTime()->defaultExpression('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
        ]);

        // 3. Criar tabela de relacionamento role_permissions (N:N)
        $this->createTable('{{%role_permissions}}', [
            'id' => $this->primaryKey(),
            'role_id' => $this->integer()->notNull(),
            'permission_id' => $this->integer()->notNull(),
            'criado_em' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        // 4. Adicionar coluna role_id na tabela users
        $this->addColumn('{{%users}}', 'role_id', $this->integer());

        // Foreign Keys
        $this->addForeignKey(
            'fk-role_permissions-role_id',
            '{{%role_permissions}}',
            'role_id',
            '{{%roles}}',
            'id',
            'CASCADE'
        );

        $this->addForeignKey(
            'fk-role_permissions-permission_id',
            '{{%role_permissions}}',
            'permission_id',
            '{{%permissions}}',
            'id',
            'CASCADE'
        );

        $this->addForeignKey(
            'fk-users-role_id',
            '{{%users}}',
            'role_id',
            '{{%roles}}',
            'id',
            'SET NULL'
        );

        // Indexes
        $this->createIndex('idx-roles-slug', '{{%roles}}', 'slug');
        $this->createIndex('idx-roles-nivel_hierarquia', '{{%roles}}', 'nivel_hierarquia');
        $this->createIndex('idx-permissions-slug', '{{%permissions}}', 'slug');
        $this->createIndex('idx-permissions-modulo', '{{%permissions}}', 'modulo');
        $this->createIndex('idx-permissions-acao', '{{%permissions}}', 'acao');
        $this->createIndex('idx-role_permissions-role_id', '{{%role_permissions}}', 'role_id');
        $this->createIndex('idx-role_permissions-permission_id', '{{%role_permissions}}', 'permission_id');
        $this->createIndex('idx-users-role_id', '{{%users}}', 'role_id');

        // Unique constraint para evitar duplicatas na tabela role_permissions
        $this->createIndex('uk-role_permissions-role_permission', '{{%role_permissions}}', ['role_id', 'permission_id'], true);

        // Inserir roles padrão
        $this->insertDefaultRoles();

        // Inserir permissions padrão
        $this->insertDefaultPermissions();

        // Associar permissions aos roles
        $this->assignPermissionsToRoles();

        // Migrar dados existentes da coluna role para role_id
        $this->migrateExistingRoleData();
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        // Remover foreign keys
        $this->dropForeignKey('fk-users-role_id', '{{%users}}');
        $this->dropForeignKey('fk-role_permissions-role_id', '{{%role_permissions}}');
        $this->dropForeignKey('fk-role_permissions-permission_id', '{{%role_permissions}}');

        // Remover coluna role_id da tabela users
        $this->dropColumn('{{%users}}', 'role_id');

        // Remover tabelas
        $this->dropTable('{{%role_permissions}}');
        $this->dropTable('{{%permissions}}');
        $this->dropTable('{{%roles}}');
    }

    /**
     * Inserir roles padrão do sistema
     */
    private function insertDefaultRoles()
    {
        $this->batchInsert('{{%roles}}', ['nome', 'descricao', 'slug', 'nivel_hierarquia'], [
            [
                'Super Administrador',
                'Acesso total ao sistema, incluindo configurações críticas e gestão de utilizadores.',
                'super-admin',
                100
            ],
            [
                'Administrador',
                'Administrador geral com acesso a todas as funcionalidades exceto configurações críticas.',
                'admin',
                90
            ],
            [
                'Gestor de Frota',
                'Gestor responsável pela frota, veículos, condutores e relatórios operacionais.',
                'gestor',
                50
            ],
            [
                'Gestor de Manutenção',
                'Responsável pela gestão de manutenções, documentos e alertas dos veículos.',
                'gestor-manutencao',
                40
            ],
            [
                'Condutor Senior',
                'Condutor experiente com permissões adicionais para relatórios e histórico.',
                'condutor-senior',
                20
            ],
            [
                'Condutor',
                'Condutor padrão com acesso básico à aplicação móvel e funcionalidades essenciais.',
                'condutor',
                10
            ],
            [
                'Visualizador',
                'Acesso apenas de leitura para consulta de dados e relatórios.',
                'visualizador',
                5
            ]
        ]);
    }

    /**
     * Inserir permissions padrão do sistema
     */
    private function insertDefaultPermissions()
    {
        $permissions = [
            // Gestão de Utilizadores
            ['Criar Utilizadores', 'users', 'create', 'users.create'],
            ['Ver Utilizadores', 'users', 'read', 'users.read'],
            ['Editar Utilizadores', 'users', 'update', 'users.update'],
            ['Eliminar Utilizadores', 'users', 'delete', 'users.delete'],
            ['Gerir Roles', 'users', 'manage_roles', 'users.manage_roles'],

            // Gestão de Veículos
            ['Criar Veículos', 'vehicles', 'create', 'vehicles.create'],
            ['Ver Veículos', 'vehicles', 'read', 'vehicles.read'],
            ['Editar Veículos', 'vehicles', 'update', 'vehicles.update'],
            ['Eliminar Veículos', 'vehicles', 'delete', 'vehicles.delete'],
            ['Atribuir Condutores', 'vehicles', 'assign_driver', 'vehicles.assign_driver'],

            // Gestão de Condutores
            ['Criar Perfis de Condutores', 'drivers', 'create', 'drivers.create'],
            ['Ver Perfis de Condutores', 'drivers', 'read', 'drivers.read'],
            ['Editar Perfis de Condutores', 'drivers', 'update', 'drivers.update'],
            ['Eliminar Perfis de Condutores', 'drivers', 'delete', 'drivers.delete'],
            ['Ver Histórico de Condutores', 'drivers', 'view_history', 'drivers.view_history'],

            // Manutenções
            ['Criar Manutenções', 'maintenances', 'create', 'maintenances.create'],
            ['Ver Manutenções', 'maintenances', 'read', 'maintenances.read'],
            ['Editar Manutenções', 'maintenances', 'update', 'maintenances.update'],
            ['Eliminar Manutenções', 'maintenances', 'delete', 'maintenances.delete'],
            ['Agendar Manutenções', 'maintenances', 'schedule', 'maintenances.schedule'],

            // Documentos
            ['Upload de Documentos', 'documents', 'create', 'documents.create'],
            ['Ver Documentos', 'documents', 'read', 'documents.read'],
            ['Editar Documentos', 'documents', 'update', 'documents.update'],
            ['Eliminar Documentos', 'documents', 'delete', 'documents.delete'],
            ['Gerir Validades', 'documents', 'manage_validity', 'documents.manage_validity'],

            // Registos de Combustível
            ['Registar Combustível', 'fuel_logs', 'create', 'fuel_logs.create'],
            ['Ver Registos de Combustível', 'fuel_logs', 'read', 'fuel_logs.read'],
            ['Editar Registos de Combustível', 'fuel_logs', 'update', 'fuel_logs.update'],
            ['Eliminar Registos de Combustível', 'fuel_logs', 'delete', 'fuel_logs.delete'],

            // Rotas e Viagens
            ['Iniciar Viagens', 'routes', 'create', 'routes.create'],
            ['Ver Rotas', 'routes', 'read', 'routes.read'],
            ['Editar Rotas', 'routes', 'update', 'routes.update'],
            ['Eliminar Rotas', 'routes', 'delete', 'routes.delete'],
            ['Ver Tracking GPS', 'routes', 'view_gps', 'routes.view_gps'],

            // Alertas
            ['Criar Alertas', 'alerts', 'create', 'alerts.create'],
            ['Ver Alertas', 'alerts', 'read', 'alerts.read'],
            ['Marcar Alertas como Resolvidos', 'alerts', 'resolve', 'alerts.resolve'],
            ['Configurar Alertas', 'alerts', 'configure', 'alerts.configure'],

            // Relatórios
            ['Gerar Relatórios', 'reports', 'create', 'reports.create'],
            ['Ver Relatórios', 'reports', 'read', 'reports.read'],
            ['Exportar Relatórios', 'reports', 'export', 'reports.export'],
            ['Relatórios Avançados', 'reports', 'advanced', 'reports.advanced'],

            // Sistema e Configurações
            ['Configurações do Sistema', 'system', 'config', 'system.config'],
            ['Ver Logs de Atividade', 'system', 'view_logs', 'system.view_logs'],
            ['Gerir Backups', 'system', 'backup', 'system.backup'],
            ['Suporte Técnico', 'system', 'support', 'system.support'],

            // Dashboard
            ['Ver Dashboard', 'dashboard', 'read', 'dashboard.read'],
            ['Dashboard Avançado', 'dashboard', 'advanced', 'dashboard.advanced'],
        ];

        foreach ($permissions as $permission) {
            $this->insert('{{%permissions}}', [
                'nome' => $permission[0],
                'modulo' => $permission[1],
                'acao' => $permission[2],
                'slug' => $permission[3],
                'descricao' => "Permissão para {$permission[0]}"
            ]);
        }
    }

    /**
     * Associar permissions aos roles
     */
    private function assignPermissionsToRoles()
    {
        // Super Admin - Todas as permissões
        $superAdminId = $this->db->createCommand("SELECT id FROM {{%roles}} WHERE slug = 'super-admin'")->queryScalar();
        $allPermissions = $this->db->createCommand("SELECT id FROM {{%permissions}}")->queryColumn();
        
        foreach ($allPermissions as $permissionId) {
            $this->insert('{{%role_permissions}}', [
                'role_id' => $superAdminId,
                'permission_id' => $permissionId
            ]);
        }

        // Admin - Quase todas exceto configurações críticas
        $adminId = $this->db->createCommand("SELECT id FROM {{%roles}} WHERE slug = 'admin'")->queryScalar();
        $adminPermissions = $this->db->createCommand(
            "SELECT id FROM {{%permissions}} WHERE slug NOT IN ('system.config', 'system.backup')"
        )->queryColumn();
        
        foreach ($adminPermissions as $permissionId) {
            $this->insert('{{%role_permissions}}', [
                'role_id' => $adminId,
                'permission_id' => $permissionId
            ]);
        }

        // Gestor de Frota
        $gestorId = $this->db->createCommand("SELECT id FROM {{%roles}} WHERE slug = 'gestor'")->queryScalar();
        $gestorPermissions = [
            'vehicles.create', 'vehicles.read', 'vehicles.update', 'vehicles.assign_driver',
            'drivers.create', 'drivers.read', 'drivers.update', 'drivers.view_history',
            'fuel_logs.read', 'fuel_logs.update',
            'routes.read', 'routes.view_gps',
            'alerts.read', 'alerts.resolve',
            'reports.create', 'reports.read', 'reports.export',
            'dashboard.read', 'dashboard.advanced'
        ];
        
        foreach ($gestorPermissions as $slug) {
            $permissionId = $this->db->createCommand("SELECT id FROM {{%permissions}} WHERE slug = :slug", [':slug' => $slug])->queryScalar();
            if ($permissionId) {
                $this->insert('{{%role_permissions}}', [
                    'role_id' => $gestorId,
                    'permission_id' => $permissionId
                ]);
            }
        }

        // Gestor de Manutenção
        $gestorManutencaoId = $this->db->createCommand("SELECT id FROM {{%roles}} WHERE slug = 'gestor-manutencao'")->queryScalar();
        $manutencaoPermissions = [
            'vehicles.read',
            'maintenances.create', 'maintenances.read', 'maintenances.update', 'maintenances.schedule',
            'documents.create', 'documents.read', 'documents.update', 'documents.manage_validity',
            'alerts.create', 'alerts.read', 'alerts.resolve', 'alerts.configure',
            'reports.read',
            'dashboard.read'
        ];
        
        foreach ($manutencaoPermissions as $slug) {
            $permissionId = $this->db->createCommand("SELECT id FROM {{%permissions}} WHERE slug = :slug", [':slug' => $slug])->queryScalar();
            if ($permissionId) {
                $this->insert('{{%role_permissions}}', [
                    'role_id' => $gestorManutencaoId,
                    'permission_id' => $permissionId
                ]);
            }
        }

        // Condutor Senior
        $condutorSeniorId = $this->db->createCommand("SELECT id FROM {{%roles}} WHERE slug = 'condutor-senior'")->queryScalar();
        $condutorSeniorPermissions = [
            'vehicles.read',
            'drivers.read',
            'fuel_logs.create', 'fuel_logs.read',
            'routes.create', 'routes.read',
            'alerts.read',
            'reports.read',
            'dashboard.read'
        ];
        
        foreach ($condutorSeniorPermissions as $slug) {
            $permissionId = $this->db->createCommand("SELECT id FROM {{%permissions}} WHERE slug = :slug", [':slug' => $slug])->queryScalar();
            if ($permissionId) {
                $this->insert('{{%role_permissions}}', [
                    'role_id' => $condutorSeniorId,
                    'permission_id' => $permissionId
                ]);
            }
        }

        // Condutor
        $condutorId = $this->db->createCommand("SELECT id FROM {{%roles}} WHERE slug = 'condutor'")->queryScalar();
        $condutorPermissions = [
            'vehicles.read',
            'fuel_logs.create', 'fuel_logs.read',
            'routes.create', 'routes.read',
            'alerts.read',
            'dashboard.read'
        ];
        
        foreach ($condutorPermissions as $slug) {
            $permissionId = $this->db->createCommand("SELECT id FROM {{%permissions}} WHERE slug = :slug", [':slug' => $slug])->queryScalar();
            if ($permissionId) {
                $this->insert('{{%role_permissions}}', [
                    'role_id' => $condutorId,
                    'permission_id' => $permissionId
                ]);
            }
        }

        // Visualizador
        $visualizadorId = $this->db->createCommand("SELECT id FROM {{%roles}} WHERE slug = 'visualizador'")->queryScalar();
        $visualizadorPermissions = [
            'vehicles.read',
            'drivers.read',
            'fuel_logs.read',
            'routes.read',
            'alerts.read',
            'reports.read',
            'dashboard.read'
        ];
        
        foreach ($visualizadorPermissions as $slug) {
            $permissionId = $this->db->createCommand("SELECT id FROM {{%permissions}} WHERE slug = :slug", [':slug' => $slug])->queryScalar();
            if ($permissionId) {
                $this->insert('{{%role_permissions}}', [
                    'role_id' => $visualizadorId,
                    'permission_id' => $permissionId
                ]);
            }
        }
    }

    /**
     * Migrar dados existentes da coluna role para role_id
     */
    private function migrateExistingRoleData()
    {
        // Mapear roles antigos para novos IDs
        $roleMapping = [
            'admin' => 'admin',
            'gestor' => 'gestor',
            'condutor' => 'condutor'
        ];

        foreach ($roleMapping as $oldRole => $newRoleSlug) {
            $roleId = $this->db->createCommand("SELECT id FROM {{%roles}} WHERE slug = :slug", [':slug' => $newRoleSlug])->queryScalar();
            if ($roleId) {
                $this->update('{{%users}}', ['role_id' => $roleId], ['role' => $oldRole]);
            }
        }
    }
}
