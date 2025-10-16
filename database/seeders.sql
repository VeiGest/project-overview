-- ============================================================================
-- VeiGest - Dados Iniciais (Seeders)
-- Este arquivo contém dados de exemplo para desenvolvimento e testes
-- ============================================================================

USE veigest;

-- Limpar dados existentes (cuidado em produção!)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE activity_logs;
TRUNCATE TABLE gps_points;
TRUNCATE TABLE routes;
TRUNCATE TABLE fuel_logs;
TRUNCATE TABLE alerts;
TRUNCATE TABLE documents;
TRUNCATE TABLE maintenances;
TRUNCATE TABLE vehicles;
TRUNCATE TABLE drivers_profiles;
TRUNCATE TABLE users;
TRUNCATE TABLE support_tickets;
TRUNCATE TABLE reports;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- USUÁRIOS DE EXEMPLO
-- ============================================================================

INSERT INTO users (nome, email, senha_hash, telefone, role, estado) VALUES
-- Administradores
('João Silva', 'admin@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351912345678', 'admin', 'ativo'),
('Maria Santos', 'maria.admin@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351987654321', 'admin', 'ativo'),

-- Gestores
('Pedro Costa', 'gestor@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351923456789', 'gestor', 'ativo'),
('Ana Ferreira', 'ana.gestor@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351934567890', 'gestor', 'ativo'),

-- Condutores
('Carlos Mendes', 'carlos@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351945678901', 'condutor', 'ativo'),
('Rita Oliveira', 'rita@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351956789012', 'condutor', 'ativo'),
('Miguel Sousa', 'miguel@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351967890123', 'condutor', 'ativo'),
('Joana Rodrigues', 'joana@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351978901234', 'condutor', 'ativo'),
('Rui Almeida', 'rui@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351989012345', 'condutor', 'ativo'),
('Sofia Pereira', 'sofia@veigest.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+351990123456', 'condutor', 'ativo');

-- ============================================================================
-- PERFIS DOS CONDUTORES
-- ============================================================================

INSERT INTO drivers_profiles (user_id, numero_carta, validade_carta, nif, endereco) VALUES
(5, 'B1234567890', '2028-12-31', '123456789', 'Rua das Flores, 123, Lisboa'),
(6, 'B2345678901', '2027-06-15', '234567890', 'Avenida Central, 456, Porto'),
(7, 'B3456789012', '2029-03-20', '345678901', 'Praça da República, 789, Braga'),
(8, 'B4567890123', '2026-11-10', '456789012', 'Rua da Liberdade, 321, Coimbra'),
(9, 'B5678901234', '2030-01-25', '567890123', 'Largo do Município, 654, Faro'),
(10, 'B6789012345', '2028-08-30', '678901234', 'Rua do Comércio, 987, Aveiro');

-- ============================================================================
-- VEÍCULOS DA FROTA
-- ============================================================================

INSERT INTO vehicles (matricula, marca, modelo, ano, tipo_combustivel, quilometragem, estado, data_aquisicao, condutor_id, notas) VALUES
-- Carros de passageiros
('12-AB-34', 'Volkswagen', 'Golf', 2020, 'diesel', 45000, 'ativo', '2020-03-15', 5, 'Carro em excelente estado'),
('56-CD-78', 'Toyota', 'Corolla', 2019, 'híbrido', 62000, 'ativo', '2019-07-22', 6, 'Híbrido com baixo consumo'),
('90-EF-12', 'BMW', 'Serie 3', 2021, 'diesel', 28000, 'ativo', '2021-01-10', 7, 'Carro executivo'),
('34-GH-56', 'Renault', 'Clio', 2018, 'gasolina', 78000, 'ativo', '2018-11-05', 8, 'Carro urbano económico'),

-- Comerciais ligeiros
('78-IJ-90', 'Ford', 'Transit', 2020, 'diesel', 89000, 'ativo', '2020-06-18', 9, 'Carrinha de carga'),
('23-KL-45', 'Mercedes', 'Sprinter', 2019, 'diesel', 112000, 'manutencao', NULL, 'Em manutenção preventiva'),

-- Veículos elétricos
('67-MN-89', 'Tesla', 'Model 3', 2022, 'elétrico', 15000, 'ativo', '2022-09-12', 10, 'Veículo 100% elétrico'),
('01-OP-23', 'Nissan', 'Leaf', 2021, 'elétrico', 22000, 'ativo', '2021-12-03', NULL, 'Disponível para atribuição');

-- ============================================================================
-- MANUTENÇÕES (HISTÓRICO)
-- ============================================================================

