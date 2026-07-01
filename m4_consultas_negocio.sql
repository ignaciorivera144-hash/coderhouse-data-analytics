USE Ventas_Tech_DB;
GO

SELECT * FROM ventas;

-- =====================================================
-- CONSULTA 1 - Resumen ejecutivo mensual
-- =====================================================

SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- =====================================================
-- CONSULTA 2 - Ranking de productos
-- =====================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- =====================================================
-- CONSULTA 3 - Clientes recurrentes
-- =====================================================

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- =====================================================
-- CONSULTA 4 - Meses por encima o por debajo del promedio
-- =====================================================

WITH VentasMensuales AS
(
    SELECT
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)

SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado >
             (SELECT AVG(total_facturado) FROM VentasMensuales)
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM VentasMensuales
ORDER BY mes;

-- =====================================================
-- HALLAZGOS
-- (Modificar luego de ejecutar las consultas)
-- =====================================================

-- 1. El producto con ID ____ fue el que obtuvo la mayor facturación.
-- 2. El cliente con ID ____ realizó la mayor cantidad de pedidos.
-- 3. El mes ____ presentó una facturación por encima del promedio mensual.