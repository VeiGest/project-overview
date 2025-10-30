-- VeiGest - Schema Simplificado para MariaDB (RBAC Yii2)
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS veigest;
CREATE DATABASE veigest CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE veigest;

-- 1. companies (simplificado)
CREATE TABLE companies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    nif VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(150),
    telefone VARCHAR(20),
    cidade VARCHAR(100),
    pais VARCHAR(100) DEFAULT 'Portugal',
    estado ENUM('ativa','suspensa','inativa') NOT NULL DEFAULT 'ativa',
    plano ENUM('basico','profissional','enterprise') NOT NULL DEFAULT 'basico',
    limite_veiculos INT DEFAULT 10,
    limite_condutores INT DEFAULT 5,
    configuracoes JSON,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nif (nif),
    INDEX idx_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- RBAC (Yii2) - substitui as tabelas roles, permissions, role_permissions
-- ============================================================================
CREATE TABLE auth_rule (
    name VARCHAR(64) NOT NULL PRIMARY KEY,
    data TEXT,
    created_at INT,
    updated_at INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE auth_item (
    name VARCHAR(64) NOT NULL PRIMARY KEY,
    type INT NOT NULL COMMENT '1=role, 2=permission',
    description TEXT,
    rule_name VARCHAR(64),
    data TEXT,
    created_at INT,
    updated_at INT,
    CONSTRAINT fk_auth_item_rule FOREIGN KEY (rule_name) REFERENCES auth_rule(name) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE auth_item_child (
    parent VARCHAR(64) NOT NULL,
    child VARCHAR(64) NOT NULL,
    PRIMARY KEY (parent, child),
    CONSTRAINT fk_auth_item_child_parent FOREIGN KEY (parent) REFERENCES auth_item(name) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_auth_item_child_child FOREIGN KEY (child) REFERENCES auth_item(name) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE auth_assignment (
    item_name VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    created_at INT,
    PRIMARY KEY (item_name, user_id),
    CONSTRAINT fk_auth_assignment_item FOREIGN KEY (item_name) REFERENCES auth_item(name) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. users e drivers_profiles (simplificados)
-- ============================================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    role ENUM('admin','gestor','condutor') NOT NULL DEFAULT 'condutor',
    estado ENUM('ativo','inativo') NOT NULL DEFAULT 'ativo',
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_company_id (company_id),
    INDEX idx_email (email),
    INDEX idx_estado (estado),
    CONSTRAINT fk_users_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE drivers_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    numero_carta VARCHAR(50),
    validade_carta DATE,
    nif VARCHAR(20),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_id (user_id),
    INDEX idx_numero_carta (numero_carta),
    INDEX idx_validade_carta (validade_carta),
    CONSTRAINT fk_drivers_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. files (simplificado)
CREATE TABLE files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    nome_original VARCHAR(255) NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    extensao VARCHAR(10),
    mime_type VARCHAR(100),
    tamanho BIGINT NOT NULL,
    servidor_tipo ENUM('local','aws_s3','google_cloud','azure','filestash') NOT NULL DEFAULT 'local',
    servidor_path VARCHAR(500),
    uploaded_by INT NOT NULL,
    visibilidade ENUM('publico','privado','restrito') NOT NULL DEFAULT 'privado',
    estado ENUM('ativo','arquivado','eliminado') NOT NULL DEFAULT 'ativo',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_company_id (company_id),
    INDEX idx_nome_arquivo (nome_arquivo),
    INDEX idx_estado (estado),
    CONSTRAINT fk_files_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_files_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. vehicles e maintenances
CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    matricula VARCHAR(20) NOT NULL,
    marca VARCHAR(100),
    modelo VARCHAR(100),
    ano INT,
    tipo_combustivel ENUM('gasolina','diesel','eletrico','hibrido'),
    quilometragem INT NOT NULL DEFAULT 0,
    estado ENUM('ativo','manutencao','inativo') NOT NULL DEFAULT 'ativo',
    condutor_id INT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_matricula_company (matricula, company_id),
    INDEX idx_company_id (company_id),
    INDEX idx_estado (estado),
    INDEX idx_condutor_id (condutor_id),
    CONSTRAINT fk_vehicles_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicles_condutor FOREIGN KEY (condutor_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE maintenances (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    data DATE NOT NULL,
    custo DECIMAL(10,2) DEFAULT 0.00,
    km_registro INT,
    proxima_data DATE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_proxima_data (proxima_data),
    INDEX idx_data (data),
    CONSTRAINT fk_maintenances_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_maintenances_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. documents (mantendo campos essenciais)
CREATE TABLE documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    file_id INT NOT NULL,
    vehicle_id INT,
    driver_id INT,
    tipo ENUM('dua','seguro','inspecao','carta_conducao','contrato','manual','outro') NOT NULL,
    numero_documento VARCHAR(100),
    entidade_emissora VARCHAR(200),
    data_emissao DATE,
    data_validade DATE,
    prioridade ENUM('baixa','normal','alta','critica') NOT NULL DEFAULT 'normal',
    status ENUM('valido','expirado','por_renovar','cancelado') NOT NULL DEFAULT 'valido',
    lembrete_dias INT DEFAULT 30,
    versao INT DEFAULT 1,
    documento_anterior_id INT,
    criado_por INT NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_file_id (file_id),
    INDEX idx_data_validade (data_validade),
    INDEX idx_status (status),
    INDEX idx_tipo (tipo),
    CONSTRAINT fk_documents_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_documents_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE RESTRICT,
    CONSTRAINT fk_documents_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    CONSTRAINT fk_documents_driver FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_documents_anterior FOREIGN KEY (documento_anterior_id) REFERENCES documents(id) ON DELETE SET NULL,
    CONSTRAINT fk_documents_criado_por FOREIGN KEY (criado_por) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_documents_entity CHECK (vehicle_id IS NOT NULL OR driver_id IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. fuel_logs, routes, gps_points
CREATE TABLE fuel_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    driver_id INT,
    data DATE NOT NULL,
    litros DECIMAL(10,2) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    preco_litro DECIMAL(8,4) AS (CASE WHEN litros = 0 THEN 0 ELSE valor / litros END) STORED,
    km_atual INT,
    referencia_ficheiro VARCHAR(255),
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_data_vehicle (data, vehicle_id),
    INDEX idx_vehicle_id (vehicle_id),
    CONSTRAINT fk_fuel_logs_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_fuel_logs_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    CONSTRAINT fk_fuel_logs_driver FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE routes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    driver_id INT,
    vehicle_id INT,
    inicio DATETIME NOT NULL,
    fim DATETIME,
    distancia_km DECIMAL(10,2),
    km_inicial INT,
    km_final INT,
    origem_coordenadas VARCHAR(255),
    destino_coordenadas VARCHAR(255),
    status ENUM('iniciada','finalizada','cancelada') NOT NULL DEFAULT 'iniciada',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_inicio (inicio),
    INDEX idx_status (status),
    INDEX idx_vehicle_id (vehicle_id),
    CONSTRAINT fk_routes_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_routes_driver FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_routes_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE gps_points (
    id INT PRIMARY KEY AUTO_INCREMENT,
    route_id INT NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    timestamp DATETIME NOT NULL,
    INDEX idx_route_timestamp (route_id, timestamp),
    CONSTRAINT fk_gps_points_route FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. alerts
CREATE TABLE alerts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    tipo ENUM('manutencao','seguro','inspecao','documento','combustivel','outro') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    data_limite DATE,
    prioridade ENUM('baixa','media','alta','critica') NOT NULL DEFAULT 'media',
    status ENUM('ativo','resolvido','expirado','ignorado') NOT NULL DEFAULT 'ativo',
    user_id INT,
    vehicle_id INT,
    document_id INT,
    notificado BOOLEAN NOT NULL DEFAULT FALSE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolvido_em DATETIME,
    INDEX idx_status (status),
    INDEX idx_data_limite (data_limite),
    INDEX idx_prioridade (prioridade),
    CONSTRAINT fk_alerts_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_alerts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_alerts_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    CONSTRAINT fk_alerts_document FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. reports e activity_logs
CREATE TABLE reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    tipo ENUM('frota','condutor','custos','rotas','manutencao','combustivel') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    periodo_inicio DATE,
    periodo_fim DATE,
    parametros JSON,
    gerado_por INT,
    arquivo VARCHAR(255),
    status ENUM('processando','concluido','erro') NOT NULL DEFAULT 'processando',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_tipo (tipo),
    CONSTRAINT fk_reports_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_reports_gerado_por FOREIGN KEY (gerado_por) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    user_id INT,
    acao VARCHAR(255) NOT NULL,
    entidade VARCHAR(100) NOT NULL,
    entidade_id INT,
    detalhes JSON,
    ip VARCHAR(45),
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_criado_em (criado_em),
    INDEX idx_entidade (entidade),
    INDEX idx_acao (acao),
    CONSTRAINT fk_activity_logs_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_activity_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. settings e support_tickets (simplificados)
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    chave VARCHAR(100) NOT NULL,
    valor TEXT,
    tipo ENUM('string','number','boolean','json') NOT NULL DEFAULT 'string',
    categoria VARCHAR(50) NOT NULL DEFAULT 'geral',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_chave_company (chave, company_id),
    INDEX idx_categoria (categoria),
    CONSTRAINT fk_settings_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE support_tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    user_id INT NOT NULL,
    assunto VARCHAR(255) NOT NULL,
    mensagem TEXT NOT NULL,
    prioridade ENUM('baixa','media','alta') NOT NULL DEFAULT 'media',
    status ENUM('aberto','em_progresso','fechado','cancelado') NOT NULL DEFAULT 'aberto',
    atribuido_para INT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_prioridade (prioridade),
    CONSTRAINT fk_support_tickets_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    CONSTRAINT fk_support_tickets_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_support_tickets_atribuido FOREIGN KEY (atribuido_para) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. VIEWS (mantidas, com colunas essenciais)
CREATE VIEW v_documents_with_files AS
SELECT
    d.id AS document_id,
    d.company_id,
    d.tipo,
    d.numero_documento,
    d.data_validade,
    d.status,
    f.nome_original,
    f.extensao,
    f.tamanho,
    c.nome AS empresa_nome,
    COALESCE(v.matricula, u.nome) AS entidade_nome
FROM documents d
JOIN files f ON d.file_id = f.id
JOIN companies c ON d.company_id = c.id
LEFT JOIN vehicles v ON d.vehicle_id = v.id
LEFT JOIN users u ON d.driver_id = u.id;

CREATE VIEW v_company_stats AS
SELECT
    c.id,
    c.nome,
    c.plano,
    COUNT(DISTINCT u.id) AS total_users,
    COUNT(DISTINCT v.id) AS total_vehicles,
    COALESCE(SUM(f.tamanho),0) AS total_storage_bytes
FROM companies c
LEFT JOIN users u ON c.id = u.company_id
LEFT JOIN vehicles v ON c.id = v.company_id
LEFT JOIN files f ON c.id = f.company_id
GROUP BY c.id, c.nome, c.plano;

CREATE VIEW v_documents_expiring AS
SELECT
    d.id,
    d.company_id,
    d.tipo,
    d.data_validade,
    f.nome_original,
    DATEDIFF(d.data_validade, CURDATE()) AS dias_para_vencimento
FROM documents d
JOIN files f ON d.file_id = f.id
WHERE d.data_validade IS NOT NULL
  AND d.status = 'valido'
  AND DATEDIFF(d.data_validade, CURDATE()) <= d.lembrete_dias
ORDER BY d.data_validade ASC;

CREATE VIEW v_company_costs AS
SELECT
    c.id AS company_id,
    c.nome AS empresa_nome,
    COUNT(DISTINCT v.id) AS total_vehicles,
    COALESCE(SUM(m.custo),0) AS total_maintenance_costs,
    COALESCE(SUM(fl.valor),0) AS total_fuel_costs
FROM companies c
LEFT JOIN vehicles v ON c.id = v.company_id
LEFT JOIN maintenances m ON v.id = m.vehicle_id
LEFT JOIN fuel_logs fl ON v.id = fl.vehicle_id
GROUP BY c.id, c.nome;

-- 12. Seed básico (empresas, users, SETTINGS mantidos)
INSERT INTO companies (nome, nif, email, cidade, pais, estado, plano, limite_veiculos, limite_condutores)
VALUES ('VeiGest Empresa Padrão', '999999990', 'admin@veigest.com', 'Lisboa', 'Portugal', 'ativa', 'enterprise', 1000, 500);

-- Inserir roles (auth_item type=1)
INSERT INTO auth_item (name, type, description, created_at, updated_at) VALUES
('super-admin', 1, 'Super Administrador', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('admin', 1, 'Administrador', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('gestor', 1, 'Gestor de Frota', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('gestor-manutencao', 1, 'Gestor de Manutenção', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('condutor-senior', 1, 'Condutor Senior', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('condutor', 1, 'Condutor', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('visualizador', 1, 'Visualizador', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- Inserir permissões (auth_item type=2)
INSERT INTO auth_item (name, type, description, created_at, updated_at) VALUES
('companies.create', 2, 'Criar Empresas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('companies.read', 2, 'Ver Empresas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('companies.update', 2, 'Editar Empresas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('companies.delete', 2, 'Eliminar Empresas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('companies.manage_plans', 2, 'Gerir Planos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('users.create', 2, 'Criar Utilizadores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('users.read', 2, 'Ver Utilizadores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('users.update', 2, 'Editar Utilizadores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('users.delete', 2, 'Eliminar Utilizadores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('users.manage_roles', 2, 'Gerir Roles', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('vehicles.create', 2, 'Criar Veículos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('vehicles.read', 2, 'Ver Veículos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('vehicles.update', 2, 'Editar Veículos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('vehicles.delete', 2, 'Eliminar Veículos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('vehicles.assign_driver', 2, 'Atribuir Condutores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('drivers.create', 2, 'Criar Perfis de Condutores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('drivers.read', 2, 'Ver Perfis de Condutores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('drivers.update', 2, 'Editar Perfis de Condutores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('drivers.delete', 2, 'Eliminar Perfis de Condutores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('drivers.view_history', 2, 'Ver Histórico de Condutores', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('files.create', 2, 'Upload de Ficheiros', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('files.read', 2, 'Ver Ficheiros', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('files.update', 2, 'Editar Ficheiros', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('files.delete', 2, 'Eliminar Ficheiros', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('files.manage_servers', 2, 'Gerir Servidores de Ficheiros', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('maintenances.create', 2, 'Criar Manutenções', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('maintenances.read', 2, 'Ver Manutenções', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('maintenances.update', 2, 'Editar Manutenções', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('maintenances.delete', 2, 'Eliminar Manutenções', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('maintenances.schedule', 2, 'Agendar Manutenções', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('documents.create', 2, 'Upload de Documentos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('documents.read', 2, 'Ver Documentos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('documents.update', 2, 'Editar Documentos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('documents.delete', 2, 'Eliminar Documentos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('documents.manage_validity', 2, 'Gerir Validades', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('documents.verify', 2, 'Verificar Documentos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('fuel_logs.create', 2, 'Registar Combustível', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('fuel_logs.read', 2, 'Ver Registos de Combustível', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('fuel_logs.update', 2, 'Editar Registos de Combustível', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('fuel_logs.delete', 2, 'Eliminar Registos de Combustível', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('routes.create', 2, 'Iniciar Viagens', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('routes.read', 2, 'Ver Rotas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('routes.update', 2, 'Editar Rotas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('routes.delete', 2, 'Eliminar Rotas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('routes.view_gps', 2, 'Ver Tracking GPS', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('alerts.create', 2, 'Criar Alertas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('alerts.read', 2, 'Ver Alertas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('alerts.resolve', 2, 'Marcar Alertas como Resolvidos', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('alerts.configure', 2, 'Configurar Alertas', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('reports.create', 2, 'Gerar Relatórios', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('reports.read', 2, 'Ver Relatórios', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('reports.export', 2, 'Exportar Relatórios', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('reports.advanced', 2, 'Relatórios Avançados', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('system.config', 2, 'Configurações do Sistema', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('system.view_logs', 2, 'Ver Logs de Atividade', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('system.backup', 2, 'Gerir Backups', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('system.support', 2, 'Suporte Técnico', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),

('dashboard.read', 2, 'Ver Dashboard', UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
('dashboard.advanced', 2, 'Dashboard Avançado', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- Associar permissions aos roles via auth_item_child
-- Super Admin recebe todas as permissões
INSERT INTO auth_item_child (parent, child)
SELECT 'super-admin', name FROM auth_item WHERE type = 2;

-- Admin (exclui certas permissões críticas)
INSERT INTO auth_item_child (parent, child)
SELECT 'admin', name FROM auth_item WHERE type = 2
  AND name NOT IN ('system.config','system.backup','companies.create','companies.delete');

-- Gestor de Frota
INSERT INTO auth_item_child (parent, child)
SELECT 'gestor', name FROM auth_item WHERE type = 2
AND name IN (
  'companies.read',
  'users.read','users.create','users.update',
  'vehicles.create','vehicles.read','vehicles.update','vehicles.assign_driver',
  'drivers.create','drivers.read','drivers.update','drivers.view_history',
  'files.create','files.read','files.update',
  'fuel_logs.read','fuel_logs.update',
  'routes.read','routes.view_gps',
  'alerts.read','alerts.resolve',
  'reports.create','reports.read','reports.export',
  'dashboard.read','dashboard.advanced'
);

-- Gestor de Manutenção
INSERT INTO auth_item_child (parent, child)
SELECT 'gestor-manutencao', name FROM auth_item WHERE type = 2
AND name IN (
  'companies.read',
  'users.read',
  'vehicles.read',
  'files.create','files.read','files.update',
  'maintenances.create','maintenances.read','maintenances.update','maintenances.schedule',
  'documents.create','documents.read','documents.update','documents.manage_validity','documents.verify',
  'alerts.create','alerts.read','alerts.resolve','alerts.configure',
  'reports.read','dashboard.read'
);

-- Condutor Senior
INSERT INTO auth_item_child (parent, child)
SELECT 'condutor-senior', name FROM auth_item WHERE type = 2
AND name IN (
  'vehicles.read','drivers.read','files.read',
  'fuel_logs.create','fuel_logs.read',
  'routes.create','routes.read',
  'documents.read','alerts.read','reports.read','dashboard.read'
);

-- Condutor
INSERT INTO auth_item_child (parent, child)
SELECT 'condutor', name FROM auth_item WHERE type = 2
AND name IN (
  'vehicles.read','files.read',
  'fuel_logs.create','fuel_logs.read',
  'routes.create','routes.read',
  'documents.read','alerts.read','dashboard.read'
);

-- Visualizador
INSERT INTO auth_item_child (parent, child)
SELECT 'visualizador', name FROM auth_item WHERE type = 2
AND name IN (
  'companies.read',
  'users.read',
  'vehicles.read',
  'drivers.read',
  'files.read',
  'fuel_logs.read',
  'routes.read',
  'documents.read',
  'alerts.read',
  'reports.read',
  'dashboard.read'
);

-- criar utilizador admin primeiro
INSERT INTO users (company_id, nome, email, senha_hash, role, estado)
VALUES (1, 'Administrador', 'admin@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'ativo');

-- atribuir role 'super-admin' ao user_id = 1 (auth_assignment)
INSERT INTO auth_assignment (item_name, user_id, created_at)
VALUES ('super-admin', '1', UNIX_TIMESTAMP());

SET FOREIGN_KEY_CHECKS = 1;
