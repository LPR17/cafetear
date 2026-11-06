-- Cafetear · Copia de seguridad y restauración
-- Se ejecuta a mano (no forma parte de la carga).
-- Sin ruta: el archivo queda en la carpeta de respaldos por defecto de SQL Server (en Windows suele ser
-- C:\Program Files\Microsoft SQL Server\MSSQL..\MSSQL\Backup).

USE cafetear;
GO

-- 1) Copia completa, con control de integridad.
BACKUP DATABASE cafetear
TO DISK = N'cafetear.bak'
WITH INIT, CHECKSUM, STATS = 25;
GO

-- 2) Verificar que la copia se puede restaurar (no toca la base).
RESTORE VERIFYONLY
FROM DISK = N'cafetear.bak'
WITH CHECKSUM;
GO

-- 3) Restaurar sobre la base actual (borra lo que haya en ella). Descomentar para usar.
-- USE master;
-- ALTER DATABASE cafetear SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- RESTORE DATABASE cafetear FROM DISK = N'cafetear.bak' WITH REPLACE, RECOVERY;
-- ALTER DATABASE cafetear SET MULTI_USER;
-- GO
