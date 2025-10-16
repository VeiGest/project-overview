Este documento apresenta a **estrutura completa do projeto VeiGest**, incluindo arquitetura, stack tecnológica, modelagem da base de dados e interfaces principais.

---
# 🚛 VeiGest — Plataforma de Gestão de Frotas Empresariais

---

## 📘 Visão Geral

**VeiGest** é uma plataforma integrada para **gestão de frotas empresariais**, projetada para conectar **gestores** e **condutores** num ecossistema digital centralizado.  
A solução combina **website (painel administrativo)**, **API backend** e **aplicação móvel**, permitindo:

- Monitorizar veículos e condutores em tempo real  
- Planejar e registrar viagens  
- Controlar documentos, manutenções e alertas  
- Otimizar custos e operações da frota  

---

## 🧩 Estrutura do Projeto

| Camada | Tecnologia | Descrição |
|--------|-------------|-----------|
| **WebApp (Gestão)** | Yii2.0 (PHP Framework) | Interface principal para gestores administrarem veículos, condutores e relatórios. |
| **API (Integração)** | Yii2.0 (RESTful API) | Serviço intermediário para integração entre app mobile e backend. |
| **Mobile App (Condutor)** | Android SDK (Java/Kotlin) | Aplicação móvel para os condutores acompanharem viagens e registarem eventos. |
| **Database** | MariaDB / MySQL | Banco de dados relacional, com tabelas normalizadas e integradas via ORM do Yii2. |
| **Infraestrutura** | Docker (opcional) | Containerização e ambiente de deploy simplificado. |

---

## 🧱 Arquitetura Geral

