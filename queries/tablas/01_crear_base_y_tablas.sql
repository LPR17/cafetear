-- Cafetear · Crear la base y las tablas
-- Ejecutar primero. Borra y vuelve a crear todo, así que sirve para empezar de cero.
-- Las restricciones CHECK y UNIQUE de los enunciados 32 a 34 NO están acá a propósito: son parte del ejercicio.

IF DB_ID('cafetear') IS NULL
    CREATE DATABASE cafetear;
GO
USE cafetear;
GO

DROP TABLE IF EXISTS Calificacion;
DROP TABLE IF EXISTS Calibracion;
DROP TABLE IF EXISTS Lote;
DROP TABLE IF EXISTS Grano;
DROP TABLE IF EXISTS Proveedor;
DROP TABLE IF EXISTS Barista;
DROP TABLE IF EXISTS Cliente;
GO

CREATE TABLE Proveedor (
    idProveedor INT IDENTITY(1,1) PRIMARY KEY,
    cuit        VARCHAR(13)  NOT NULL UNIQUE,
    razonSocial VARCHAR(100) NOT NULL
);

CREATE TABLE Grano (
    idGrano       INT PRIMARY KEY,
    alturaCosecha INT          NOT NULL,   -- metros sobre el nivel del mar
    regionCosecha VARCHAR(60)  NOT NULL,
    fechaCosecha  DATE         NOT NULL
);

CREATE TABLE Lote (
    idLote       INT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,   -- nombre de la finca, microlote o proceso
    idGrano      INT NOT NULL REFERENCES Grano(idGrano),
    idProveedor  INT NOT NULL REFERENCES Proveedor(idProveedor),
    fechaIngreso DATE NOT NULL,
    fechaTostado DATE NOT NULL,
    cantidadKg   DECIMAL(6,2) NOT NULL
);

CREATE TABLE Barista (
    idBarista   INT IDENTITY(1,1) PRIMARY KEY,
    dni         VARCHAR(8)  NOT NULL UNIQUE,
    nombre      VARCHAR(50) NOT NULL,
    apellido    VARCHAR(50) NOT NULL,
    experiencia INT         NOT NULL       -- años de experiencia
);

CREATE TABLE Cliente (
    idCliente INT IDENTITY(1,1) PRIMARY KEY,
    dni       VARCHAR(8)  NOT NULL UNIQUE,
    nombre    VARCHAR(50) NOT NULL,
    apellido  VARCHAR(50) NOT NULL
);

CREATE TABLE Calibracion (
    idCalibracion    INT PRIMARY KEY,
    fechaCalibracion DATETIME     NOT NULL,
    dosis            DECIMAL(5,1) NOT NULL,   -- gramos de café molido
    tiempoExtraccion INT          NOT NULL,   -- segundos
    rendimiento      DECIMAL(5,1) NOT NULL,   -- gramos de café en la taza
    idBarista        INT NOT NULL REFERENCES Barista(idBarista),
    idLote           INT NOT NULL REFERENCES Lote(idLote)
);

CREATE TABLE Calificacion (
    idCalificacion INT PRIMARY KEY,
    fecha          DATETIME NOT NULL,
    puntaje        INT      NOT NULL,
    idCliente      INT NOT NULL REFERENCES Cliente(idCliente),
    idCalibracion  INT NOT NULL REFERENCES Calibracion(idCalibracion)
);

-- Índices: SQL Server no los crea sobre las claves foráneas. Estos aceleran los joins y los filtros más usados.
CREATE INDEX ixCalibracionIdLote ON Calibracion (idLote);
CREATE INDEX ixCalibracionFecha ON Calibracion (fechaCalibracion);
-- INCLUDE guarda el puntaje dentro del índice: el promedio de una calibración se calcula sin leer la tabla.
CREATE INDEX ixCalificacionIdCalibracion ON Calificacion (idCalibracion) INCLUDE (puntaje);
GO
