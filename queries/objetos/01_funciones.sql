-- Cafetear · Funciones

USE Cafetear;
GO

-- Relación de extracción: gramos de café en la taza por cada gramo de café molido. Con 18 g y 36 g da 2,00 (1:2).
CREATE OR ALTER FUNCTION dbo.fn_RelacionExtraccion (@dosis DECIMAL(5,1), @rendimiento DECIMAL(5,1))
RETURNS DECIMAL(5,2)
AS
BEGIN
    RETURN CASE WHEN @dosis > 0 THEN CAST(@rendimiento / @dosis AS DECIMAL(5,2)) END;
END
GO

-- Puntaje promedio que recibió un lote, sumando las calificaciones de todas sus calibraciones.
CREATE OR ALTER FUNCTION dbo.fn_PuntajePromedioLote (@IDLote INT)
RETURNS DECIMAL(4,2)
AS
BEGIN
    RETURN (SELECT CAST(AVG(k.puntaje * 1.0) AS DECIMAL(4,2))
            FROM Calibracion c
            JOIN Calificacion k ON k.IDCalibracion = c.IDCalibracion
            WHERE c.IDLote = @IDLote);
END
GO

-- Días que pasaron entre el tostado del lote y una fecha: sirve para medir la frescura del café.
CREATE OR ALTER FUNCTION dbo.fn_DiasDesdeTostado (@IDLote INT, @fecha DATETIME)
RETURNS INT
AS
BEGIN
    RETURN (SELECT DATEDIFF(DAY, fechaTostado, @fecha) FROM Lote WHERE IDLote = @IDLote);
END
GO

-- Calibraciones de un barista, con la relación de extracción ya calculada.
CREATE OR ALTER FUNCTION dbo.fn_CalibracionesDeBarista (@IDBarista INT)
RETURNS TABLE
AS
RETURN
(
    SELECT c.IDCalibracion, c.fechaCalibracion, c.dosis, c.tiempoExtraccion, c.rendimiento,
           dbo.fn_RelacionExtraccion(c.dosis, c.rendimiento) AS relacionExtraccion, c.IDLote
    FROM Calibracion c
    WHERE c.IDBarista = @IDBarista
);
GO
