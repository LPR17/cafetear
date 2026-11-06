-- Cafetear · Crear la base y las tablas
-- Ejecutar primero. Borra y vuelve a crear todo, así que sirve para empezar de cero.
-- Las restricciones CHECK y UNIQUE de los enunciados 32 a 34 NO están acá a propósito: son parte del ejercicio.

IF DB_ID('cafetear') IS NULL
    CREATE DATABASE cafetear;
GO
USE cafetear;
GO

DROP TABLE IF EXISTS calificacion;
DROP TABLE IF EXISTS calibracion;
DROP TABLE IF EXISTS lote;
DROP TABLE IF EXISTS grano;
DROP TABLE IF EXISTS proveedor;
DROP TABLE IF EXISTS barista;
DROP TABLE IF EXISTS cliente;
GO

CREATE TABLE proveedor (
    idProveedor INT IDENTITY(1,1) PRIMARY KEY,
    cuit        VARCHAR(13)  NOT NULL UNIQUE,
    razonSocial VARCHAR(100) NOT NULL
);

CREATE TABLE grano (
    idGrano       INT PRIMARY KEY,
    alturaCosecha INT          NOT NULL,   -- metros sobre el nivel del mar
    regionCosecha VARCHAR(60)  NOT NULL,
    fechaCosecha  DATE         NOT NULL
);

CREATE TABLE lote (
    idLote       INT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,   -- nombre de la finca, microlote o proceso
    idGrano      INT NOT NULL REFERENCES grano(idGrano),
    idProveedor  INT NOT NULL REFERENCES proveedor(idProveedor),
    fechaIngreso DATE NOT NULL,
    fechaTostado DATE NOT NULL,
    cantidadKg   DECIMAL(6,2) NOT NULL
);

CREATE TABLE barista (
    idBarista   INT IDENTITY(1,1) PRIMARY KEY,
    dni         VARCHAR(8)  NOT NULL UNIQUE,
    nombre      VARCHAR(50) NOT NULL,
    apellido    VARCHAR(50) NOT NULL,
    experiencia INT         NOT NULL       -- años de experiencia
);

CREATE TABLE cliente (
    idCliente INT IDENTITY(1,1) PRIMARY KEY,
    dni       VARCHAR(8)  NOT NULL UNIQUE,
    nombre    VARCHAR(50) NOT NULL,
    apellido  VARCHAR(50) NOT NULL
);

CREATE TABLE calibracion (
    idCalibracion    INT PRIMARY KEY,
    fechaCalibracion DATETIME     NOT NULL,
    dosis            DECIMAL(5,1) NOT NULL,   -- gramos de café molido
    tiempoExtraccion INT          NOT NULL,   -- segundos
    rendimiento      DECIMAL(5,1) NOT NULL,   -- gramos de café en la taza
    idBarista        INT NOT NULL REFERENCES barista(idBarista),
    idLote           INT NOT NULL REFERENCES lote(idLote)
);

CREATE TABLE calificacion (
    idCalificacion INT PRIMARY KEY,
    fecha          DATETIME NOT NULL,
    puntaje        INT      NOT NULL,
    idCliente      INT NOT NULL REFERENCES cliente(idCliente),
    idCalibracion  INT NOT NULL REFERENCES calibracion(idCalibracion)
);

-- Índices: SQL Server no los crea sobre las claves foráneas. Estos aceleran los joins y los filtros más usados.
CREATE INDEX ixCalibracionIdLote ON calibracion (idLote);
CREATE INDEX ixCalibracionFecha ON calibracion (fechaCalibracion);
-- INCLUDE guarda el puntaje dentro del índice: el promedio de una calibración se calcula sin leer la tabla.
CREATE INDEX ixCalificacionIdCalibracion ON calificacion (idCalibracion) INCLUDE (puntaje);
GO