INSERT INTO maintenances (vehicle_id, tipo, descricao, data, custo, km_registro, proxima_data, oficina, notas) VALUES
(1, 'Revisão Geral', 'Revisão dos 40.000 km - troca de óleo, filtros', '2024-09-15', 185.50, 40000, '2025-03-15', 'AutoServiço Lisboa', 'Tudo OK'),
(2, 'Troca de Pneus', 'Substituição dos 4 pneus por desgaste', '2024-08-22', 320.00, 60000, NULL, 'PneuCenter Porto', 'Pneus de inverno'),
(3, 'Manutenção Sistema Híbrido', 'Verificação do sistema híbrido', '2024-10-01', 95.00, 25000, '2025-04-01', 'Toyota Oficial', 'Sistema funcionando perfeitamente'),
(4, 'Troca de Óleo', 'Mudança de óleo do motor', '2024-07-10', 65.00, 75000, '2024-12-10', 'Oficina Central', 'Óleo sintético'),
(5, 'Revisão Comercial', 'Revisão específica para veículo comercial', '2024-06-25', 245.00, 85000, '2024-12-25', 'Ford Service', 'Incluiu verificação da carga'),
(6, 'Reparação Motor', 'Reparação do sistema de injeção', '2024-10-10', 850.00, 110000, '2025-01-10', 'Mercedes Oficial', 'Garantia de 6 meses');

-- ============================================================================
-- DOCUMENTOS
-- ============================================================================

INSERT INTO documents (vehicle_id, driver_id, tipo, numero, emissor, data_emissao, validade, status, notas) VALUES
-- Documentos de veículos
(1, NULL, 'DUA', 'DUA123456', 'AT - Autoridade Tributária', '2024-01-01', '2024-12-31', 'valido', 'DUA pago em dia'),
(1, NULL, 'Seguro', 'SEG789012', 'Seguros Unidos', '2024-03-01', '2025-02-28', 'valido', 'Seguro contra todos os riscos'),
(1, NULL, 'Inspecao', 'INS345678', 'Centro de Inspeções', '2024-02-15', '2025-02-14', 'valido', 'Inspeção periódica aprovada'),

(2, NULL, 'DUA', 'DUA234567', 'AT - Autoridade Tributária', '2024-01-01', '2024-12-31', 'valido', NULL),
(2, NULL, 'Seguro', 'SEG890123', 'Seguros Globais', '2024-04-01', '2025-03-31', 'valido', NULL),
(2, NULL, 'Inspecao', 'INS456789', 'Centro de Inspeções', '2024-05-20', '2025-05-19', 'valido', NULL),

-- Documentos de condutores
(NULL, 5, 'Carta', 'B1234567890', 'IMTT', '2020-01-01', '2028-12-31', 'valido', 'Carta de condução categoria B'),
(NULL, 6, 'Carta', 'B2345678901', 'IMTT', '2019-06-15', '2027-06-15', 'valido', 'Renovar em breve'),
(NULL, 7, 'Carta', 'B3456789012', 'IMTT', '2021-03-20', '2029-03-20', 'valido', NULL);

-- ============================================================================
-- ABASTECIMENTOS
-- ============================================================================

INSERT INTO fuel_logs (vehicle_id, driver_id, data, litros, valor, local, km_atual, notas) VALUES
(1, 5, '2024-10-01', 45.20, 63.78, 'BP - Alameda, Lisboa', 44500, 'Tanque cheio'),
(1, 5, '2024-09-15', 38.50, 54.25, 'Galp - Sete Rios', 44000, NULL),
(2, 6, '2024-10-05', 42.30, 59.22, 'Repsol - Campanhã, Porto', 61800, 'Desconto cartão'),
(3, 7, '2024-09-28', 35.10, 49.64, 'BP - Braga Centro', 27500, 'Combustível premium'),
(4, 8, '2024-10-08', 40.80, 56.32, 'Galp - Coimbra Sul', 77900, NULL),
(5, 9, '2024-09-20', 65.40, 89.85, 'Repsol - A1 Cartaxo', 88200, 'Viagem longa'),
(7, 10, '2024-10-12', 0.00, 12.50, 'EDP - Carregamento Elétrico', 14800, 'Carregamento rápido 80%');

-- ============================================================================
-- ROTAS/VIAGENS
-- ============================================================================

