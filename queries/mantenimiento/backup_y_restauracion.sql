-- Cafetear · Copia de seguridad y restauración
-- Se ejecuta a mano (no forma parte de la carga automática).
-- La ruta es la de dentro del contenedor. Para sacar el archivo: docker cp cafetear_sqlserver:/var/opt/mssql/data/Cafetear.bak .

-- 1) Copia completa, con control de integridad.
BACKUP DATABASE Cafetear
TO DISK = N'/var/opt/mssql/data/Cafetear.bak'
WITH INIT, CHECKSUM, STATS = 25;
GO

-- 2) Verificar que la copia se puede restaurar (no toca la base).
RESTORE VERIFYONLY
FROM DISK = N'/var/opt/mssql/data/Cafetear.bak'
WITH CHECKSUM;
GO

-- 3) Restaurar sobre la base actual (borra lo que haya en ella). Descomentar para usar.
-- USE master;
-- ALTER DATABASE Cafetear SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- RESTORE DATABASE Cafetear FROM DISK = N'/var/opt/mssql/data/Cafetear.bak' WITH REPLACE, RECOVERY;
-- ALTER DATABASE Cafetear SET MULTI_USER;
-- GO
