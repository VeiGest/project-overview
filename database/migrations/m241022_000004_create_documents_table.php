<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%documents}}`.
 * Sistema de documentos que referencia a tabela de ficheiros
 */
class m241022_000004_create_documents_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%documents}}', [
            'id' => $this->primaryKey(),
            'company_id' => $this->integer()->notNull(),
            'file_id' => $this->integer()->notNull(), // Referência para a tabela files
            
            // Entidade associada (veículo ou condutor)
            'vehicle_id' => $this->integer(),
            'driver_id' => $this->integer(),
            
            // Informações do documento
            'tipo' => "ENUM('dua', 'seguro', 'inspecao', 'carta_conducao', 'licenca_conducao', 'certificado_formacao', 'contrato', 'manual', 'outro') NOT NULL",
            'numero_documento' => $this->string(100),
            'entidade_emissora' => $this->string(200),
            'data_emissao' => $this->date(),
            'data_validade' => $this->date(),
            'renovacao_automatica' => $this->boolean()->defaultValue(false),
            
            // Classificação e organização
            'categoria' => $this->string(50), // legal, operacional, administrativo, etc.
            'prioridade' => "ENUM('baixa', 'normal', 'alta', 'critica') NOT NULL DEFAULT 'normal'",
            'confidencial' => $this->boolean()->defaultValue(false),
            'tags' => $this->json(), // Tags para organização
            
            // Status e controlo
            'status' => "ENUM('valido', 'expirado', 'por_renovar', 'cancelado', 'suspenso') NOT NULL DEFAULT 'valido'",
            'observacoes' => $this->text(),
            'lembrete_dias' => $this->integer()->defaultValue(30), // Dias antes da expiração para lembrete
            'notificacao_enviada' => $this->boolean()->defaultValue(false),
            'data_ultima_verificacao' => $this->dateTime(),
            
            // Histórico e versioning
            'versao' => $this->integer()->defaultValue(1),
            'documento_anterior_id' => $this->integer(), // Referência para versão anterior
            'motivo_atualizacao' => $this->text(), // Motivo da atualização/nova versão
            
            // Auditoria
            'criado_por' => $this->integer()->notNull(),
            'atualizado_por' => $this->integer(),
            'verificado_por' => $this->integer(),
            'data_verificacao' => $this->dateTime(),
            'criado_em' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            'atualizado_em' => $this->dateTime()->defaultExpression('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
        ]);

        // Foreign Keys
        $this->addForeignKey(
            'fk-documents-company_id',
            '{{%documents}}',
            'company_id',
            '{{%companies}}',
            'id',
            'CASCADE'
        );

        $this->addForeignKey(
            'fk-documents-file_id',
            '{{%documents}}',
            'file_id',
            '{{%files}}',
            'id',
            'RESTRICT'
        );

        $this->addForeignKey(
            'fk-documents-vehicle_id',
            '{{%documents}}',
            'vehicle_id',
            '{{%vehicles}}',
            'id',
            'CASCADE'
        );

        $this->addForeignKey(
            'fk-documents-driver_id',
            '{{%documents}}',
            'driver_id',
            '{{%users}}',
            'id',
            'CASCADE'
        );

        $this->addForeignKey(
            'fk-documents-criado_por',
            '{{%documents}}',
            'criado_por',
            '{{%users}}',
            'id',
            'RESTRICT'
        );

        $this->addForeignKey(
            'fk-documents-atualizado_por',
            '{{%documents}}',
            'atualizado_por',
            '{{%users}}',
            'id',
            'RESTRICT'
        );

        $this->addForeignKey(
            'fk-documents-verificado_por',
            '{{%documents}}',
            'verificado_por',
            '{{%users}}',
            'id',
            'RESTRICT'
        );

        $this->addForeignKey(
            'fk-documents-documento_anterior_id',
            '{{%documents}}',
            'documento_anterior_id',
            '{{%documents}}',
            'id',
            'SET NULL'
        );

        // Indexes
        $this->createIndex('idx-documents-company_id', '{{%documents}}', 'company_id');
        $this->createIndex('idx-documents-file_id', '{{%documents}}', 'file_id');
        $this->createIndex('idx-documents-vehicle_id', '{{%documents}}', 'vehicle_id');
        $this->createIndex('idx-documents-driver_id', '{{%documents}}', 'driver_id');
        $this->createIndex('idx-documents-tipo', '{{%documents}}', 'tipo');
        $this->createIndex('idx-documents-status', '{{%documents}}', 'status');
        $this->createIndex('idx-documents-data_validade', '{{%documents}}', 'data_validade');
        $this->createIndex('idx-documents-categoria', '{{%documents}}', 'categoria');
        $this->createIndex('idx-documents-prioridade', '{{%documents}}', 'prioridade');
        $this->createIndex('idx-documents-criado_por', '{{%documents}}', 'criado_por');
        $this->createIndex('idx-documents-numero_documento', '{{%documents}}', 'numero_documento');
        $this->createIndex('idx-documents-confidencial', '{{%documents}}', 'confidencial');
        $this->createIndex('idx-documents-renovacao_automatica', '{{%documents}}', 'renovacao_automatica');

        // Índices compostos para consultas frequentes
        $this->createIndex('idx-documents-validade-status', '{{%documents}}', ['data_validade', 'status']);
        $this->createIndex('idx-documents-tipo-entity', '{{%documents}}', ['tipo', 'vehicle_id', 'driver_id']);
        $this->createIndex('idx-documents-company-tipo', '{{%documents}}', ['company_id', 'tipo']);

        // Check constraint para garantir que o documento está associado a pelo menos uma entidade
        $this->execute("ALTER TABLE {{%documents}} ADD CONSTRAINT chk_documents_entity 
                       CHECK (vehicle_id IS NOT NULL OR driver_id IS NOT NULL)");
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        // Remover constraint
        $this->execute("ALTER TABLE {{%documents}} DROP CONSTRAINT chk_documents_entity");

        // Remover foreign keys
        $this->dropForeignKey('fk-documents-company_id', '{{%documents}}');
        $this->dropForeignKey('fk-documents-file_id', '{{%documents}}');
        $this->dropForeignKey('fk-documents-vehicle_id', '{{%documents}}');
        $this->dropForeignKey('fk-documents-driver_id', '{{%documents}}');
        $this->dropForeignKey('fk-documents-criado_por', '{{%documents}}');
        $this->dropForeignKey('fk-documents-atualizado_por', '{{%documents}}');
        $this->dropForeignKey('fk-documents-verificado_por', '{{%documents}}');
        $this->dropForeignKey('fk-documents-documento_anterior_id', '{{%documents}}');

        $this->dropTable('{{%documents}}');
    }
}
