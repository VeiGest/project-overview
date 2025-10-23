-- ============================================================================
-- VeiGest - Sistema de Gestão de Frotas Multi-Empresa
-- Schema Completo - MariaDB/MySQL
-- Versão 2.0 com Sistema Multi-Empresa e Gestão de Ficheiros
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS veigest;
CREATE DATABASE veigest CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE veigest;

-- ============================================================================
-- 1. EMPRESAS (MULTI-TENANCY)
-- ============================================================================

CREATE TABLE companies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    nome_comercial VARCHAR(200),
    nif VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(150),
    telefone VARCHAR(20),
    endereco TEXT,
    codigo_postal VARCHAR(10),
    cidade VARCHAR(100),
    pais VARCHAR(100) DEFAULT 'Portugal',
    website VARCHAR(255),
    logo VARCHAR(255),
    estado ENUM('ativa', 'suspensa', 'inativa') NOT NULL DEFAULT 'ativa',
    plano ENUM('basico', 'profissional', 'enterprise') NOT NULL DEFAULT 'basico',
    limite_veiculos INT DEFAULT 10,
    limite_condutores INT DEFAULT 5,
    data_expiracao DATE,
    configuracoes JSON,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_nif (nif),
    INDEX idx_estado (estado),
    INDEX idx_plano (plano),
    INDEX idx_nome (nome)
);

-- ============================================================================
-- 2. AUTENTICAÇÃO E UTILIZADORES
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
    company_id INT NOT NULL,
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
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE SET NULL,
    INDEX idx_company_id (company_id),
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
-- 3. GESTÃO DE FICHEIROS
-- ============================================================================

CREATE TABLE files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    nome_original VARCHAR(255) NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    extensao VARCHAR(10) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    tamanho BIGINT NOT NULL,
    hash_md5 VARCHAR(32),
    hash_sha256 VARCHAR(64),
    
    -- Configuração do servidor de ficheiros
    servidor_tipo ENUM('local', 'filestash', 'aws_s3', 'google_cloud', 'azure') NOT NULL DEFAULT 'local',
    servidor_url VARCHAR(500),
    servidor_bucket VARCHAR(100),
    servidor_path VARCHAR(500) NOT NULL,
    servidor_config JSON,
    
    -- Metadados
    visibilidade ENUM('publico', 'privado', 'restrito') NOT NULL DEFAULT 'privado',
    categoria VARCHAR(50),
    tags JSON,
    metadados JSON,
    
    -- Controlo de acesso
    uploaded_by INT NOT NULL,
    url_publica VARCHAR(500),
    url_download VARCHAR(500),
    expira_em DATETIME,
    
    -- Estado
    estado ENUM('ativo', 'arquivado', 'eliminado') NOT NULL DEFAULT 'ativo',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT,
    
    INDEX idx_company_id (company_id),
    INDEX idx_nome_arquivo (nome_arquivo),
    INDEX idx_extensao (extensao),
    INDEX idx_categoria (categoria),
    INDEX idx_estado (estado),
    INDEX idx_servidor_tipo (servidor_tipo),
    INDEX idx_uploaded_by (uploaded_by),
    UNIQUE INDEX uk_hash_company (hash_md5, company_id)
);

-- ============================================================================
-- 4. GESTÃO DE FROTA
-- ============================================================================

-- Veículos da frota
CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    matricula VARCHAR(20) NOT NULL,
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
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (condutor_id) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uk_matricula_company (matricula, company_id),
    INDEX idx_company_id (company_id),
    INDEX idx_matricula (matricula),
    INDEX idx_estado (estado),
    INDEX idx_condutor (condutor_id),
    INDEX idx_tipo_combustivel (tipo_combustivel)
);

-- Histórico de manutenções
CREATE TABLE maintenances (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
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
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_data (data),
    INDEX idx_proxima_data (proxima_data),
    INDEX idx_tipo (tipo)
);

-- ============================================================================
-- 5. DOCUMENTOS (NOVA VERSÃO COM FICHEIROS)
-- ============================================================================

