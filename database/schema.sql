-- ============================================================================
-- VeiGest - Sistema de Gestão de Frotas Empresariais
-- Database Schema - MariaDB/MySQL
-- Esquema inicial para a db
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS veigest;
CREATE DATABASE veigest CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE veigest;

-- ============================================================================
-- 1. AUTENTICAÇÃO E UTILIZADORES
-- ============================================================================

-- Tabela de roles/funções do sistema
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    slug VARCHAR(100) NOT NULL UNIQUE,
    nivel_hierarquia INT NOT NULL DEFAULT 1,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_slug (slug),
    INDEX idx_nivel_hierarquia (nivel_hierarquia)
);

-- Tabela de permissões do sistema
CREATE TABLE permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    modulo VARCHAR(50) NOT NULL,
    acao VARCHAR(50) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_slug (slug),
    INDEX idx_modulo (modulo),
    INDEX idx_acao (acao)
);

-- Tabela de relacionamento roles-permissions (N:N)
CREATE TABLE role_permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id)
);

-- Tabela principal de utilizadores
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    role_id INT,
    role ENUM('admin', 'gestor', 'condutor') NOT NULL DEFAULT 'condutor', -- Mantido para compatibilidade
    estado ENUM('ativo', 'inativo') NOT NULL DEFAULT 'ativo',
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_login DATETIME,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE SET NULL,
    INDEX idx_email (email),
    INDEX idx_role_id (role_id),
    INDEX idx_role (role),
    INDEX idx_estado (estado)
);

-- Perfis específicos dos condutores
CREATE TABLE drivers_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    numero_carta VARCHAR(50),
    validade_carta DATE,
    nif VARCHAR(20),
    endereco VARCHAR(255),
    foto VARCHAR(255),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_id (user_id),
    INDEX idx_numero_carta (numero_carta),
    INDEX idx_validade_carta (validade_carta)
);

-- ============================================================================
-- 2. GESTÃO DE FROTA
-- ============================================================================

-- Veículos da frota
CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    tipo_combustivel ENUM('gasolina', 'diesel', 'elétrico', 'híbrido') NOT NULL,
    quilometragem INT NOT NULL DEFAULT 0,
    estado ENUM('ativo', 'manutencao', 'inativo') NOT NULL DEFAULT 'ativo',
    data_aquisicao DATE,
    condutor_id INT,
    notas TEXT,
    foto VARCHAR(255),
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (condutor_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_matricula (matricula),
    INDEX idx_estado (estado),
    INDEX idx_condutor (condutor_id),
    INDEX idx_tipo_combustivel (tipo_combustivel)
);

-- Histórico de manutenções
CREATE TABLE maintenances (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    descricao TEXT,
    data DATE NOT NULL,
    custo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    km_registro INT NOT NULL,
    proxima_data DATE,
    oficina VARCHAR(150),
    notas TEXT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_data (data),
    INDEX idx_proxima_data (proxima_data),
    INDEX idx_tipo (tipo)
);

-- Documentos dos veículos e condutores
CREATE TABLE documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT,
    driver_id INT,
    tipo ENUM('DUA', 'Seguro', 'Inspecao', 'Carta', 'Outro') NOT NULL,
    numero VARCHAR(100),
    emissor VARCHAR(150),
    data_emissao DATE,
    validade DATE,
    arquivo VARCHAR(255),
    status ENUM('valido', 'expirado', 'pendente') NOT NULL DEFAULT 'valido',
    notas TEXT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_driver_id (driver_id),
    INDEX idx_tipo (tipo),
    INDEX idx_validade (validade),
    INDEX idx_status (status),
    
    CHECK (vehicle_id IS NOT NULL OR driver_id IS NOT NULL)
);

-- ============================================================================
-- 3. REGISTOS OPERACIONAIS
-- ============================================================================

