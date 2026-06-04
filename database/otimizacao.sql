-- ============================================================
--  ARENA GAMER  –  otimizacao.sql (VERSÃO DO ALUNO)
--  AULA 5  –  EXPLAIN, ANALYZE e INDEX estratégico
-- ============================================================

USE arena_gamer;

-- ── 1. Diagnóstico: ver o plano de execução ANTES de criar índices
EXPLAIN
SELECT s.id_sessao, cl.nome, co.numero, s.valor_total
FROM   sessoes s
JOIN   clientes     cl ON s.id_cliente    = cl.id_cliente
JOIN   computadores co ON s.id_computador = co.id_computador
WHERE  s.status = 'fechada'
ORDER  BY s.valor_total DESC;

-- Observar: tipo de acesso (ALL vs ref), rows estimadas, Extra (Using filesort?)

-- ── 2. Criar índices direcionados

-- TODO: Aula 5 - Crie os índices abaixo e execute novamente o EXPLAIN acima para comparar.

-- a. Filtramos sessões pelo status frequentemente. Crie um índice para 'status' em 'sessoes'.
-- IMPLEMENTE AQUI

-- b. JOIN entre sessões e clientes. Crie um índice para 'id_cliente' em 'sessoes'.
-- IMPLEMENTE AQUI

-- c. JOIN entre sessões e computadores. Crie um índice para 'id_computador' em 'sessoes'.
-- IMPLEMENTE AQUI

-- d. Pesquisa de cliente por e-mail (login futuro). Crie um índice para 'email' em 'clientes'.
-- IMPLEMENTE AQUI

-- ── 3. Diagnóstico APÓS criar índices – comparar o resultado
EXPLAIN
SELECT s.id_sessao, cl.nome, co.numero, s.valor_total
FROM   sessoes s
JOIN   clientes     cl ON s.id_cliente    = cl.id_cliente
JOIN   computadores co ON s.id_computador = co.id_computador
WHERE  s.status = 'fechada'
ORDER  BY s.valor_total DESC;

-- ── 4. EXPLAIN FORMAT=JSON  – versão mais detalhada (MySQL 8+)
EXPLAIN FORMAT=JSON
SELECT cl.nome, COUNT(*) AS sessoes, SUM(s.valor_total) AS total
FROM   clientes cl
JOIN   sessoes s ON cl.id_cliente = s.id_cliente
WHERE  s.status = 'fechada'
GROUP  BY cl.id_cliente
HAVING total > 30
ORDER  BY total DESC;

-- ── 5. Query com subquery correlacionada – cenário real de análise
-- "Clientes que gastaram mais que a média geral"
EXPLAIN
SELECT cl.nome,
       SUM(s.valor_total)                     AS total_gasto,
       (SELECT AVG(valor_total) FROM sessoes
        WHERE  status = 'fechada')             AS media_geral
FROM   clientes cl
JOIN   sessoes  s ON cl.id_cliente = s.id_cliente AND s.status = 'fechada'
GROUP  BY cl.id_cliente, cl.nome
HAVING total_gasto > (SELECT AVG(valor_total) FROM sessoes WHERE status = 'fechada')
ORDER  BY total_gasto DESC;

-- ── 6. Ver todos os índices do banco
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, NON_UNIQUE
FROM   INFORMATION_SCHEMA.STATISTICS
WHERE  TABLE_SCHEMA = 'arena_gamer'
ORDER  BY TABLE_NAME, INDEX_NAME;
