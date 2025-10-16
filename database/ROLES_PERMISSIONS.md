# 🔐 Sistema de Roles e Permissions - VeiGest

## 📋 Visão Geral

O VeiGest implementa um sistema de controlo de acesso baseado em **RBAC (Role-Based Access Control)** seguindo a arquitetura:

```
User → Role → Permission
```

Este modelo permite:
- **Flexibilidade**: Fácil gestão de permissões por grupos
- **Escalabilidade**: Novos roles e permissions sem alterar código
- **Segurança**: Controlo granular de acesso
- **Auditoria**: Rastreamento completo de ações

---

## 🎭 Roles do Sistema

### 1. Super Administrador (Nível 100)
**Slug**: `super-admin`

**Descrição**: Acesso total ao sistema, incluindo configurações críticas e gestão de utilizadores.

**Permissões**: Todas as permissões do sistema

**Casos de Uso**:
- Configuração inicial do sistema
- Gestão de backups e segurança
- Resolução de problemas críticos

---

### 2. Administrador (Nível 90)
**Slug**: `admin`

**Descrição**: Administrador geral com acesso a todas as funcionalidades exceto configurações críticas.

**Permissões**: Todas exceto:
- `system.config` - Configurações críticas do sistema
- `system.backup` - Gestão de backups

**Casos de Uso**:
- Administração diária do sistema
- Gestão de utilizadores e roles
- Supervisão geral da frota

---

### 3. Gestor de Frota (Nível 50)
**Slug**: `gestor`

**Descrição**: Gestor responsável pela frota, veículos, condutores e relatórios operacionais.

**Permissões Principais**:
- **Veículos**: create, read, update, assign_driver
- **Condutores**: create, read, update, view_history
- **Combustível**: read, update
- **Rotas**: read, view_gps
- **Alertas**: read, resolve
- **Relatórios**: create, read, export
- **Dashboard**: read, advanced

**Casos de Uso**:
- Gestão diária da frota
- Atribuição de veículos a condutores
- Análise de performance e custos
- Geração de relatórios operacionais

---

### 4. Gestor de Manutenção (Nível 40)
**Slug**: `gestor-manutencao`

**Descrição**: Responsável pela gestão de manutenções, documentos e alertas dos veículos.

**Permissões Principais**:
- **Veículos**: read
- **Manutenções**: create, read, update, schedule
- **Documentos**: create, read, update, manage_validity
- **Alertas**: create, read, resolve, configure
- **Relatórios**: read
- **Dashboard**: read

**Casos de Uso**:
- Agendamento de manutenções
- Controlo de validade de documentos
- Gestão de alertas automáticos
- Acompanhamento de custos de manutenção

---

### 5. Condutor Senior (Nível 20)
**Slug**: `condutor-senior`

**Descrição**: Condutor experiente com permissões adicionais para relatórios e histórico.

**Permissões Principais**:
- **Veículos**: read
- **Condutores**: read (próprio perfil)
- **Combustível**: create, read
- **Rotas**: create, read
- **Alertas**: read
- **Relatórios**: read
- **Dashboard**: read

**Casos de Uso**:
- Condução de veículos
- Registo detalhado de viagens
- Consulta de histórico próprio
- Acesso a relatórios básicos

---

### 6. Condutor (Nível 10)
**Slug**: `condutor`

**Descrição**: Condutor padrão com acesso básico à aplicação móvel e funcionalidades essenciais.

**Permissões Principais**:
- **Veículos**: read (atribuídos)
- **Combustível**: create, read
- **Rotas**: create, read
- **Alertas**: read
- **Dashboard**: read

**Casos de Uso**:
- Utilização da app móvel
- Registo de viagens básico
- Abastecimentos
- Visualização de alertas

---

### 7. Visualizador (Nível 5)
**Slug**: `visualizador`

**Descrição**: Acesso apenas de leitura para consulta de dados e relatórios.

**Permissões Principais**:
- **Todas as entidades**: read only
- **Dashboard**: read

**Casos de Uso**:
- Auditoria externa
- Consultoria
- Stakeholders externos
- Relatórios para direção

---

## 🔑 Sistema de Permissions

### Estrutura das Permissions

Cada permission segue o padrão: `{modulo}.{acao}`

**Exemplo**: `vehicles.create` = Criar veículos

### Módulos Disponíveis

#### 👥 Users (Utilizadores)
- `users.create` - Criar utilizadores
- `users.read` - Ver utilizadores
- `users.update` - Editar utilizadores
- `users.delete` - Eliminar utilizadores
- `users.manage_roles` - Gerir roles e permissions

#### 🚗 Vehicles (Veículos)
- `vehicles.create` - Adicionar veículos
- `vehicles.read` - Ver veículos
- `vehicles.update` - Editar veículos
- `vehicles.delete` - Remover veículos
- `vehicles.assign_driver` - Atribuir condutores