CREATE TABLE documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    file_id INT NOT NULL,
    
    -- Entidade associada
    vehicle_id INT,
    driver_id INT,
    
    -- Informações do documento
    tipo ENUM('dua', 'seguro', 'inspecao', 'carta_conducao', 'licenca_conducao', 'certificado_formacao', 'contrato', 'manual', 'outro') NOT NULL,
    numero_documento VARCHAR(100),
    entidade_emissora VARCHAR(200),
    data_emissao DATE,
    data_validade DATE,
    renovacao_automatica BOOLEAN DEFAULT FALSE,
    
    -- Classificação
    categoria VARCHAR(50),
    prioridade ENUM('baixa', 'normal', 'alta', 'critica') NOT NULL DEFAULT 'normal',
    confidencial BOOLEAN DEFAULT FALSE,
    tags JSON,
    
    -- Status
    status ENUM('valido', 'expirado', 'por_renovar', 'cancelado', 'suspenso') NOT NULL DEFAULT 'valido',
    observacoes TEXT,
    lembrete_dias INT DEFAULT 30,
    notificacao_enviada BOOLEAN DEFAULT FALSE,
    data_ultima_verificacao DATETIME,
    
    -- Versionamento
    versao INT DEFAULT 1,
    documento_anterior_id INT,
    motivo_atualizacao TEXT,
    
    -- Auditoria
    criado_por INT NOT NULL,
    atualizado_por INT,
    verificado_por INT,
    data_verificacao DATETIME,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE RESTRICT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (documento_anterior_id) REFERENCES documents(id) ON DELETE SET NULL,
    FOREIGN KEY (criado_por) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (atualizado_por) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (verificado_por) REFERENCES users(id) ON DELETE RESTRICT,
    
    INDEX idx_company_id (company_id),
    INDEX idx_file_id (file_id),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_driver_id (driver_id),
    INDEX idx_tipo (tipo),
    INDEX idx_status (status),
    INDEX idx_data_validade (data_validade),
    INDEX idx_categoria (categoria),
    INDEX idx_validade_status (data_validade, status),
    INDEX idx_company_tipo (company_id, tipo),
    
    CONSTRAINT chk_documents_entity CHECK (vehicle_id IS NOT NULL OR driver_id IS NOT NULL)
);

-- ============================================================================
-- 6. REGISTOS OPERACIONAIS
-- ============================================================================

-- Registos de abastecimento
CREATE TABLE fuel_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
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
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_driver_id (driver_id),
    INDEX idx_data (data),
    INDEX idx_data_vehicle (data, vehicle_id)
);

-- Rotas e viagens
CREATE TABLE routes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
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
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id),
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
-- 7. ALERTAS E NOTIFICAÇÕES
-- ============================================================================

-- Sistema de alertas
CREATE TABLE alerts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
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
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id),
    INDEX idx_tipo (tipo),
    INDEX idx_status (status),
    INDEX idx_prioridade (prioridade),
    INDEX idx_data_limite (data_limite),
    INDEX idx_user_id (user_id),
    INDEX idx_vehicle_id (vehicle_id)
);

-- ============================================================================
-- 8. RELATÓRIOS E AUDITORIA
-- ============================================================================

-- Relatórios gerados
CREATE TABLE reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
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
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (gerado_por) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id),
    INDEX idx_tipo (tipo),
    INDEX idx_gerado_por (gerado_por),
    INDEX idx_status (status),
    INDEX idx_criado_em (criado_em)
);

-- Logs de atividade para auditoria
CREATE TABLE activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    user_id INT,
    acao VARCHAR(255) NOT NULL,
    entidade VARCHAR(100) NOT NULL,
    entidade_id INT,
    detalhes JSON,
    ip VARCHAR(45),
    user_agent TEXT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_company_id (company_id),
    INDEX idx_user_id (user_id),
    INDEX idx_acao (acao),
    INDEX idx_entidade (entidade),
    INDEX idx_criado_em (criado_em),
    INDEX idx_entidade_id (entidade, entidade_id)
);

-- ============================================================================
-- 9. CONFIGURAÇÕES E SUPORTE
-- ============================================================================

