-- Cafetear · Borra vistas, procedimientos, funciones y triggers
-- Lo ejecuta inicializar.sh antes de recrearlos, así no quedan objetos de versiones anteriores. No toca tablas ni datos.

USE Cafetear;
GO

DECLARE @borrar NVARCHAR(MAX) = N'';

SELECT @borrar += N'DROP TRIGGER ' + QUOTENAME(SCHEMA_NAME(o.schema_id)) + N'.' + QUOTENAME(t.name) + N';'
FROM sys.triggers t
JOIN sys.objects o ON o.object_id = t.parent_id
WHERE t.parent_class = 1;

SELECT @borrar += N'DROP VIEW ' + QUOTENAME(SCHEMA_NAME(schema_id)) + N'.' + QUOTENAME(name) + N';'
FROM sys.views
WHERE is_ms_shipped = 0;

SELECT @borrar += N'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + N'.' + QUOTENAME(name) + N';'
FROM sys.procedures
WHERE is_ms_shipped = 0;

SELECT @borrar += N'DROP FUNCTION ' + QUOTENAME(SCHEMA_NAME(schema_id)) + N'.' + QUOTENAME(name) + N';'
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF') AND is_ms_shipped = 0;

EXEC sp_executesql @borrar;
GO