```plaintext
[ Mobile App ]
     ↕
[ REST API – Yii2 ]
     ↕
[ WebApp – Yii2 Admin Panel ]
     ↕
[ Database (MariaDB) ]
````

---

## 🗄️ Estrutura da Base de Dados

O sistema foi projetado com base em uma arquitetura relacional, priorizando **integridade, escalabilidade e auditabilidade**.

### 🔐 Autenticação e Utilizadores

* **users** — Armazena todos os tipos de utilizadores (admin, gestor, condutor).
* **drivers_profiles** — Detalhes específicos dos condutores (carta de condução, validade, etc).

### 🚗 Gestão de Frota

* **vehicles** — Cadastro de veículos (marca, modelo, matrícula, condutor, estado).
* **maintenances** — Histórico e agendamento de manutenções.
* **documents** — Controle de validade e upload de documentos (DUA, seguro, inspeção).
* **fuel_logs** — Registo de abastecimentos e comprovativos.
* **routes** — Registo de viagens com origem, destino e quilometragem.
* **gps_points** — Pontos GPS (tracking em tempo real).

### ⚠️ Alertas e Notificações

* **alerts** — Lembretes automáticos e avisos críticos (manutenção, seguro, inspeção).

### 📊 Relatórios e Registos

* **reports** — Geração de relatórios e exportações.
* **activity_logs** — Auditoria e histórico de ações dos utilizadores.
* **support_tickets** — Sistema de suporte interno.

---

## 🧭 Principais Relacionamentos (ER Resumido)

```
users (1) ───< vehicles (N)
users (1) ───< drivers_profiles (1)
vehicles (1) ───< maintenances (N)
vehicles (1) ───< documents (N)
vehicles (1) ───< fuel_logs (N)
vehicles (1) ───< routes (N)
routes (1) ───< gps_points (N)
users (1) ───< alerts (N)
```

---

## 🖥️ Interface Web (Gestores)

A aplicação web é o **centro de controlo** do sistema.

### Páginas Principais

| Secção             | Página                       | Elementos Principais                           |
| ------------------ | ---------------------------- | ---------------------------------------------- |
| **Login e Sessão** | Login / Recuperar Senha      | Campos de autenticação e recuperação.          |
| **Dashboard**      | Painel Resumo                | Cards de KPIs, alertas e gráficos.             |
| **Frota**          | Lista e Detalhe de Veículos  | Tabela, filtros, formulário de criação/edição. |
| **Condutores**     | Lista e Perfil               | Dados pessoais, histórico de viagens.          |
| **Manutenções**    | Histórico / Agendar          | Registo de revisões, alertas de manutenção.    |
| **Documentos**     | Gestão Documental            | Upload, validade e status.                     |
| **Alertas**        | Painel de Lembretes          | Lista de alertas por tipo.                     |
| **Rotas**          | Mapa Tracking                | Google Maps API, visualização em tempo real.   |
| **Relatórios**     | Estatísticas e Exportações   | KPIs, custos, manutenção, consumo.             |
| **Administração**  | Utilizadores / Configurações | Gestão de permissões e preferências.           |

---

## 📱 Aplicação Mobile (Condutores)

A app mobile é o **ponto de interação rápido** dos condutores.

### Telas Principais

| Secção           | Tela                    | Campos / Elementos                         |
| ---------------- | ----------------------- | ------------------------------------------ |
| **Login**        | Autenticação            | Email, senha, botão entrar.                |
| **Dashboard**    | Ecrã Inicial            | Dados do veículo, alertas, iniciar viagem. |
| **Tracking**     | Iniciar Viagem          | Mapa (GPS ativo), botão “Finalizar”.       |
| **Histórico**    | Viagens anteriores      | Lista com data, distância e custo.         |
| **Avarias**      | Reportar Avaria         | Campos: tipo, descrição, upload de foto.   |
| **Combustível**  | Registrar Abastecimento | Litros, valor, recibo.                     |
| **Documentos**   | Meus Documentos         | Lista e validade.                          |
| **Notificações** | Alertas ativos          | Lista com ícones e estados.                |
| **Perfil**       | Meu Perfil              | Nome, e-mail, logout, editar perfil.       |

---

## 🎯 Funcionalidades-Chave

### Funcionalidades Básicas

* Tracking GPS e registo de rotas
* Gestão de veículos e condutores
* Registo de manutenções e revisões
* Lembretes automáticos (IUC, seguro, inspeção)
* Gestão documental e uploads
* Alertas e notificações automáticas
* Relatórios e estatísticas

### Funcionalidades Avançadas (Futuro)

* Otimização de rotas
* Alertas de atividade em tempo real (excesso de velocidade, desvio de percurso)
* Deteção de roubo / uso indevido

---

## ⚙️ Stack Tecnológica

| Camada               | Tecnologia                        |
| -------------------- | --------------------------------- |
| **Backend / API**    | PHP 8.x + Yii2 Framework          |
| **Frontend Web**     | Yii2 MVC + Bootstrap              |
| **Mobile App**       | Android SDK (Java/Kotlin)         |
| **Banco de Dados**   | MariaDB / MySQL                   |
| **Infraestrutura**   | Docker, Nginx, PHP-FPM            |
| **Mapas e Tracking** | Google Maps API / GPS             |
| **Relatórios**       | Charts.js / Recharts / Export PDF |
| **Autenticação**     | JWT (API) e Sessions (Web)        |

---

## 🚀 Implementação e Desenvolvimento

### Fase 1: Base de Dados e Backend
- [x] **Modelagem ER** — Diagrama completo criado (`database/ER_Diagram.md`)
- [x] **Schema SQL** — Script completo de criação (`database/schema.sql`)
- [x] **Migrations Yii2** — Estrutura base preparada (`database/migrations/`)
- [ ] **Modelos ActiveRecord** — Criar modelos Yii2 para todas as tabelas
- [ ] **API REST** — Implementar endpoints: `/vehicles`, `/drivers`, `/routes`, `/alerts`
- [ ] **Autenticação JWT** — Sistema de login e controle de acesso

### Fase 2: Interface Web
- [ ] **Dashboard Gestor** — Painel principal com KPIs e alertas
- [ ] **CRUD Veículos** — Gestão completa da frota
- [ ] **CRUD Condutores** — Gestão de condutores e perfis
- [ ] **Sistema de Alertas** — Notificações automáticas
- [ ] **Relatórios** — Geração de relatórios em PDF/Excel
- [ ] **Gestão Documental** — Upload e controle de validade

### Fase 3: Aplicação Mobile
- [ ] **Interface Android** — App nativo para condutores
- [ ] **Integração GPS** — Tracking em tempo real
- [ ] **Sincronização Offline** — Funcionamento sem internet
- [ ] **Notificações Push** — Alertas móveis

### Fase 4: Funcionalidades Avançadas
- [ ] **Otimização de Rotas** — Algoritmos de melhor caminho
- [ ] **Analytics Avançados** — Machine Learning para padrões
- [ ] **Integração APIs** — Combustível, seguros, oficinas
- [ ] **Sistema de Backup** — Backup automático e recovery

## 🧠 Próximos Passos Imediatos

1. **Configurar Ambiente de Desenvolvimento**
   ```bash
   composer create-project --prefer-dist yiisoft/yii2-app-advanced veigest
   cd veigest
   php init
   ```

2. **Configurar Base de Dados**
   ```bash
   # Executar schema.sql no MySQL/MariaDB
   mysql -u root -p < database/schema.sql
   
   # Configurar conexão no common/config/main-local.php
   # Executar migrations
   php yii migrate
   ```

3. **Implementar Modelos Base**
   - User, Vehicle, Route, Alert, Document
   - Relacionamentos e validações
   - Behaviors (TimestampBehavior, BlameableBehavior)

4. **Criar Controllers API**
   - RESTful controllers para cada entidade
   - Serialização JSON
   - Paginação e filtros

5. **Implementar Autenticação**
   - JWT tokens
   - Middleware de autorização
   - Roles e permissões

---

## 📂 Organização do Projeto

```plaintext
VeiGest/
├── backend/                    # Yii2 API (REST)
│   ├── controllers/
│   ├── models/
│   ├── modules/
│   └── runtime/
├── frontend/                   # Yii2 WebApp
│   ├── controllers/
│   ├── models/
│   ├── views/
│   ├── web/
│   └── widgets/
├── mobile/                     # Android App
│   ├── app/src/main/java/
│   ├── app/src/main/res/
│   └── app/build.gradle
├── database/                   # Scripts e Migrations
│   ├── migrations/             # Yii2 migrations
│   ├── schema.sql             # Schema completo
│   ├── ER_Diagram.md          # Diagrama ER
│   └── seeders.sql            # Dados iniciais
├── docker/                     # Containerização
│   ├── docker-compose.yml
│   ├── nginx/
│   ├── php/
│   └── mysql/
├── docs/                       # Documentação
│   ├── API.md                 # Documentação da API
│   ├── Wireframes/            # Protótipos UI
│   └── User_Manual.md         # Manual do usuário
├── common/                     # Código compartilhado
│   ├── config/
│   ├── models/
│   └── mail/
├── console/                    # Comandos CLI
│   ├── controllers/
│   └── migrations/
├── .env.example               # Variáveis de ambiente
├── composer.json              # Dependências PHP
└── README.md                  # Documentação principal
```

---

## 📜 Licença

Projeto interno (privado).
Desenvolvido para **gestão corporativa de frotas empresariais**.

---

## 👥 Equipa / Autoria

**Projeto:** VeiGest
**Tipo:** Sistema Web + Mobile + API
**Função:** Gestão e monitorização de frotas
**Ano:** 2025