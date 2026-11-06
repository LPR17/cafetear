-- Cafetear · Procedimientos de reporte (además de los del CRUD)

USE Cafetear;
GO

-- Ranking de baristas por puntaje promedio, en un período. Sin fechas, considera todo el historial.
CREATE OR ALTER PROCEDURE dbo.usp_RankingBaristas
    @desde DATE = NULL,
    @hasta DATE = NULL
AS
BEGIN
    SELECT b.IDBarista, b.nombre + ' ' + b.apellido AS barista,
           COUNT(DISTINCT c.IDCalibracion) AS calibraciones,
           COUNT(k.IDCalificacion) AS calificaciones,
           CAST(AVG(k.puntaje * 1.0) AS DECIMAL(4,2)) AS puntajePromedio
    FROM Barista b
    JOIN Calibracion c ON c.IDBarista = b.IDBarista
    LEFT JOIN Calificacion k ON k.IDCalibracion = c.IDCalibracion
    WHERE (@desde IS NULL OR c.fechaCalibracion >= @desde)
      AND (@hasta IS NULL OR c.fechaCalibracion < DATEADD(DAY, 1, @hasta))
    GROUP BY b.IDBarista, b.nombre, b.apellido
    ORDER BY puntajePromedio DESC;
END
GO

-- Resumen de un lote: sus datos, su rendimiento y las calibraciones que tuvo.
CREATE OR ALTER PROCEDURE dbo.usp_ReporteLote
    @IDLote INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Lote WHERE IDLote = @IDLote)
        THROW 50000, N'No existe un lote con ese ID.', 1;

    SELECT * FROM vw_RendimientoPorLote WHERE IDLote = @IDLote;

    SELECT IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, relacionExtraccion, calificaciones, puntajePromedio
    FROM vw_PuntajePorCalibracion
    WHERE IDLote = @IDLote
    ORDER BY fechaCalibracion;
END
GO
