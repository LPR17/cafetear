-- Cafetear · Calibraciones de hoy
-- Para el enunciado 31 (vista de calibraciones de hoy). Se puede ejecutar todos los días: borra y vuelve a cargar las de hoy.

USE Cafetear;
GO
SET NOCOUNT ON;

DELETE FROM Calificacion WHERE IDCalificacion BETWEEN 9001 AND 9099;
DELETE FROM Calibracion  WHERE IDCalibracion  BETWEEN 9001 AND 9099;

DECLARE @hoy DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);

INSERT INTO Calibracion (IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista, IDLote) VALUES
    (9001, DATEADD(MINUTE, 420, @hoy), 18.0, 22, 33.0, 1, 39),
    (9002, DATEADD(MINUTE, 432, @hoy), 18.0, 25, 34.5, 1, 39),
    (9003, DATEADD(MINUTE, 444, @hoy), 18.0, 28, 36.0, 1, 39),
    (9004, DATEADD(MINUTE, 450, @hoy), 17.5, 33, 38.0, 4, 37),
    (9005, DATEADD(MINUTE, 462, @hoy), 17.5, 30, 36.5, 4, 37),
    (9006, DATEADD(MINUTE, 474, @hoy), 17.5, 27, 35.0, 4, 37),
    (9007, DATEADD(MINUTE, 480, @hoy), 19.0, 29, 38.5, 2, 38),
    (9008, DATEADD(MINUTE, 492, @hoy), 19.0, 28, 38.0, 2, 38);

INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente, IDCalibracion) VALUES
    (9001, DATEADD(MINUTE, 520, @hoy), 5, 1, 9003),
    (9002, DATEADD(MINUTE, 535, @hoy), 4, 2, 9003),
    (9003, DATEADD(MINUTE, 560, @hoy), 4, 12, 9006),
    (9004, DATEADD(MINUTE, 575, @hoy), 3, 25, 9006),
    (9005, DATEADD(MINUTE, 590, @hoy), 5, 7, 9008);
