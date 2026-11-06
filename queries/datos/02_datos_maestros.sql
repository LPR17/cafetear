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
    (N'30-71562918-5', N'Sidamo Importaciones S.R.L.'),
    (N'30-71099321-6', N'Cafés del Valle S.A.'),
    (N'30-70744810-3', N'Importadora Tierra Alta S.R.L.'),
    (N'33-71320485-9', N'Granos del Mundo S.A.'),
    (N'30-71688104-2', N'Selecta Cafés S.R.L.');


-- Grano: el tipo de café y su origen

INSERT INTO Grano (IDGrano, alturaCosecha, regionCosecha, fechaCosecha) VALUES
    (1, 1800, N'Huila, Colombia', '2025-01-20'),
    (2, 1100, N'Cerrado Mineiro, Brasil', '2025-03-10'),
    (3, 2000, N'Yirgacheffe, Etiopía', '2025-02-05'),
    (4, 1600, N'Antigua, Guatemala', '2025-03-12'),
    (5, 1000, N'Sul de Minas, Brasil', '2025-04-25'),
    (6, 2100, N'Nariño, Colombia', '2025-01-30'),
    (7, 1900, N'Sidamo, Etiopía', '2025-02-18'),
    (8, 1700, N'Tarrazú, Costa Rica', '2025-03-02'),
    (9, 1950, N'Huila, Colombia', '2025-06-18'),
    (10, 2150, N'Yirgacheffe, Etiopía', '2025-05-22');


-- Lote: una bolsa concreta de café, con su nombre (el lote 40 queda sin calibrar a propósito)

INSERT INTO Lote (IDLote, nombre, IDGrano, IDProveedor, fechaIngreso, fechaTostado, cantidadKg) VALUES
    (1, N'La Esperanza Lavado', 1, 1, '2025-05-20', '2025-05-17', 6.00),
    (2, N'Finca Los Volcanes Lavado', 4, 2, '2025-06-02', '2025-05-25', 8.00),
    (3, N'Guji Natural Lote 7', 7, 3, '2025-06-15', '2025-06-08', 10.00),
    (4, N'Fazenda Santa Luzia Natural', 2, 4, '2025-06-28', '2025-06-22', 12.00),
    (5, N'Fazenda Boa Vista Natural', 5, 5, '2025-07-11', '2025-07-06', 15.00),
    (6, N'Finca La Pastora Honey', 8, 6, '2025-07-24', '2025-07-20', 6.00),
    (7, N'Kochere Lavado', 3, 7, '2025-08-06', '2025-08-03', 8.00),
    (8, N'La Unión Lavado', 6, 8, '2025-08-19', '2025-08-11', 10.00),
    (9, N'Pink Bourbon Microlote', 1, 9, '2025-09-01', '2025-08-25', 12.00),
    (10, N'Finca San Rafael Honey', 4, 10, '2025-09-14', '2025-09-08', 15.00),
    (11, N'Bensa Lavado', 7, 1, '2025-09-27', '2025-09-22', 6.00),
    (12, N'Cerrado Natural', 2, 2, '2025-10-10', '2025-10-06', 8.00),
    (13, N'Sul de Minas Pulped Natural', 5, 3, '2025-10-23', '2025-10-20', 10.00),
    (14, N'Dota Microlote Anaeróbico', 8, 4, '2025-11-05', '2025-10-28', 12.00),
    (15, N'Aricha Natural', 3, 5, '2025-11-18', '2025-11-11', 15.00),
    (16, N'Cooperativa Cumbal Lavado', 6, 6, '2025-12-01', '2025-11-25', 6.00),
    (17, N'El Mirador Honey', 1, 7, '2025-12-14', '2025-12-09', 8.00),
    (18, N'El Pilar Lavado', 4, 8, '2025-12-27', '2025-12-23', 10.00),
    (19, N'Shantawene Natural', 7, 9, '2026-01-09', '2026-01-06', 12.00),
    (20, N'Fazenda Primavera Pulped', 2, 10, '2026-01-22', '2026-01-14', 15.00),
    (21, N'Serra Verde Natural', 5, 1, '2026-02-04', '2026-01-28', 6.00),
    (22, N'Santa María Lavado', 8, 2, '2026-02-17', '2026-02-11', 8.00),
    (23, N'Konga Lavado', 3, 3, '2026-03-02', '2026-02-25', 10.00),
    (24, N'Buesaco Lavado', 6, 4, '2026-03-15', '2026-03-11', 12.00),
    (25, N'Villa Rica Natural', 1, 5, '2026-03-28', '2026-03-25', 15.00),
    (26, N'Hunapú Natural', 4, 6, '2026-04-10', '2026-04-02', 6.00),
    (27, N'Hambela Lavado', 7, 7, '2026-04-23', '2026-04-16', 8.00),
    (28, N'Serra Dourada Natural', 2, 8, '2026-05-06', '2026-04-30', 10.00),
    (29, N'Fazenda Alvorada Honey', 5, 9, '2026-05-19', '2026-05-14', 12.00),
    (30, N'San Marcos Honey', 8, 10, '2026-06-01', '2026-05-28', 15.00),
    (31, N'Idido Natural', 3, 1, '2026-06-14', '2026-06-11', 6.00),
    (32, N'Génova Honey', 6, 2, '2026-06-27', '2026-06-19', 8.00),
    (33, N'Cerro Azul Lavado', 1, 3, '2026-07-10', '2026-07-03', 10.00),
    (34, N'Santa Clara Lavado', 4, 4, '2026-07-23', '2026-07-17', 12.00),
    (35, N'Aleta Wondo Honey', 7, 5, '2026-08-05', '2026-07-31', 15.00),
    (36, N'Boa Esperança Honey', 2, 6, '2026-08-18', '2026-08-14', 6.00),
    (37, N'São João Natural', 5, 7, '2026-08-31', '2026-08-28', 8.00),
    (38, N'León Cortés Natural', 8, 8, '2026-09-13', '2026-09-05', 10.00),
    (39, N'Gedeb Anaeróbico', 3, 9, '2026-09-26', '2026-09-19', 12.00),
    (40, N'El Tablón Natural', 6, 10, '2026-10-09', '2026-10-03', 15.00);