-- Registos de abastecimento
CREATE TABLE fuel_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    driver_id INT NOT NULL,
    data DATE NOT NULL,
    litros DECIMAL(10,2) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    preco_litro DECIMAL(6,3) GENERATED ALWAYS AS (valor / litros) STORED,
    local VARCHAR(150),
    km_atual INT,
    recibo VARCHAR(255),
    notas TEXT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_driver_id (driver_id),
    INDEX idx_data (data),
    INDEX idx_data_vehicle (data, vehicle_id)
);

-- Rotas e viagens
CREATE TABLE routes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    driver_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    inicio DATETIME NOT NULL,
    fim DATETIME,
    distancia_km DECIMAL(10,2),
    tempo_total INT, -- minutos
    origem VARCHAR(255),
    destino VARCHAR(255),
    km_inicial INT,
    km_final INT,
    proposito VARCHAR(200),
    observacoes TEXT,
    status ENUM('iniciada', 'finalizada', 'cancelada') NOT NULL DEFAULT 'iniciada',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_driver_id (driver_id),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_inicio (inicio),
    INDEX idx_status (status)
);

-- Pontos GPS para tracking (opcional)
CREATE TABLE gps_points (
    id INT PRIMARY KEY AUTO_INCREMENT,
    route_id INT NOT NULL,
    latitude DECIMAL(10,6) NOT NULL,
    longitude DECIMAL(10,6) NOT NULL,
    velocidade DECIMAL(6,2),
    altitude DECIMAL(8,2),
    timestamp DATETIME NOT NULL,
    
    FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
    INDEX idx_route_id (route_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_route_timestamp (route_id, timestamp)
);

-- ============================================================================
-- 4. ALERTAS E NOTIFICAÇÕES
-- ============================================================================

-- Sistema de alertas
CREATE TABLE alerts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('manutencao', 'seguro', 'inspecao', 'documento', 'combustivel', 'outro') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    data_limite DATE,
    prioridade ENUM('baixa', 'media', 'alta', 'critica') NOT NULL DEFAULT 'media',
    status ENUM('ativo', 'resolvido', 'expirado', 'ignorado') NOT NULL DEFAULT 'ativo',
    user_id INT,
    vehicle_id INT,
    document_id INT,
    notificado BOOLEAN NOT NULL DEFAULT FALSE,
    data_notificacao DATETIME,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolvido_em DATETIME,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    INDEX idx_tipo (tipo),
    INDEX idx_status (status),
    INDEX idx_prioridade (prioridade),
    INDEX idx_data_limite (data_limite),
    INDEX idx_user_id (user_id),
    INDEX idx_vehicle_id (vehicle_id)
);

-- ============================================================================
-- 5. RELATÓRIOS E AUDITORIA
-- ============================================================================

-- Relatórios gerados
CREATE TABLE reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('frota', 'condutor', 'custos', 'rotas', 'manutencao', 'combustivel') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    periodo_inicio DATE,
    periodo_fim DATE,
    parametros JSON,
    gerado_por INT NOT NULL,
    arquivo VARCHAR(255),
    status ENUM('processando', 'concluido', 'erro') NOT NULL DEFAULT 'processando',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    concluido_em DATETIME,
    
    FOREIGN KEY (gerado_por) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_tipo (tipo),
    INDEX idx_gerado_por (gerado_por),
    INDEX idx_status (status),
    INDEX idx_criado_em (criado_em)
);

-- Logs de atividade para auditoria
CREATE TABLE activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    acao VARCHAR(255) NOT NULL,
    entidade VARCHAR(100) NOT NULL,
    entidade_id INT,
    detalhes JSON,
    ip VARCHAR(45),
    user_agent TEXT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_acao (acao),
    INDEX idx_entidade (entidade),
    INDEX idx_criado_em (criado_em),
    INDEX idx_entidade_id (entidade, entidade_id)
);

-- ============================================================================
-- 6. CONFIGURAÇÕES E SUPORTE
-- ============================================================================