#### 👨‍💼 Drivers (Condutores)
- `drivers.create` - Criar perfis
- `drivers.read` - Ver perfis
- `drivers.update` - Editar perfis
- `drivers.delete` - Eliminar perfis
- `drivers.view_history` - Ver histórico

#### 🔧 Maintenances (Manutenções)
- `maintenances.create` - Registar manutenções
- `maintenances.read` - Ver manutenções
- `maintenances.update` - Editar manutenções
- `maintenances.delete` - Eliminar manutenções
- `maintenances.schedule` - Agendar manutenções

#### 📄 Documents (Documentos)
- `documents.create` - Upload documentos
- `documents.read` - Ver documentos
- `documents.update` - Editar documentos
- `documents.delete` - Eliminar documentos
- `documents.manage_validity` - Gerir validades

#### ⛽ Fuel Logs (Combustível)
- `fuel_logs.create` - Registar abastecimentos
- `fuel_logs.read` - Ver registos
- `fuel_logs.update` - Editar registos
- `fuel_logs.delete` - Eliminar registos

#### 🗺️ Routes (Rotas)
- `routes.create` - Iniciar viagens
- `routes.read` - Ver rotas
- `routes.update` - Editar rotas
- `routes.delete` - Eliminar rotas
- `routes.view_gps` - Ver tracking GPS

#### ⚠️ Alerts (Alertas)
- `alerts.create` - Criar alertas
- `alerts.read` - Ver alertas
- `alerts.resolve` - Resolver alertas
- `alerts.configure` - Configurar alertas

#### 📊 Reports (Relatórios)
- `reports.create` - Gerar relatórios
- `reports.read` - Ver relatórios
- `reports.export` - Exportar relatórios
- `reports.advanced` - Relatórios avançados

#### ⚙️ System (Sistema)
- `system.config` - Configurações críticas
- `system.view_logs` - Ver logs auditoria
- `system.backup` - Gerir backups
- `system.support` - Suporte técnico

#### 📈 Dashboard
- `dashboard.read` - Dashboard básico
- `dashboard.advanced` - Dashboard avançado

---

## 🛠️ Implementação Técnica

### Base de Dados

#### Tabela `roles`
```sql
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    slug VARCHAR(100) NOT NULL UNIQUE,
    nivel_hierarquia INT NOT NULL DEFAULT 1,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### Tabela `permissions`
```sql
CREATE TABLE permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    modulo VARCHAR(50) NOT NULL,
    acao VARCHAR(50) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### Tabela `role_permissions` (N:N)
```sql
CREATE TABLE role_permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    UNIQUE KEY uk_role_permission (role_id, permission_id)
);
```

### Models Yii2

#### Role.php
```php
<?php

namespace app\models;

use Yii;
use yii\db\ActiveRecord;

class Role extends ActiveRecord
{
    public static function tableName()
    {
        return 'roles';
    }

    public function rules()
    {
        return [
            [['nome', 'slug'], 'required'],
            [['nome', 'slug'], 'string', 'max' => 100],
            [['nome', 'slug'], 'unique'],
            [['descricao'], 'string'],
            [['nivel_hierarquia'], 'integer', 'min' => 1],
            [['ativo'], 'boolean'],
        ];
    }

    public function getPermissions()
    {
        return $this->hasMany(Permission::class, ['id' => 'permission_id'])
            ->viaTable('role_permissions', ['role_id' => 'id']);
    }

    public function getUsers()
    {
        return $this->hasMany(User::class, ['role_id' => 'id']);
    }

    public function hasPermission($permission)
    {
        return $this->getPermissions()
            ->where(['slug' => $permission])
            ->exists();
    }
}
```

#### Permission.php
```php
<?php

namespace app\models;

use Yii;
use yii\db\ActiveRecord;

class Permission extends ActiveRecord
{
    public static function tableName()
    {
        return 'permissions';
    }

    public function rules()
    {
        return [
            [['nome', 'modulo', 'acao', 'slug'], 'required'],
            [['nome', 'slug'], 'string', 'max' => 100],
            [['modulo', 'acao'], 'string', 'max' => 50],
            [['nome', 'slug'], 'unique'],
            [['descricao'], 'string'],
            [['ativo'], 'boolean'],
        ];
    }

    public function getRoles()
    {
        return $this->hasMany(Role::class, ['id' => 'role_id'])
            ->viaTable('role_permissions', ['permission_id' => 'id']);
    }
}
```

### Verificação de Permissions

