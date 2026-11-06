-- Cafetear · CRUD de Grano (procedimientos almacenados)

USE Cafetear;
GO

-- Crear
CREATE OR ALTER PROCEDURE usp_Grano_Crear
    @alturaCosecha INT,
    @regionCosecha VARCHAR(60),
    @fechaCosecha DATE
AS
BEGIN
    DECLARE @IDGrano INT = (SELECT ISNULL(MAX(IDGrano), 0) + 1 FROM Grano);

    INSERT INTO Grano (IDGrano, alturaCosecha, regionCosecha, fechaCosecha)
    VALUES (@IDGrano, @alturaCosecha, @regionCosecha, @fechaCosecha);

    SELECT @IDGrano AS IDGrano;
END
GO

-- Obtener
CREATE OR ALTER PROCEDURE usp_Grano_Obtener
    @IDGrano INT
AS
BEGIN
    SELECT * FROM Grano WHERE IDGrano = @IDGrano;
END
GO

-- Listar
CREATE OR ALTER PROCEDURE usp_Grano_Listar
AS
BEGIN
    SELECT * FROM Grano ORDER BY IDGrano;
END
GO

-- Actualizar
CREATE OR ALTER PROCEDURE usp_Grano_Actualizar
    @IDGrano INT,
    @alturaCosecha INT,
    @regionCosecha VARCHAR(60),
    @fechaCosecha DATE
AS
BEGIN
    UPDATE Grano
    SET alturaCosecha = @alturaCosecha,
        regionCosecha = @regionCosecha,
        fechaCosecha = @fechaCosecha
    WHERE IDGrano = @IDGrano;
END
GO

-- Eliminar
CREATE OR ALTER PROCEDURE usp_Grano_Eliminar
    @IDGrano INT
AS
BEGIN
    DELETE FROM Grano WHERE IDGrano = @IDGrano;
END
GO