-- Configurações do sistema
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chave VARCHAR(100) NOT NULL UNIQUE,
    valor TEXT,
    tipo ENUM('string', 'number', 'boolean', 'json') NOT NULL DEFAULT 'string',
    descricao TEXT,
    categoria VARCHAR(50) NOT NULL DEFAULT 'geral',
    editavel BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_chave (chave),
    INDEX idx_categoria (categoria)
);

-- Tickets de suporte
CREATE TABLE support_tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    assunto VARCHAR(255) NOT NULL,
    mensagem TEXT NOT NULL,
    prioridade ENUM('baixa', 'media', 'alta') NOT NULL DEFAULT 'media',
    status ENUM('aberto', 'em_progresso', 'fechado', 'cancelado') NOT NULL DEFAULT 'aberto',
    atribuido_para INT,
    resposta TEXT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fechado_em DATETIME,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (atribuido_para) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_prioridade (prioridade),
    INDEX idx_criado_em (criado_em)
);

-- ============================================================================
-- 7. DADOS INICIAIS (SEEDS)
-- ============================================================================

-- Inserir roles padrão do sistema
INSERT INTO roles (nome, descricao, slug, nivel_hierarquia) VALUES
('Super Administrador', 'Acesso total ao sistema, incluindo configurações críticas e gestão de utilizadores.', 'super-admin', 100),
('Administrador', 'Administrador geral com acesso a todas as funcionalidades exceto configurações críticas.', 'admin', 90),
('Gestor de Frota', 'Gestor responsável pela frota, veículos, condutores e relatórios operacionais.', 'gestor', 50),
('Gestor de Manutenção', 'Responsável pela gestão de manutenções, documentos e alertas dos veículos.', 'gestor-manutencao', 40),
('Condutor Senior', 'Condutor experiente com permissões adicionais para relatórios e histórico.', 'condutor-senior', 20),
('Condutor', 'Condutor padrão com acesso básico à aplicação móvel e funcionalidades essenciais.', 'condutor', 10),
('Visualizador', 'Acesso apenas de leitura para consulta de dados e relatórios.', 'visualizador', 5);

-- Inserir permissions padrão do sistema
INSERT INTO permissions (nome, descricao, modulo, acao, slug) VALUES
-- Gestão de Utilizadores
('Criar Utilizadores', 'Permissão para criar novos utilizadores', 'users', 'create', 'users.create'),
('Ver Utilizadores', 'Permissão para visualizar utilizadores', 'users', 'read', 'users.read'),
('Editar Utilizadores', 'Permissão para editar utilizadores existentes', 'users', 'update', 'users.update'),
('Eliminar Utilizadores', 'Permissão para eliminar utilizadores', 'users', 'delete', 'users.delete'),
('Gerir Roles', 'Permissão para gerir roles e permissões', 'users', 'manage_roles', 'users.manage_roles'),

-- Gestão de Veículos
('Criar Veículos', 'Permissão para adicionar novos veículos à frota', 'vehicles', 'create', 'vehicles.create'),
('Ver Veículos', 'Permissão para visualizar veículos da frota', 'vehicles', 'read', 'vehicles.read'),
('Editar Veículos', 'Permissão para editar informações dos veículos', 'vehicles', 'update', 'vehicles.update'),
('Eliminar Veículos', 'Permissão para remover veículos da frota', 'vehicles', 'delete', 'vehicles.delete'),
('Atribuir Condutores', 'Permissão para atribuir condutores aos veículos', 'vehicles', 'assign_driver', 'vehicles.assign_driver'),

-- Gestão de Condutores
('Criar Perfis de Condutores', 'Permissão para criar perfis de condutores', 'drivers', 'create', 'drivers.create'),
('Ver Perfis de Condutores', 'Permissão para visualizar perfis de condutores', 'drivers', 'read', 'drivers.read'),
('Editar Perfis de Condutores', 'Permissão para editar perfis de condutores', 'drivers', 'update', 'drivers.update'),
('Eliminar Perfis de Condutores', 'Permissão para eliminar perfis de condutores', 'drivers', 'delete', 'drivers.delete'),
('Ver Histórico de Condutores', 'Permissão para visualizar histórico de viagens dos condutores', 'drivers', 'view_history', 'drivers.view_history'),

