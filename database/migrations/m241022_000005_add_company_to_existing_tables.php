<?php

use yii\db\Migration;

/**
 * Handles adding company relationship to existing tables.
 * Adiciona company_id às tabelas users e vehicles
 */
class m241022_000005_add_company_to_existing_tables extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        // Adicionar company_id à tabela users
        $this->addColumn('{{%users}}', 'company_id', $this->integer());

        // Adicionar foreign key para users
        $this->addForeignKey(
            'fk-users-company_id',
            '{{%users}}',
            'company_id',
            '{{%companies}}',
            'id',
            'CASCADE'
        );

        // Adicionar índice para users
        $this->createIndex('idx-users-company_id', '{{%users}}', 'company_id');

        // Adicionar company_id à tabela vehicles
        $this->addColumn('{{%vehicles}}', 'company_id', $this->integer());

        // Adicionar foreign key para vehicles
        $this->addForeignKey(
            'fk-vehicles-company_id',
            '{{%vehicles}}',
            'company_id',
            '{{%companies}}',
            'id',
            'CASCADE'
        );

        // Adicionar índice para vehicles
        $this->createIndex('idx-vehicles-company_id', '{{%vehicles}}', 'company_id');

        // Migrar dados existentes para a empresa padrão
        $defaultCompanyId = $this->db->createCommand("SELECT id FROM {{%companies}} WHERE nif = '999999990'")->queryScalar();
        
        if ($defaultCompanyId) {
            // Atualizar users existentes
            $this->update('{{%users}}', ['company_id' => $defaultCompanyId], 'company_id IS NULL');
            
            // Atualizar vehicles existentes
            $this->update('{{%vehicles}}', ['company_id' => $defaultCompanyId], 'company_id IS NULL');
        }

        // Tornar company_id obrigatório após migração
        $this->alterColumn('{{%users}}', 'company_id', $this->integer()->notNull());
        $this->alterColumn('{{%vehicles}}', 'company_id', $this->integer()->notNull());

        // Adicionar company_id a outras tabelas importantes
        $tablesToUpdate = [
            'maintenances',
            'fuel_logs',
            'routes',
            'alerts',
            'reports',
            'activity_logs',
            'support_tickets'
        ];

        foreach ($tablesToUpdate as $table) {
            // Verificar se a tabela existe antes de adicionar a coluna
            $tableExists = $this->db->createCommand("SHOW TABLES LIKE '{{%{$table}}}'")->queryScalar();
            
            if ($tableExists) {
                $this->addColumn("{{%{$table}}}", 'company_id', $this->integer());
                
                $this->addForeignKey(
                    "fk-{$table}-company_id",
                    "{{%{$table}}}",
                    'company_id',
                    '{{%companies}}',
                    'id',
                    'CASCADE'
                );
                
                $this->createIndex("idx-{$table}-company_id", "{{%{$table}}}", 'company_id');
                
                // Migrar dados existentes
                if ($defaultCompanyId) {
                    $this->update("{{%{$table}}}", ['company_id' => $defaultCompanyId], 'company_id IS NULL');
                }
                
                // Tornar obrigatório
                $this->alterColumn("{{%{$table}}}", 'company_id', $this->integer()->notNull());
            }
        }
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        // Remover company_id das tabelas adicionais
        $tablesToUpdate = [
            'maintenances',
            'fuel_logs', 
            'routes',
            'alerts',
            'reports',
            'activity_logs',
            'support_tickets'
        ];

        foreach ($tablesToUpdate as $table) {
            $tableExists = $this->db->createCommand("SHOW TABLES LIKE '{{%{$table}}}'")->queryScalar();
            
            if ($tableExists) {
                $this->dropForeignKey("fk-{$table}-company_id", "{{%{$table}}}");
                $this->dropIndex("idx-{$table}-company_id", "{{%{$table}}}");
                $this->dropColumn("{{%{$table}}}", 'company_id');
            }
        }

        // Remover company_id das tabelas principais
        $this->dropForeignKey('fk-users-company_id', '{{%users}}');
        $this->dropIndex('idx-users-company_id', '{{%users}}');
        $this->dropColumn('{{%users}}', 'company_id');

        $this->dropForeignKey('fk-vehicles-company_id', '{{%vehicles}}');
        $this->dropIndex('idx-vehicles-company_id', '{{%vehicles}}');
        $this->dropColumn('{{%vehicles}}', 'company_id');
    }
}
