<?php

use yii\db\Migration;

/**
 * Handles adding company relationship to settings table.
 * Permite configurações específicas por empresa
 */
class m241022_000002_add_company_to_settings extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        // Adicionar coluna company_id à tabela settings
        $this->addColumn('{{%settings}}', 'company_id', $this->integer());

        // Adicionar foreign key
        $this->addForeignKey(
            'fk-settings-company_id',
            '{{%settings}}',
            'company_id',
            '{{%companies}}',
            'id',
            'CASCADE'
        );

        // Adicionar índice
        $this->createIndex('idx-settings-company_id', '{{%settings}}', 'company_id');

        // Modificar o índice único da chave para incluir company_id
        $this->dropIndex('idx_chave', '{{%settings}}');
        $this->createIndex('uk-settings-chave-company', '{{%settings}}', ['chave', 'company_id'], true);

        // Migrar dados existentes para a empresa padrão
        $defaultCompanyId = $this->db->createCommand("SELECT id FROM {{%companies}} WHERE nif = '999999990'")->queryScalar();
        
        if ($defaultCompanyId) {
            $this->update('{{%settings}}', ['company_id' => $defaultCompanyId], 'company_id IS NULL');
        }

        // Tornar company_id obrigatório após migração
        $this->alterColumn('{{%settings}}', 'company_id', $this->integer()->notNull());
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        // Remover foreign key e índices
        $this->dropForeignKey('fk-settings-company_id', '{{%settings}}');
        $this->dropIndex('uk-settings-chave-company', '{{%settings}}');
        $this->dropIndex('idx-settings-company_id', '{{%settings}}');
        
        // Restaurar índice original
        $this->createIndex('idx_chave', '{{%settings}}', 'chave');
        
        // Remover coluna
        $this->dropColumn('{{%settings}}', 'company_id');
    }
}