-- Manutenções
('Criar Manutenções', 'Permissão para registar manutenções', 'maintenances', 'create', 'maintenances.create'),
('Ver Manutenções', 'Permissão para visualizar histórico de manutenções', 'maintenances', 'read', 'maintenances.read'),
('Editar Manutenções', 'Permissão para editar registos de manutenções', 'maintenances', 'update', 'maintenances.update'),
('Eliminar Manutenções', 'Permissão para eliminar registos de manutenções', 'maintenances', 'delete', 'maintenances.delete'),
('Agendar Manutenções', 'Permissão para agendar manutenções futuras', 'maintenances', 'schedule', 'maintenances.schedule'),

-- Documentos
('Upload de Documentos', 'Permissão para fazer upload de documentos', 'documents', 'create', 'documents.create'),
('Ver Documentos', 'Permissão para visualizar documentos', 'documents', 'read', 'documents.read'),
('Editar Documentos', 'Permissão para editar informações de documentos', 'documents', 'update', 'documents.update'),
('Eliminar Documentos', 'Permissão para eliminar documentos', 'documents', 'delete', 'documents.delete'),
('Gerir Validades', 'Permissão para gerir validades de documentos', 'documents', 'manage_validity', 'documents.manage_validity'),

-- Registos de Combustível
('Registar Combustível', 'Permissão para registar abastecimentos', 'fuel_logs', 'create', 'fuel_logs.create'),
('Ver Registos de Combustível', 'Permissão para visualizar registos de combustível', 'fuel_logs', 'read', 'fuel_logs.read'),
('Editar Registos de Combustível', 'Permissão para editar registos de combustível', 'fuel_logs', 'update', 'fuel_logs.update'),
('Eliminar Registos de Combustível', 'Permissão para eliminar registos de combustível', 'fuel_logs', 'delete', 'fuel_logs.delete'),

-- Rotas e Viagens
('Iniciar Viagens', 'Permissão para iniciar novas viagens', 'routes', 'create', 'routes.create'),
('Ver Rotas', 'Permissão para visualizar rotas e viagens', 'routes', 'read', 'routes.read'),
('Editar Rotas', 'Permissão para editar informações das rotas', 'routes', 'update', 'routes.update'),
('Eliminar Rotas', 'Permissão para eliminar registos de rotas', 'routes', 'delete', 'routes.delete'),
('Ver Tracking GPS', 'Permissão para visualizar tracking GPS em tempo real', 'routes', 'view_gps', 'routes.view_gps'),

-- Alertas
('Criar Alertas', 'Permissão para criar alertas manuais', 'alerts', 'create', 'alerts.create'),
('Ver Alertas', 'Permissão para visualizar alertas', 'alerts', 'read', 'alerts.read'),
('Marcar Alertas como Resolvidos', 'Permissão para resolver alertas', 'alerts', 'resolve', 'alerts.resolve'),
('Configurar Alertas', 'Permissão para configurar alertas automáticos', 'alerts', 'configure', 'alerts.configure'),

-- Relatórios
('Gerar Relatórios', 'Permissão para gerar novos relatórios', 'reports', 'create', 'reports.create'),
('Ver Relatórios', 'Permissão para visualizar relatórios existentes', 'reports', 'read', 'reports.read'),
('Exportar Relatórios', 'Permissão para exportar relatórios', 'reports', 'export', 'reports.export'),
('Relatórios Avançados', 'Permissão para aceder a relatórios avançados', 'reports', 'advanced', 'reports.advanced'),

