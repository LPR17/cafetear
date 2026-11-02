-- Cafetear · CRUD de Lote (procedimientos almacenados)

USE Cafetear;
GO

-- Crear
CREATE OR ALTER PROCEDURE usp_Lote_Crear
    @nombre VARCHAR(100),
    @IDGrano INT,
    @IDProveedor INT,
    @fechaIngreso DATE,
    @fechaTostado DATE,
    @cantidadKg DECIMAL(6,2)
AS
BEGIN
    IF @cantidadKg <= 0
        THROW 50000, N'La cantidad en kilos debe ser mayor a cero.', 1;
    IF @fechaTostado > @fechaIngreso
        THROW 50000, N'El tostado no puede ser posterior al ingreso del lote.', 1;

    DECLARE @IDLote INT = (SELECT ISNULL(MAX(IDLote), 0) + 1 FROM Lote);

    INSERT INTO Lote (IDLote, nombre, IDGrano, IDProveedor, fechaIngreso, fechaTostado, cantidadKg)
    VALUES (@IDLote, @nombre, @IDGrano, @IDProveedor, @fechaIngreso, @fechaTostado, @cantidadKg);

    SELECT @IDLote AS IDLote;
END
GO

-- Obtener
CREATE OR ALTER PROCEDURE usp_Lote_Obtener
    @IDLote INT
AS
BEGIN
    SELECT * FROM Lote WHERE IDLote = @IDLote;
END
GO

-- Listar
CREATE OR ALTER PROCEDURE usp_Lote_Listar
AS
BEGIN
    SELECT * FROM Lote ORDER BY IDLote;
END
GO

-- Actualizar
CREATE OR ALTER PROCEDURE usp_Lote_Actualizar
    @IDLote INT,
    @nombre VARCHAR(100),
    @IDGrano INT,
    @IDProveedor INT,
    @fechaIngreso DATE,
    @fechaTostado DATE,
    @cantidadKg DECIMAL(6,2)
AS
BEGIN
    IF @cantidadKg <= 0
        THROW 50000, N'La cantidad en kilos debe ser mayor a cero.', 1;
    IF @fechaTostado > @fechaIngreso
        THROW 50000, N'El tostado no puede ser posterior al ingreso del lote.', 1;

    UPDATE Lote
    SET nombre = @nombre,
        IDGrano = @IDGrano,
        IDProveedor = @IDProveedor,
        fechaIngreso = @fechaIngreso,
        fechaTostado = @fechaTostado,
        cantidadKg = @cantidadKg
    WHERE IDLote = @IDLote;
END
GO

-- Eliminar
CREATE OR ALTER PROCEDURE usp_Lote_Eliminar
    @IDLote INT
AS
BEGIN
    DELETE FROM Lote WHERE IDLote = @IDLote;
END
GO
