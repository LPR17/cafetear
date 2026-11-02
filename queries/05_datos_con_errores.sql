-- Cafetear · Datos con errores a propósito
-- Sirve para los enunciados 27 y 28. Ejecutar 07 antes de agregar las restricciones de los enunciados 32 a 34.

USE Cafetear;
GO
SET NOCOUNT ON;


-- Calificaciones con fecha anterior a la de su calibración (enunciado 27)

INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente, IDCalibracion) VALUES
    (8001, '2026-09-08T08:10:00', 4, 50, 185),
    (8002, '2026-10-12T17:59:00', 4, 51, 201),
    (8003, '2026-09-23T07:13:00', 4, 52, 192);


-- Una calibración con fecha anterior al ingreso de su lote (enunciado 27)

INSERT INTO Calibracion (IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista, IDLote) VALUES
    (8001, '2026-09-08T08:00:00', 18.0, 28, 36.0, 3, 38);


-- El mismo cliente califica dos veces la misma calibración (enunciado 28)

INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente, IDCalibracion) VALUES
    (8101, '2026-02-03T20:07:00', 3, 4, 100),
    (8102, '2025-08-12T10:21:00', 2, 49, 36),
    (8103, '2026-02-03T19:00:00', 2, 8, 100);
