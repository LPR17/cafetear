-- Cafetear · Roles y permisos
-- Tres perfiles. Quien carga datos lo hace solo por los procedimientos: los roles no tienen permiso sobre las tablas.
-- Los usuarios se crean aparte (con su login) y se agregan a uno de estos roles.

USE Cafetear;
GO

IF DATABASE_PRINCIPAL_ID('rol_barista') IS NULL CREATE ROLE rol_barista;
IF DATABASE_PRINCIPAL_ID('rol_analista') IS NULL CREATE ROLE rol_analista;
IF DATABASE_PRINCIPAL_ID('rol_administrador') IS NULL CREATE ROLE rol_administrador;
GO

-- Barista: registra y consulta calibraciones, y consulta lotes y granos.
GRANT EXECUTE ON dbo.usp_Calibracion_Crear TO rol_barista;
GRANT EXECUTE ON dbo.usp_Calibracion_Obtener TO rol_barista;
GRANT EXECUTE ON dbo.usp_Calibracion_Listar TO rol_barista;
GRANT EXECUTE ON dbo.usp_Calibracion_Actualizar TO rol_barista;
GRANT EXECUTE ON dbo.usp_Lote_Obtener TO rol_barista;
GRANT EXECUTE ON dbo.usp_Lote_Listar TO rol_barista;
GRANT EXECUTE ON dbo.usp_Grano_Listar TO rol_barista;
GRANT SELECT ON dbo.vw_CalibracionesDeHoy TO rol_barista;
GRANT SELECT ON dbo.vw_MejorCalibracionPorGrano TO rol_barista;

-- Analista: lee todo (tablas y vistas) y no modifica nada.
GRANT SELECT ON SCHEMA::dbo TO rol_analista;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_analista;
GRANT EXECUTE ON dbo.usp_RankingBaristas TO rol_analista;
GRANT EXECUTE ON dbo.usp_ReporteLote TO rol_analista;

-- Administrador: lee todo y ejecuta todos los procedimientos.
GRANT SELECT ON SCHEMA::dbo TO rol_administrador;
GRANT EXECUTE ON SCHEMA::dbo TO rol_administrador;
GO
