-- Cafetear · Vistas

USE Cafetear;
GO

-- Una fila por calibración con el puntaje promedio que recibió. La reutilizan vw_MejorCalibracionPorGrano y usp_RankingBaristas.
CREATE OR ALTER VIEW dbo.vw_PuntajePorCalibracion AS
SELECT c.IDCalibracion, c.fechaCalibracion, c.dosis, c.tiempoExtraccion, c.rendimiento,
       dbo.fn_RelacionExtraccion(c.dosis, c.rendimiento) AS relacionExtraccion,
       c.IDBarista, c.IDLote, l.IDGrano,
       COUNT(k.IDCalificacion) AS calificaciones,
       SUM(k.puntaje) AS sumaPuntajes,
       CAST(AVG(k.puntaje * 1.0) AS DECIMAL(4,2)) AS puntajePromedio
FROM Calibracion c
JOIN Lote l ON l.IDLote = c.IDLote
LEFT JOIN Calificacion k ON k.IDCalibracion = c.IDCalibracion
GROUP BY c.IDCalibracion, c.fechaCalibracion, c.dosis, c.tiempoExtraccion, c.rendimiento,
         c.IDBarista, c.IDLote, l.IDGrano;
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
