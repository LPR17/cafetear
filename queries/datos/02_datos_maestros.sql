-- Cafetear · Datos maestros
-- Proveedor, Grano, Lote, Barista y Cliente. Ejecutar después de 01 y antes de 03.

USE Cafetear;
GO
SET NOCOUNT ON;


-- Proveedor (los CUIT son inventados)

INSERT INTO proveedor (cuit, razonSocial) VALUES
    ('30-71458230-4', 'Café Andino S.R.L.'),
    ('30-70912345-1', 'Tostadores del Sur S.A.'),
    ('30-71203344-7', 'Finca Los Altos S.A.'),
    ('33-70655120-9', 'Origen Colombia Import S.A.'),
    ('30-71877650-2', 'Brasil Café Trading S.R.L.'),
    ('30-71562918-5', 'Sidamo Importaciones S.R.L.'),
    ('30-71099321-6', 'Cafés del Valle S.A.'),
    ('30-70744810-3', 'Importadora Tierra Alta S.R.L.'),
    ('33-71320485-9', 'Granos del Mundo S.A.'),
    ('30-71688104-2', 'Selecta Cafés S.R.L.');


-- Grano: el tipo de café y su origen

INSERT INTO grano (idGrano, alturaCosecha, regionCosecha, fechaCosecha) VALUES
    (1, 1800, 'Huila, Colombia', '2025-01-20'),
    (2, 1100, 'Cerrado Mineiro, Brasil', '2025-03-10'),
    (3, 2000, 'Yirgacheffe, Etiopía', '2025-02-05'),
    (4, 1600, 'Antigua, Guatemala', '2025-03-12'),
    (5, 1000, 'Sul de Minas, Brasil', '2025-04-25'),
    (6, 2100, 'Nariño, Colombia', '2025-01-30'),
    (7, 1900, 'Sidamo, Etiopía', '2025-02-18'),
    (8, 1700, 'Tarrazú, Costa Rica', '2025-03-02'),
    (9, 1950, 'Huila, Colombia', '2025-06-18'),
    (10, 2150, 'Yirgacheffe, Etiopía', '2025-05-22');


-- Lote: una bolsa concreta de café, con su nombre (el lote 40 queda sin calibrar a propósito)

INSERT INTO lote (idLote, nombre, idGrano, idProveedor, fechaIngreso, fechaTostado, cantidadKg) VALUES
    (1, 'La Esperanza Lavado', 1, 1, '2025-05-20', '2025-05-17', 6.00),
    (2, 'Finca Los Volcanes Lavado', 4, 2, '2025-06-02', '2025-05-25', 8.00),
    (3, 'Guji Natural Lote 7', 7, 3, '2025-06-15', '2025-06-08', 10.00),
    (4, 'Fazenda Santa Luzia Natural', 2, 4, '2025-06-28', '2025-06-22', 12.00),
    (5, 'Fazenda Boa Vista Natural', 5, 5, '2025-07-11', '2025-07-06', 15.00),
    (6, 'Finca La Pastora Honey', 8, 6, '2025-07-24', '2025-07-20', 6.00),
    (7, 'Kochere Lavado', 3, 7, '2025-08-06', '2025-08-03', 8.00),
    (8, 'La Unión Lavado', 6, 8, '2025-08-19', '2025-08-11', 10.00),
    (9, 'Pink Bourbon Microlote', 1, 9, '2025-09-01', '2025-08-25', 12.00),
    (10, 'Finca San Rafael Honey', 4, 10, '2025-09-14', '2025-09-08', 15.00),
    (11, 'Bensa Lavado', 7, 1, '2025-09-27', '2025-09-22', 6.00),
    (12, 'Cerrado Natural', 2, 2, '2025-10-10', '2025-10-06', 8.00),
    (13, 'Sul de Minas Pulped Natural', 5, 3, '2025-10-23', '2025-10-20', 10.00),
    (14, 'Dota Microlote Anaeróbico', 8, 4, '2025-11-05', '2025-10-28', 12.00),
    (15, 'Aricha Natural', 3, 5, '2025-11-18', '2025-11-11', 15.00),
    (16, 'Cooperativa Cumbal Lavado', 6, 6, '2025-12-01', '2025-11-25', 6.00),
    (17, 'El Mirador Honey', 1, 7, '2025-12-14', '2025-12-09', 8.00),
    (18, 'El Pilar Lavado', 4, 8, '2025-12-27', '2025-12-23', 10.00),
    (19, 'Shantawene Natural', 7, 9, '2026-01-09', '2026-01-06', 12.00),
    (20, 'Fazenda Primavera Pulped', 2, 10, '2026-01-22', '2026-01-14', 15.00),
    (21, 'Serra Verde Natural', 5, 1, '2026-02-04', '2026-01-28', 6.00),
    (22, 'Santa María Lavado', 8, 2, '2026-02-17', '2026-02-11', 8.00),
    (23, 'Konga Lavado', 3, 3, '2026-03-02', '2026-02-25', 10.00),
    (24, 'Buesaco Lavado', 6, 4, '2026-03-15', '2026-03-11', 12.00),
    (25, 'Villa Rica Natural', 1, 5, '2026-03-28', '2026-03-25', 15.00),
    (26, 'Hunapú Natural', 4, 6, '2026-04-10', '2026-04-02', 6.00),
    (27, 'Hambela Lavado', 7, 7, '2026-04-23', '2026-04-16', 8.00),
    (28, 'Serra Dourada Natural', 2, 8, '2026-05-06', '2026-04-30', 10.00),
    (29, 'Fazenda Alvorada Honey', 5, 9, '2026-05-19', '2026-05-14', 12.00),
    (30, 'San Marcos Honey', 8, 10, '2026-06-01', '2026-05-28', 15.00),
    (31, 'Idido Natural', 3, 1, '2026-06-14', '2026-06-11', 6.00),
    (32, 'Génova Honey', 6, 2, '2026-06-27', '2026-06-19', 8.00),
    (33, 'Cerro Azul Lavado', 1, 3, '2026-07-10', '2026-07-03', 10.00),
    (34, 'Santa Clara Lavado', 4, 4, '2026-07-23', '2026-07-17', 12.00),
    (35, 'Aleta Wondo Honey', 7, 5, '2026-08-05', '2026-07-31', 15.00),
    (36, 'Boa Esperança Honey', 2, 6, '2026-08-18', '2026-08-14', 6.00),
    (37, 'São João Natural', 5, 7, '2026-08-31', '2026-08-28', 8.00),
    (38, 'León Cortés Natural', 8, 8, '2026-09-13', '2026-09-05', 10.00),
    (39, 'Gedeb Anaeróbico', 3, 9, '2026-09-26', '2026-09-19', 12.00),
    (40, 'El Tablón Natural', 6, 10, '2026-10-09', '2026-10-03', 15.00);


