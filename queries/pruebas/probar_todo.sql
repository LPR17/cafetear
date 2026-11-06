-- Cafetear · Prueba de la función, las vistas, los procedimientos, los triggers y los permisos
-- Cada línea de la sección de errores debe decir OK. No deja datos: al terminar compara los totales con los del principio.

USE Cafetear;
GO
SET NOCOUNT ON;

DECLARE @totalAntes INT = (SELECT (SELECT COUNT(*) FROM Calibracion) + (SELECT COUNT(*) FROM Calificacion) + (SELECT COUNT(*) FROM Cliente));

PRINT '=== 1) Función y vistas ===';
SELECT dbo.fn_RelacionExtraccion(18.0, 36.0) AS relacion_18g_36g, dbo.fn_RelacionExtraccion(0, 36.0) AS dosis_cero;
SELECT TOP 3 IDCalibracion, dosis, rendimiento, relacionExtraccion, calificaciones, puntajePromedio FROM vw_PuntajePorCalibracion ORDER BY puntajePromedio DESC, calificaciones DESC;
SELECT IDGrano, regionCosecha, IDCalibracion, tiempoExtraccion, relacionExtraccion, calificaciones, puntajePromedio FROM vw_MejorCalibracionPorGrano ORDER BY IDGrano;

PRINT '=== 2) Procedimientos: registrar una calibración y una calificación, sin indicar la calibración ===';
EXEC usp_Calibracion_Crear @fechaCalibracion = '2026-12-01T08:00:00', @dosis = 18.0, @tiempoExtraccion = 28, @rendimiento = 36.0, @IDBarista = 1, @IDLote = 3;
DECLARE @calibracion INT = (SELECT MAX(IDCalibracion) FROM Calibracion);
EXEC usp_Calificacion_Crear @fecha = '2026-12-01T10:00:00', @puntaje = 5, @IDCliente = 1;
DECLARE @asignada INT = (SELECT IDCalibracion FROM Calificacion WHERE IDCalificacion = (SELECT MAX(IDCalificacion) FROM Calificacion));
PRINT CASE WHEN @asignada = @calibracion THEN 'OK: el trigger asignó la calibración más próxima (' + CAST(@asignada AS VARCHAR(10)) + ')' ELSE 'FALLÓ: asignó otra calibración' END;
EXEC usp_RankingBaristas @desde = '2026-01-01', @hasta = '2026-10-31';

