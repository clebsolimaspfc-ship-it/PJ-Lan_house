const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/sessoes/ativas
router.get('/ativas', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT * FROM vw_sessoes_ativas'
        );

        res.json(rows);
    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
});

// GET /api/sessoes/historico
router.get('/historico', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT
                s.id_sessao,
                c.nome AS cliente,
                cp.numero AS computador,
                s.inicio,
                s.fim,
                s.valor_total,
                s.status
            FROM sessoes s
            JOIN clientes c
                ON s.id_cliente = c.id_cliente
            JOIN computadores cp
                ON s.id_computador = cp.id_computador
            ORDER BY s.inicio DESC
            LIMIT 50
        `);

        res.json(rows);
    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
});

// POST /api/sessoes/abrir
router.post('/abrir', async (req, res) => {
    const { id_cliente, id_computador } = req.body;

    if (!id_cliente || !id_computador) {
        return res.status(400).json({
            error: 'id_cliente e id_computador são obrigatórios.'
        });
    }

    try {
        await db.query(
            'CALL sp_abrir_sessao(?, ?)',
            [id_cliente, id_computador]
        );

        res.json({
            message: 'Sessão aberta com sucesso.'
        });
    } catch (err) {
        res.status(400).json({
            error: err.message
        });
    }
});

// POST /api/sessoes/fechar/:id
router.post('/fechar/:id', async (req, res) => {
    try {
        const id = req.params.id;

        await db.query(
            'CALL sp_fechar_sessao(?)',
            [id]
        );

        const [sessao] = await db.query(
            'SELECT valor_total FROM sessoes WHERE id_sessao = ?',
            [id]
        );

        res.json({
            message: 'Sessão encerrada com sucesso.',
            valor_total: sessao[0].valor_total
        });
    } catch (err) {
        res.status(400).json({
            error: err.message
        });
    }
});

module.exports = router;