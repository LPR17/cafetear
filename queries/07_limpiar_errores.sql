-- Cafetear · Limpiar los datos con errores
-- Ejecutar antes de agregar las restricciones UNIQUE y CHECK (enunciados 32 a 34), si no, el ALTER TABLE falla.

USE Cafetear;
GO

DELETE FROM Calificacion WHERE IDCalificacion BETWEEN 8001 AND 8199;
DELETE FROM Calibracion  WHERE IDCalibracion = 8001;
GO