PRINT '=== 3) Errores que se tienen que rechazar ===';
BEGIN TRY EXEC usp_Calibracion_Crear @fechaCalibracion = '2026-12-01T08:00:00', @dosis = 0, @tiempoExtraccion = 28, @rendimiento = 36, @IDBarista = 1, @IDLote = 3; PRINT 'FALLÓ: aceptó dosis cero'; END TRY
BEGIN CATCH PRINT 'OK (procedimiento): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calibracion_Crear @fechaCalibracion = '2000-01-01T08:00:00', @dosis = 18, @tiempoExtraccion = 28, @rendimiento = 36, @IDBarista = 1, @IDLote = 3; PRINT 'FALLÓ: aceptó una calibración anterior al ingreso del lote'; END TRY
BEGIN CATCH PRINT 'OK (procedimiento): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calificacion_Crear @fecha = '2026-12-01T11:00:00', @puntaje = 9, @IDCliente = 2; PRINT 'FALLÓ: aceptó un puntaje de 9'; END TRY
BEGIN CATCH PRINT 'OK (trigger): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calificacion_Crear @fecha = '2026-12-01T11:00:00', @puntaje = 3, @IDCliente = 1; PRINT 'FALLÓ: aceptó que el mismo cliente califique dos veces'; END TRY
BEGIN CATCH PRINT 'OK (trigger): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calificacion_Crear @fecha = '2000-01-01T10:00:00', @puntaje = 4, @IDCliente = 2; PRINT 'FALLÓ: aceptó una calificación sin calibración anterior'; END TRY
BEGIN CATCH PRINT 'OK (trigger): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY UPDATE Calificacion SET fecha = '2000-01-01T10:00:00' WHERE IDCalificacion = 1; PRINT 'FALLÓ: aceptó una calificación anterior a la calibración'; END TRY
BEGIN CATCH PRINT 'OK (trigger): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO Barista (DNI, nombre, apellido, experiencia) VALUES ('10000001', N'Prueba', N'Tipo', 'mucha'); PRINT 'FALLÓ: aceptó texto en un número'; END TRY
BEGIN CATCH PRINT 'OK (tipo de dato): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO Cliente (DNI, nombre, apellido) VALUES ('123456789012', N'Prueba', N'Largo'); PRINT 'FALLÓ: aceptó un DNI de más de 8 caracteres'; END TRY
BEGIN CATCH PRINT 'OK (tamaño): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO Cliente (DNI, nombre, apellido) VALUES ('10000002', NULL, N'SinNombre'); PRINT 'FALLÓ: aceptó un nombre vacío'; END TRY
BEGIN CATCH PRINT 'OK (NOT NULL): ' + ERROR_MESSAGE(); END CATCH
DECLARE @dniExistente VARCHAR(8) = (SELECT TOP 1 DNI FROM Cliente ORDER BY IDCliente);
BEGIN TRY INSERT INTO Cliente (DNI, nombre, apellido) VALUES (@dniExistente, N'Repetido', N'Repetido'); PRINT 'FALLÓ: aceptó un DNI repetido'; END TRY
BEGIN CATCH PRINT 'OK (UNIQUE): ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO Calibracion (IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista, IDLote) VALUES (99999, '2026-12-02T08:00:00', 18, 28, 36, 1, 9999); PRINT 'FALLÓ: aceptó un lote inexistente'; END TRY
BEGIN CATCH PRINT 'OK (clave foránea): ' + ERROR_MESSAGE(); END CATCH

PRINT '=== 4) Permisos: un usuario barista solo puede usar procedimientos ===';
IF DATABASE_PRINCIPAL_ID('usuario_prueba') IS NOT NULL DROP USER usuario_prueba;
CREATE USER usuario_prueba WITHOUT LOGIN;
ALTER ROLE rol_barista ADD MEMBER usuario_prueba;
EXECUTE AS USER = 'usuario_prueba';
BEGIN TRY EXEC usp_Calibracion_Crear @fechaCalibracion = '2026-12-03T08:00:00', @dosis = 18.0, @tiempoExtraccion = 28, @rendimiento = 36.0, @IDBarista = 1, @IDLote = 3; PRINT 'OK: el barista puede registrar una calibración con el procedimiento, sin permiso sobre la tabla'; END TRY
BEGIN CATCH PRINT 'FALLÓ: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY SELECT TOP 1 IDGrano, regionCosecha FROM vw_MejorCalibracionPorGrano; PRINT 'OK: el barista puede leer la mejor calibración por grano'; END TRY
BEGIN CATCH PRINT 'FALLÓ: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY SELECT TOP 1 * FROM Calificacion; PRINT 'FALLÓ: el barista pudo leer la tabla directamente'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_RankingBaristas; PRINT 'FALLÓ: el barista pudo ver el ranking'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
REVERT;
DROP USER usuario_prueba;

PRINT '=== 5) Limpieza ===';
DELETE FROM Calificacion WHERE IDCalibracion = @calibracion;
DELETE FROM Calibracion WHERE IDCalibracion >= @calibracion;
DECLARE @totalDespues INT = (SELECT (SELECT COUNT(*) FROM Calibracion) + (SELECT COUNT(*) FROM Calificacion) + (SELECT COUNT(*) FROM Cliente));
PRINT CASE WHEN @totalAntes = @totalDespues THEN 'OK: la base quedó igual que antes' ELSE 'FALLÓ: quedaron datos de prueba' END;
