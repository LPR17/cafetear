-- Cafetear · CRUD de Calificacion (procedimientos almacenados)

USE Cafetear;
GO

-- Crear
CREATE OR ALTER PROCEDURE usp_Calificacion_Crear
    @fecha DATETIME,
    @puntaje INT,
    @IDCliente INT,
    @IDCalibracion INT
AS
BEGIN
    IF @puntaje NOT BETWEEN 1 AND 5
        THROW 50000, N'El puntaje debe estar entre 1 y 5.', 1;
    IF EXISTS (SELECT 1 FROM Calificacion WHERE IDCliente = @IDCliente AND IDCalibracion = @IDCalibracion)
        THROW 50000, N'Ese cliente ya calificó esta calibración.', 1;

    DECLARE @IDCalificacion INT = (SELECT ISNULL(MAX(IDCalificacion), 0) + 1 FROM Calificacion);

    INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente, IDCalibracion)
    VALUES (@IDCalificacion, @fecha, @puntaje, @IDCliente, @IDCalibracion);

    SELECT @IDCalificacion AS IDCalificacion;
END
GO

-- Obtener
CREATE OR ALTER PROCEDURE usp_Calificacion_Obtener
    @IDCalificacion INT
AS
BEGIN
    SELECT * FROM Calificacion WHERE IDCalificacion = @IDCalificacion;
END
GO

-- Listar
CREATE OR ALTER PROCEDURE usp_Calificacion_Listar
AS
BEGIN
    SELECT * FROM Calificacion ORDER BY IDCalificacion;
END
GO

-- Actualizar
CREATE OR ALTER PROCEDURE usp_Calificacion_Actualizar
    @IDCalificacion INT,
    @fecha DATETIME,
    @puntaje INT,
    @IDCliente INT,
    @IDCalibracion INT
AS
BEGIN
    IF @puntaje NOT BETWEEN 1 AND 5
        THROW 50000, N'El puntaje debe estar entre 1 y 5.', 1;
    IF EXISTS (SELECT 1 FROM Calificacion WHERE IDCliente = @IDCliente AND IDCalibracion = @IDCalibracion AND IDCalificacion <> @IDCalificacion)
        THROW 50000, N'Ese cliente ya calificó esta calibración.', 1;

    UPDATE Calificacion
    SET fecha = @fecha,
        puntaje = @puntaje,
        IDCliente = @IDCliente,
        IDCalibracion = @IDCalibracion
    WHERE IDCalificacion = @IDCalificacion;
END
GO

-- Eliminar
CREATE OR ALTER PROCEDURE usp_Calificacion_Eliminar
    @IDCalificacion INT
AS
BEGIN
    DELETE FROM Calificacion WHERE IDCalificacion = @IDCalificacion;
END
GO
