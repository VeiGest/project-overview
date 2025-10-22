<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%files}}`.
 * Sistema de gestão de ficheiros com referência para CDN/FileStash
 */
class m241022_000003_create_files_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%files}}', [
            'id' => $this->primaryKey(),
            'company_id' => $this->integer()->notNull(),
            'nome_original' => $this->string(255)->notNull(),
            'nome_arquivo' => $this->string(255)->notNull(), // Nome único gerado pelo sistema
            'extensao' => $this->string(10)->notNull(),
            'mime_type' => $this->string(100)->notNull(),
            'tamanho' => $this->bigInteger()->notNull(), // Tamanho em bytes
            'hash_md5' => $this->string(32), // Para verificar integridade
            'hash_sha256' => $this->string(64), // Hash secundário
            
            // Informações do servidor de ficheiros (CDN/FileStash)
            'servidor_tipo' => "ENUM('local', 'filestash', 'aws_s3', 'google_cloud', 'azure') NOT NULL DEFAULT 'local'",
            'servidor_url' => $this->string(500), // URL base do servidor
            'servidor_bucket' => $this->string(100), // Bucket/container name
            'servidor_path' => $this->string(500)->notNull(), // Caminho completo no servidor
            'servidor_config' => $this->json(), // Configurações específicas do servidor
            
            // Metadados do ficheiro
            'visibilidade' => "ENUM('publico', 'privado', 'restrito') NOT NULL DEFAULT 'privado'",
            'categoria' => $this->string(50), // documento, imagem, video, etc.
            'tags' => $this->json(), // Tags para pesquisa
            'metadados' => $this->json(), // Metadados adicionais (EXIF para imagens, etc.)
            
            // Controlo de acesso
            'uploaded_by' => $this->integer()->notNull(),
            'url_publica' => $this->string(500), // URL pública se disponível
            'url_download' => $this->string(500), // URL para download direto
            'expira_em' => $this->dateTime(), // Data de expiração (se aplicável)
            
            // Auditoria
            'estado' => "ENUM('ativo', 'arquivado', 'eliminado') NOT NULL DEFAULT 'ativo'",
            'criado_em' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            'atualizado_em' => $this->dateTime()->defaultExpression('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
        ]);

        // Foreign Keys
        $this->addForeignKey(
            'fk-files-company_id',
            '{{%files}}',
            'company_id',
            '{{%companies}}',
            'id',
            'CASCADE'
        );

        $this->addForeignKey(
            'fk-files-uploaded_by',
            '{{%files}}',
            'uploaded_by',
            '{{%users}}',
            'id',
            'RESTRICT'
        );

        // Indexes
        $this->createIndex('idx-files-company_id', '{{%files}}', 'company_id');
        $this->createIndex('idx-files-nome_arquivo', '{{%files}}', 'nome_arquivo');
        $this->createIndex('idx-files-extensao', '{{%files}}', 'extensao');
        $this->createIndex('idx-files-mime_type', '{{%files}}', 'mime_type');
        $this->createIndex('idx-files-categoria', '{{%files}}', 'categoria');
        $this->createIndex('idx-files-estado', '{{%files}}', 'estado');
        $this->createIndex('idx-files-uploaded_by', '{{%files}}', 'uploaded_by');
        $this->createIndex('idx-files-servidor_tipo', '{{%files}}', 'servidor_tipo');
        $this->createIndex('idx-files-visibilidade', '{{%files}}', 'visibilidade');
        $this->createIndex('idx-files-criado_em', '{{%files}}', 'criado_em');
        
        // Índice único para evitar duplicatas baseado no hash
        $this->createIndex('uk-files-hash-company', '{{%files}}', ['hash_md5', 'company_id'], true);
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropForeignKey('fk-files-company_id', '{{%files}}');
        $this->dropForeignKey('fk-files-uploaded_by', '{{%files}}');
        $this->dropTable('{{%files}}');
    }
}