-- Configurações do sistema
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    chave VARCHAR(100) NOT NULL,
    valor TEXT,
    tipo ENUM('string', 'number', 'boolean', 'json') NOT NULL DEFAULT 'string',
    descricao TEXT,
    categoria VARCHAR(50) NOT NULL DEFAULT 'geral',
    editavel BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE INDEX uk_chave_company (chave, company_id),
    INDEX idx_company_id (company_id),
    INDEX idx_categoria (categoria)
);

-- Tickets de suporte
CREATE TABLE support_tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
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
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (atribuido_para) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_company_id (company_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_prioridade (prioridade),
    INDEX idx_criado_em (criado_em)
);

-- ============================================================================
-- 10. VIEWS ÚTEIS PARA CONSULTAS
-- ============================================================================

-- View para documentos com informações do ficheiro
CREATE VIEW v_documents_with_files AS
SELECT 
    d.*,
    f.nome_original,
    f.extensao,
    f.tamanho,
    f.servidor_tipo,
    f.url_publica,
    f.url_download,
    c.nome as empresa_nome,
    CASE 
        WHEN d.vehicle_id IS NOT NULL THEN v.matricula
        WHEN d.driver_id IS NOT NULL THEN u.nome
    END as entidade_nome
FROM documents d
JOIN files f ON d.file_id = f.id
JOIN companies c ON d.company_id = c.id
LEFT JOIN vehicles v ON d.vehicle_id = v.id
LEFT JOIN users u ON d.driver_id = u.id;

-- View para estatísticas por empresa
CREATE VIEW v_company_stats AS
SELECT 
    c.id,
    c.nome,
    c.plano,
    COUNT(DISTINCT u.id) as total_users,
    COUNT(DISTINCT v.id) as total_vehicles,
    COUNT(DISTINCT d.id) as total_documents,
    COUNT(DISTINCT f.id) as total_files,
    COALESCE(SUM(f.tamanho), 0) as total_storage_bytes
FROM companies c
LEFT JOIN users u ON c.id = u.company_id
LEFT JOIN vehicles v ON c.id = v.company_id
LEFT JOIN documents d ON c.id = d.company_id
LEFT JOIN files f ON c.id = f.company_id
GROUP BY c.id, c.nome, c.plano;

-- View para documentos próximos do vencimento
CREATE VIEW v_documents_expiring AS
SELECT 
    d.*,
    f.nome_original,
    c.nome as empresa_nome,
    DATEDIFF(d.data_validade, CURDATE()) as dias_para_vencimento
FROM documents d
JOIN files f ON d.file_id = f.id
JOIN companies c ON d.company_id = c.id
WHERE d.data_validade IS NOT NULL 
  AND d.status = 'valido'
  AND DATEDIFF(d.data_validade, CURDATE()) <= d.lembrete_dias
ORDER BY d.data_validade ASC;

-- View para relatório de custos por empresa
CREATE VIEW v_company_costs AS
SELECT 
    c.id as company_id,
    c.nome as empresa_nome,
    COUNT(DISTINCT v.id) as total_vehicles,
    COALESCE(SUM(m.custo), 0) as total_maintenance_costs,
    COALESCE(SUM(fl.valor), 0) as total_fuel_costs,
    COALESCE(SUM(m.custo) + SUM(fl.valor), 0) as total_costs
FROM companies c
LEFT JOIN vehicles v ON c.id = v.company_id
LEFT JOIN maintenances m ON v.id = m.vehicle_id
LEFT JOIN fuel_logs fl ON v.id = fl.vehicle_id
GROUP BY c.id, c.nome;

-- ============================================================================
-- 11. DADOS INICIAIS (SEEDS)
-- ============================================================================

-- Inserir empresa padrão
INSERT INTO companies (nome, nome_comercial, nif, email, telefone, cidade, pais, estado, plano, limite_veiculos, limite_condutores) VALUES
('VeiGest Empresa Padrão', 'VeiGest', '999999990', 'admin@veigest.com', '+351900000000', 'Lisboa', 'Portugal', 'ativa', 'enterprise', 1000, 500);

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
-- Gestão de Empresas
('Criar Empresas', 'Permissão para criar novas empresas', 'companies', 'create', 'companies.create'),
('Ver Empresas', 'Permissão para visualizar empresas', 'companies', 'read', 'companies.read'),
('Editar Empresas', 'Permissão para editar empresas', 'companies', 'update', 'companies.update'),
('Eliminar Empresas', 'Permissão para eliminar empresas', 'companies', 'delete', 'companies.delete'),
('Gerir Planos', 'Permissão para gerir planos das empresas', 'companies', 'manage_plans', 'companies.manage_plans'),

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

