-- Cafetear · Consultas del equipo
-- Antes de ejecutar: cargar la base (queries/instalador/Cafetear_completo.sql).
-- Si ejecutás todo el archivo, las 10 consultas devuelven un resultado cada una, en orden.

USE cafetear;
GO

-- 1) Lotes con puntaje promedio menor a 3,5: cantidad de calibraciones, gramos usados y puntaje promedio.
SELECT l.nombre,
       COUNT(c.idCalibracion) AS cantidadCalibraciones,
       SUM(c.dosis) AS gramosTotalesUsados,
       SUM(p.sumaPuntajes * 1.0) / SUM(p.cantidadCalificaciones) AS puntajePromedio
FROM Lote l
JOIN Calibracion c ON c.idLote = l.idLote
LEFT JOIN (SELECT idCalibracion,
                  SUM(puntaje) AS sumaPuntajes,
                  COUNT(*) AS cantidadCalificaciones
           FROM Calificacion
           GROUP BY idCalibracion) p ON p.idCalibracion = c.idCalibracion
GROUP BY l.idLote, l.nombre
HAVING SUM(p.sumaPuntajes * 1.0) / SUM(p.cantidadCalificaciones) < 3.5;


-- 2) Puntaje promedio y cantidad de calificaciones de cada mes.
SELECT CONCAT(MONTH(fecha), '/', YEAR(fecha)) AS mesAnio,
       AVG(puntaje) * 1.0 AS calificacionPromedio,
       COUNT(*) AS cantidadCalificaciones
FROM Calificacion
GROUP BY MONTH(fecha), YEAR(fecha)
ORDER BY MONTH(fecha), YEAR(fecha);


-- 3) Puntaje promedio según las semanas transcurridas desde el tostado, por grano y proveedor.
SELECT g.idGrano,
       g.regionCosecha AS grano,
       p.razonSocial AS proveedor,
       DATEDIFF(DAY, l.fechaTostado, c.fechaCalibracion) / 7 AS semanasDesdeTostado,
       AVG(cf.puntaje * 1.0) AS puntajePromedio,
       COUNT(*) AS cantidadCalificaciones
FROM Grano g
JOIN Lote l ON l.idGrano = g.idGrano
JOIN Proveedor p ON p.idProveedor = l.idProveedor            -- el mismo grano puede venir de distintos proveedores
JOIN Calibracion c ON c.idLote = l.idLote                    -- cada calibración usa un lote
JOIN Calificacion cf ON cf.idCalibracion = c.idCalibracion   -- cada calificación evalúa una calibración
GROUP BY g.idGrano,
         g.regionCosecha,
         p.idProveedor,
         p.razonSocial,
         DATEDIFF(DAY, l.fechaTostado, c.fechaCalibracion) / 7
ORDER BY g.idGrano, p.razonSocial, semanasDesdeTostado;


-- 4) Para cada grano y proveedor, la calibración con mayor calificación promedio.
--    Se exigen al menos 3 calificaciones; si hay empate gana la que tiene más calificaciones y, si siguen
--    empatadas, la más antigua. Usa la vista vwPuntajePorCalibracion (queries/vistas/vistas.sql).
SELECT g.regionCosecha AS grano,
       p.razonSocial AS proveedor,
       v.idCalibracion,
       v.dosis,
       v.tiempoExtraccion,
       v.rendimiento,
       v.puntajePromedio,
       v.calificaciones
FROM vwPuntajePorCalibracion v
JOIN Lote l ON l.idLote = v.idLote
JOIN Grano g ON g.idGrano = l.idGrano
JOIN Proveedor p ON p.idProveedor = l.idProveedor
WHERE v.idCalibracion = (SELECT TOP 1 v2.idCalibracion
                         FROM vwPuntajePorCalibracion v2
                         JOIN Lote l2 ON l2.idLote = v2.idLote
                         WHERE l2.idGrano = l.idGrano
                           AND l2.idProveedor = l.idProveedor   -- mismo grano y mismo proveedor
                           AND v2.calificaciones >= 3
                         ORDER BY v2.puntajePromedio DESC, v2.calificaciones DESC, v2.idCalibracion)
ORDER BY g.regionCosecha, p.razonSocial;


-- 5) Proveedor con mejor café (con más de 5 calificaciones).
SELECT TOP 1 p.idProveedor,
             p.razonSocial,
             ROUND(AVG(cf.puntaje * 1.0), 2) AS puntajePromedio
