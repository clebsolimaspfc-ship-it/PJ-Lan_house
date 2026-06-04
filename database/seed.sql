-- ============================================================
--  ARENA GAMER  –  seed.sql  (VERSÃO DO ALUNO)
--  AULA 1  –  Dados iniciais para desenvolvimento e testes
--
--  Execute APÓS schema.sql.
--  O sistema precisa de dados para funcionar corretamente.
-- ============================================================

USE arena_gamer;

-- ──────────────────────────────────────────────────────────────
--  COMPUTADORES
--  Insira pelo menos 6 computadores com números, descrições e
--  valores de hora diferentes (mix de configs gamer e standard).
-- ──────────────────────────────────────────────────────────────
-- TODO: Insira os computadores
-- Exemplo de linha:
-- INSERT INTO computadores (numero, descricao, valor_hora) VALUES (1, 'PC Gamer RTX 4070', 9.00);
INSERT INTO computadores (numero, descricao, valor_hora) VALUES
(1, 'PC Gamer RTX 4070', 9.50),
(2, 'PC Gamer RTX 4060', 8.50),
(3, 'PC Gamer RTX 3060', 7.50),
(4, 'PC Intermediario GTX 1660', 6.50),
(5, 'PC Basico Ryzen 5', 5.50),
(6, 'PC Basico Core i5', 5.00);
-- ──────────────────────────────────────────────────────────────
--  CLIENTES
--  Insira pelo menos 5 clientes com nome, email, telefone e
--  saldo_creditos variado (alguns com saldo, outros sem).
-- ──────────────────────────────────────────────────────────────
-- TODO: Insira os clientes
INSERT INTO clientes (nome, email, telefone, saldo_creditos) VALUES
('Leo Moura', 'leomoura@email.com', '81988783768', 50.00),
('Maria Eduarda Sabino', 'maria@email.com', '81996503336', 20.00),
('Joao Teofilo', 'joaoteofilo@email.com', '87999646558', 0.00),
('Lara Silva', 'lara@email.com', '81996480354', 35.00),
('Leandra Teofilo', 'leandra@email.com', '87999224883', 10.00);

-- ──────────────────────────────────────────────────────────────
--  PRODUTOS
--  Insira produtos nas categorias: Bebidas, Snacks, Lanches, Acessorios.
--  Cada produto precisa de preco e estoque definidos.
-- ──────────────────────────────────────────────────────────────
-- TODO: Insira os produtos
INSERT INTO produtos (nome, categoria, preco, estoque) VALUES
('Coca-Cola Lata', 'Bebidas', 6.00, 50),
('Agua Mineral', 'Bebidas', 3.00, 80),
('Doritos', 'Snacks', 8.50, 30),
('KitKat', 'Snacks', 4.50, 40),
('Hamburguer Artesanal', 'Lanches', 18.00, 20),
('Mouse Pad Gamer', 'Acessorios', 25.00, 15);

-- ──────────────────────────────────────────────────────────────
--  SESSÕES HISTÓRICAS (status = 'fechada')
--  Insira pelo menos 6 sessões já encerradas para que as queries
--  de análise (ranking, receita por computador, etc.) tenham dados.
--  Atenção: insira diretamente com inicio, fim, valor_total e status.
--  Não use as stored procedures para este seed — elas dependem
--  de lógica de negócio que pode não estar pronta ainda.
-- ──────────────────────────────────────────────────────────────
-- TODO: Insira sessões históricas fechadas
-- Exemplo de linha:
-- INSERT INTO sessoes (id_cliente, id_computador, inicio, fim, valor_total, status)
-- VALUES (1, 1, '2026-04-20 14:00:00', '2026-04-20 16:30:00', 22.50, 'fechada');
INSERT INTO sessoes
(id_cliente, id_computador, inicio, fim, valor_total, status)
VALUES
(1, 1, '2026-04-20 14:00:00', '2026-04-20 16:30:00', 22.50, 'fechada'),
(2, 2, '2026-04-21 09:00:00', '2026-04-21 11:00:00', 17.00, 'fechada'),
(3, 3, '2026-04-22 13:00:00', '2026-04-22 15:00:00', 15.00, 'fechada'),
(4, 4, '2026-04-23 18:00:00', '2026-04-23 20:30:00', 16.25, 'fechada'),
(5, 5, '2026-04-24 10:00:00', '2026-04-24 12:00:00', 11.00, 'fechada'),
(1, 6, '2026-04-25 15:00:00', '2026-04-25 17:00:00', 10.00, 'fechada');

-- ──────────────────────────────────────────────────────────────
--  VENDAS (vinculadas às sessões históricas)
--  Insira vendas nas sessões criadas acima para popular as
--  queries de produtos mais vendidos e receita.
-- ──────────────────────────────────────────────────────────────
-- TODO: Insira registros de vendas
INSERT INTO vendas
(id_sessao, id_produto, quantidade, preco_unitario)
VALUES
(1, 1, 2, 6.00),
(1, 3, 1, 8.50),
(2, 2, 1, 3.00),
(3, 4, 2, 4.50),
(4, 5, 1, 18.00),
(5, 1, 1, 6.00),
(6, 6, 1, 25.00);

-- ──────────────────────────────────────────────────────────────
--  AUDITORIA_CAIXA (lançamentos iniciais)
--  Insira os lançamentos correspondentes às sessões históricas
--  (tipo 'entrada') e pelo menos uma saída (ex: reposição de estoque).
--  Nota: após criar o trigger trg_auditoria_sessao, novos fechamentos
--  de sessão gerarão lançamentos automaticamente.
-- ──────────────────────────────────────────────────────────────
-- TODO: Insira os lançamentos de caixa iniciais
INSERT INTO auditoria_caixa
(tipo, valor, descricao, id_sessao)
VALUES
('entrada', 22.50, 'Fechamento da sessao 1', 1),
('entrada', 17.00, 'Fechamento da sessao 2', 2),
('entrada', 15.00, 'Fechamento da sessao 3', 3),
('entrada', 16.25, 'Fechamento da sessao 4', 4),
('entrada', 11.00, 'Fechamento da sessao 5', 5),
('entrada', 10.00, 'Fechamento da sessao 6', 6),
('saida', 50.00, 'Reposicao de estoque', NULL);
