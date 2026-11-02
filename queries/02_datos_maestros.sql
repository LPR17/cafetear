-- Cafetear · Datos maestros
-- Proveedor, Grano, Lote, Barista y Cliente. Ejecutar después de 01 y antes de 03.

USE Cafetear;
GO
SET NOCOUNT ON;


-- Proveedor (los CUIT son inventados)

INSERT INTO Proveedor (CUIT, razonSocial) VALUES
    (N'30-71458230-4', N'Café Andino S.R.L.'),
    (N'30-70912345-1', N'Tostadores del Sur S.A.'),
    (N'30-71203344-7', N'Finca Los Altos S.A.'),
    (N'33-70655120-9', N'Origen Colombia Import S.A.'),
    (N'30-71877650-2', N'Brasil Café Trading S.R.L.'),
    (N'30-71562918-5', N'Sidamo Importaciones S.R.L.');


-- Grano: el tipo de café y su origen

INSERT INTO Grano (IDGrano, alturaCosecha, regionCosecha, fechaCosecha) VALUES
    (1, 1800, N'Huila, Colombia', '2025-01-20'),
    (2, 1100, N'Cerrado Mineiro, Brasil', '2025-03-10'),
    (3, 2000, N'Yirgacheffe, Etiopía', '2025-02-05'),
    (4, 1600, N'Antigua, Guatemala', '2025-03-12'),
    (5, 1000, N'Sul de Minas, Brasil', '2025-04-25'),
    (6, 2100, N'Nariño, Colombia', '2025-01-30'),
    (7, 1900, N'Sidamo, Etiopía', '2025-02-18'),
    (8, 1700, N'Tarrazú, Costa Rica', '2025-03-02');


-- Lote: una bolsa concreta de café, con su nombre (el lote 40 queda sin calibrar a propósito)

INSERT INTO Lote (IDLote, nombre, IDGrano, IDProveedor, fechaIngreso, fechaTostado, cantidadKg) VALUES
    (1, N'La Esperanza Lavado', 1, 1, '2025-05-20', '2025-05-17', 6.00),
    (2, N'Finca Los Volcanes Lavado', 4, 2, '2025-06-02', '2025-05-25', 8.00),
    (3, N'Guji Natural Lote 7', 7, 3, '2025-06-15', '2025-06-08', 10.00),
    (4, N'Fazenda Santa Luzia Natural', 2, 4, '2025-06-28', '2025-06-22', 12.00),
    (5, N'Fazenda Boa Vista Natural', 5, 5, '2025-07-11', '2025-07-06', 15.00),
    (6, N'Finca La Pastora Honey', 8, 6, '2025-07-24', '2025-07-20', 6.00),
    (7, N'Kochere Lavado', 3, 1, '2025-08-06', '2025-08-03', 8.00),
    (8, N'La Unión Lavado', 6, 2, '2025-08-19', '2025-08-11', 10.00),
    (9, N'Pink Bourbon Microlote', 1, 3, '2025-09-01', '2025-08-25', 12.00),
    (10, N'Finca San Rafael Honey', 4, 4, '2025-09-14', '2025-09-08', 15.00),
    (11, N'Bensa Lavado', 7, 5, '2025-09-27', '2025-09-22', 6.00),
    (12, N'Cerrado Natural', 2, 6, '2025-10-10', '2025-10-06', 8.00),
    (13, N'Sul de Minas Pulped Natural', 5, 1, '2025-10-23', '2025-10-20', 10.00),
    (14, N'Dota Microlote Anaeróbico', 8, 2, '2025-11-05', '2025-10-28', 12.00),
    (15, N'Aricha Natural', 3, 3, '2025-11-18', '2025-11-11', 15.00),
    (16, N'Cooperativa Cumbal Lavado', 6, 4, '2025-12-01', '2025-11-25', 6.00),
    (17, N'El Mirador Honey', 1, 5, '2025-12-14', '2025-12-09', 8.00),
    (18, N'El Pilar Lavado', 4, 6, '2025-12-27', '2025-12-23', 10.00),
    (19, N'Shantawene Natural', 7, 1, '2026-01-09', '2026-01-06', 12.00),
    (20, N'Fazenda Primavera Pulped', 2, 2, '2026-01-22', '2026-01-14', 15.00),
    (21, N'Serra Verde Natural', 5, 3, '2026-02-04', '2026-01-28', 6.00),
    (22, N'Santa María Lavado', 8, 4, '2026-02-17', '2026-02-11', 8.00),
    (23, N'Konga Lavado', 3, 5, '2026-03-02', '2026-02-25', 10.00),
    (24, N'Buesaco Lavado', 6, 6, '2026-03-15', '2026-03-11', 12.00),
    (25, N'Villa Rica Natural', 1, 1, '2026-03-28', '2026-03-25', 15.00),
    (26, N'Hunapú Natural', 4, 2, '2026-04-10', '2026-04-02', 6.00),
    (27, N'Hambela Lavado', 7, 3, '2026-04-23', '2026-04-16', 8.00),
    (28, N'Serra Dourada Natural', 2, 4, '2026-05-06', '2026-04-30', 10.00),
    (29, N'Fazenda Alvorada Honey', 5, 5, '2026-05-19', '2026-05-14', 12.00),
    (30, N'San Marcos Honey', 8, 6, '2026-06-01', '2026-05-28', 15.00),
    (31, N'Idido Natural', 3, 1, '2026-06-14', '2026-06-11', 6.00),
    (32, N'Génova Honey', 6, 2, '2026-06-27', '2026-06-19', 8.00),
    (33, N'Cerro Azul Lavado', 1, 3, '2026-07-10', '2026-07-03', 10.00),
    (34, N'Santa Clara Lavado', 4, 4, '2026-07-23', '2026-07-17', 12.00),
    (35, N'Aleta Wondo Honey', 7, 5, '2026-08-05', '2026-07-31', 15.00),
    (36, N'Boa Esperança Honey', 2, 6, '2026-08-18', '2026-08-14', 6.00),
    (37, N'São João Natural', 5, 1, '2026-08-31', '2026-08-28', 8.00),
    (38, N'León Cortés Natural', 8, 2, '2026-09-13', '2026-09-05', 10.00),
    (39, N'Gedeb Anaeróbico', 3, 3, '2026-09-26', '2026-09-19', 12.00),
    (40, N'El Tablón Natural', 6, 4, '2026-10-09', '2026-10-03', 15.00);