-- Gestão de Ficheiros
('Upload de Ficheiros', 'Permissão para fazer upload de ficheiros', 'files', 'create', 'files.create'),
('Ver Ficheiros', 'Permissão para visualizar ficheiros', 'files', 'read', 'files.read'),
('Editar Ficheiros', 'Permissão para editar metadados de ficheiros', 'files', 'update', 'files.update'),
('Eliminar Ficheiros', 'Permissão para eliminar ficheiros', 'files', 'delete', 'files.delete'),
('Gerir Servidores de Ficheiros', 'Permissão para configurar servidores de ficheiros', 'files', 'manage_servers', 'files.manage_servers'),

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
('Verificar Documentos', 'Permissão para verificar e validar documentos', 'documents', 'verify', 'documents.verify'),

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
WHERE slug NOT IN ('system.config', 'system.backup', 'companies.create', 'companies.delete');

-- Gestor de Frota (ID=3)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions 
WHERE slug IN (
    'companies.read',
    'users.read', 'users.create', 'users.update',
    'vehicles.create', 'vehicles.read', 'vehicles.update', 'vehicles.assign_driver',
    'drivers.create', 'drivers.read', 'drivers.update', 'drivers.view_history',
    'files.create', 'files.read', 'files.update',
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
    'companies.read',
    'users.read',
    'vehicles.read',
    'files.create', 'files.read', 'files.update',
    'maintenances.create', 'maintenances.read', 'maintenances.update', 'maintenances.schedule',
    'documents.create', 'documents.read', 'documents.update', 'documents.manage_validity', 'documents.verify',
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
    'files.read',
    'fuel_logs.create', 'fuel_logs.read',
    'routes.create', 'routes.read',
    'documents.read',
    'alerts.read',
    'reports.read',
    'dashboard.read'
);

-- Condutor (ID=6)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 6, id FROM permissions 
WHERE slug IN (
    'vehicles.read',
    'files.read',
    'fuel_logs.create', 'fuel_logs.read',
    'routes.create', 'routes.read',
    'documents.read',
    'alerts.read',
    'dashboard.read'
);

