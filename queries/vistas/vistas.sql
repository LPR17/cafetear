-- Cafetear · Vistas

USE cafetear;
GO

-- Una fila por calibración con el puntaje promedio que recibió. La reutilizan vwMejorCalibracionPorGrano y uspRankingBaristas.
CREATE OR ALTER VIEW dbo.vwPuntajePorCalibracion AS
SELECT c.idCalibracion, c.fechaCalibracion, c.dosis, c.tiempoExtraccion, c.rendimiento,
       dbo.fnRelacionExtraccion(c.dosis, c.rendimiento) AS relacionExtraccion,
       c.idBarista, c.idLote, l.idGrano,
       COUNT(k.idCalificacion) AS calificaciones,
       SUM(k.puntaje) AS sumaPuntajes,
       CAST(AVG(k.puntaje * 1.0) AS DECIMAL(4,2)) AS puntajePromedio
FROM calibracion c
JOIN lote l ON l.idLote = c.idLote
LEFT JOIN calificacion k ON k.idCalibracion = c.idCalibracion
GROUP BY c.idCalibracion, c.fechaCalibracion, c.dosis, c.tiempoExtraccion, c.rendimiento,
         c.idBarista, c.idLote, l.idGrano;
GO

-- La receta de referencia de cada grano: la calibración con mejor puntaje promedio (con al menos 3 calificaciones).
CREATE OR ALTER VIEW dbo.vwMejorCalibracionPorGrano AS
SELECT g.idGrano, g.regionCosecha, v.idCalibracion, v.fechaCalibracion, v.dosis, v.tiempoExtraccion,
       v.rendimiento, v.relacionExtraccion, v.calificaciones, v.puntajePromedio
FROM vwPuntajePorCalibracion v
JOIN grano g ON g.idGrano = v.idGrano
WHERE v.calificaciones >= 3
  AND NOT EXISTS (SELECT 1
                  FROM vwPuntajePorCalibracion otra
                  WHERE otra.idGrano = v.idGrano
                    AND otra.calificaciones >= 3
                    AND otra.puntajePromedio > v.puntajePromedio);
GO
