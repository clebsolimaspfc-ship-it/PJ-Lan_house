-- ============================================================
--  ARENA GAMER  –  procedures.sql (VERSÃO DO ALUNO)
--  AULAS 3 e 4  –  Functions, Stored Procedures, Triggers e Views
--
--  Execute APÓS schema.sql e seed.sql
-- ============================================================

USE arena_gamer;

DELIMITER //

-- ──────────────────────────────────────────────
--  FUNCTIONS (AULA 3)  
-- ──────────────────────────────────────────────

-- TODO: Aula 3 - Implementar fn_duracao_minutos
-- Recebe inicio DATETIME e fim DATETIME
-- Retorna INT (diferença em minutos)
-- Dica: Use a função TIMESTAMPDIFF
CREATE FUNCTION fn_duracao_minutos(
    p_inicio DATETIME,
    p_fim DATETIME
)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(MINUTE, p_inicio, p_fim);
END //
-- TODO: Aula 3 - Implementar fn_calcular_valor
-- Recebe inicio DATETIME, fim DATETIME e valor_hora DECIMAL(6,2)
-- Retorna DECIMAL(8,2) (valor a ser cobrado)
-- Dica: Use fn_duracao_minutos (ou TIMESTAMPDIFF) e faça o cálculo do valor proporcional por minuto.
-- Arredonde o resultado para 2 casas decimais usando ROUND()
CREATE FUNCTION fn_calcular_valor(
    p_inicio DATETIME,
    p_fim DATETIME,
    p_valor_hora DECIMAL(6,2)
)
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    DECLARE v_minutos INT;
    
    SET v_minutos = fn_duracao_minutos(p_inicio, p_fim);

    RETURN ROUND((v_minutos / 60) * p_valor_hora, 2);
END //
-- ──────────────────────────────────────────────
--  STORED PROCEDURES (AULA 3)
-- ──────────────────────────────────────────────

-- TODO: Aula 3 - Implementar sp_abrir_sessao 
-- Recebe p_id_cliente INT, p_id_computador INT 
-- Regras de negócio: 
-- 1. Verificar se o computador está 'disponivel'.
--    Se não estiver, lançar erro (SIGNAL SQLSTATE '45000') com a mensagem: 'Computador não está disponível.'
-- 2. Se estiver disponível, iniciar transação (START TRANSACTION): 
--    a. Inserir a nova sessão na tabela 'sessoes'
--    b. Atualizar o status do computador para 'ocupado'
--    c. Confirmar transação (COMMIT)
CREATE PROCEDURE sp_abrir_sessao(
    IN p_id_cliente INT,
    IN p_id_computador INT
)
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status
    INTO v_status
    FROM computadores
    WHERE id_computador = p_id_computador;

    IF v_status <> 'disponivel' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Computador não está disponível.';
    END IF;

    START TRANSACTION;

    INSERT INTO sessoes (
        id_cliente,
        id_computador
    )
    VALUES (
        p_id_cliente,
        p_id_computador
    );

    UPDATE computadores
    SET status = 'ocupado'
    WHERE id_computador = p_id_computador;

    COMMIT;
END //
-- TODO: Aula 3 - Implementar sp_fechar_sessao
-- Recebe p_id_sessao INT
-- Regras de negócio:
-- 1. Buscar a data/hora de inicio, o id do computador e o valor_hora do computador vinculado à sessão.
--    Verificar também se a sessão existe e está 'aberta'.
--    Se não encontrar a sessão aberta, lançar erro (SIGNAL SQLSTATE '45000') com a mensagem: 'Sessão não encontrada ou já encerrada.'
-- 2. Calcular o valor da sessão (usando a function fn_calcular_valor)
-- 3. Calcular o valor total em vendas (produtos) vinculadas à sessão. Use COALESCE para garantir que retorna 0 se não houver vendas.
-- 4. Somar os dois valores para ter o v_valor_total.
-- 5. Iniciar transação (START TRANSACTION):
--    a. Atualizar a tabela 'sessoes': definir fim = NOW(), valor_total = v_valor_total, status = 'fechada'
--    b. Atualizar a tabela 'computadores': voltar status para 'disponivel'
--    c. Confirmar transação (COMMIT)
CREATE PROCEDURE sp_fechar_sessao(
    IN p_id_sessao INT
)
BEGIN
    DECLARE v_inicio DATETIME;
    DECLARE v_id_computador INT;
    DECLARE v_valor_hora DECIMAL(6,2);
    DECLARE v_valor_sessao DECIMAL(8,2);
    DECLARE v_valor_vendas DECIMAL(8,2);
    DECLARE v_valor_total DECIMAL(8,2);

    SELECT
        s.inicio,
        s.id_computador,
        c.valor_hora
    INTO
        v_inicio,
        v_id_computador,
        v_valor_hora
    FROM sessoes s
    INNER JOIN computadores c
        ON c.id_computador = s.id_computador
    WHERE s.id_sessao = p_id_sessao
      AND s.status = 'aberta';

    IF v_inicio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sessão não encontrada ou já encerrada.';
    END IF;

    SET v_valor_sessao =
        fn_calcular_valor(
            v_inicio,
            NOW(),
            v_valor_hora
        );

    SELECT COALESCE(
        SUM(quantidade * preco_unitario),
        0
    )
    INTO v_valor_vendas
    FROM vendas
    WHERE id_sessao = p_id_sessao;

    SET v_valor_total =
        v_valor_sessao + v_valor_vendas;

    START TRANSACTION;

    UPDATE sessoes
    SET
        fim = NOW(),
        valor_total = v_valor_total,
        status = 'fechada'
    WHERE id_sessao = p_id_sessao;

    UPDATE computadores
    SET status = 'disponivel'
    WHERE id_computador = v_id_computador;

    COMMIT;