-- Visualizador (ID=7)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 7, id FROM permissions 
WHERE slug IN (
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

-- Usuário administrador padrão
INSERT INTO users (company_id, nome, email, senha_hash, role_id, role, estado) VALUES
(1, 'Administrador', 'admin@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 'admin', 'ativo');

-- Configurações padrão do sistema para a empresa padrão
INSERT INTO settings (company_id, chave, valor, tipo, descricao, categoria) VALUES
(1, 'app_name', 'VeiGest', 'string', 'Nome da aplicação', 'geral'),
(1, 'app_version', '2.0.0', 'string', 'Versão da aplicação', 'geral'),
(1, 'max_file_size', '10485760', 'number', 'Tamanho máximo de arquivo em bytes (10MB)', 'uploads'),
(1, 'allowed_file_types', 'jpg,jpeg,png,pdf,doc,docx', 'string', 'Tipos de arquivo permitidos para upload', 'uploads'),
(1, 'default_fuel_alert_km', '50000', 'number', 'Quilometragem padrão para alerta de manutenção', 'alertas'),
(1, 'gps_tracking_enabled', 'true', 'boolean', 'Ativar tracking GPS', 'gps'),
(1, 'backup_retention_days', '30', 'number', 'Dias para manter backups', 'sistema'),
(1, 'file_server_type', 'local', 'string', 'Tipo de servidor de ficheiros padrão', 'files'),
(1, 'document_retention_days', '2555', 'number', 'Dias para manter documentos arquivados (7 anos)', 'documents'),
(1, 'auto_alert_days', '30', 'number', 'Dias de antecedência para alertas automáticos', 'alertas');

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- 12. TRIGGERS PARA AUTOMATIZAÇÕES E VALIDAÇÕES
-- ============================================================================

DELIMITER //

-- ============================================================================
-- TRIGGERS PARA AUDITORIA AUTOMÁTICA
-- ============================================================================

-- Trigger para registar login de utilizadores
CREATE TRIGGER tr_user_login_update
    AFTER UPDATE ON users
    FOR EACH ROW
BEGIN
    IF NEW.ultimo_login != OLD.ultimo_login THEN
        INSERT INTO activity_logs (company_id, user_id, acao, entidade, entidade_id, detalhes, criado_em)
        VALUES (NEW.company_id, NEW.id, 'login', 'users', NEW.id, 
                JSON_OBJECT('timestamp', NEW.ultimo_login), NOW());
    END IF;
END//

-- Trigger para auditoria de alterações em veículos
CREATE TRIGGER tr_vehicles_audit_insert
    AFTER INSERT ON vehicles
    FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (company_id, user_id, acao, entidade, entidade_id, detalhes, criado_em)
    VALUES (NEW.company_id, NULL, 'create', 'vehicles', NEW.id,
            JSON_OBJECT('matricula', NEW.matricula, 'marca', NEW.marca, 'modelo', NEW.modelo), NOW());
END//

CREATE TRIGGER tr_vehicles_audit_update
    AFTER UPDATE ON vehicles
    FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (company_id, user_id, acao, entidade, entidade_id, detalhes, criado_em)
    VALUES (NEW.company_id, NULL, 'update', 'vehicles', NEW.id,
            JSON_OBJECT(
                'old_estado', OLD.estado, 'new_estado', NEW.estado,
                'old_km', OLD.quilometragem, 'new_km', NEW.quilometragem,
                'old_condutor', OLD.condutor_id, 'new_condutor', NEW.condutor_id
            ), NOW());
END//

CREATE TRIGGER tr_vehicles_audit_delete
    AFTER DELETE ON vehicles
    FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (company_id, user_id, acao, entidade, entidade_id, detalhes, criado_em)
    VALUES (OLD.company_id, NULL, 'delete', 'vehicles', OLD.id,
            JSON_OBJECT('matricula', OLD.matricula, 'marca', OLD.marca, 'modelo', OLD.modelo), NOW());
END//

-- ============================================================================
-- TRIGGERS PARA GESTÃO DE DOCUMENTOS E ALERTAS
-- ============================================================================

-- Trigger para criar alertas automáticos quando documentos expiram
CREATE TRIGGER tr_documents_expiration_alert
    AFTER INSERT ON documents
    FOR EACH ROW
BEGIN
    IF NEW.data_validade IS NOT NULL THEN
        INSERT INTO alerts (company_id, tipo, titulo, descricao, data_limite, prioridade, user_id, vehicle_id, document_id, criado_em)
        VALUES (
            NEW.company_id,
            'documento',
            CONCAT('Documento ', NEW.tipo, ' próximo do vencimento'),
            CONCAT('O documento ', NEW.numero_documento, ' vence em ', NEW.data_validade),
            DATE_SUB(NEW.data_validade, INTERVAL NEW.lembrete_dias DAY),
            CASE 
                WHEN DATEDIFF(NEW.data_validade, CURDATE()) <= 7 THEN 'critica'
                WHEN DATEDIFF(NEW.data_validade, CURDATE()) <= 15 THEN 'alta'
                WHEN DATEDIFF(NEW.data_validade, CURDATE()) <= 30 THEN 'media'
                ELSE 'baixa'
            END,
            CASE WHEN NEW.driver_id IS NOT NULL THEN NEW.driver_id ELSE NULL END,
            NEW.vehicle_id,
            NEW.id,
            NOW()
        );
    END IF;
END//

-- Trigger para atualizar status de documentos expirados
CREATE TRIGGER tr_documents_status_update
    BEFORE UPDATE ON documents
    FOR EACH ROW
BEGIN
    IF NEW.data_validade IS NOT NULL AND NEW.data_validade < CURDATE() AND OLD.status = 'valido' THEN
        SET NEW.status = 'expirado';
    END IF;
END//

-- ============================================================================
-- TRIGGERS PARA VALIDAÇÕES DE NEGÓCIO
-- ============================================================================

-- Trigger para validar limites da empresa
CREATE TRIGGER tr_users_company_limit_check
    BEFORE INSERT ON users
    FOR EACH ROW
BEGIN
    DECLARE user_count INT;
    DECLARE user_limit INT;
    
    SELECT COUNT(*), c.limite_condutores 
    INTO user_count, user_limit
    FROM users u 
    JOIN companies c ON u.company_id = c.id 
    WHERE u.company_id = NEW.company_id AND c.id = NEW.company_id;
    
    IF user_count >= user_limit THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Limite de condutores da empresa atingido';
    END IF;
END//

CREATE TRIGGER tr_vehicles_company_limit_check
    BEFORE INSERT ON vehicles
    FOR EACH ROW
BEGIN
    DECLARE vehicle_count INT;
    DECLARE vehicle_limit INT;
    
    SELECT COUNT(*), c.limite_veiculos 
    INTO vehicle_count, vehicle_limit
    FROM vehicles v 
    JOIN companies c ON v.company_id = c.id 
    WHERE v.company_id = NEW.company_id AND c.id = NEW.company_id;
    
    IF vehicle_count >= vehicle_limit THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Limite de veículos da empresa atingido';
    END IF;
END//

-- Trigger para validar quilometragem crescente
CREATE TRIGGER tr_fuel_logs_km_validation
    BEFORE INSERT ON fuel_logs
    FOR EACH ROW
BEGIN
    DECLARE last_km INT DEFAULT 0;
    
    SELECT COALESCE(MAX(km_atual), 0) INTO last_km
    FROM fuel_logs 
    WHERE vehicle_id = NEW.vehicle_id;
    
    IF NEW.km_atual < last_km THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Quilometragem não pode ser inferior ao último registo';
    END IF;
    
    -- Atualizar quilometragem do veículo
    UPDATE vehicles 
    SET quilometragem = NEW.km_atual, atualizado_em = NOW()
    WHERE id = NEW.vehicle_id;
END//

-- ============================================================================
-- TRIGGERS PARA MANUTENÇÃO DE DADOS
-- ============================================================================

-- Trigger para atualizar automaticamente o hash MD5 dos ficheiros
CREATE TRIGGER tr_files_hash_update
    BEFORE UPDATE ON files
    FOR EACH ROW
BEGIN
    IF NEW.tamanho != OLD.tamanho OR NEW.nome_arquivo != OLD.nome_arquivo THEN
        SET NEW.atualizado_em = NOW();
    END IF;
END//

-- Trigger para limpar alertas resolvidos automaticamente
CREATE TRIGGER tr_documents_resolved_alerts
    AFTER UPDATE ON documents
    FOR EACH ROW
BEGIN
    IF NEW.status = 'valido' AND OLD.status IN ('expirado', 'por_renovar') THEN
        UPDATE alerts 
        SET status = 'resolvido', resolvido_em = NOW()
        WHERE document_id = NEW.id AND status = 'ativo';
    END IF;
END//

-- ============================================================================
-- TRIGGERS PARA GESTÃO DE ROTAS E GPS
-- ============================================================================

-- Trigger para calcular distância e tempo total das rotas
CREATE TRIGGER tr_routes_calculate_totals
    BEFORE UPDATE ON routes
    FOR EACH ROW
BEGIN
    IF NEW.fim IS NOT NULL AND OLD.fim IS NULL THEN
        -- Calcular tempo total em minutos
        SET NEW.tempo_total = TIMESTAMPDIFF(MINUTE, NEW.inicio, NEW.fim);
        
        -- Calcular distância se temos km inicial e final
        IF NEW.km_inicial IS NOT NULL AND NEW.km_final IS NOT NULL THEN
            SET NEW.distancia_km = NEW.km_final - NEW.km_inicial;
        END IF;
        
        -- Atualizar status para finalizada se ainda não foi definido
        IF NEW.status = 'iniciada' THEN
            SET NEW.status = 'finalizada';
        END IF;
    END IF;
END//

-- ============================================================================
-- TRIGGERS PARA ALERTAS AUTOMÁTICOS DE MANUTENÇÃO
-- ============================================================================

-- Trigger para criar alertas de manutenção baseados em quilometragem
CREATE TRIGGER tr_maintenances_next_alert
    AFTER INSERT ON maintenances
    FOR EACH ROW
BEGIN
    DECLARE next_km INT;
    DECLARE vehicle_km INT;
    
    -- Obter quilometragem atual do veículo
    SELECT quilometragem INTO vehicle_km 
    FROM vehicles 
    WHERE id = NEW.vehicle_id;
    
    -- Calcular próxima manutenção (exemplo: a cada 10.000 km)
    SET next_km = NEW.km_registro + 10000;
    
    -- Criar alerta se a próxima manutenção está próxima (dentro de 1000 km)
    IF (next_km - vehicle_km) <= 1000 THEN
        INSERT INTO alerts (company_id, tipo, titulo, descricao, prioridade, vehicle_id, criado_em)
        VALUES (
            NEW.company_id,
            'manutencao',
            'Manutenção preventiva necessária',
            CONCAT('Veículo precisa de manutenção em ', next_km, ' km'),
            CASE 
                WHEN (next_km - vehicle_km) <= 200 THEN 'critica'
                WHEN (next_km - vehicle_km) <= 500 THEN 'alta'
                ELSE 'media'
            END,
            NEW.vehicle_id,
            NOW()
        );
    END IF;
END//

-- ============================================================================
-- TRIGGERS PARA GESTÃO DE FICHEIROS E STORAGE
-- ============================================================================

-- Trigger para atualizar estatísticas de storage da empresa
CREATE TRIGGER tr_files_storage_stats_insert
    AFTER INSERT ON files
    FOR EACH ROW
BEGIN
    -- Atualizar configurações da empresa com novo total de storage
    UPDATE companies 
    SET configuracoes = JSON_SET(
        COALESCE(configuracoes, '{}'),
        '$.total_storage_bytes', 
        COALESCE(JSON_EXTRACT(configuracoes, '$.total_storage_bytes'), 0) + NEW.tamanho,
        '$.total_files',
        COALESCE(JSON_EXTRACT(configuracoes, '$.total_files'), 0) + 1,
        '$.last_file_upload',
        NOW()
    )
    WHERE id = NEW.company_id;
END//

CREATE TRIGGER tr_files_storage_stats_delete
    AFTER DELETE ON files
    FOR EACH ROW
BEGIN
    -- Atualizar configurações da empresa removendo storage
    UPDATE companies 
    SET configuracoes = JSON_SET(
        COALESCE(configuracoes, '{}'),
        '$.total_storage_bytes', 
        GREATEST(0, COALESCE(JSON_EXTRACT(configuracoes, '$.total_storage_bytes'), 0) - OLD.tamanho),
        '$.total_files',
        GREATEST(0, COALESCE(JSON_EXTRACT(configuracoes, '$.total_files'), 0) - 1)
    )
    WHERE id = OLD.company_id;
END//

-- ============================================================================
-- TRIGGERS PARA VERSIONAMENTO DE DOCUMENTOS
-- ============================================================================

-- Trigger para manter histórico de versões de documentos
CREATE TRIGGER tr_documents_versioning
    BEFORE UPDATE ON documents
    FOR EACH ROW
BEGIN
    -- Se o file_id mudou, é uma nova versão
    IF NEW.file_id != OLD.file_id THEN
        SET NEW.versao = OLD.versao + 1;
        SET NEW.documento_anterior_id = OLD.id;
        
        -- Registar auditoria da nova versão
        INSERT INTO activity_logs (company_id, user_id, acao, entidade, entidade_id, detalhes, criado_em)
        VALUES (NEW.company_id, NEW.atualizado_por, 'version_update', 'documents', NEW.id,
                JSON_OBJECT(
                    'old_version', OLD.versao, 
                    'new_version', NEW.versao,
                    'old_file_id', OLD.file_id,
                    'new_file_id', NEW.file_id,
                    'motivo', NEW.motivo_atualizacao
                ), NOW());
    END IF;
END//

DELIMITER ;

-- ============================================================================
-- FIM DO SCHEMA COMPLETO COM TRIGGERS
-- ============================================================================
