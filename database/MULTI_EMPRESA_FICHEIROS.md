# 🏢 Sistema Multi-Empresa e Gestão de Ficheiros - VeiGest

## 📋 Visão Geral

Esta documentação descreve as novas funcionalidades implementadas no VeiGest para suporte a **múltiplas empresas** e **gestão avançada de ficheiros**. As mudanças foram projetadas para permitir que uma única instalação do VeiGest sirva múltiplas organizações de forma isolada e segura.

---

## 🏢 Sistema Multi-Empresa

### Arquitetura

O sistema multi-empresa implementa isolamento completo de dados através da adição de `company_id` em todas as tabelas principais:

```
Companies (1) ───< Users (N)
Companies (1) ───< Vehicles (N)
Companies (1) ───< Settings (N)
Companies (1) ───< Documents (N)
Companies (1) ───< Files (N)
Companies (1) ───< [Todas as outras tabelas] (N)
```

### Tabela de Empresas (`companies`)

#### Campos Principais
- **Identificação**: `nome`, `nome_comercial`, `nif`, `email`
- **Contactos**: `telefone`, `endereco`, `codigo_postal`, `cidade`, `pais`
- **Branding**: `website`, `logo`
- **Subscrição**: `plano`, `limite_veiculos`, `limite_condutores`, `data_expiracao`
- **Estado**: `estado` (ativa, suspensa, inativa)
- **Configurações**: `configuracoes` (JSON para configurações específicas)

#### Planos Disponíveis
- **Básico**: Até 10 veículos, 5 condutores
- **Profissional**: Até 50 veículos, 25 condutores
- **Enterprise**: Sem limites

#### Estados da Empresa
- **Ativa**: Funcionamento normal
- **Suspensa**: Acesso limitado (só leitura)
- **Inativa**: Sem acesso

### Impacto nas Tabelas Existentes

Todas as tabelas principais agora incluem `company_id`:
- `users` - Utilizadores pertencem a uma empresa
- `vehicles` - Veículos pertencem a uma empresa
- `settings` - Configurações específicas por empresa
- `maintenances` - Manutenções isoladas por empresa
- `fuel_logs` - Registos de combustível por empresa
- `routes` - Viagens isoladas por empresa
- `alerts` - Alertas específicos por empresa
- `reports` - Relatórios por empresa
- `activity_logs` - Logs de auditoria por empresa
- `support_tickets` - Tickets de suporte por empresa

### Configurações por Empresa (`settings`)

As configurações agora são específicas por empresa, permitindo:
- **Personalização**: Cada empresa tem as suas configurações
- **Moeda**: Configuração de moeda específica
- **Idioma**: Idioma padrão da empresa
- **Alertas**: Configurações de notificação personalizadas
- **Integração**: APIs e serviços externos específicos

**Exemplo de configurações**:
```json
{
  "moeda": "EUR",
  "idioma": "pt-PT",
  "timezone": "Europe/Lisbon",
  "alertas": {
    "documentos_dias_antecedencia": 30,
    "manutencao_quilometragem": 1000
  },
  "integracao": {
    "google_maps_api": "AIza...",
    "fuel_api_key": "abc123..."
  }
}
```

---

## 📁 Sistema de Gestão de Ficheiros

### Arquitetura

O sistema separa claramente **ficheiros físicos** de **documentos lógicos**:

```
Files (1) ───< Documents (N)
Users (1) ───< Files (N) [uploadedBy]
Companies (1) ───< Files (N)
```

### Tabela de Ficheiros (`files`)

#### Informações do Ficheiro
- **Identificação**: `nome_original`, `nome_arquivo`, `extensao`, `mime_type`
- **Tamanho**: `tamanho` (em bytes)
- **Integridade**: `hash_md5`, `hash_sha256`

#### Configuração do Servidor
- **Tipo**: `servidor_tipo` (local, filestash, aws_s3, google_cloud, azure)
- **URL**: `servidor_url` (URL base do servidor)
- **Bucket**: `servidor_bucket` (nome do bucket/container)
- **Caminho**: `servidor_path` (caminho completo no servidor)
- **Configuração**: `servidor_config` (JSON com configurações específicas)

#### Metadados e Controlo
- **Visibilidade**: `visibilidade` (publico, privado, restrito)
- **Categoria**: `categoria` (documento, imagem, video, etc.)
- **Tags**: `tags` (JSON array para pesquisa)
- **Metadados**: `metadados` (JSON com metadados específicos)

#### URLs e Acesso
- **URL Pública**: `url_publica` (se disponível)
- **URL Download**: `url_download` (para download direto)
- **Expiração**: `expira_em` (data de expiração)

### Tipos de Servidor Suportados

#### Local
```json
{
  "servidor_tipo": "local",
  "servidor_path": "/uploads/2024/10/documento.pdf",
  "servidor_config": {
    "base_path": "/var/www/uploads"
  }
}
```

#### FileStash
```json
{
  "servidor_tipo": "filestash",
  "servidor_url": "https://filestash.empresa.com",
  "servidor_path": "/documentos/2024/10/documento.pdf",
  "servidor_config": {
    "api_key": "abc123",
    "username": "veigest"
  }
}
```

#### AWS S3
```json
{
  "servidor_tipo": "aws_s3",
  "servidor_bucket": "veigest-files",
  "servidor_path": "empresa1/documentos/2024/10/documento.pdf",
  "servidor_config": {
    "region": "eu-west-1",
    "access_key": "AKIA...",
    "secret_key": "xyz..."
  }
}
```

