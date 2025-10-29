-- VeiGest - Schema Simplificado
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
    INDEX (nif),
    INDEX (estado)
);

-- 2. roles, permissions, role_permissions
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    nivel_hierarquia INT NOT NULL DEFAULT 1,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL UNIQUE,
    modulo VARCHAR(50) NOT NULL,
    acao VARCHAR(50) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role_permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    UNIQUE KEY (role_id, permission_id)
);

-- 3. users e drivers_profiles (simplificados)
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    role_id INT,
    role ENUM('admin','gestor','condutor') NOT NULL DEFAULT 'condutor',
    estado ENUM('ativo','inativo') NOT NULL DEFAULT 'ativo',
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_login DATETIME,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE SET NULL
);

CREATE TABLE drivers_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    numero_carta VARCHAR(50),
    validade_carta DATE,
    nif VARCHAR(20),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (user_id)
);

-- 4. files (simplificado)
CREATE TABLE files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    nome_original VARCHAR(255) NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    extensao VARCHAR(10),
    mime_type VARCHAR(100),
    tamanho BIGINT NOT NULL,
    servidor_tipo ENUM('local','aws_s3','google_cloud','azure') NOT NULL DEFAULT 'local',
    servidor_path VARCHAR(500),
    uploaded_by INT NOT NULL,
    visibilidade ENUM('publico','privado','restrito') NOT NULL DEFAULT 'privado',
    estado ENUM('ativo','arquivado','eliminado') NOT NULL DEFAULT 'ativo',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT
);

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
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (condutor_id) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY (matricula, company_id)
);

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
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

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
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE RESTRICT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (documento_anterior_id) REFERENCES documents(id) ON DELETE SET NULL,
    FOREIGN KEY (criado_por) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_documents_entity CHECK (vehicle_id IS NOT NULL OR driver_id IS NOT NULL)
);

-- 7. fuel_logs, routes, gps_points
CREATE TABLE fuel_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    driver_id INT,
    data DATE NOT NULL,
    litros DECIMAL(10,2) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    preco_litro DECIMAL(8,4) GENERATED ALWAYS AS (CASE WHEN litros = 0 THEN 0 ELSE valor / litros END) STORED,
    km_atual INT,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE SET NULL
);

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
    status ENUM('iniciada','finalizada','cancelada') NOT NULL DEFAULT 'iniciada',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL
);

CREATE TABLE gps_points (
    id INT PRIMARY KEY AUTO_INCREMENT,
    route_id INT NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    timestamp DATETIME NOT NULL,
    FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
);

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
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
);

-- 9. reports e activity_logs
CREATE TABLE reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    tipo ENUM('frota','condutor','custos','rotas','manutencao','combustivel') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    periodo_inicio DATE,
    periodo_fim DATE,
    parametros JSON,
    gerado_por INT NOT NULL,
    arquivo VARCHAR(255),
    status ENUM('processando','concluido','erro') NOT NULL DEFAULT 'processando',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (gerado_por) REFERENCES users(id) ON DELETE SET NULL
);

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
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 10. settings e support_tickets (simplificados)
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    chave VARCHAR(100) NOT NULL,
    valor TEXT,
    tipo ENUM('string','number','boolean','json') NOT NULL DEFAULT 'string',
    categoria VARCHAR(50) NOT NULL DEFAULT 'geral',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE KEY (chave, company_id)
);

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
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (atribuido_para) REFERENCES users(id) ON DELETE SET NULL
);

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

-- 12. Seed básico
INSERT INTO companies (nome, nif, email, cidade, pais, estado, plano, limite_veiculos, limite_condutores)
VALUES ('VeiGest Empresa Padrão', '999999990', 'admin@veigest.com', 'Lisboa', 'Portugal', 'ativa', 'enterprise', 1000, 500);

INSERT INTO roles (nome, slug, nivel_hierarquia) VALUES
('Super Administrador','super-admin',100),
('Administrador','admin',90),
('Gestor de Frota','gestor',50),
('Condutor','condutor',10),
('Visualizador','visualizador',5);

-- Algumas permissions essenciais (exemplo reduzido)
INSERT INTO permissions (nome, modulo, acao, slug) VALUES
('Ver Empresas','companies','read','companies.read'),
('Gerir Utilizadores','users','manage','users.manage'),
('Gestão Veículos','vehicles','manage','vehicles.manage'),
('Gestão Documentos','documents','manage','documents.manage'),
('Gestão Ficheiros','files','manage','files.manage'),
('Registos Combustível','fuel_logs','manage','fuel_logs.manage'),
('Manutenções','maintenances','manage','maintenances.manage'),
('Relatórios','reports','generate','reports.generate'),
('Config Sistema','system','config','system.config');

-- Super Admin recebe todas as permissions inseridas
INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

