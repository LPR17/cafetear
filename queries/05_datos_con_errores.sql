-- Cafetear · Datos con errores a propósito
-- Sirve para los enunciados 27 y 28. Ejecutar 07 antes de agregar las restricciones de los enunciados 32 a 34.

USE Cafetear;
GO
SET NOCOUNT ON;


-- Calificaciones con fecha anterior a la de su calibración (enunciado 27)

INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente, IDCalibracion) VALUES
    (8001, '2026-09-29T09:38:00', 4, 50, 208),
    (8002, '2026-09-27T07:53:00', 4, 51, 207),
    (8003, '2026-10-24T08:37:00', 4, 52, 220);


-- Una calibración con fecha anterior al ingreso de su lote (enunciado 27)

INSERT INTO Calibracion (IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista, IDLote) VALUES
    (8001, '2026-09-08T08:00:00', 18.0, 28, 36.0, 3, 38);


-- El mismo cliente califica dos veces la misma calibración (enunciado 28)

INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente, IDCalibracion) VALUES
    (8101, '2026-10-22T19:14:00', 2, 6, 218),
    (8102, '2026-03-27T20:17:00', 2, 2, 138),
    (8103, '2026-03-26T14:26:00', 3, 1, 135);
