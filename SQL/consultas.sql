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