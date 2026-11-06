-- Cafetear · Prueba de la función, las vistas, los procedimientos, los triggers y los permisos
-- Cada línea de la sección de errores debe decir OK. No deja datos: al terminar compara los totales con los del principio.

USE cafetear;
GO
SET NOCOUNT ON;

DECLARE @totalAntes INT = (SELECT (SELECT COUNT(*) FROM calibracion) + (SELECT COUNT(*) FROM calificacion) + (SELECT COUNT(*) FROM cliente));

PRINT '=== 1) Función y vistas ===';
SELECT dbo.fnRelacionExtraccion(18.0, 36.0) AS relacion18g36g, dbo.fnRelacionExtraccion(0, 36.0) AS dosisCero;
SELECT TOP 3 idCalibracion, dosis, rendimiento, relacionExtraccion, calificaciones, puntajePromedio FROM vwPuntajePorCalibracion ORDER BY puntajePromedio DESC, calificaciones DESC;
SELECT idGrano, regionCosecha, idCalibracion, tiempoExtraccion, relacionExtraccion, calificaciones, puntajePromedio FROM vwMejorCalibracionPorGrano ORDER BY idGrano;

PRINT '=== 2) Procedimientos: registrar una calibración y una calificación, sin indicar la calibración ===';
EXEC uspCalibracionCrear @fechaCalibracion = '2026-12-01T08:00:00', @dosis = 18.0, @tiempoExtraccion = 28, @rendimiento = 36.0, @idBarista = 1, @idLote = 3;
DECLARE @calibracion INT = (SELECT MAX(idCalibracion) FROM calibracion);
EXEC uspCalificacionCrear @fecha = '2026-12-01T10:00:00', @puntaje = 5, @idCliente = 1;
DECLARE @asignada INT = (SELECT idCalibracion FROM calificacion WHERE idCalificacion = (SELECT MAX(idCalificacion) FROM calificacion));
PRINT CASE WHEN @asignada = @calibracion THEN 'OK: el trigger asignó la calibración más próxima (' + CAST(@asignada AS VARCHAR(10)) + ')' ELSE 'FALLÓ: asignó otra calibración' END;
EXEC uspRankingBaristas @desde = '2026-01-01', @hasta = '2026-10-31';

PRINT '=== 3) Errores que se tienen que rechazar ===';
BEGIN TRY EXEC uspCalibracionCrear @fechaCalibracion = '2026-12-01T08:00:00', @dosis = 0, @tiempoExtraccion = 28, @rendimiento = 36, @idBarista = 1, @idLote = 3; PRINT 'FALLÓ: aceptó dosis cero'; END TRY
BEGIN CATCH PRINT 'OK (procedimiento): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC uspCalibracionCrear @fechaCalibracion = '2000-01-01T08:00:00', @dosis = 18, @tiempoExtraccion = 28, @rendimiento = 36, @idBarista = 1, @idLote = 3; PRINT 'FALLÓ: aceptó una calibración anterior al ingreso del lote'; END TRY
BEGIN CATCH PRINT 'OK (procedimiento): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC uspCalificacionCrear @fecha = '2026-12-01T11:00:00', @puntaje = 9, @idCliente = 2; PRINT 'FALLÓ: aceptó un puntaje de 9'; END TRY
BEGIN CATCH PRINT 'OK (trigger): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC uspCalificacionCrear @fecha = '2026-12-01T11:00:00', @puntaje = 3, @idCliente = 1; PRINT 'FALLÓ: aceptó que el mismo cliente califique dos veces'; END TRY
BEGIN CATCH PRINT 'OK (trigger): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC uspCalificacionCrear @fecha = '2000-01-01T10:00:00', @puntaje = 4, @idCliente = 2; PRINT 'FALLÓ: aceptó una calificación sin calibración anterior'; END TRY
BEGIN CATCH PRINT 'OK (trigger): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY UPDATE calificacion SET fecha = '2000-01-01T10:00:00' WHERE idCalificacion = 1; PRINT 'FALLÓ: aceptó una calificación anterior a la calibración'; END TRY
BEGIN CATCH PRINT 'OK (trigger): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO barista (dni, nombre, apellido, experiencia) VALUES ('10000001', N'Prueba', N'Tipo', 'mucha'); PRINT 'FALLÓ: aceptó texto en un número'; END TRY
BEGIN CATCH PRINT 'OK (tipo de dato): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO cliente (dni, nombre, apellido) VALUES ('123456789012', N'Prueba', N'Largo'); PRINT 'FALLÓ: aceptó un dni de más de 8 caracteres'; END TRY
BEGIN CATCH PRINT 'OK (tamaño): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO cliente (dni, nombre, apellido) VALUES ('10000002', NULL, N'SinNombre'); PRINT 'FALLÓ: aceptó un nombre vacío'; END TRY
BEGIN CATCH PRINT 'OK (NOT NULL): ' + ERROR_MESSAGE(); END CATCH
DECLARE @dniExistente VARCHAR(8) = (SELECT TOP 1 dni FROM cliente ORDER BY idCliente);
BEGIN TRY INSERT INTO cliente (dni, nombre, apellido) VALUES (@dniExistente, N'Repetido', N'Repetido'); PRINT 'FALLÓ: aceptó un dni repetido'; END TRY
BEGIN CATCH PRINT 'OK (UNIQUE): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO calibracion (idCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, idBarista, idLote) VALUES (99999, '2026-12-02T08:00:00', 18, 28, 36, 1, 9999); PRINT 'FALLÓ: aceptó un lote inexistente'; END TRY
BEGIN CATCH PRINT 'OK (clave foránea): ' + ERROR_MESSAGE(); END CATCH

