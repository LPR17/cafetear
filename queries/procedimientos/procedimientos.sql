-- Cafetear · Procedimientos almacenados

USE Cafetear;
GO

-- Registrar una calibración: valida los datos, calcula el próximo ID y lo devuelve.
CREATE OR ALTER PROCEDURE usp_Calibracion_Crear
    @fechaCalibracion DATETIME,
    @dosis DECIMAL(5,1),
    @tiempoExtraccion INT,
    @rendimiento DECIMAL(5,1),
    @IDBarista INT,
    @IDLote INT
AS
BEGIN
    IF @dosis <= 0
        THROW 50000, N'La dosis debe ser mayor a cero.', 1;
    IF @tiempoExtraccion <= 0
        THROW 50000, N'El tiempo de extracción debe ser mayor a cero.', 1;
    IF @rendimiento <= 0
        THROW 50000, N'El rendimiento debe ser mayor a cero.', 1;
    IF EXISTS (SELECT 1 FROM Lote WHERE IDLote = @IDLote AND CAST(@fechaCalibracion AS DATE) < fechaIngreso)
        THROW 50000, N'La calibración no puede ser anterior al ingreso del lote.', 1;

    DECLARE @IDCalibracion INT = (SELECT ISNULL(MAX(IDCalibracion), 0) + 1 FROM Calibracion);

    INSERT INTO Calibracion (IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista, IDLote)
    VALUES (@IDCalibracion, @fechaCalibracion, @dosis, @tiempoExtraccion, @rendimiento, @IDBarista, @IDLote);

    SELECT @IDCalibracion AS IDCalibracion;
END
GO

-- Registrar una calificación. El cliente no informa la calibración: la asigna el trigger trg_Calificacion_AsignarCalibracion.
CREATE OR ALTER PROCEDURE usp_Calificacion_Crear
    @fecha DATETIME,
    @puntaje INT,
    @IDCliente INT
AS
BEGIN
    IF @puntaje NOT BETWEEN 1 AND 5
        THROW 50000, N'El puntaje debe estar entre 1 y 5.', 1;

    DECLARE @IDCalificacion INT = (SELECT ISNULL(MAX(IDCalificacion), 0) + 1 FROM Calificacion);

    INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente)
    VALUES (@IDCalificacion, @fecha, @puntaje, @IDCliente);

    SELECT @IDCalificacion AS IDCalificacion;
END
GO

-- Ranking de baristas por puntaje promedio, en un período. Sin fechas, considera todo el historial. Reutiliza vw_PuntajePorCalibracion.
CREATE OR ALTER PROCEDURE dbo.usp_RankingBaristas
    @desde DATE = NULL,
    @hasta DATE = NULL
AS
BEGIN
    SELECT b.IDBarista, b.nombre + ' ' + b.apellido AS barista,
           COUNT(*) AS calibraciones,
           SUM(v.calificaciones) AS calificaciones,
           CAST(SUM(v.sumaPuntajes) * 1.0 / NULLIF(SUM(v.calificaciones), 0) AS DECIMAL(4,2)) AS puntajePromedio
    FROM vw_PuntajePorCalibracion v
    JOIN Barista b ON b.IDBarista = v.IDBarista
    WHERE (@desde IS NULL OR v.fechaCalibracion >= @desde)
      AND (@hasta IS NULL OR v.fechaCalibracion < DATEADD(DAY, 1, @hasta))
    GROUP BY b.IDBarista, b.nombre, b.apellido
    ORDER BY puntajePromedio DESC;
END
GO
