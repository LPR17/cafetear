-- Cafetear · Triggers
-- Aplican las reglas de negocio en la propia base: valen aunque alguien inserte sin pasar por un procedimiento.
-- Se crean después de cargar los datos, así que no afectan a la carga inicial.

USE Cafetear;
GO

-- Control de lote: no se calibra antes de que el lote ingrese ni con café que ya se agotó.
CREATE OR ALTER TRIGGER dbo.trg_Calibracion_ControlLote
ON dbo.Calibracion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1
               FROM inserted i
               JOIN Lote l ON l.IDLote = i.IDLote
               WHERE CAST(i.fechaCalibracion AS DATE) < l.fechaIngreso)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50010, N'No se puede calibrar con un lote antes de su ingreso.', 1;
    END;

    IF EXISTS (SELECT 1
               FROM inserted i
               JOIN Lote l ON l.IDLote = i.IDLote
               WHERE (SELECT SUM(c.dosis) FROM Calibracion c WHERE c.IDLote = i.IDLote) > l.cantidadKg * 1000)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50011, N'El lote no tiene café suficiente para esta calibración.', 1;
    END;
END
GO

-- Control de calificaciones: puntaje de 1 a 5, no anterior a la calibración y una sola por cliente y calibración.
CREATE OR ALTER TRIGGER dbo.trg_Calificacion_Control
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
               JOIN Calibracion c ON c.IDCalibracion = i.IDCalibracion
               WHERE i.fecha < c.fechaCalibracion)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50021, N'La calificación no puede ser anterior a la calibración.', 1;
    END;

    IF EXISTS (SELECT 1
               FROM Calificacion k
               JOIN inserted i ON i.IDCliente = k.IDCliente AND i.IDCalibracion = k.IDCalibracion
               GROUP BY k.IDCliente, k.IDCalibracion
               HAVING COUNT(*) > 1)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50022, N'Ese cliente ya calificó esta calibración.', 1;
    END;
END
GO