PRINT '=== 4) Permisos: un usuario barista solo puede usar procedimientos ===';
IF DATABASE_PRINCIPAL_ID('usuarioPrueba') IS NOT NULL DROP USER usuarioPrueba;
CREATE USER usuarioPrueba WITHOUT LOGIN;
ALTER ROLE rolBarista ADD MEMBER usuarioPrueba;
EXECUTE AS USER = 'usuarioPrueba';
BEGIN TRY EXEC uspCalibracionCrear @fechaCalibracion = '2026-12-03T08:00:00', @dosis = 18.0, @tiempoExtraccion = 28, @rendimiento = 36.0, @idBarista = 1, @idLote = 3; PRINT 'OK: el barista puede registrar una calibración con el procedimiento, sin permiso sobre la tabla'; END TRY
BEGIN CATCH PRINT 'FALLÓ: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC uspCalificacionCrear @fecha = '2026-12-03T10:00:00', @puntaje = 4, @idCliente = 3; PRINT 'OK: el barista puede registrar una calificación con el procedimiento'; END TRY
BEGIN CATCH PRINT 'FALLÓ: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY SELECT TOP 1 idGrano, regionCosecha FROM vwMejorCalibracionPorGrano; PRINT 'OK: el barista puede leer la mejor calibración por grano'; END TRY
BEGIN CATCH PRINT 'FALLÓ: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY SELECT TOP 1 * FROM calificacion; PRINT 'FALLÓ: el barista pudo leer la tabla directamente'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC uspRankingBaristas; PRINT 'FALLÓ: el barista pudo ver el ranking'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
REVERT;
DROP USER usuarioPrueba;

PRINT '=== 4b) Permisos: un dueño ve todo y puede ver el ranking, y el barista no ===';
CREATE USER usuarioDuenio WITHOUT LOGIN;
ALTER ROLE rolDuenio ADD MEMBER usuarioDuenio;
EXECUTE AS USER = 'usuarioDuenio';
BEGIN TRY SELECT TOP 1 * FROM calificacion; EXEC uspRankingBaristas; PRINT 'OK: el dueño puede leer las tablas y ver el ranking de baristas'; END TRY
BEGIN CATCH PRINT 'FALLÓ: ' + ERROR_MESSAGE(); END CATCH
REVERT;
DROP USER usuarioDuenio;

PRINT '=== 5) Limpieza ===';
DELETE FROM calificacion WHERE idCalibracion >= @calibracion;
DELETE FROM calibracion WHERE idCalibracion >= @calibracion;
DECLARE @totalDespues INT = (SELECT (SELECT COUNT(*) FROM calibracion) + (SELECT COUNT(*) FROM calificacion) + (SELECT COUNT(*) FROM cliente));
PRINT CASE WHEN @totalAntes = @totalDespues THEN 'OK: la base quedó igual que antes' ELSE 'FALLÓ: quedaron datos de prueba' END;