-- Admin user
INSERT INTO users (company_id, nome, email, senha_hash, role_id, role, estado)
VALUES (1, 'Administrador', 'admin@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, 'admin', 'ativo');

-- 13. Triggers simplificados (uso de delimitador)
DELIMITER $$
CREATE TRIGGER tr_user_login_update
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.ultimo_login IS NOT NULL AND NEW.ultimo_login != OLD.ultimo_login THEN
        INSERT INTO activity_logs (company_id, user_id, acao, entidade, entidade_id, detalhes, criado_em)
        VALUES (NEW.company_id, NEW.id, 'login', 'users', NEW.id, JSON_OBJECT('timestamp', NEW.ultimo_login), NOW());
    END IF;
END$$

CREATE TRIGGER tr_vehicles_audit_insert
AFTER INSERT ON vehicles
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (company_id, acao, entidade, entidade_id, detalhes, criado_em)
    VALUES (NEW.company_id, 'create', 'vehicles', NEW.id, JSON_OBJECT('matricula',NEW.matricula,'modelo',NEW.modelo), NOW());
END$$

CREATE TRIGGER tr_vehicles_audit_update
AFTER UPDATE ON vehicles
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (company_id, acao, entidade, entidade_id, detalhes, criado_em)
    VALUES (NEW.company_id, 'update', 'vehicles', NEW.id,
            JSON_OBJECT('old_km',OLD.quilometragem,'new_km',NEW.quilometragem,'old_estado',OLD.estado,'new_estado',NEW.estado), NOW());
END$$

CREATE TRIGGER tr_documents_expiration_alert
AFTER INSERT ON documents
FOR EACH ROW
BEGIN
    IF NEW.data_validade IS NOT NULL THEN
        INSERT INTO alerts (company_id, tipo, titulo, descricao, data_limite, prioridade, user_id, vehicle_id, document_id, criado_em)
        VALUES (NEW.company_id, 'documento',
            CONCAT('Documento ', NEW.tipo, ' próximo do vencimento'),
            CONCAT('Documento ', COALESCE(NEW.numero_documento,''), ' vence em ', NEW.data_validade),
            DATE_SUB(NEW.data_validade, INTERVAL NEW.lembrete_dias DAY),
            CASE WHEN DATEDIFF(NEW.data_validade, CURDATE()) <= 7 THEN 'critica' WHEN DATEDIFF(NEW.data_validade, CURDATE()) <= 30 THEN 'alta' ELSE 'media' END,
            NEW.driver_id, NEW.vehicle_id, NEW.id, NOW());
    END IF;
END$$

CREATE TRIGGER tr_documents_status_update
BEFORE UPDATE ON documents
FOR EACH ROW
BEGIN
    IF NEW.data_validade IS NOT NULL AND NEW.data_validade < CURDATE() AND OLD.status = 'valido' THEN
        SET NEW.status = 'expirado';
    END IF;
END$$

CREATE TRIGGER tr_fuel_logs_km_validation
BEFORE INSERT ON fuel_logs
FOR EACH ROW
BEGIN
    DECLARE last_km INT DEFAULT 0;
    SELECT COALESCE(MAX(km_atual),0) INTO last_km FROM fuel_logs WHERE vehicle_id = NEW.vehicle_id;
    IF NEW.km_atual IS NOT NULL AND NEW.km_atual < last_km THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quilometragem não pode ser inferior ao último registo';
    END IF;
    -- Atualiza quilometragem do veículo (simples)
    IF NEW.km_atual IS NOT NULL THEN
        UPDATE vehicles SET quilometragem = NEW.km_atual, atualizado_em = NOW() WHERE id = NEW.vehicle_id;
    END IF;
END$$

CREATE TRIGGER tr_routes_calculate_totals
BEFORE UPDATE ON routes
FOR EACH ROW
BEGIN
    IF NEW.fim IS NOT NULL AND OLD.fim IS NULL THEN
        SET NEW.distancia_km = CASE WHEN NEW.km_inicial IS NOT NULL AND NEW.km_final IS NOT NULL THEN NEW.km_final - NEW.km_inicial ELSE NEW.distancia_km END;
    END IF;
END$$

CREATE TRIGGER tr_documents_versioning
BEFORE UPDATE ON documents
FOR EACH ROW
BEGIN
    IF NEW.file_id != OLD.file_id THEN
        SET NEW.versao = OLD.versao + 1;
        SET NEW.documento_anterior_id = OLD.id;
        INSERT INTO activity_logs (company_id, user_id, acao, entidade, entidade_id, detalhes, criado_em)
        VALUES (NEW.company_id, NEW.criado_por, 'version_update', 'documents', NEW.id,
                JSON_OBJECT('old_version', OLD.versao, 'new_version', NEW.versao), NOW());
    END IF;
END$$
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
