-- Cafetear · Roles y permisos
-- Dos perfiles: barista y dueños. El barista no tiene permiso sobre las tablas: carga datos solo por los procedimientos.
-- Los usuarios se crean aparte (con su login) y se agregan a uno de estos roles.

USE cafetear;
GO

IF DATABASE_PRINCIPAL_ID('rolBarista') IS NULL CREATE ROLE rolBarista;
IF DATABASE_PRINCIPAL_ID('rolDuenio') IS NULL CREATE ROLE rolDuenio;
GO

-- barista: registra calibraciones y calificaciones, y consulta la mejor receta de cada grano.
GRANT EXECUTE ON dbo.uspCalibracionCrear TO rolBarista;
GRANT EXECUTE ON dbo.uspCalificacionCrear TO rolBarista;
GRANT SELECT ON dbo.vwMejorCalibracionPorGrano TO rolBarista;

-- Dueños: ven todo (tablas y vistas) y ejecutan todos los procedimientos, incluido el ranking de baristas.
GRANT SELECT ON SCHEMA::dbo TO rolDuenio;
GRANT EXECUTE ON SCHEMA::dbo TO rolDuenio;
GO
