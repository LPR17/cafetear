-- Cafetear · CRUD de Barista (procedimientos almacenados)

USE Cafetear;
GO

-- Crear
CREATE OR ALTER PROCEDURE usp_Barista_Crear
    @DNI VARCHAR(8),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @experiencia INT
AS
BEGIN
    IF @experiencia < 0
        THROW 50000, N'La experiencia no puede ser negativa.', 1;

    INSERT INTO Barista (DNI, nombre, apellido, experiencia)
    VALUES (@DNI, @nombre, @apellido, @experiencia);

    SELECT SCOPE_IDENTITY() AS IDBarista;
END
GO

-- Obtener
CREATE OR ALTER PROCEDURE usp_Barista_Obtener
    @IDBarista INT
AS
BEGIN
    SELECT * FROM Barista WHERE IDBarista = @IDBarista;
END
GO

-- Listar
CREATE OR ALTER PROCEDURE usp_Barista_Listar
AS
BEGIN
    SELECT * FROM Barista ORDER BY IDBarista;
END
GO

-- Actualizar
CREATE OR ALTER PROCEDURE usp_Barista_Actualizar
    @IDBarista INT,
    @DNI VARCHAR(8),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @experiencia INT
AS
BEGIN
    IF @experiencia < 0
        THROW 50000, N'La experiencia no puede ser negativa.', 1;

    UPDATE Barista
    SET DNI = @DNI,
        nombre = @nombre,
        apellido = @apellido,
        experiencia = @experiencia
    WHERE IDBarista = @IDBarista;
END
GO

-- Eliminar
CREATE OR ALTER PROCEDURE usp_Barista_Eliminar
    @IDBarista INT
AS
BEGIN
    DELETE FROM Barista WHERE IDBarista = @IDBarista;
END
GO