INSERT INTO routes (driver_id, vehicle_id, inicio, fim, distancia_km, tempo_total, origem, destino, km_inicial, km_final, proposito, status) VALUES
(5, 1, '2024-10-15 08:00:00', '2024-10-15 10:30:00', 85.5, 150, 'Lisboa - Sede', 'Porto - Cliente ABC', 44000, 44085, 'Reunião comercial', 'finalizada'),
(6, 2, '2024-10-14 14:00:00', '2024-10-14 18:45:00', 125.2, 285, 'Porto - Filial', 'Braga - Fornecedor XYZ', 61500, 61625, 'Recolha de material', 'finalizada'),
(7, 3, '2024-10-16 09:15:00', '2024-10-16 11:00:00', 45.8, 105, 'Braga - Escritório', 'Guimarães - Reunião', 27200, 27246, 'Apresentação projeto', 'finalizada'),
(8, 4, '2024-10-13 16:30:00', '2024-10-13 17:45:00', 28.3, 75, 'Coimbra - Base', 'Figueira da Foz - Entrega', 77500, 77528, 'Entrega documentos', 'finalizada'),
(9, 5, '2024-10-12 07:00:00', '2024-10-12 19:30:00', 320.0, 750, 'Lisboa - Armazém', 'Faro - Distribuição', 87500, 87820, 'Entrega mercadoria', 'finalizada'),
(10, 7, '2024-10-16 10:00:00', NULL, NULL, NULL, 'Aveiro - Sede', 'Lisboa - Reunião', 14650, NULL, 'Reunião diretoria', 'iniciada');

-- ============================================================================
-- ALERTAS ATIVOS
-- ============================================================================

INSERT INTO alerts (tipo, titulo, descricao, data_limite, prioridade, status, user_id, vehicle_id, document_id) VALUES
('inspecao', 'Inspeção Próxima do Vencimento', 'A inspeção do veículo 56-CD-78 vence em 30 dias', '2025-05-19', 'media', 'ativo', 6, 2, 6),
('documento', 'Carta de Condução a Expirar', 'A carta de condução de Rita Oliveira expira em 2027', '2027-06-15', 'baixa', 'ativo', 6, NULL, 8),
('manutencao', 'Manutenção Programada', 'Veículo 23-KL-45 necessita de manutenção', '2024-12-25', 'alta', 'ativo', NULL, 6, NULL),
('seguro', 'Renovação de Seguro', 'Seguro do veículo 12-AB-34 renova em 3 meses', '2025-02-28', 'media', 'ativo', 5, 1, 2),
('combustivel', 'Consumo Elevado', 'Veículo 78-IJ-90 com consumo acima da média', NULL, 'baixa', 'ativo', 9, 5, NULL);

-- ============================================================================
-- CONFIGURAÇÕES ADICIONAIS
-- ============================================================================

INSERT INTO settings (chave, valor, tipo, descricao, categoria) VALUES
('smtp_host', 'mail.veigest.com', 'string', 'Servidor SMTP para envio de emails', 'email'),
('smtp_port', '587', 'number', 'Porta do servidor SMTP', 'email'),
('smtp_username', 'noreply@veigest.com', 'string', 'Utilizador SMTP', 'email'),
('alert_days_before_expiry', '30', 'number', 'Dias antes do vencimento para alertar', 'alertas'),
('max_fuel_variance', '15', 'number', 'Percentagem máxima de variação no consumo', 'combustivel'),
('company_name', 'VeiGest - Gestão de Frotas', 'string', 'Nome da empresa', 'geral'),
('company_address', 'Rua da Inovação, 100\n1000-000 Lisboa', 'string', 'Morada da empresa', 'geral'),
('company_phone', '+351 210 000 000', 'string', 'Telefone da empresa', 'geral'),
('company_email', 'info@veigest.com', 'string', 'Email da empresa', 'geral');

-- ============================================================================
-- LOG DE ATIVIDADES (EXEMPLOS)
-- ============================================================================

INSERT INTO activity_logs (user_id, acao, entidade, entidade_id, detalhes, ip) VALUES
(1, 'LOGIN', 'users', 1, '{"role": "admin", "timestamp": "2024-10-16 08:30:00"}', '192.168.1.100'),
(5, 'CREATE', 'fuel_logs', 1, '{"vehicle_id": 1, "litros": 45.20, "valor": 63.78}', '192.168.1.105'),
(3, 'UPDATE', 'vehicles', 6, '{"campo_alterado": "estado", "valor_anterior": "ativo", "valor_novo": "manutencao"}', '192.168.1.103'),
(6, 'CREATE', 'routes', 6, '{"vehicle_id": 7, "origem": "Aveiro", "destino": "Lisboa"}', '192.168.1.106'),
(2, 'GENERATE', 'reports', 1, '{"tipo": "frota", "periodo": "2024-10"}', '192.168.1.102');

COMMIT;
