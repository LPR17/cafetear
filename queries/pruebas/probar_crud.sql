-- Cafetear · Prueba de los procedimientos de CRUD
-- Crea un registro de cada tabla, lo lee, lo modifica y lo borra. Después prueba que los errores se rechacen.
-- No deja datos: al terminar compara los totales con los del principio.

USE Cafetear;
GO
SET NOCOUNT ON;

DECLARE @totalAntes INT = (SELECT (SELECT COUNT(*) FROM Proveedor) + (SELECT COUNT(*) FROM Grano) + (SELECT COUNT(*) FROM Lote)
                                + (SELECT COUNT(*) FROM Barista) + (SELECT COUNT(*) FROM Cliente)
                                + (SELECT COUNT(*) FROM Calibracion) + (SELECT COUNT(*) FROM Calificacion));

PRINT '=== 1) Crear: cada procedimiento devuelve el ID nuevo ===';
EXEC usp_Proveedor_Crear   @CUIT = '30-99999999-9', @razonSocial = N'Proveedor de prueba';
EXEC usp_Grano_Crear       @alturaCosecha = 1700, @regionCosecha = N'Región de prueba', @fechaCosecha = '2026-01-10';
DECLARE @proveedor INT = (SELECT IDProveedor FROM Proveedor WHERE CUIT = '30-99999999-9');
DECLARE @grano INT = (SELECT IDGrano FROM Grano WHERE regionCosecha = N'Región de prueba');
EXEC usp_Lote_Crear        @nombre = N'Lote de prueba', @IDGrano = @grano, @IDProveedor = @proveedor,
                           @fechaIngreso = '2026-10-01', @fechaTostado = '2026-09-27', @cantidadKg = 5;
EXEC usp_Barista_Crear     @DNI = '10000001', @nombre = N'Barista', @apellido = N'De Prueba', @experiencia = 2;
EXEC usp_Cliente_Crear     @DNI = '10000002', @nombre = N'Cliente', @apellido = N'De Prueba';
DECLARE @lote INT = (SELECT IDLote FROM Lote WHERE nombre = N'Lote de prueba');
DECLARE @barista INT = (SELECT IDBarista FROM Barista WHERE DNI = '10000001');
DECLARE @cliente INT = (SELECT IDCliente FROM Cliente WHERE DNI = '10000002');
EXEC usp_Calibracion_Crear @fechaCalibracion = '2026-10-05T08:00:00', @dosis = 18.0, @tiempoExtraccion = 28, @rendimiento = 36.0,
                           @IDBarista = @barista, @IDLote = @lote;
DECLARE @calibracion INT = (SELECT IDCalibracion FROM Calibracion WHERE IDLote = @lote);
EXEC usp_Calificacion_Crear @fecha = '2026-10-05T10:00:00', @puntaje = 5, @IDCliente = @cliente, @IDCalibracion = @calibracion;
DECLARE @calificacion INT = (SELECT IDCalificacion FROM Calificacion WHERE IDCalibracion = @calibracion);

PRINT '=== 2) Obtener y listar ===';
EXEC usp_Proveedor_Obtener @IDProveedor = @proveedor;
EXEC usp_Calibracion_Obtener @IDCalibracion = @calibracion;
EXEC usp_Calificacion_Obtener @IDCalificacion = @calificacion;
DECLARE @baristas INT = (SELECT COUNT(*) FROM Barista);
PRINT 'Listar devuelve todas las filas: ' + CAST(@baristas AS VARCHAR(10)) + ' baristas en la tabla.';
EXEC usp_Barista_Listar;

PRINT '=== 3) Actualizar ===';
EXEC usp_Proveedor_Actualizar @IDProveedor = @proveedor, @CUIT = '30-99999999-9', @razonSocial = N'Proveedor de prueba S.A.';
EXEC usp_Calificacion_Actualizar @IDCalificacion = @calificacion, @fecha = '2026-10-05T10:00:00', @puntaje = 4,
                                @IDCliente = @cliente, @IDCalibracion = @calibracion;
EXEC usp_Calificacion_Obtener @IDCalificacion = @calificacion;