FROM Proveedor p
JOIN Lote l ON l.idProveedor = p.idProveedor
JOIN Calibracion cl ON cl.idLote = l.idLote
JOIN Calificacion cf ON cf.idCalibracion = cl.idCalibracion
GROUP BY p.idProveedor, p.razonSocial
HAVING COUNT(cf.idCalificacion) > 5
ORDER BY AVG(cf.puntaje * 1.0) DESC;


-- 6) Clientes que calificaron alguna vez y no calificaron en los últimos 90 días.
SELECT CONCAT(c.nombre, ' ', c.apellido) AS nombreCliente,
       c.dni
FROM Cliente c
JOIN Calificacion cal ON cal.idCliente = c.idCliente
GROUP BY c.idCliente, c.nombre, c.apellido, c.dni
HAVING DATEDIFF(DAY, MAX(cal.fecha), GETDATE()) > 90;


-- 7) Calidad por día de la semana.
SELECT DATENAME(WEEKDAY, fecha) AS diaDeLaSemana,
       AVG(puntaje * 1.0) AS calificacionPromedio
FROM Calificacion
GROUP BY DATENAME(WEEKDAY, fecha), DATEPART(WEEKDAY, fecha)
ORDER BY DATEPART(WEEKDAY, fecha);


-- 8) Lotes cuya calificación promedio del último mes es menor a la del mes anterior.
SELECT l.idLote,
       l.nombre AS lote,
       AVG(cf.puntaje * 1.0) AS promedioUltimoMes,
       (SELECT AVG(cf2.puntaje * 1.0)
        FROM Calibracion c2
        JOIN Calificacion cf2 ON cf2.idCalibracion = c2.idCalibracion
        WHERE c2.idLote = l.idLote
          AND cf2.fecha >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0)
          AND cf2.fecha <  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)) AS promedioMesAnterior,
       COUNT(*) AS calificacionesUltimoMes
FROM Lote l
JOIN Calibracion c ON c.idLote = l.idLote
JOIN Calificacion cf ON cf.idCalibracion = c.idCalibracion
WHERE cf.fecha >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
  AND cf.fecha <  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
GROUP BY l.idLote, l.nombre
HAVING AVG(cf.puntaje * 1.0) < (SELECT AVG(cf2.puntaje * 1.0)
                                FROM Calibracion c2
                                JOIN Calificacion cf2 ON cf2.idCalibracion = c2.idCalibracion
                                WHERE c2.idLote = l.idLote
                                  AND cf2.fecha >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0)
                                  AND cf2.fecha <  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0))
ORDER BY promedioUltimoMes;


-- 9) Diferencia entre la mejor y la peor calificación de cada lote (para evaluar consistencia).
SELECT l.nombre AS lote,
       p.razonSocial AS proveedor,
       MIN(cf.puntaje) AS peorPuntaje,
       MAX(cf.puntaje) AS mejorPuntaje,
       MAX(cf.puntaje) - MIN(cf.puntaje) AS diferencia,
       AVG(cf.puntaje * 1.0) AS puntajePromedio,
       COUNT(*) AS cantidadCalificaciones
FROM Lote l
JOIN Proveedor p ON p.idProveedor = l.idProveedor
JOIN Calibracion c ON c.idLote = l.idLote
JOIN Calificacion cf ON cf.idCalibracion = c.idCalibracion
GROUP BY l.idLote, l.nombre, p.razonSocial
HAVING COUNT(*) >= 3
ORDER BY diferencia DESC;


-- 10) Top 5 tiempos de extracción con mejor calificación promedio.
SELECT TOP 5 c.tiempoExtraccion AS tiempoSeg,
             AVG(cf.puntaje * 1.0) AS puntajePromedio,                -- * 1.0 para no truncar
             COUNT(*) AS cantidadCalificaciones,
             COUNT(DISTINCT c.idCalibracion) AS cantidadCalibraciones -- cuántas calibraciones usaron ese tiempo
FROM Calibracion c
JOIN Calificacion cf ON cf.idCalibracion = c.idCalibracion            -- cada calificación evalúa una calibración
GROUP BY c.tiempoExtraccion
HAVING COUNT(*) >= 5                                                  -- evidencia mínima
ORDER BY puntajePromedio DESC, cantidadCalificaciones DESC;           -- desempate: más opiniones
