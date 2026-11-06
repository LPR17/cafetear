-- Cafetear · Índices
-- SQL Server no crea índices sobre las claves foráneas. Estos aceleran los joins y los filtros más usados.

USE Cafetear;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Calibracion_IDLote' AND object_id = OBJECT_ID('dbo.Calibracion'))
    CREATE INDEX IX_Calibracion_IDLote ON dbo.Calibracion (IDLote) INCLUDE (dosis);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Calibracion_Fecha' AND object_id = OBJECT_ID('dbo.Calibracion'))
    CREATE INDEX IX_Calibracion_Fecha ON dbo.Calibracion (fechaCalibracion);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Calificacion_IDCalibracion' AND object_id = OBJECT_ID('dbo.Calificacion'))
    CREATE INDEX IX_Calificacion_IDCalibracion ON dbo.Calificacion (IDCalibracion) INCLUDE (puntaje);
GO
