-- Cafetear · Índices
-- SQL Server no crea índices sobre las claves foráneas. Estos aceleran los joins y los filtros más usados.

USE Cafetear;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Lote_IDGrano' AND object_id = OBJECT_ID('dbo.Lote'))
    CREATE INDEX IX_Lote_IDGrano ON dbo.Lote (IDGrano);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Lote_IDProveedor' AND object_id = OBJECT_ID('dbo.Lote'))
    CREATE INDEX IX_Lote_IDProveedor ON dbo.Lote (IDProveedor);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Calibracion_IDLote' AND object_id = OBJECT_ID('dbo.Calibracion'))
    CREATE INDEX IX_Calibracion_IDLote ON dbo.Calibracion (IDLote) INCLUDE (dosis);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Calibracion_IDBarista' AND object_id = OBJECT_ID('dbo.Calibracion'))
    CREATE INDEX IX_Calibracion_IDBarista ON dbo.Calibracion (IDBarista);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Calibracion_Fecha' AND object_id = OBJECT_ID('dbo.Calibracion'))
    CREATE INDEX IX_Calibracion_Fecha ON dbo.Calibracion (fechaCalibracion);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Calificacion_IDCalibracion' AND object_id = OBJECT_ID('dbo.Calificacion'))
    CREATE INDEX IX_Calificacion_IDCalibracion ON dbo.Calificacion (IDCalibracion) INCLUDE (puntaje);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Calificacion_IDCliente' AND object_id = OBJECT_ID('dbo.Calificacion'))
    CREATE INDEX IX_Calificacion_IDCliente ON dbo.Calificacion (IDCliente);
GO
