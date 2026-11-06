-- Cafetear · Prueba de funciones, vistas, triggers y permisos
-- No deja datos: lo que crea para probar lo borra al terminar.

USE Cafetear;
GO
SET NOCOUNT ON;

PRINT '=== 1) Funciones ===';
SELECT dbo.fn_RelacionExtraccion(18.0, 36.0) AS relacion_18g_36g, dbo.fn_RelacionExtraccion(0, 36.0) AS dosis_cero;
SELECT TOP 1 IDLote, nombre, dbo.fn_PuntajePromedioLote(IDLote) AS puntajePromedio FROM Lote WHERE IDLote = 1;
SELECT dbo.fn_DiasDesdeTostado(1, '2025-07-01') AS dias_desde_tostado_lote_1;
SELECT TOP 3 * FROM dbo.fn_CalibracionesDeBarista(1) ORDER BY fechaCalibracion DESC;

PRINT '=== 2) Vistas ===';
SELECT TOP 3 lote, regionCosecha, calibraciones, gramosUsados, calificaciones, puntajePromedio FROM vw_RendimientoPorLote WHERE calificaciones > 0 ORDER BY puntajePromedio DESC;
SELECT IDGrano, regionCosecha, IDCalibracion, tiempoExtraccion, relacionExtraccion, calificaciones, puntajePromedio FROM vw_MejorCalibracionPorGrano ORDER BY IDGrano;

PRINT '=== 3) Procedimientos de reporte ===';
EXEC usp_RankingBaristas @desde = '2026-01-01', @hasta = '2026-10-31';

PRINT '=== 4) Triggers: insertar directo en la tabla, sin pasar por un procedimiento ===';
DECLARE @lote INT = 1;
BEGIN TRY INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente) VALUES (99989, '2000-01-01T10:00:00', 4, 1); PRINT 'FALLÓ: aceptó una calificación sin calibración anterior'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente) VALUES (99988, '2999-01-01T10:00:00', 4, 1);
DECLARE @asignada INT = (SELECT IDCalibracion FROM Calificacion WHERE IDCalificacion = 99988);
DECLARE @esperada INT = (SELECT TOP 1 IDCalibracion FROM Calibracion ORDER BY fechaCalibracion DESC, IDCalibracion DESC);
PRINT CASE WHEN @asignada = @esperada THEN 'OK: asignó la calibración más próxima (' + CAST(@asignada AS VARCHAR(10)) + ')' ELSE 'FALLÓ: asignó otra calibración' END;
DELETE FROM Calificacion WHERE IDCalificacion = 99988;
BEGIN TRY INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente, IDCalibracion) VALUES (99990, '2026-10-01T10:00:00', 9, 1, 1); PRINT 'FALLÓ: aceptó un puntaje de 9'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY UPDATE Calificacion SET fecha = '2000-01-01T10:00:00' WHERE IDCalificacion = 1; PRINT 'FALLÓ: aceptó una calificación anterior a la calibración'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente) SELECT 99992, fecha, 4, IDCliente FROM Calificacion WHERE IDCalificacion = 1; PRINT 'FALLÓ: aceptó una calificación repetida'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO Calibracion (IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista, IDLote) VALUES (99993, '2000-01-01T08:00:00', 18, 28, 36, 1, @lote); PRINT 'FALLÓ: aceptó calibrar antes del ingreso del lote'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT INTO Calibracion (IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista, IDLote) VALUES (99994, GETDATE(), 9000, 28, 36, 1, @lote); PRINT 'FALLÓ: aceptó una dosis mayor al café que tiene el lote'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH

PRINT '=== 5) Permisos: un usuario barista solo puede usar procedimientos ===';
IF DATABASE_PRINCIPAL_ID('usuario_prueba') IS NOT NULL DROP USER usuario_prueba;
CREATE USER usuario_prueba WITHOUT LOGIN;
ALTER ROLE rol_barista ADD MEMBER usuario_prueba;
EXECUTE AS USER = 'usuario_prueba';
BEGIN TRY EXEC usp_Lote_Obtener @IDLote = 1; PRINT 'OK: el barista puede ejecutar usp_Lote_Obtener'; END TRY
BEGIN CATCH PRINT 'FALLÓ: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY SELECT TOP 1 * FROM Calificacion; PRINT 'FALLÓ: el barista pudo leer la tabla directamente'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Cliente_Eliminar @IDCliente = 1; PRINT 'FALLÓ: el barista pudo borrar un cliente'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
REVERT;
DROP USER usuario_prueba;
