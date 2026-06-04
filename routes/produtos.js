const express = require('express');
const router  = express.Router();
const db      = require('../db');

// GET /api/produtos
// Retorna todos os produtos ordenados por categoria e nome.
// Colunas esperadas: id_produto, nome, categoria, preco, estoque
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT *
            FROM produtos
            ORDER BY categoria, nome
        `);

        res.json(rows);

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// GET /api/produtos/mais-vendidos
// Retorna produtos ranqueados pela quantidade vendida.
// Depende da view: vw_produtos_mais_vendidos
// Colunas esperadas: nome, categoria, total_vendido, receita_total
router.get('/mais-vendidos', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT *
            FROM vw_produtos_mais_vendidos
        `);

        res.json(rows);

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// POST /api/produtos/vender
// Registra uma venda de produto vinculada a uma sessão ativa.
// Body esperado: { id_sessao, id_produto, quantidade }
// O trigger trg_atualiza_estoque deve diminuir o estoque automaticamente.
// O trigger trg_valida_estoque deve bloquear vendas com estoque insuficiente.
router.post('/vender', async (req, res) => {
    const { id_sessao, id_produto, quantidade } = req.body;

    if (!id_sessao || !id_produto || !quantidade) {
        return res.status(400).json({
            error: 'id_sessao, id_produto e quantidade são obrigatórios.'
        });
    }

    try {

        const [produto] = await db.query(
            'SELECT preco FROM produtos WHERE id_produto = ?',
            [id_produto]
        );

        if (produto.length === 0) {
            return res.status(404).json({
                error: 'Produto não encontrado.'
            });
        }

        const preco_unitario = produto[0].preco;

        await db.query(
            `INSERT INTO vendas
            (id_sessao, id_produto, quantidade, preco_unitario)
            VALUES (?, ?, ?, ?)`,
            [id_sessao, id_produto, quantidade, preco_unitario]
        );

        res.json({
            message: 'Venda registrada.'
        });

    } catch (err) {
        res.status(400).json({
            error: err.message
        });
    }
});

module.exports = router;