PRINT '=== 4) Errores que se tienen que rechazar (cada línea debe decir OK) ===';
BEGIN TRY EXEC usp_Proveedor_Crear @CUIT = '30-99999999-9', @razonSocial = N'Repetido'; PRINT 'FALLÓ: aceptó un CUIT repetido'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Lote_Crear @nombre = N'Sin grano', @IDGrano = 9999, @IDProveedor = @proveedor, @fechaIngreso = '2026-10-01', @fechaTostado = '2026-09-27', @cantidadKg = 5; PRINT 'FALLÓ: aceptó un grano inexistente'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Lote_Crear @nombre = N'Sin kilos', @IDGrano = @grano, @IDProveedor = @proveedor, @fechaIngreso = '2026-10-01', @fechaTostado = '2026-09-27', @cantidadKg = 0; PRINT 'FALLÓ: aceptó cero kilos'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Barista_Crear @DNI = '10000003', @nombre = N'X', @apellido = N'Y', @experiencia = -1; PRINT 'FALLÓ: aceptó experiencia negativa'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Cliente_Crear @DNI = '10000002', @nombre = N'X', @apellido = N'Y'; PRINT 'FALLÓ: aceptó un DNI repetido'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calibracion_Crear @fechaCalibracion = '2026-10-05T08:00:00', @dosis = 0, @tiempoExtraccion = 28, @rendimiento = 36, @IDBarista = @barista, @IDLote = @lote; PRINT 'FALLÓ: aceptó dosis cero'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calibracion_Crear @fechaCalibracion = '2026-09-01T08:00:00', @dosis = 18, @tiempoExtraccion = 28, @rendimiento = 36, @IDBarista = @barista, @IDLote = @lote; PRINT 'FALLÓ: aceptó una calibración anterior al ingreso del lote'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calificacion_Crear @fecha = '2026-10-05T11:00:00', @puntaje = 6, @IDCliente = @cliente, @IDCalibracion = @calibracion; PRINT 'FALLÓ: aceptó un puntaje de 6'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calificacion_Crear @fecha = '2026-10-05T11:00:00', @puntaje = 3, @IDCliente = @cliente, @IDCalibracion = @calibracion; PRINT 'FALLÓ: aceptó que el mismo cliente califique dos veces'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Proveedor_Eliminar @IDProveedor = @proveedor; PRINT 'FALLÓ: borró un proveedor con lotes'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY EXEC usp_Calibracion_Eliminar @IDCalibracion = @calibracion; PRINT 'FALLÓ: borró una calibración con calificaciones'; END TRY
BEGIN CATCH PRINT 'OK: ' + ERROR_MESSAGE(); END CATCH

PRINT '=== 5) Eliminar: se borra todo lo creado, en el orden inverso ===';
EXEC usp_Calificacion_Eliminar @IDCalificacion = @calificacion;
EXEC usp_Calibracion_Eliminar  @IDCalibracion = @calibracion;
EXEC usp_Cliente_Eliminar      @IDCliente = @cliente;
EXEC usp_Barista_Eliminar      @IDBarista = @barista;
EXEC usp_Lote_Eliminar         @IDLote = @lote;
EXEC usp_Grano_Eliminar        @IDGrano = @grano;
EXEC usp_Proveedor_Eliminar    @IDProveedor = @proveedor;

DECLARE @totalDespues INT = (SELECT (SELECT COUNT(*) FROM Proveedor) + (SELECT COUNT(*) FROM Grano) + (SELECT COUNT(*) FROM Lote)
                                  + (SELECT COUNT(*) FROM Barista) + (SELECT COUNT(*) FROM Cliente)
                                  + (SELECT COUNT(*) FROM Calibracion) + (SELECT COUNT(*) FROM Calificacion));
PRINT CASE WHEN @totalAntes = @totalDespues
           THEN 'OK: la base quedó igual que antes (' + CAST(@totalDespues AS VARCHAR(10)) + ' filas en total).'
           ELSE 'FALLÓ: quedaron registros de prueba (antes ' + CAST(@totalAntes AS VARCHAR(10)) + ', después ' + CAST(@totalDespues AS VARCHAR(10)) + ').' END;
