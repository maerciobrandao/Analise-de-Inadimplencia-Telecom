-- Projeto: Análise de Inadimplência em Telecom
-- Banco: telecom_inadimplencia
-- Ferramenta: SQL Server

-- 1. Visão geral dos pagamentos com cliente e contrato
SELECT
    c.nome,
    c.tipo_cliente,
    ct.plano,
    ct.valor_mensal,
    p.data_vencimento,
    p.data_pagamento,
    p.valor_pago
FROM pagamentos p
INNER JOIN contratos ct
    ON p.contrato_id = ct.contrato_id
INNER JOIN clientes c
    ON ct.cliente_id = c.cliente_id
ORDER BY p.data_vencimento;


-- 2. Clientes inadimplentes
-- Regra: inadimplente = sem pagamento ou atraso maior que 10 dias
SELECT
    c.nome,
    c.tipo_cliente,
    ct.plano,
    p.data_vencimento,
    p.data_pagamento,
    p.valor_pago
FROM pagamentos p
INNER JOIN contratos ct
    ON p.contrato_id = ct.contrato_id
INNER JOIN clientes c
    ON ct.cliente_id = c.cliente_id
WHERE p.data_pagamento IS NULL
   OR DATEDIFF(day, p.data_vencimento, p.data_pagamento) > 10
ORDER BY p.valor_pago DESC;


-- 3. Total de inadimplências por tipo de cliente
SELECT
    c.tipo_cliente,
    COUNT(*) AS total_inadimplencias
FROM pagamentos p
INNER JOIN contratos ct
    ON p.contrato_id = ct.contrato_id
INNER JOIN clientes c
    ON ct.cliente_id = c.cliente_id
WHERE p.data_pagamento IS NULL
   OR DATEDIFF(day, p.data_vencimento, p.data_pagamento) > 10
GROUP BY c.tipo_cliente
ORDER BY total_inadimplencias DESC;


-- 4. Total de inadimplências por plano
SELECT
    ct.plano,
    COUNT(*) AS total_inadimplencias
FROM pagamentos p
INNER JOIN contratos ct
    ON p.contrato_id = ct.contrato_id
WHERE p.data_pagamento IS NULL
   OR DATEDIFF(day, p.data_vencimento, p.data_pagamento) > 10
GROUP BY ct.plano
ORDER BY total_inadimplencias DESC;


-- 5. Atraso médio em dias
SELECT
    AVG(DATEDIFF(day, p.data_vencimento, p.data_pagamento)) AS media_dias_atraso
FROM pagamentos p
WHERE p.data_pagamento IS NOT NULL
  AND DATEDIFF(day, p.data_vencimento, p.data_pagamento) > 0;


-- 6. Valor total em aberto
SELECT
    SUM(p.valor_pago) AS valor_total_em_aberto
FROM pagamentos p
WHERE p.data_pagamento IS NULL;


-- 7. Clientes com maior valor em inadimplência
SELECT
    c.nome,
    c.tipo_cliente,
    ct.plano,
    SUM(p.valor_pago) AS valor_total_inadimplente
FROM pagamentos p
INNER JOIN contratos ct
    ON p.contrato_id = ct.contrato_id
INNER JOIN clientes c
    ON ct.cliente_id = c.cliente_id
WHERE p.data_pagamento IS NULL
   OR DATEDIFF(day, p.data_vencimento, p.data_pagamento) > 10
GROUP BY c.nome, c.tipo_cliente, ct.plano
ORDER BY valor_total_inadimplente DESC;


-- 8. Análise de inadimplência por UF
SELECT
    c.uf,
    COUNT(*) AS qtd_inadimplentes,
    SUM(p.valor_pago) AS valor_total_inadimplente,
    AVG(
        CASE
            WHEN p.data_pagamento IS NOT NULL
            THEN DATEDIFF(DAY, p.data_vencimento, p.data_pagamento)
        END
    ) AS atraso_medio
FROM pagamentos p
INNER JOIN contratos ct
    ON p.contrato_id = ct.contrato_id
INNER JOIN clientes c
    ON ct.cliente_id = c.cliente_id
WHERE p.data_pagamento IS NULL
   OR DATEDIFF(DAY, p.data_vencimento, p.data_pagamento) > 10
GROUP BY c.uf
ORDER BY valor_total_inadimplente DESC;


-- 9. Ranking de UFs por valor inadimplente
SELECT
    c.uf,
    SUM(p.valor_pago) AS valor_total_inadimplente
FROM pagamentos p
INNER JOIN contratos ct
    ON p.contrato_id = ct.contrato_id
INNER JOIN clientes c
    ON ct.cliente_id = c.cliente_id
WHERE p.data_pagamento IS NULL
   OR DATEDIFF(DAY, p.data_vencimento, p.data_pagamento) > 10
GROUP BY c.uf
ORDER BY valor_total_inadimplente DESC;


-- 10. Inadimplência por UF e plano
SELECT
    c.uf,
    ct.plano,
    COUNT(*) AS qtd_inadimplentes,
    SUM(p.valor_pago) AS valor_total_inadimplente
FROM pagamentos p
INNER JOIN contratos ct
    ON p.contrato_id = ct.contrato_id
INNER JOIN clientes c
    ON ct.cliente_id = c.cliente_id
WHERE p.data_pagamento IS NULL
   OR DATEDIFF(DAY, p.data_vencimento, p.data_pagamento) > 10
GROUP BY c.uf, ct.plano
ORDER BY c.uf, valor_total_inadimplente DESC;


-- 11. Conferência geral da base
SELECT
    (SELECT COUNT(*) FROM clientes) AS total_clientes,
    (SELECT COUNT(*) FROM contratos) AS total_contratos,
    (SELECT COUNT(*) FROM pagamentos) AS total_pagamentos;
