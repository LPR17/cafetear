-- Cafetear · Procedimientos almacenados

USE cafetear;
GO

-- Registrar una calibración: valida los datos, calcula el próximo ID y lo devuelve.
CREATE OR ALTER PROCEDURE uspCalibracionCrear
    @fechaCalibracion DATETIME,
    @dosis DECIMAL(5,1),
    @tiempoExtraccion INT,
    @rendimiento DECIMAL(5,1),
    @idBarista INT,
    @idLote INT
AS
BEGIN
    IF @dosis <= 0
        THROW 50000, N'La dosis debe ser mayor a cero.', 1;
    IF @tiempoExtraccion <= 0
        THROW 50000, N'El tiempo de extracción debe ser mayor a cero.', 1;
    IF @rendimiento <= 0
        THROW 50000, N'El rendimiento debe ser mayor a cero.', 1;
    IF EXISTS (SELECT 1 FROM lote WHERE idLote = @idLote AND CAST(@fechaCalibracion AS DATE) < fechaIngreso)
        THROW 50000, N'La calibración no puede ser anterior al ingreso del lote.', 1;

    DECLARE @idCalibracion INT = (SELECT ISNULL(MAX(idCalibracion), 0) + 1 FROM calibracion);

    INSERT INTO calibracion (idCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, idBarista, idLote)
    VALUES (@idCalibracion, @fechaCalibracion, @dosis, @tiempoExtraccion, @rendimiento, @idBarista, @idLote);

    SELECT @idCalibracion AS idCalibracion;
END
GO

-- Registrar una calificación. El cliente no informa la calibración: la asigna el trigger trgCalificacionAsignarCalibracion.
CREATE OR ALTER PROCEDURE uspCalificacionCrear
    @fecha DATETIME,
    @puntaje INT,
    @idCliente INT
AS
BEGIN
    IF @puntaje NOT BETWEEN 1 AND 5
        THROW 50000, N'El puntaje debe estar entre 1 y 5.', 1;

    DECLARE @idCalificacion INT = (SELECT ISNULL(MAX(idCalificacion), 0) + 1 FROM calificacion);

    INSERT INTO calificacion (idCalificacion, fecha, puntaje, idCliente)
    VALUES (@idCalificacion, @fecha, @puntaje, @idCliente);

    SELECT @idCalificacion AS idCalificacion;
END
GO

-- Ranking de baristas por puntaje promedio, en un período. Sin fechas, considera todo el historial. Reutiliza vwPuntajePorCalibracion.
CREATE OR ALTER PROCEDURE dbo.uspRankingBaristas
    @desde DATE = NULL,
    @hasta DATE = NULL
AS
BEGIN
    SELECT b.idBarista, b.nombre + ' ' + b.apellido AS barista,
           COUNT(*) AS calibraciones,
           SUM(v.calificaciones) AS calificaciones,
           CAST(SUM(v.sumaPuntajes) * 1.0 / NULLIF(SUM(v.calificaciones), 0) AS DECIMAL(4,2)) AS puntajePromedio
    FROM vwPuntajePorCalibracion v
    JOIN barista b ON b.idBarista = v.idBarista
    WHERE (@desde IS NULL OR v.fechaCalibracion >= @desde)
      AND (@hasta IS NULL OR v.fechaCalibracion < DATEADD(DAY, 1, @hasta))
    GROUP BY b.idBarista, b.nombre, b.apellido
    ORDER BY puntajePromedio DESC;
END
GO