-- Sistema e Configurações
('Configurações do Sistema', 'Permissão para alterar configurações do sistema', 'system', 'config', 'system.config'),
('Ver Logs de Atividade', 'Permissão para visualizar logs de auditoria', 'system', 'view_logs', 'system.view_logs'),
('Gerir Backups', 'Permissão para gerir backups do sistema', 'system', 'backup', 'system.backup'),
('Suporte Técnico', 'Permissão para aceder ao suporte técnico', 'system', 'support', 'system.support'),

-- Dashboard
('Ver Dashboard', 'Permissão para aceder ao dashboard básico', 'dashboard', 'read', 'dashboard.read'),
('Dashboard Avançado', 'Permissão para aceder ao dashboard avançado com KPIs', 'dashboard', 'advanced', 'dashboard.advanced');

-- Associar permissions aos roles
-- Super Admin (ID=1) - Todas as permissões
INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

-- Admin (ID=2) - Todas exceto configurações críticas do sistema
INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions 
WHERE slug NOT IN ('system.config', 'system.backup');

-- Gestor de Frota (ID=3)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions 
WHERE slug IN (
    'vehicles.create', 'vehicles.read', 'vehicles.update', 'vehicles.assign_driver',
    'drivers.create', 'drivers.read', 'drivers.update', 'drivers.view_history',
    'fuel_logs.read', 'fuel_logs.update',
    'routes.read', 'routes.view_gps',
    'alerts.read', 'alerts.resolve',
    'reports.create', 'reports.read', 'reports.export',
    'dashboard.read', 'dashboard.advanced'
);

-- Gestor de Manutenção (ID=4)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 4, id FROM permissions 
WHERE slug IN (
    'vehicles.read',
    'maintenances.create', 'maintenances.read', 'maintenances.update', 'maintenances.schedule',
    'documents.create', 'documents.read', 'documents.update', 'documents.manage_validity',
    'alerts.create', 'alerts.read', 'alerts.resolve', 'alerts.configure',
    'reports.read',
    'dashboard.read'
);

-- Condutor Senior (ID=5)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 5, id FROM permissions 
WHERE slug IN (
    'vehicles.read',
    'drivers.read',
    'fuel_logs.create', 'fuel_logs.read',
    'routes.create', 'routes.read',
    'alerts.read',
    'reports.read',
    'dashboard.read'
);

-- Condutor (ID=6)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 6, id FROM permissions 
WHERE slug IN (
    'vehicles.read',
    'fuel_logs.create', 'fuel_logs.read',
    'routes.create', 'routes.read',
    'alerts.read',
    'dashboard.read'
);

-- Visualizador (ID=7)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 7, id FROM permissions 
WHERE slug IN (
    'vehicles.read',
    'drivers.read',
    'fuel_logs.read',
    'routes.read',
    'alerts.read',
    'reports.read',
    'dashboard.read'
);

-- Configurações padrão do sistema
INSERT INTO settings (chave, valor, tipo, descricao, categoria) VALUES
('app_name', 'VeiGest', 'string', 'Nome da aplicação', 'geral'),
('app_version', '1.0.0', 'string', 'Versão da aplicação', 'geral'),
('max_file_size', '10485760', 'number', 'Tamanho máximo de arquivo em bytes (10MB)', 'uploads'),
('allowed_file_types', 'jpg,jpeg,png,pdf,doc,docx', 'string', 'Tipos de arquivo permitidos para upload', 'uploads'),
('default_fuel_alert_km', '50000', 'number', 'Quilometragem padrão para alerta de manutenção', 'alertas'),
('gps_tracking_enabled', 'true', 'boolean', 'Ativar tracking GPS', 'gps'),
('backup_retention_days', '30', 'number', 'Dias para manter backups', 'sistema');

-- Usuário administrador padrão
INSERT INTO users (nome, email, senha_hash, role_id, role, estado) VALUES
('Administrador', 'admin@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 'admin', 'ativo');

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================
