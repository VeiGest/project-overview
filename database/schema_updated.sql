-- ============================================================================
-- VeiGest - Schema Atualizado com Sistema Multi-Empresa e Gestão de Ficheiros
-- Este script mostra a estrutura das novas tabelas e alterações
-- ============================================================================

-- ============================================================================
-- 1. NOVA TABELA DE EMPRESAS
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
-- 2. NOVA TABELA DE FICHEIROS
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
-- 3. NOVA TABELA DE DOCUMENTOS (SUBSTITUINDO A ANTIGA)
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
-- 4. ALTERAÇÕES NAS TABELAS EXISTENTES
-- ============================================================================

-- Adicionar company_id à tabela users
ALTER TABLE users ADD COLUMN company_id INT NOT NULL;
ALTER TABLE users ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE users ADD INDEX idx_company_id (company_id);

-- Adicionar company_id à tabela vehicles
ALTER TABLE vehicles ADD COLUMN company_id INT NOT NULL;
ALTER TABLE vehicles ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE vehicles ADD INDEX idx_company_id (company_id);

-- Alterar tabela settings para incluir company_id
ALTER TABLE settings ADD COLUMN company_id INT NOT NULL;
ALTER TABLE settings ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE settings ADD INDEX idx_company_id (company_id);
ALTER TABLE settings DROP INDEX idx_chave;
ALTER TABLE settings ADD UNIQUE INDEX uk_chave_company (chave, company_id);

-- Adicionar company_id às demais tabelas
ALTER TABLE maintenances ADD COLUMN company_id INT NOT NULL;
ALTER TABLE maintenances ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE maintenances ADD INDEX idx_company_id (company_id);

ALTER TABLE fuel_logs ADD COLUMN company_id INT NOT NULL;
ALTER TABLE fuel_logs ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE fuel_logs ADD INDEX idx_company_id (company_id);

ALTER TABLE routes ADD COLUMN company_id INT NOT NULL;
ALTER TABLE routes ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE routes ADD INDEX idx_company_id (company_id);

ALTER TABLE alerts ADD COLUMN company_id INT NOT NULL;
ALTER TABLE alerts ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE alerts ADD INDEX idx_company_id (company_id);

ALTER TABLE reports ADD COLUMN company_id INT NOT NULL;
ALTER TABLE reports ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE reports ADD INDEX idx_company_id (company_id);

ALTER TABLE activity_logs ADD COLUMN company_id INT NOT NULL;
ALTER TABLE activity_logs ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE activity_logs ADD INDEX idx_company_id (company_id);

ALTER TABLE support_tickets ADD COLUMN company_id INT NOT NULL;
ALTER TABLE support_tickets ADD FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE;
ALTER TABLE support_tickets ADD INDEX idx_company_id (company_id);

-- ============================================================================
-- 5. DADOS INICIAIS
-- ============================================================================

-- Inserir empresa padrão
INSERT INTO companies (nome, nome_comercial, nif, email, telefone, cidade, pais, estado, plano, limite_veiculos, limite_condutores) VALUES
('VeiGest Empresa Padrão', 'VeiGest', '999999990', 'admin@veigest.com', '+351900000000', 'Lisboa', 'Portugal', 'ativa', 'enterprise', 1000, 500);

-- ============================================================================
-- 6. VIEWS ÚTEIS PARA CONSULTAS
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
    SUM(f.tamanho) as total_storage_bytes
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