-- Barista (IDENTITY: los IDs salen 1 a 7 si la tabla estaba vacía)

INSERT INTO barista (dni, nombre, apellido, experiencia) VALUES
    ('28450121', 'Martina', 'Ríos', 8),
    ('31220987', 'Lucas', 'Benítez', 5),
    ('36874512', 'Sofía', 'Carrizo', 3),
    ('41093376', 'Mateo', 'Duarte', 1),
    ('33781450', 'Valentina', 'Pereyra', 6),
    ('39665208', 'Julián', 'Acosta', 2),
    ('35118843', 'Camila', 'Ferrer', 4),
    ('37552901', 'Ramiro', 'Quiroga', 2),
    ('34219876', 'Florencia', 'Montero', 3),
    ('42180533', 'Tomás', 'Arias', 1);


-- Cliente (IDENTITY: los IDs salen 1 a 60 si la tabla estaba vacía)

INSERT INTO cliente (dni, nombre, apellido) VALUES
    ('34259659', 'Daniela', 'Pérez'),
    ('32118183', 'Carolina', 'Sánchez'),
    ('36604773', 'Romina', 'Romero'),
    ('26442537', 'Cristian', 'López'),
    ('41197271', 'Yamila', 'Gómez'),
    ('25371313', 'Hernán', 'Ruiz'),
    ('31004088', 'Milagros', 'Silva'),
    ('32291592', 'Santiago', 'Romero'),
    ('39966682', 'Carolina', 'Álvarez'),
    ('31421406', 'Gabriela', 'Pérez'),
    ('45183582', 'Violeta', 'Núñez'),
    ('29319477', 'Tamara', 'Medina'),
    ('27620485', 'Ximena', 'Rodríguez'),
    ('43235265', 'Ximena', 'Martínez'),
    ('43690318', 'Carolina', 'Torres'),
    ('25095121', 'Daniela', 'Silva'),
    ('33077687', 'Ximena', 'Torres'),
    ('31669149', 'Santiago', 'Álvarez'),
    ('26653775', 'Pablo', 'Castro'),
    ('31679492', 'Joaquín', 'Núñez'),
    ('42899958', 'Santiago', 'Medina'),
    ('39940460', 'Tamara', 'Romero'),
    ('30129023', 'Andrés', 'Torres'),
    ('36683689', 'Santiago', 'Díaz'),
    ('36067885', 'Carolina', 'Medina'),
    ('44594416', 'Gabriela', 'Suárez'),
    ('32040497', 'Zoe', 'López'),
    ('27558531', 'Andrés', 'Álvarez'),
    ('25407674', 'Ximena', 'Molina'),
    ('38208949', 'Leandro', 'Suárez'),
    ('29346139', 'Hernán', 'Núñez'),
    ('45231408', 'Karina', 'Romero'),
    ('37923148', 'Zoe', 'Gómez'),
    ('40417127', 'Ximena', 'Álvarez'),
    ('42015544', 'Carolina', 'Rodríguez'),
    ('35125056', 'Hernán', 'Pérez'),
    ('39266985', 'Daniela', 'Gómez'),
    ('36201756', 'Agustina', 'Díaz'),
    ('37002927', 'Gabriela', 'Silva'),
    ('36530420', 'Joaquín', 'Ortiz'),
    ('45764954', 'Esteban', 'Núñez'),
    ('37244364', 'Hernán', 'Suárez'),
    ('36342243', 'Santiago', 'Rodríguez'),
    ('27925543', 'Pablo', 'Herrera'),
    ('42444119', 'Olivia', 'Díaz'),
    ('45526285', 'Tamara', 'Torres'),
    ('32447788', 'Agustina', 'Sánchez'),
    ('30229318', 'Romina', 'Fernández'),
    ('25462423', 'Walter', 'Álvarez'),
    ('38555138', 'Leandro', 'Álvarez'),
    ('26523867', 'Yamila', 'Ruiz'),
    ('33645037', 'Leandro', 'Martínez'),
    ('36657684', 'Nicolás', 'Gómez'),
    ('27884659', 'Pablo', 'Gómez'),
    ('44505536', 'Yamila', 'Herrera'),
    ('32012025', 'Walter', 'Suárez'),
    ('30553162', 'Inés', 'Herrera'),
    ('28314516', 'Esteban', 'Herrera'),
    ('28018756', 'Joaquín', 'Sánchez'),
    ('42545149', 'Karina', 'Silva');
