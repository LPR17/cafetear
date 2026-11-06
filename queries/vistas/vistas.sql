-- Cafetear · Vistas

USE Cafetear;
GO

-- Una fila por calibración con el puntaje promedio que recibió. Es la base de las otras vistas.
CREATE OR ALTER VIEW dbo.vw_PuntajePorCalibracion AS
SELECT c.IDCalibracion, c.fechaCalibracion, c.dosis, c.tiempoExtraccion, c.rendimiento,
       dbo.fn_RelacionExtraccion(c.dosis, c.rendimiento) AS relacionExtraccion,
       c.IDBarista, c.IDLote, l.IDGrano,
       COUNT(k.IDCalificacion) AS calificaciones,
       CAST(AVG(k.puntaje * 1.0) AS DECIMAL(4,2)) AS puntajePromedio
FROM Calibracion c
JOIN Lote l ON l.IDLote = c.IDLote
LEFT JOIN Calificacion k ON k.IDCalibracion = c.IDCalibracion
GROUP BY c.IDCalibracion, c.fechaCalibracion, c.dosis, c.tiempoExtraccion, c.rendimiento,
         c.IDBarista, c.IDLote, l.IDGrano;
GO

-- Tablero de cada lote: cuánto café se usó, cuántas opiniones tiene, qué puntaje lleva y qué tan fresco está.
CREATE OR ALTER VIEW dbo.vw_RendimientoPorLote AS
SELECT l.IDLote, l.nombre AS lote, g.regionCosecha, p.razonSocial AS proveedor, l.fechaTostado,
       DATEDIFF(DAY, l.fechaTostado, GETDATE()) AS diasDesdeTostado,
       ISNULL(uso.calibraciones, 0) AS calibraciones,
       ISNULL(uso.gramosUsados, 0) AS gramosUsados,
       ISNULL(opinion.calificaciones, 0) AS calificaciones,
       opinion.puntajePromedio
FROM Lote l
JOIN Grano g ON g.IDGrano = l.IDGrano
JOIN Proveedor p ON p.IDProveedor = l.IDProveedor
LEFT JOIN (SELECT IDLote, COUNT(*) AS calibraciones, SUM(dosis) AS gramosUsados
           FROM Calibracion
           GROUP BY IDLote) uso ON uso.IDLote = l.IDLote
LEFT JOIN (SELECT c.IDLote, COUNT(*) AS calificaciones, CAST(AVG(k.puntaje * 1.0) AS DECIMAL(4,2)) AS puntajePromedio
           FROM Calibracion c
           JOIN Calificacion k ON k.IDCalibracion = c.IDCalibracion
           GROUP BY c.IDLote) opinion ON opinion.IDLote = l.IDLote;
GO

-- La receta de referencia de cada grano: la calibración con mejor puntaje promedio (con al menos 3 calificaciones).
CREATE OR ALTER VIEW dbo.vw_MejorCalibracionPorGrano AS
SELECT g.IDGrano, g.regionCosecha, v.IDCalibracion, v.fechaCalibracion, v.dosis, v.tiempoExtraccion,
       v.rendimiento, v.relacionExtraccion, v.calificaciones, v.puntajePromedio
FROM vw_PuntajePorCalibracion v
JOIN Grano g ON g.IDGrano = v.IDGrano
WHERE v.calificaciones >= 3
  AND NOT EXISTS (SELECT 1
                  FROM vw_PuntajePorCalibracion otra
                  WHERE otra.IDGrano = v.IDGrano
                    AND otra.calificaciones >= 3
                    AND otra.puntajePromedio > v.puntajePromedio);
GO

-- Lo que se calibró hoy, con el nombre del barista y del lote.
CREATE OR ALTER VIEW dbo.vw_CalibracionesDeHoy AS
SELECT c.IDCalibracion, c.fechaCalibracion, b.nombre + ' ' + b.apellido AS barista, l.nombre AS lote,
       c.dosis, c.tiempoExtraccion, c.rendimiento, dbo.fn_RelacionExtraccion(c.dosis, c.rendimiento) AS relacionExtraccion
FROM Calibracion c
JOIN Barista b ON b.IDBarista = c.IDBarista
JOIN Lote l ON l.IDLote = c.IDLote
WHERE CAST(c.fechaCalibracion AS DATE) = CAST(GETDATE() AS DATE);
GO
