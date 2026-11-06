-- Cafetear · Crear la base y las tablas
-- Ejecutar primero. Borra y vuelve a crear todo, así que sirve para empezar de cero.
-- Las restricciones CHECK y UNIQUE de los enunciados 32 a 34 NO están acá a propósito: son parte del ejercicio.

IF DB_ID('Cafetear') IS NULL
    CREATE DATABASE Cafetear;
GO
USE Cafetear;
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
    IDProveedor INT IDENTITY(1,1) PRIMARY KEY,
    CUIT        VARCHAR(13)  NOT NULL UNIQUE,
    razonSocial VARCHAR(100) NOT NULL
);

CREATE TABLE Grano (
    IDGrano       INT PRIMARY KEY,
    alturaCosecha INT          NOT NULL,   -- metros sobre el nivel del mar
    regionCosecha VARCHAR(60)  NOT NULL,
    fechaCosecha  DATE         NOT NULL
);

CREATE TABLE Lote (
    IDLote       INT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,   -- nombre de la finca, microlote o proceso
    IDGrano      INT NOT NULL REFERENCES Grano(IDGrano),
    IDProveedor  INT NOT NULL REFERENCES Proveedor(IDProveedor),
    fechaIngreso DATE NOT NULL,
    fechaTostado DATE NOT NULL,
    cantidadKg   DECIMAL(6,2) NOT NULL
);

CREATE TABLE Barista (
    IDBarista   INT IDENTITY(1,1) PRIMARY KEY,
    DNI         VARCHAR(8)  NOT NULL UNIQUE,
    nombre      VARCHAR(50) NOT NULL,
    apellido    VARCHAR(50) NOT NULL,
    experiencia INT         NOT NULL       -- años de experiencia
);

CREATE TABLE Cliente (
    IDCliente INT IDENTITY(1,1) PRIMARY KEY,
    DNI       VARCHAR(8)  NOT NULL UNIQUE,
    nombre    VARCHAR(50) NOT NULL,
    apellido  VARCHAR(50) NOT NULL
);

CREATE TABLE Calibracion (
    IDCalibracion    INT PRIMARY KEY,
    fechaCalibracion DATETIME     NOT NULL,
    dosis            DECIMAL(5,1) NOT NULL,   -- gramos de café molido
    tiempoExtraccion INT          NOT NULL,   -- segundos
    rendimiento      DECIMAL(5,1) NOT NULL,   -- gramos de café en la taza
    IDBarista        INT NOT NULL REFERENCES Barista(IDBarista),
    IDLote           INT NOT NULL REFERENCES Lote(IDLote)
);

CREATE TABLE Calificacion (
    IDCalificacion INT PRIMARY KEY,
    fecha          DATETIME NOT NULL,
    puntaje        INT      NOT NULL,
    IDCliente      INT NOT NULL REFERENCES Cliente(IDCliente),
    IDCalibracion  INT NOT NULL REFERENCES Calibracion(IDCalibracion)
);
GO
