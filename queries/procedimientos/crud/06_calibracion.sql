-- Cafetear · CRUD de Calibracion (procedimientos almacenados)

USE Cafetear;
GO

-- Crear
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

-- Obtener
CREATE OR ALTER PROCEDURE usp_Calibracion_Obtener
    @IDCalibracion INT
AS
BEGIN
    SELECT * FROM Calibracion WHERE IDCalibracion = @IDCalibracion;
END
GO

-- Listar
CREATE OR ALTER PROCEDURE usp_Calibracion_Listar
AS
BEGIN
    SELECT * FROM Calibracion ORDER BY IDCalibracion;
END
GO

-- Actualizar
CREATE OR ALTER PROCEDURE usp_Calibracion_Actualizar
    @IDCalibracion INT,
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

    UPDATE Calibracion
    SET fechaCalibracion = @fechaCalibracion,
        dosis = @dosis,
        tiempoExtraccion = @tiempoExtraccion,
        rendimiento = @rendimiento,
        IDBarista = @IDBarista,
        IDLote = @IDLote
    WHERE IDCalibracion = @IDCalibracion;
END
GO

-- Eliminar
CREATE OR ALTER PROCEDURE usp_Calibracion_Eliminar
    @IDCalibracion INT
AS
BEGIN
    DELETE FROM Calibracion WHERE IDCalibracion = @IDCalibracion;
END
GO
