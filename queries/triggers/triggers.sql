-- Cafetear · Triggers
-- Aplican las reglas de negocio en la propia base: valen aunque alguien inserte sin pasar por un procedimiento.
-- Se crean después de cargar los datos, así que no afectan a la carga inicial.

USE cafetear;
GO

-- Control de calificaciones: puntaje de 1 a 5, no anterior a la calibración y una sola por cliente y calibración.
CREATE OR ALTER TRIGGER dbo.trgCalificacionControl
ON dbo.Calificacion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE puntaje NOT BETWEEN 1 AND 5)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50020, N'El puntaje debe estar entre 1 y 5.', 1;
    END;

    IF EXISTS (SELECT 1
               FROM inserted i
               JOIN Calibracion c ON c.idCalibracion = i.idCalibracion
               WHERE i.fecha < c.fechaCalibracion)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50021, N'La calificación no puede ser anterior a la calibración.', 1;
    END;

    IF EXISTS (SELECT 1
               FROM Calificacion k
               JOIN inserted i ON i.idCliente = k.idCliente AND i.idCalibracion = k.idCalibracion
               GROUP BY k.idCliente, k.idCalibracion
               HAVING COUNT(*) > 1)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50022, N'Ese cliente ya calificó esta calibración.', 1;
    END;
END
GO

-- Asignación de calibración: el cliente no sabe qué calibración le tocó, así que se le asigna la más próxima anterior a su calificación.
-- Vale para cualquier INSERT, aunque no pase por un procedimiento; si el insert trae un idCalibracion, se reemplaza por el que corresponde.
CREATE OR ALTER TRIGGER dbo.trgCalificacionAsignarCalibracion
ON dbo.Calificacion
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1
               FROM inserted i
               WHERE NOT EXISTS (SELECT 1 FROM Calibracion c WHERE c.fechaCalibracion <= i.fecha))
        THROW 50023, N'No hay ninguna calibración anterior a esa fecha.', 1;

    INSERT INTO Calificacion (idCalificacion, fecha, puntaje, idCliente, idCalibracion)
    SELECT i.idCalificacion, i.fecha, i.puntaje, i.idCliente, nearest.idCalibracion
    FROM inserted i
    CROSS APPLY (SELECT TOP 1 c.idCalibracion
                 FROM Calibracion c
                 WHERE c.fechaCalibracion <= i.fecha
                 ORDER BY c.fechaCalibracion DESC, c.idCalibracion DESC) nearest;
END
GO
