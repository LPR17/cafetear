-- Active: 1787956958115@@127.0.0.1@1433@Cafetear
-- 1) Mostrar por lote la cantidad de calibraciones, los gramos totales usados en 
--ellas y el puntaje promedio, 
--solo para los lotes con promedio menor a 3,5.


-- Nombre lote, cant calibraciones, gramos totales y puntaje promedio.

SELECT l.nombre, 
COUNT(c.IDCalibracion) AS CantidadCalibraciones, 
SUM(c.dosis) AS GramosTotalesUsados,
SUM(p.SumaPuntajes* 1.0)/ SUM(p.CantidadCalificaciones) AS PuntajePromedio
FROM Lote l
JOIN Calibracion c ON c.IDLote = l.IDLote
LEFT JOIN(
    SELECT IDCalibracion,
    SUM(puntaje) AS SumaPuntajes,
    COUNT(*) AS CantidadCalificaciones
    FROM Calificacion 
    GROUP BY IDCalibracion) p ON p.IDCalibracion = c.IDCalibracion
GROUP BY l.IDLote, l.nombre
HAVING SUM(p.SumaPuntajes* 1.0)/ SUM(p.CantidadCalificaciones) < 3.5;


/*

Mostrar el puntaje
promedio y la cantidad de
calificaciones de cada
mes.


MES CalificacionPromedio CantCalificaciones


*/
SELECT 
    CONCAT(MONTH(fecha), '/', YEAR(fecha)) AS MesAnio,
    AVG(puntaje)* 1.0 AS CalificacionPromedio,
    COUNT(*) AS CantidadCalificaciones
FROM
    Calificacion
GROUP BY MONTH(fecha), YEAR(fecha)
ORDER BY MONTH(fecha), YEAR(fecha)

/*
Mostrar Puntaje Promedio según las semanas transcurridas desde el tostado
*/

SELECT
    g.IDGrano,
    g.regionCosecha AS Grano,
    DATEDIFF(DAY, l.fechaTostado, c.fechaCalibracion) / 7 AS SemanasDesdeTostado,
    AVG(cf.puntaje * 1.0) AS PuntajePromedio,
    COUNT(*) AS CatnidadCalificaciones
FROM
    Grano g
JOIN Lote l ON l.IDGrano = g.IDGrano --Cada lote pertenece a un grano
JOIN Calibracion c ON c.IDLote = l.IDLote --Cada calibración usa un lote
JOIN Calificacion cf ON cf.IDCalibracion = c.IDCalibracion -- Cada calificacion evalua una calibracion

GROUP BY 
    g.IDGrano,
    g.regionCosecha,
    DATEDIFF(DAY, l.fechaTostado, c.fechaCalibracion) / 7
ORDER BY g.IDGrano, SemanasDesdeTostado;