END //
-- ──────────────────────────────────────────────
--  TRIGGERS (AULA 4)
-- ──────────────────────────────────────────────

-- TODO: Aula 4 - Implementar trg_auditoria_sessao
-- Gatilho: AFTER UPDATE ON sessoes
-- Regra: 
-- Quando o status mudar para 'fechada' (e antes era 'aberta'), inserir um registro na tabela 'auditoria_caixa'.
-- Use: tipo = 'entrada', valor = NEW.valor_total, descricao = 'Sessão #[id] encerrada – cliente [id_cliente]', id_sessao = NEW.id_sessao
-- Dica: Use CONCAT() para montar a string da descrição.
CREATE TRIGGER trg_auditoria_sessao
AFTER UPDATE ON sessoes
FOR EACH ROW
BEGIN
    IF OLD.status = 'aberta'
       AND NEW.status = 'fechada' THEN

        INSERT INTO auditoria_caixa (
            tipo,
            valor,
            descricao,
            id_sessao
        )
        VALUES (
            'entrada',
            NEW.valor_total,
            CONCAT(
                'Sessao #',
                NEW.id_sessao,
                ' encerrada - cliente ',
                NEW.id_cliente
            ),
            NEW.id_sessao
        );

    END IF;
END //
-- TODO: Aula 4 - Implementar trg_atualiza_estoque
-- Gatilho: AFTER INSERT ON vendas
-- Regra: Ao registrar uma venda, diminuir a quantidade vendida do estoque do produto correspondente.
CREATE TRIGGER trg_atualiza_estoque
AFTER INSERT ON vendas
FOR EACH ROW
BEGIN
    UPDATE produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;
END //
-- TODO: Aula 4 - Implementar trg_valida_estoque
-- Gatilho: BEFORE INSERT ON vendas
-- Regra: Antes de registrar a venda, verificar se há estoque suficiente.
-- Se o estoque for menor que NEW.quantidade, lançar erro (SIGNAL SQLSTATE '45000') com a mensagem: 'Estoque insuficiente para a venda.'
CREATE TRIGGER trg_valida_estoque
BEFORE INSERT ON vendas
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;

    SELECT estoque
    INTO v_estoque
    FROM produtos
    WHERE id_produto = NEW.id_produto;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Estoque insuficiente para a venda.';
    END IF;
END //
DELIMITER ;

-- ──────────────────────────────────────────────
--  VIEWS (AULAS 1 E 2)
-- ──────────────────────────────────────────────

-- TODO: Aula 2 - Implementar vw_sessoes_ativas
-- Deve listar todas as sessões com status = 'aberta'.
-- Colunas necessárias (para o backend/frontend): 
-- id_sessao, cliente (nome), computador (numero), descricao_computador (descricao), 
-- inicio, minutos_em_uso (usar TIMESTAMPDIFF com NOW()), valor_parcial (cálculo usando NOW())
CREATE VIEW vw_sessoes_ativas AS
SELECT
    s.id_sessao,
    c.nome AS cliente,
    cp.numero AS computador,
    cp.descricao AS descricao_computador,
    s.inicio,
    TIMESTAMPDIFF(
        MINUTE,
        s.inicio,
        NOW()
    ) AS minutos_em_uso,
    ROUND(
        (
            TIMESTAMPDIFF(
                MINUTE,
                s.inicio,
                NOW()
            ) / 60
        ) * cp.valor_hora,
        2
    ) AS valor_parcial
FROM sessoes s
INNER JOIN clientes c
    ON c.id_cliente = s.id_cliente
INNER JOIN computadores cp
    ON cp.id_computador = s.id_computador
WHERE s.status = 'aberta';
-- TODO: Aula 2 - Implementar vw_ranking_clientes
-- Deve listar todos os clientes e ranqueá-los pelo gasto.
-- Colunas necessárias: 
-- id_cliente, nome, total_sessoes (COUNT), total_gasto (SUM de valor_total das sessões fechadas), gasto_medio (AVG)
-- Ordenar por total_gasto DESC.
-- Dica: Use LEFT JOIN com sessoes (status = 'fechada') e não esqueça do COALESCE para tratar NULLs.
CREATE VIEW vw_ranking_clientes AS
SELECT
    c.id_cliente,
    c.nome,
    COUNT(s.id_sessao) AS total_sessoes,
    COALESCE(
        SUM(s.valor_total),
        0
    ) AS total_gasto,
    COALESCE(
        AVG(s.valor_total),
        0
    ) AS gasto_medio
FROM clientes c
LEFT JOIN sessoes s
    ON s.id_cliente = c.id_cliente
   AND s.status = 'fechada'
GROUP BY
    c.id_cliente,
    c.nome
ORDER BY total_gasto DESC;
-- TODO: Aula 2 - Implementar vw_produtos_mais_vendidos
-- Deve listar os produtos ranqueados pela quantidade vendida.
-- Colunas necessárias:
-- nome (do produto), categoria, total_vendido (SUM de quantidade em vendas), receita_total (SUM de quantidade * preco_unitario)
-- Ordenar por total_vendido DESC.
CREATE VIEW vw_produtos_mais_vendidos AS
SELECT
    p.nome,
    p.categoria,
    COALESCE(
        SUM(v.quantidade),
        0
    ) AS total_vendido,
    COALESCE(
        SUM(
            v.quantidade * v.preco_unitario
        ),
        0
    ) AS receita_total
FROM produtos p
LEFT JOIN vendas v
    ON v.id_produto = p.id_produto
GROUP BY
    p.id_produto,
    p.nome,
    p.categoria
ORDER BY total_vendido DESC;