-- Barista (IDENTITY: los IDs salen 1 a 7 si la tabla estaba vacía)

INSERT INTO Barista (DNI, nombre, apellido, experiencia) VALUES
    (N'28450121', N'Martina', N'Ríos', 8),
    (N'31220987', N'Lucas', N'Benítez', 5),
    (N'36874512', N'Sofía', N'Carrizo', 3),
    (N'41093376', N'Mateo', N'Duarte', 1),
    (N'33781450', N'Valentina', N'Pereyra', 6),
    (N'39665208', N'Julián', N'Acosta', 2),
    (N'35118843', N'Camila', N'Ferrer', 4);


-- Cliente (IDENTITY: los IDs salen 1 a 60 si la tabla estaba vacía)

INSERT INTO Cliente (DNI, nombre, apellido) VALUES
    (N'41906502', N'Violeta', N'Torres'),
    (N'38858468', N'Belén', N'Molina'),
    (N'31569475', N'Olivia', N'Álvarez'),
    (N'45432390', N'Emilia', N'Castro'),
    (N'35710345', N'Olivia', N'Torres'),
    (N'39441340', N'Yamila', N'Sánchez'),
    (N'33512522', N'Andrés', N'Ruiz'),
    (N'30076823', N'Ximena', N'Núñez'),
    (N'39384203', N'Zoe', N'López'),
    (N'38230522', N'Inés', N'Castro'),
    (N'26919534', N'Tamara', N'Molina'),
    (N'33103829', N'Olivia', N'Silva'),
    (N'32781603', N'Nicolás', N'Romero'),
    (N'28940845', N'Inés', N'Álvarez'),
    (N'38214083', N'Pablo', N'Romero'),
    (N'31756123', N'Yamila', N'Molina'),
    (N'40803101', N'Emilia', N'Romero'),
    (N'28498817', N'Cristian', N'Fernández'),
    (N'32562866', N'Leandro', N'López'),
    (N'36167187', N'Violeta', N'Sánchez'),
    (N'43634918', N'Gabriela', N'Herrera'),
    (N'27507611', N'Daniela', N'Núñez'),
    (N'32200498', N'Ximena', N'López'),
    (N'26839758', N'Gabriela', N'Rodríguez'),
    (N'34489468', N'Joaquín', N'Martínez'),
    (N'45435428', N'Agustina', N'Ortiz'),
    (N'33396819', N'Violeta', N'Romero'),
    (N'30555814', N'Santiago', N'Fernández'),
    (N'38754606', N'Karina', N'Torres'),
    (N'37294740', N'Cristian', N'Herrera'),
    (N'30779861', N'Carolina', N'Pérez'),
    (N'30669763', N'Hernán', N'Medina'),
    (N'41553984', N'Federico', N'Castro'),
    (N'40977683', N'Diego', N'Ruiz'),
    (N'28092307', N'Gabriela', N'Martínez'),
    (N'27381546', N'Carolina', N'Fernández'),
    (N'30255918', N'Emilia', N'Torres'),
    (N'34323805', N'Emilia', N'Núñez'),
    (N'27416630', N'Joaquín', N'Díaz'),
    (N'31177528', N'Ximena', N'Molina'),
    (N'45917178', N'Diego', N'Torres'),
    (N'40337625', N'Violeta', N'Fernández'),
    (N'33793102', N'Violeta', N'Núñez'),
    (N'38021361', N'Bruno', N'López'),
    (N'28331655', N'Inés', N'Sánchez'),
    (N'28548056', N'Gabriela', N'Silva'),
    (N'42153065', N'Tamara', N'Martínez'),
    (N'38232313', N'Cristian', N'Gómez'),
    (N'44207127', N'Gabriela', N'Molina'),
    (N'39056448', N'Yamila', N'Herrera'),
    (N'44842640', N'Emilia', N'Fernández'),
    (N'39910389', N'Milagros', N'Medina'),
    (N'37507331', N'Romina', N'Núñez'),
    (N'38163101', N'Emilia', N'Martínez'),
    (N'24493900', N'Diego', N'Díaz'),
    (N'40385160', N'Santiago', N'Medina'),
    (N'44051588', N'Federico', N'Suárez'),
    (N'25355340', N'Ximena', N'Castro'),
    (N'41265721', N'Daniela', N'Gómez'),
    (N'43960303', N'Romina', N'Castro');
