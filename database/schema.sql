-- ============================================================
--  ARENA GAMER  –  schema.sql  (VERSÃO DO ALUNO)
--  AULA 1  –  DDL: criação do banco e das tabelas
--
--  Entregável: execute este script do zero sem erros.
--  O sistema não funciona sem este arquivo.
-- ============================================================

CREATE DATABASE IF NOT EXISTS arena_gamer
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE arena_gamer;

-- ──────────────────────────────────────────────────────────────
--  TABELA: clientes
--  Armazena os clientes cadastrados na lan house.
--  Colunas obrigatórias para o sistema:
--    id_cliente     INT PK AUTO_INCREMENT
--    nome           VARCHAR(100) NOT NULL
--    email          VARCHAR(100) UNIQUE NOT NULL
--    telefone       VARCHAR(20)
--    saldo_creditos DECIMAL(8,2) DEFAULT 0.00
--    data_cadastro  DATETIME DEFAULT CURRENT_TIMESTAMP
-- ──────────────────────────────────────────────────────────────
-- TODO: Crie a tabela 'clientes'
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT, 
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    saldo_creditos DECIMAL(8,2) DEFAULT 0.00,
    CONSTRAINT PK_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT UN_cliente_email UNIQUE (email)
  );

-- ──────────────────────────────────────────────────────────────
--  TABELA: computadores
--  Representa cada PC disponível para locação.
--  Colunas obrigatórias para o sistema:
--    id_computador  INT PK AUTO_INCREMENT
--    numero         INT NOT NULL UNIQUE
--    descricao      VARCHAR(100)
--    status         ENUM('disponivel','ocupado','manutencao') DEFAULT 'disponivel'
--    valor_hora     DECIMAL(6,2) NOT NULL DEFAULT 5.00
-- ──────────────────────────────────────────────────────────────
-- TODO: Crie a tabela 'computadores'
CREATE TABLE computadores (
    id_computador INT AUTO_INCREMENT,
    numero INT NOT NULL,
    descricao VARCHAR(100),
    status ENUM('disponivel','ocupado','manutencao') DEFAULT 'disponivel',
    valor_hora DECIMAL(6,2) NOT NULL DEFAULT 5.00,
    CONSTRAINT PK_computadores PRIMARY KEY (id_computador),
    CONSTRAINT UN_computadores_numero UNIQUE (numero)
  );

-- ──────────────────────────────────────────────────────────────
--  TABELA: sessoes
--  Registra cada período de uso de um computador por um cliente.
--  Colunas obrigatórias para o sistema:
--    id_sessao      INT PK AUTO_INCREMENT
--    id_cliente     INT NOT NULL  → FK para clientes
--    id_computador  INT NOT NULL  → FK para computadores
--    inicio         DATETIME DEFAULT CURRENT_TIMESTAMP
--    fim            DATETIME  (NULL enquanto a sessão está aberta)
--    valor_total    DECIMAL(8,2)
--    status         ENUM('aberta','fechada') DEFAULT 'aberta'
-- ──────────────────────────────────────────────────────────────
-- TODO: Crie a tabela 'sessoes' com as chaves estrangeiras corretas
CREATE TABLE sessoes (
    id_sessao INT AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_computador INT NOT NULL,
    inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
    fim DATETIME,
    valor_total DECIMAL(8,2),
    status ENUM('aberta','fechada') DEFAULT 'aberta',
    CONSTRAINT PK_Sessoes PRIMARY KEY (id_sessao),
    CONSTRAINT FK_Sessoes_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT FK_Sessoes_computadores FOREIGN KEY (id_computador) REFERENCES computadores(id_computador)
  );
-- ──────────────────────────────────────────────────────────────
--  TABELA: produtos
--  Snacks, bebidas e acessórios vendidos durante as sessões.
--  Colunas obrigatórias para o sistema:
--    id_produto     INT PK AUTO_INCREMENT
--    nome           VARCHAR(100) NOT NULL
--    categoria      VARCHAR(50)
--    preco          DECIMAL(6,2) NOT NULL
--    estoque        INT NOT NULL DEFAULT 0
-- ──────────────────────────────────────────────────────────────
-- TODO: Crie a tabela 'produtos'
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    preco DECIMAL(6,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    CONSTRAINT PK_produtos PRIMARY KEY (id_produto)
  );

-- ──────────────────────────────────────────────────────────────
--  TABELA: vendas
--  Itens vendidos dentro de uma sessão aberta.
--  Colunas obrigatórias para o sistema:
--    id_venda        INT PK AUTO_INCREMENT
--    id_sessao       INT NOT NULL  → FK para sessoes
--    id_produto      INT NOT NULL  → FK para produtos
--    quantidade      INT NOT NULL DEFAULT 1
--    preco_unitario  DECIMAL(6,2) NOT NULL
--    data_venda      DATETIME DEFAULT CURRENT_TIMESTAMP
-- ──────────────────────────────────────────────────────────────
-- TODO: Crie a tabela 'vendas' com as chaves estrangeiras corretas
CREATE TABLE vendas (
    id_venda INT AUTO_INCREMENT,
    id_sessao INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(6,2) NOT NULL,
    data_venda DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Vendas PRIMARY KEY (id_venda),
    CONSTRAINT FK_Vendas_sessoes FOREIGN KEY (id_sessao) REFERENCES sessoes(id_sessao),
    CONSTRAINT FK_Vendas_produtos FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
  );

-- ──────────────────────────────────────────────────────────────
--  TABELA: auditoria_caixa
--  Log financeiro. Cada entrada é gerada automaticamente
--  pelo trigger trg_auditoria_sessao ao fechar uma sessão.
--  Colunas obrigatórias para o sistema:
--    id_auditoria   INT PK AUTO_INCREMENT
--    tipo           ENUM('entrada','saida') NOT NULL
--    valor          DECIMAL(8,2) NOT NULL
--    descricao      VARCHAR(255)
--    data_hora      DATETIME DEFAULT CURRENT_TIMESTAMP
--    id_sessao      INT  → FK para sessoes (pode ser NULL para lançamentos manuais)
-- ──────────────────────────────────────────────────────────────
-- TODO: Crie a tabela 'auditoria_caixa'
CREATE TABLE auditoria_caixa (
    id_auditoria INT AUTO_INCREMENT,
    tipo ENUM('entrada','saida') NOT NULL,
    valor DECIMAL(8,2) NOT NULL,
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_sessao INT,
    CONSTRAINT PK_Auditoria PRIMARY KEY (id_auditoria),
    CONSTRAINT FK_Auditoria_sessoes FOREIGN KEY (id_sessao) REFERENCES sessoes(id_sessao)
  );
