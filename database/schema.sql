-- ============================================================================
-- VeiGest - Sistema de Gestão de Frotas Empresariais
-- Database Schema - MariaDB/MySQL
-- Data: Outubro 2025
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS veigest;
CREATE DATABASE veigest CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE veigest;

-- ============================================================================
-- 1. AUTENTICAÇÃO E UTILIZADORES
-- ============================================================================

-- Tabela principal de utilizadores
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    role ENUM('admin', 'gestor', 'condutor') NOT NULL DEFAULT 'condutor',
    estado ENUM('ativo', 'inativo') NOT NULL DEFAULT 'ativo',
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_login DATETIME,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
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
INSERT INTO users (nome, email, senha_hash, role, estado) VALUES
('Administrador', 'admin@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'ativo');

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================
