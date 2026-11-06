-- Cafetear · Verificación de la carga
-- Compara lo que debería haber (filas por tabla y cantidad de objetos) con lo que hay.
-- Si algo no coincide, muestra ERROR en esa fila y termina con un error.

USE cafetear;
GO

DECLARE @controles TABLE (control VARCHAR(50), esperado INT, actual INT);

INSERT INTO @controles VALUES
    ('Proveedor', 10, (SELECT COUNT(*) FROM Proveedor)),
    ('Grano', 10, (SELECT COUNT(*) FROM Grano)),
    ('Lote', 40, (SELECT COUNT(*) FROM Lote)),
    ('Barista', 10, (SELECT COUNT(*) FROM Barista)),
    ('Cliente', 60, (SELECT COUNT(*) FROM Cliente)),
    ('Calibracion', 225, (SELECT COUNT(*) FROM Calibracion)),
    ('Calificacion', 346, (SELECT COUNT(*) FROM Calificacion)),
    ('procedimientos', 3, (SELECT COUNT(*) FROM sys.procedures)),
    ('vistas', 2, (SELECT COUNT(*) FROM sys.views)),
    ('funciones', 1, (SELECT COUNT(*) FROM sys.objects WHERE type = 'FN')),
    ('triggers', 2, (SELECT COUNT(*) FROM sys.triggers)),
    ('indices', 3, (SELECT COUNT(*) FROM sys.indexes i JOIN sys.tables t ON t.object_id = i.object_id WHERE t.is_ms_shipped = 0 AND i.name LIKE 'ix%')),
    -- El apellido Ríos (con acento) tiene que estar bien escrito
    ('acentos', 1, (SELECT COUNT(*) FROM Barista WHERE apellido = 'R' + NCHAR(237) + 'os'));

SELECT control, esperado, actual, CASE WHEN esperado = actual THEN 'OK' ELSE 'ERROR' END AS estado
FROM @controles;

IF EXISTS (SELECT 1 FROM @controles WHERE esperado <> actual)
    THROW 51000, N'La carga no quedó completa: revisá los controles con estado ERROR.', 1;

PRINT 'OK: la base cafetear se cargó correctamente.';
GO
