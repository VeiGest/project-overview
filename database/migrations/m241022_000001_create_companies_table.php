<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%companies}}`.
 * Sistema multi-empresa para o VeiGest
 */
class m241022_000001_create_companies_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%companies}}', [
            'id' => $this->primaryKey(),
            'nome' => $this->string(200)->notNull(),
            'nome_comercial' => $this->string(200),
            'nif' => $this->string(20)->notNull()->unique(),
            'email' => $this->string(150),
            'telefone' => $this->string(20),
            'endereco' => $this->text(),
            'codigo_postal' => $this->string(10),
            'cidade' => $this->string(100),
            'pais' => $this->string(100)->defaultValue('Portugal'),
            'website' => $this->string(255),
            'logo' => $this->string(255), // Path para o logo da empresa
            'estado' => "ENUM('ativa', 'suspensa', 'inativa') NOT NULL DEFAULT 'ativa'",
            'plano' => "ENUM('basico', 'profissional', 'enterprise') NOT NULL DEFAULT 'basico'",
            'limite_veiculos' => $this->integer()->defaultValue(10),
            'limite_condutores' => $this->integer()->defaultValue(5),
            'data_expiracao' => $this->date(), // Data de expiração da subscrição
            'configuracoes' => $this->json(), // Configurações específicas da empresa
            'criado_em' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            'atualizado_em' => $this->dateTime()->defaultExpression('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
        ]);

        // Indexes
        $this->createIndex('idx-companies-nif', '{{%companies}}', 'nif');
        $this->createIndex('idx-companies-estado', '{{%companies}}', 'estado');
        $this->createIndex('idx-companies-plano', '{{%companies}}', 'plano');
        $this->createIndex('idx-companies-nome', '{{%companies}}', 'nome');

        // Inserir empresa padrão (para migração dos dados existentes)
        $this->insert('{{%companies}}', [
            'nome' => 'VeiGest Empresa Padrão',
            'nome_comercial' => 'VeiGest',
            'nif' => '999999990',
            'email' => 'admin@veigest.com',
            'telefone' => '+351900000000',
            'cidade' => 'Lisboa',
            'pais' => 'Portugal',
            'estado' => 'ativa',
            'plano' => 'enterprise',
            'limite_veiculos' => 1000,
            'limite_condutores' => 500,
        ]);
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropTable('{{%companies}}');
    }
}
