<?php

use yii\db\Migration;

/**
 * Handles the creation of table `{{%vehicles}}`.
 */
class m241016_000003_create_vehicles_table extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        $this->createTable('{{%vehicles}}', [
            'id' => $this->primaryKey(),
            'matricula' => $this->string(20)->notNull()->unique(),
            'marca' => $this->string(100)->notNull(),
            'modelo' => $this->string(100)->notNull(),
            'ano' => $this->integer()->notNull(),
            'tipo_combustivel' => "ENUM('gasolina', 'diesel', 'elétrico', 'híbrido') NOT NULL",
            'quilometragem' => $this->integer()->notNull()->defaultValue(0),
            'estado' => "ENUM('ativo', 'manutencao', 'inativo') NOT NULL DEFAULT 'ativo'",
            'data_aquisicao' => $this->date(),
            'condutor_id' => $this->integer(),
            'notas' => $this->text(),
            'foto' => $this->string(255),
            'criado_em' => $this->dateTime()->notNull()->defaultExpression('CURRENT_TIMESTAMP'),
            'atualizado_em' => $this->dateTime()->defaultExpression('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
        ]);

        // Foreign Keys
        $this->addForeignKey(
            'fk-vehicles-condutor_id',
            '{{%vehicles}}',
            'condutor_id',
            '{{%users}}',
            'id',
            'SET NULL'
        );

        // Indexes
        $this->createIndex('idx-vehicles-matricula', '{{%vehicles}}', 'matricula');
        $this->createIndex('idx-vehicles-estado', '{{%vehicles}}', 'estado');
        $this->createIndex('idx-vehicles-condutor_id', '{{%vehicles}}', 'condutor_id');
        $this->createIndex('idx-vehicles-tipo_combustivel', '{{%vehicles}}', 'tipo_combustivel');
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        $this->dropForeignKey('fk-vehicles-condutor_id', '{{%vehicles}}');
        $this->dropTable('{{%vehicles}}');
    }
}