### Controlo de Integridade

- **MD5**: Hash principal para verificação rápida
- **SHA256**: Hash secundário para maior segurança
- **Deduplicação**: Evita ficheiros duplicados por empresa baseado no hash
- **Verificação**: Verificação periódica da integridade dos ficheiros

---

## 📄 Sistema de Documentos Melhorado

### Nova Arquitetura

A nova tabela `documents` substitui a anterior com funcionalidades avançadas:

```
Documents (N) ───> Files (1) [file_id]
Documents (N) ───> Companies (1) [company_id]
Documents (N) ───> Vehicles (1) [vehicle_id] (opcional)
Documents (N) ───> Users (1) [driver_id] (opcional)
Documents (N) ───> Documents (1) [documento_anterior_id] (versionamento)
```

### Tipos de Documentos

- **DUA**: Documento Único Automóvel
- **Seguro**: Apólices de seguro
- **Inspeção**: Certificados de inspeção
- **Carta de Condução**: Cartas de condução
- **Licença de Condução**: Licenças profissionais
- **Certificado de Formação**: Certificados diversos
- **Contrato**: Contratos de trabalho, leasing, etc.
- **Manual**: Manuais de utilizador
- **Outro**: Outros tipos de documentos

### Estados do Documento

- **Válido**: Documento válido e ativo
- **Expirado**: Documento expirado
- **Por Renovar**: Em processo de renovação
- **Cancelado**: Documento cancelado
- **Suspenso**: Temporariamente suspenso

### Funcionalidades Avançadas

#### Versionamento
- **Histórico Completo**: Cada documento mantém histórico de versões
- **Referência Anterior**: `documento_anterior_id` cria cadeia de versões
- **Motivo de Atualização**: `motivo_atualizacao` documenta mudanças

#### Alertas Inteligentes
- **Dias de Antecedência**: `lembrete_dias` configurável por documento
- **Notificações**: `notificacao_enviada` controla envio de alertas
- **Renovação Automática**: `renovacao_automatica` para documentos recorrentes

#### Classificação e Organização
- **Categoria**: `categoria` (legal, operacional, administrativo)
- **Prioridade**: `prioridade` (baixa, normal, alta, crítica)
- **Confidencial**: `confidencial` para documentos sensíveis
- **Tags**: `tags` JSON para organização flexível

#### Auditoria Completa
- **Criado Por**: `criado_por` - quem criou o documento
- **Atualizado Por**: `atualizado_por` - quem fez a última atualização
- **Verificado Por**: `verificado_por` - quem verificou/validou
- **Data de Verificação**: `data_verificacao` - quando foi verificado

---

## 🔧 Implementação e Migração

### Ordem de Execução das Migrations

1. **m241022_000001_create_companies_table.php**
   - Cria tabela de empresas
   - Insere empresa padrão para migração

2. **m241022_000002_add_company_to_settings.php**
   - Adiciona `company_id` à tabela settings
   - Migra configurações existentes para empresa padrão

3. **m241022_000003_create_files_table.php**
   - Cria sistema de gestão de ficheiros
   - Suporte a múltiplos tipos de servidor

4. **m241022_000004_create_documents_table.php**
   - Cria nova tabela de documentos
   - Sistema avançado com versionamento

5. **m241022_000005_add_company_to_existing_tables.php**
   - Adiciona `company_id` a todas as tabelas existentes
   - Migra dados existentes para empresa padrão

### Migração de Dados Existentes

Durante a migração, todos os dados existentes são automaticamente associados à **empresa padrão** criada com:
- **Nome**: "VeiGest Empresa Padrão"
- **NIF**: "999999990"
- **Plano**: Enterprise (sem limites)

### Comandos de Migração

```bash
# Executar todas as migrations
php yii migrate/up

# Executar migrations específicas
php yii migrate/to m241022_000005_add_company_to_existing_tables

# Reverter se necessário
php yii migrate/down 5
```

---

## 🚀 Benefícios das Novas Funcionalidades

### Para Administradores
- **Escalabilidade**: Uma instalação serve múltiplas empresas
- **Isolamento**: Dados completamente separados entre empresas
- **Flexibilidade**: Configurações específicas por organização
- **Controlo**: Gestão centralizada com planos e limites

### Para Utilizadores
- **Performance**: Ficheiros servidos via CDN
- **Segurança**: Controlo granular de acesso a ficheiros
- **Organização**: Sistema avançado de documentos com tags e categorias
- **Auditoria**: Histórico completo de todas as ações

### Para Developers
- **Modularidade**: Sistema de ficheiros independente
- **Extensibilidade**: Fácil adição de novos tipos de servidor
- **Manutenibilidade**: Separação clara entre ficheiros e documentos
- **Testabilidade**: Estrutura bem definida para testes

---

## 📝 Exemplos de Uso

### Criação de Empresa
```php
$company = new Company();
$company->nome = 'Transportes ABC';
$company->nif = '123456789';
$company->plano = 'profissional';
$company->limite_veiculos = 50;
$company->save();
```

### Upload de Ficheiro
```php
$file = new File();
$file->company_id = $company->id;
$file->nome_original = 'seguro_veiculo.pdf';
$file->servidor_tipo = 'aws_s3';
$file->servidor_bucket = 'veigest-files';
$file->save();
```

### Criação de Documento
```php
$document = new Document();
$document->company_id = $company->id;
$document->file_id = $file->id;
$document->vehicle_id = $vehicle->id;
$document->tipo = 'seguro';
$document->data_validade = '2025-12-31';
$document->save();
```
