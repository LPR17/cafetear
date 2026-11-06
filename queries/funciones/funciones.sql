-- Cafetear · Función

USE cafetear;
GO

-- Relación de extracción: gramos de café en la taza por cada gramo de café molido. Con 18 g y 36 g da 2,00 (1:2).
CREATE OR ALTER FUNCTION dbo.fnRelacionExtraccion (@dosis DECIMAL(5,1), @rendimiento DECIMAL(5,1))
RETURNS DECIMAL(5,2)
AS
BEGIN
    RETURN CASE WHEN @dosis > 0 THEN CAST(@rendimiento / @dosis AS DECIMAL(5,2)) END;
END
GO
