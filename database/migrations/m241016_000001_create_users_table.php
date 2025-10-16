<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%users}}`.
 */
class m241016_000001_create_users_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%users}}', [
            'id' => $this->primaryKey(),
            'nome' => $this->string(150)->notNull(),
            'email' => $this->string(150)->notNull()->unique(),
            'senha_hash' => $this->string(255)->notNull(),
            'telefone' => $this->string(20),
            'role' => "ENUM('admin', 'gestor', 'condutor') NOT NULL DEFAULT 'condutor'",
            'estado' => "ENUM('ativo', 'inativo') NOT NULL DEFAULT 'ativo'",
            'data_criacao' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            'ultimo_login' => $this->dateTime(),
            'atualizado_em' => $this->dateTime()->defaultExpression('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
        ]);

        // Indexes
        $this->createIndex('idx-users-email', '{{%users}}', 'email');
        $this->createIndex('idx-users-role', '{{%users}}', 'role');
        $this->createIndex('idx-users-estado', '{{%users}}', 'estado');
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropTable('{{%users}}');
    }
}