#### No Controller
```php
<?php

namespace app\controllers;

use Yii;
use yii\web\Controller;
use yii\web\ForbiddenHttpException;

class VehicleController extends Controller
{
    public function actionCreate()
    {
        if (!Yii::$app->user->can('vehicles.create')) {
            throw new ForbiddenHttpException('Não tem permissão para criar veículos.');
        }
        
        // Lógica para criar veículo
    }

    public function actionIndex()
    {
        if (!Yii::$app->user->can('vehicles.read')) {
            throw new ForbiddenHttpException('Não tem permissão para ver veículos.');
        }
        
        // Lógica para listar veículos
    }
}
```

#### Na View
```php
<?php if (Yii::$app->user->can('vehicles.create')): ?>
    <a href="<?= Url::to(['vehicle/create']) ?>" class="btn btn-primary">
        Adicionar Veículo
    </a>
<?php endif; ?>
```

### Component de Authorization

#### RoleBasedAuth.php
```php
<?php

namespace app\components;

use Yii;
use yii\base\Component;

class RoleBasedAuth extends Component
{
    public function can($permission, $params = [])
    {
        $user = Yii::$app->user->identity;
        
        if (!$user || !$user->role_id) {
            return false;
        }
        
        return $user->role->hasPermission($permission);
    }

    public function hasRole($roleSlug)
    {
        $user = Yii::$app->user->identity;
        
        if (!$user || !$user->role_id) {
            return false;
        }
        
        return $user->role->slug === $roleSlug;
    }

    public function getRoleLevel()
    {
        $user = Yii::$app->user->identity;
        
        if (!$user || !$user->role_id) {
            return 0;
        }
        
        return $user->role->nivel_hierarquia;
    }
}
```

---

## 🔄 Migration e Deployment

### 1. Executar Migration
```bash
php yii migrate/up
```

### 2. Migrar Dados Existentes
A migration automaticamente migra usuários existentes da coluna `role` (enum) para `role_id` (FK):

- `admin` → Role ID 2 (Administrador)
- `gestor` → Role ID 3 (Gestor de Frota)  
- `condutor` → Role ID 6 (Condutor)

### 3. Verificar Integridade
```sql
-- Verificar se todos os users têm role_id
SELECT COUNT(*) FROM users WHERE role_id IS NULL;

-- Verificar permissions por role
SELECT r.nome, COUNT(rp.permission_id) as total_permissions
FROM roles r
LEFT JOIN role_permissions rp ON r.id = rp.role_id
GROUP BY r.id, r.nome;
```

---

## 📝 Melhores Práticas

### 1. Nomenclatura
- **Roles**: Nomes descritivos e hierárquicos
- **Permissions**: Formato `{modulo}.{acao}`
- **Slugs**: kebab-case, únicos e legíveis

### 2. Hierarquia
- Roles com níveis superiores devem ter mais permissões
- Usar `nivel_hierarquia` para ordenação e comparações

### 3. Segurança
- Sempre verificar permissions nos controllers
- Usar whitelists em vez de blacklists
- Implementar rate limiting por role

### 4. Performance
- Cache permissions por sessão
- Índices otimizados nas consultas
- Lazy loading das relations

### 5. Auditoria
- Log todas as alterações de roles/permissions
- Rastrear quem atribuiu que role a quem
- Alertas para mudanças críticas

---

## 🚀 Exemplos de Uso

### Verificação Simples
```php
// Verificar se pode criar veículos
if (Yii::$app->user->can('vehicles.create')) {
    // Permitido
}
```

### Verificação por Role
```php
// Verificar se é gestor
if (Yii::$app->user->identity->hasRole('gestor')) {
    // É gestor
}
```

### Verificação Hierárquica
```php
// Apenas gestores nível 40+ podem agendar manutenções
if (Yii::$app->user->identity->getRoleLevel() >= 40) {
    // Pode agendar
}
```

### Menu Dinâmico
```php
$menuItems = [];

if (Yii::$app->user->can('vehicles.read')) {
    $menuItems[] = ['label' => 'Veículos', 'url' => ['/vehicle/index']];
}

if (Yii::$app->user->can('reports.create')) {
    $menuItems[] = ['label' => 'Relatórios', 'url' => ['/report/index']];
}
```

---

## 🔧 Extensibilidade

### Adicionar Novo Role
1. Inserir na tabela `roles`
2. Definir permissões em `role_permissions`
3. Atualizar documentação

### Adicionar Nova Permission
1. Inserir na tabela `permissions`
2. Associar aos roles apropriados
3. Implementar verificações no código

### Custom Permissions
```php
// Permission baseada em lógica personalizada
public function canEditVehicle($vehicle)
{
    // Gestores podem editar qualquer veículo
    if (Yii::$app->user->can('vehicles.update')) {
        return true;
    }
    
    // Condutores só podem editar veículos atribuídos
    if (Yii::$app->user->can('vehicles.read') && 
        $vehicle->condutor_id === Yii::$app->user->id) {
        return true;
    }
    
    return false;
}
```

Este sistema oferece máxima flexibilidade e segurança para o controlo de acesso no VeiGest! 🚀
