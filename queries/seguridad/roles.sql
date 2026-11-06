-- Cafetear · Roles y permisos
-- Dos perfiles. Quien carga datos lo hace solo por los procedimientos: los roles no tienen permiso sobre las tablas.
-- Los usuarios se crean aparte (con su login) y se agregan a uno de estos roles.

USE Cafetear;
GO

IF DATABASE_PRINCIPAL_ID('rol_barista') IS NULL CREATE ROLE rol_barista;
IF DATABASE_PRINCIPAL_ID('rol_analista') IS NULL CREATE ROLE rol_analista;
GO

-- Barista: registra calibraciones y consulta la mejor receta de cada grano.
GRANT EXECUTE ON dbo.usp_Calibracion_Crear TO rol_barista;
GRANT SELECT ON dbo.vw_MejorCalibracionPorGrano TO rol_barista;

-- Analista: lee todo (tablas y vistas) y no modifica nada.
GRANT SELECT ON SCHEMA::dbo TO rol_analista;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_analista;
GRANT EXECUTE ON dbo.usp_RankingBaristas TO rol_analista;
GO
