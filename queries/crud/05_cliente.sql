-- Cafetear · CRUD de Cliente (procedimientos almacenados)

USE Cafetear;
GO

-- Crear
CREATE OR ALTER PROCEDURE usp_Cliente_Crear
    @DNI VARCHAR(8),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50)
AS
BEGIN
    INSERT INTO Cliente (DNI, nombre, apellido)
    VALUES (@DNI, @nombre, @apellido);

    SELECT SCOPE_IDENTITY() AS IDCliente;
END
GO

-- Obtener
CREATE OR ALTER PROCEDURE usp_Cliente_Obtener
    @IDCliente INT
AS
BEGIN
    SELECT * FROM Cliente WHERE IDCliente = @IDCliente;
END
GO

-- Listar
CREATE OR ALTER PROCEDURE usp_Cliente_Listar
AS
BEGIN
    SELECT * FROM Cliente ORDER BY IDCliente;
END
GO

-- Actualizar
CREATE OR ALTER PROCEDURE usp_Cliente_Actualizar
    @IDCliente INT,
    @DNI VARCHAR(8),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50)
AS
BEGIN
    UPDATE Cliente
    SET DNI = @DNI,
        nombre = @nombre,
        apellido = @apellido
    WHERE IDCliente = @IDCliente;
END
GO

-- Eliminar
CREATE OR ALTER PROCEDURE usp_Cliente_Eliminar
    @IDCliente INT
AS
BEGIN
    DELETE FROM Cliente WHERE IDCliente = @IDCliente;
END
GO
