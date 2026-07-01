
USE Ventas_Tech_DB;

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('CATEGORIAS', 'PRODUCTOS', 'CLIENTES', 'VENTAS')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- ========================================
-- M5: CONSULTAS CON JOINS
-- Archivo: m5_consultas_joins.sql
-- Descripción: Cruzando tablas para enriquecer el análisis
-- Proyecto: RetailPro
-- ========================================

USE Ventas_Tech_DB;
GO

-- ========================================
-- CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)
-- ========================================
-- Descripción: Cruza Ventas, Clientes, Productos y Categorías
-- para obtener en una sola fila toda la información enriquecida.
-- Esta será la fuente de datos principal para Power BI.
-- ========================================

SELECT 
    v.fecha_venta AS fecha,
    c.nombre AS nombre_cliente,
    c.email,
    c.ciudad,
    c.fecha_registro,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    p.stock,
    p.activo
FROM VENTAS v
INNER JOIN CLIENTES c ON v.id_cliente = c.id_cliente
INNER JOIN PRODUCTOS p ON v.id_producto = p.id_producto
INNER JOIN CATEGORIAS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta DESC;

GO

-- ========================================
-- CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN + IS NULL)
-- ========================================
-- Descripción: Identifica clientes registrados que aún no han 
-- realizado ninguna compra. Útil para campañas de CRM.
-- ========================================

SELECT 
    c.id_cliente,
    c.nombre,
    c.email,
    c.ciudad,
    c.fecha_registro,
    DATEDIFF(DAY, c.fecha_registro, CAST(GETDATE() AS DATE)) AS dias_registrado
FROM CLIENTES c
LEFT JOIN VENTAS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro DESC;

GO

-- ========================================
-- CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN + IS NULL)
-- ========================================
-- Descripción: Identifica productos del catálogo que no tienen 
-- ninguna venta registrada. Útil para análisis de inventario.
-- ========================================

SELECT 
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio,
    p.stock,
    p.activo
FROM PRODUCTOS p
INNER JOIN CATEGORIAS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN VENTAS v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;

GO

-- ========================================
-- CONSULTA 4: CONSOLIDADO GENERAL (INNER JOIN + GROUP BY)
-- ========================================
-- Descripción: Agregación total de ventas por categoría y cliente.
-- Muestra métricas clave: cantidad de transacciones y monto total.
-- Nota: Para separar por canal (Online/Presencial), primero hay que
-- agregar una columna 'canal' a la tabla VENTAS.
-- ========================================

SELECT 
    cat.nombre_categoria,
    c.nombre AS nombre_cliente,
    COUNT(v.id_venta) AS cantidad_ventas,
    SUM(v.cantidad) AS cantidad_total_productos,
    SUM(v.cantidad * v.precio_unitario) AS total_venta_categoria_cliente,
    AVG(v.precio_unitario) AS precio_unitario_promedio,
    MIN(v.fecha_venta) AS primera_compra,
    MAX(v.fecha_venta) AS ultima_compra
FROM VENTAS v
INNER JOIN CLIENTES c ON v.id_cliente = c.id_cliente
INNER JOIN PRODUCTOS p ON v.id_producto = p.id_producto
INNER JOIN CATEGORIAS cat ON p.id_categoria = cat.id_categoria
GROUP BY cat.nombre_categoria, c.nombre, c.id_cliente
ORDER BY total_venta_categoria_cliente DESC, cat.nombre_categoria;

GO

-- ========================================
-- CONSULTAS ADICIONALES (Opcionales pero útiles)
-- ========================================

-- Resumen por categoría
SELECT 
    cat.nombre_categoria,
    COUNT(DISTINCT v.id_venta) AS total_ventas,
    COUNT(DISTINCT v.id_cliente) AS clientes_unicos,
    COUNT(DISTINCT v.id_producto) AS productos_vendidos,
    SUM(v.cantidad * v.precio_unitario) AS monto_total,
    AVG(v.cantidad * v.precio_unitario) AS ticket_promedio
FROM VENTAS v
INNER JOIN PRODUCTOS p ON v.id_producto = p.id_producto
INNER JOIN CATEGORIAS cat ON p.id_categoria = cat.id_categoria
GROUP BY cat.nombre_categoria
ORDER BY monto_total DESC;

GO

-- Clientes más valiosos (Top 10)
SELECT TOP 10
    c.id_cliente,
    c.nombre,
    c.email,
    COUNT(DISTINCT v.id_venta) AS cantidad_compras,
    SUM(v.cantidad * v.precio_unitario) AS total_gastado,
    AVG(v.cantidad * v.precio_unitario) AS ticket_promedio
FROM CLIENTES c
INNER JOIN VENTAS v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre, c.email
ORDER BY total_gastado DESC;

GO