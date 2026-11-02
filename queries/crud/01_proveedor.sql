-- Cafetear · CRUD de Proveedor (procedimientos almacenados)

USE Cafetear;
GO

-- Crear
CREATE OR ALTER PROCEDURE usp_Proveedor_Crear
    @CUIT VARCHAR(13),
    @razonSocial VARCHAR(100)
AS
BEGIN
    INSERT INTO Proveedor (CUIT, razonSocial)
    VALUES (@CUIT, @razonSocial);

    SELECT SCOPE_IDENTITY() AS IDProveedor;
END
GO

-- Obtener
CREATE OR ALTER PROCEDURE usp_Proveedor_Obtener
    @IDProveedor INT
AS
BEGIN
    SELECT * FROM Proveedor WHERE IDProveedor = @IDProveedor;
END
GO

-- Listar
CREATE OR ALTER PROCEDURE usp_Proveedor_Listar
AS
BEGIN
    SELECT * FROM Proveedor ORDER BY IDProveedor;
END
GO

-- Actualizar
CREATE OR ALTER PROCEDURE usp_Proveedor_Actualizar
    @IDProveedor INT,
    @CUIT VARCHAR(13),
    @razonSocial VARCHAR(100)
AS
BEGIN
    UPDATE Proveedor
    SET CUIT = @CUIT,
        razonSocial = @razonSocial
    WHERE IDProveedor = @IDProveedor;
END
GO

-- Eliminar
CREATE OR ALTER PROCEDURE usp_Proveedor_Eliminar
    @IDProveedor INT
AS
BEGIN
    DELETE FROM Proveedor WHERE IDProveedor = @IDProveedor;
END
GO