-- Barista (IDENTITY: los IDs salen 1 a 7 si la tabla estaba vacía)

INSERT INTO Barista (DNI, nombre, apellido, experiencia) VALUES
    (N'28450121', N'Martina', N'Ríos', 8),
    (N'31220987', N'Lucas', N'Benítez', 5),
    (N'36874512', N'Sofía', N'Carrizo', 3),
    (N'41093376', N'Mateo', N'Duarte', 1),
    (N'33781450', N'Valentina', N'Pereyra', 6),
    (N'39665208', N'Julián', N'Acosta', 2),
    (N'35118843', N'Camila', N'Ferrer', 4),
    (N'37552901', N'Ramiro', N'Quiroga', 2),
    (N'34219876', N'Florencia', N'Montero', 3),
    (N'42180533', N'Tomás', N'Arias', 1);


-- Cliente (IDENTITY: los IDs salen 1 a 60 si la tabla estaba vacía)

INSERT INTO Cliente (DNI, nombre, apellido) VALUES
    (N'34259659', N'Daniela', N'Pérez'),
    (N'32118183', N'Carolina', N'Sánchez'),
    (N'36604773', N'Romina', N'Romero'),
    (N'26442537', N'Cristian', N'López'),
    (N'41197271', N'Yamila', N'Gómez'),
    (N'25371313', N'Hernán', N'Ruiz'),
    (N'31004088', N'Milagros', N'Silva'),
    (N'32291592', N'Santiago', N'Romero'),
    (N'39966682', N'Carolina', N'Álvarez'),
    (N'31421406', N'Gabriela', N'Pérez'),
    (N'45183582', N'Violeta', N'Núñez'),
    (N'29319477', N'Tamara', N'Medina'),
    (N'27620485', N'Ximena', N'Rodríguez'),
    (N'43235265', N'Ximena', N'Martínez'),
    (N'43690318', N'Carolina', N'Torres'),
    (N'25095121', N'Daniela', N'Silva'),
    (N'33077687', N'Ximena', N'Torres'),
    (N'31669149', N'Santiago', N'Álvarez'),
    (N'26653775', N'Pablo', N'Castro'),
    (N'31679492', N'Joaquín', N'Núñez'),
    (N'42899958', N'Santiago', N'Medina'),
    (N'39940460', N'Tamara', N'Romero'),
    (N'30129023', N'Andrés', N'Torres'),
    (N'36683689', N'Santiago', N'Díaz'),
    (N'36067885', N'Carolina', N'Medina'),
    (N'44594416', N'Gabriela', N'Suárez'),
    (N'32040497', N'Zoe', N'López'),
    (N'27558531', N'Andrés', N'Álvarez'),
    (N'25407674', N'Ximena', N'Molina'),
    (N'38208949', N'Leandro', N'Suárez'),
    (N'29346139', N'Hernán', N'Núñez'),
    (N'45231408', N'Karina', N'Romero'),
    (N'37923148', N'Zoe', N'Gómez'),
    (N'40417127', N'Ximena', N'Álvarez'),
    (N'42015544', N'Carolina', N'Rodríguez'),
    (N'35125056', N'Hernán', N'Pérez'),
    (N'39266985', N'Daniela', N'Gómez'),
    (N'36201756', N'Agustina', N'Díaz'),
    (N'37002927', N'Gabriela', N'Silva'),
    (N'36530420', N'Joaquín', N'Ortiz'),
    (N'45764954', N'Esteban', N'Núñez'),
    (N'37244364', N'Hernán', N'Suárez'),
    (N'36342243', N'Santiago', N'Rodríguez'),
    (N'27925543', N'Pablo', N'Herrera'),
    (N'42444119', N'Olivia', N'Díaz'),
    (N'45526285', N'Tamara', N'Torres'),
    (N'32447788', N'Agustina', N'Sánchez'),
    (N'30229318', N'Romina', N'Fernández'),
    (N'25462423', N'Walter', N'Álvarez'),
    (N'38555138', N'Leandro', N'Álvarez'),
    (N'26523867', N'Yamila', N'Ruiz'),
    (N'33645037', N'Leandro', N'Martínez'),
    (N'36657684', N'Nicolás', N'Gómez'),
    (N'27884659', N'Pablo', N'Gómez'),
    (N'44505536', N'Yamila', N'Herrera'),
    (N'32012025', N'Walter', N'Suárez'),
    (N'30553162', N'Inés', N'Herrera'),
    (N'28314516', N'Esteban', N'Herrera'),
    (N'28018756', N'Joaquín', N'Sánchez'),
    (N'42545149', N'Karina', N'Silva');
