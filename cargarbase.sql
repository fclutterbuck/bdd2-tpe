--CARGA DE DATOS A LA BASE
INSERT INTO Categoria (id_cat, nombre)
VALUES
    (1, 'Servicios de Internet'),
    (2, 'Servicios de Seguridad'),
    (3, 'Servicios de Hosting'),
    (4, 'Servicios de Mantenimiento de Red'),
    (5, 'Servicios de IP y Conectividad'),
    (6, 'Servicios de Soporte Técnico'),
    (7, 'Servicios de Monitoreo de Seguridad'),
    (8, 'Servicios de Correo Electrónico'),
    (9, 'Servicios de Almacenamiento'),
    (10, 'Licencias de Software'),
    (11, 'Servicios de VPN'),
    (12, 'Servicios de Reparación de Equipos'),
    (13, 'Servicios de Diagnóstico y Configuración'),
    (14, 'Servicios de Recuperación de Datos'),
    (15, 'Servicios de Antivirus'),
    (16, 'Optimización de Red'),
    (17, 'Servicios de Visitas Técnicas'),
    (18, 'Servicios de Asistencia Técnica'),
    (19, 'Servicios de Diagnóstico de Conexión'),
    (20, 'Otros Servicios Especializados');


-- Insertar servicios periódicos
INSERT INTO Servicio (id_servicio, nombre, periodico, costo, intervalo, tipo_intervalo, activo, id_cat)
VALUES
    (1, 'Internet 50 Mbps', TRUE, 1500.000, 1, 'mes', TRUE, 1),
    (2, 'Internet 100 Mbps', TRUE, 2000.000, 1, 'mes', TRUE, 1),
    (3, 'Internet 200 Mbps', TRUE, 2500.000, 1, 'mes', TRUE, 1),
    (4, 'Internet 300 Mbps', TRUE, 3000.000, 1, 'mes', TRUE, 1),
    (5, 'Antivirus Básico', TRUE, 500.000, 1, 'mes', TRUE, 2),
    (6, 'Antivirus Premium', TRUE, 800.000, 1, 'mes', TRUE, 2),
    (7, 'Hosting Web Básico', TRUE, 1000.000, 1, 'mes', TRUE, 3),
    (8, 'Hosting Web Avanzado', TRUE, 1500.000, 1, 'mes', TRUE, 3),
    (9, 'Mantenimiento de Servidor', TRUE, 2500.000, 1, 'mes', TRUE, 4),
    (10, 'Dirección IP Fija', TRUE, 1200.000, 1, 'mes', TRUE, 5),
    (11, 'Soporte Remoto Mensual', TRUE, 900.000, 1, 'mes', TRUE, 6),
    (12, 'Copia de Seguridad Mensual', TRUE, 600.000, 1, 'mes', TRUE, 6),
    (13, 'Mantenimiento de Red', TRUE, 1300.000, 1, 'mes', TRUE, 4),
    (14, 'Monitoreo de Seguridad', TRUE, 1800.000, 1, 'mes', TRUE, 7),
    (15, 'Plan Familia Internet', TRUE, 2200.000, 1, 'mes', TRUE, 1),
    (16, 'Línea Telefónica IP', TRUE, 700.000, 1, 'mes', TRUE, 5),
    (17, 'Correo Electrónico Empresarial', TRUE, 1100.000, 1, 'mes', TRUE, 8),
    (18, 'Servicio de Backup Cloud', TRUE, 2500.000, 1, 'mes', TRUE, 9),
    (19, 'Soporte Técnico Ilimitado', TRUE, 1600.000, 1, 'mes', TRUE, 6),
    (20, 'Licencia de Software Office', TRUE, 1400.000, 1, 'mes', TRUE, 10),
    (21, 'Protección Anti-Malware', TRUE, 1000.000, 1, 'mes', TRUE, 2),
    (22, 'VPN Empresarial', TRUE, 1900.000, 1, 'mes', TRUE, 11),
    (23, 'Monitoreo de Dispositivos', TRUE, 1700.000, 1, 'mes', TRUE, 7),
    (24, 'Mantenimiento Preventivo', TRUE, 1500.000, 1, 'mes', TRUE, 4),
    (25, 'Almacenamiento en la Nube', TRUE, 900.000, 1, 'mes', TRUE, 9);

-- Insertar servicios no periódicos
INSERT INTO Servicio (id_servicio, nombre, periodico, costo, intervalo, tipo_intervalo, activo, id_cat)
VALUES
    (26, 'Reparación de Router', FALSE, 1200.000, NULL, NULL, TRUE, 12),
    (27, 'Instalación de Equipos', FALSE, 1000.000, NULL, NULL, TRUE, 12),
    (28, 'Cambio de Dirección IP', FALSE, 500.000, NULL, NULL, TRUE, 13),
    (29, 'Reparación de Computadora', FALSE, 1500.000, NULL, NULL, TRUE, 14),
    (30, 'Soporte Técnico a Domicilio', FALSE, 800.000, NULL, NULL, TRUE, 12),
    (31, 'Instalación de Software', FALSE, 600.000, NULL, NULL, TRUE, 15),
    (32, 'Configuración de Red', FALSE, 1700.000, NULL, NULL, TRUE, 16),
    (33, 'Cambio de Equipos', FALSE, 2000.000, NULL, NULL, TRUE, 12),
    (34, 'Revisión Técnica de Equipos', FALSE, 900.000, NULL, NULL, TRUE, 12),
    (35, 'Visita Técnica para Inspección', FALSE, 700.000, NULL, NULL, TRUE, 17),
    (36, 'Asistencia Técnica de Emergencia', FALSE, 2500.000, NULL, NULL, TRUE, 17),
    (37, 'Reparación de Cableado', FALSE, 1400.000, NULL, NULL, TRUE, 18),
    (38, 'Reemplazo de Equipos Defectuosos', FALSE, 1900.000, NULL, NULL, TRUE, 12),
    (39, 'Desinfección de Virus', FALSE, 1000.000, NULL, NULL, TRUE, 15),
    (40, 'Reparación de Impresoras', FALSE, 1100.000, NULL, NULL, TRUE, 12),
    (41, 'Soporte Técnico Especializado', FALSE, 2200.000, NULL, NULL, TRUE, 19),
    (42, 'Reparación de Fallas en Red', FALSE, 1800.000, NULL, NULL, TRUE, 18),
    (43, 'Instalación de Antivirus', FALSE, 600.000, NULL, NULL, TRUE, 2),
    (44, 'Diagnóstico de Problemas de Conexión', FALSE, 700.000, NULL, NULL, TRUE, 13),
    (45, 'Ajuste de Configuración de Seguridad', FALSE, 800.000, NULL, NULL, TRUE, 20),
    (46, 'Reparación de Discos Duros', FALSE, 1300.000, NULL, NULL, TRUE, 14),
    (47, 'Recuperación de Datos', FALSE, 1700.000, NULL, NULL, TRUE, 14),
    (48, 'Configuración de VPN', FALSE, 1600.000, NULL, NULL, TRUE, 11),
    (49, 'Formateo de Computadora', FALSE, 800.000, NULL, NULL, TRUE, 14),
    (50, 'Optimización de Red', FALSE, 1500.000, NULL, NULL, TRUE, 16);

INSERT INTO Persona (id_persona, tipo, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, fecha_alta, fecha_baja, CUIT, activo, mail, telef_area, telef_numero)
VALUES
    (1, 'Cliente', 'dni', '12345678', 'Juan', 'Pérez', '1980-05-15 00:00:00', '2023-01-01 00:00:00', NULL, '20-12345678-9', true, 'juan.perez@example.com', 011, 12345678),
    (2, 'Cliente', 'dni', '23456789', 'María', 'González', '1990-02-20 00:00:00', '2023-01-02 00:00:00', NULL, '20-23456789-0', true, 'maria.gonzalez@example.com', 011, 23456789),
    (3, 'Cliente', 'dni', '34567890', 'Pedro', 'López', '1985-10-10 00:00:00', '2023-01-03 00:00:00', NULL, '20-34567890-1', true, 'pedro.lopez@example.com', 011, 34567890),
    (4, 'Cliente', 'dni', '45678901', 'Ana', 'Martínez', '1995-03-15 00:00:00', '2023-01-04 00:00:00', NULL, '20-45678901-2', true, 'ana.martinez@example.com', 011, 45678901),
    (5, 'Cliente', 'dni', '56789012', 'Luis', 'Fernández', '1988-12-25 00:00:00', '2023-01-05 00:00:00', NULL, '20-56789012-3', true, 'luis.fernandez@example.com', 011, 56789012),
    (6, 'Cliente', 'dni', '67890123', 'Sofía', 'Rodríguez', '1993-07-30 00:00:00', '2023-01-06 00:00:00', NULL, '20-67890123-4', true, 'sofia.rodriguez@example.com', 011, 67890123),
    (7, 'Cliente', 'dni', '78901234', 'Martín', 'Díaz', '1982-11-11 00:00:00', '2023-01-07 00:00:00', NULL, '20-78901234-5', true, 'martin.diaz@example.com', 011, 78901234),
    (8, 'Cliente', 'dni', '89012345', 'Laura', 'García', '1987-08-18 00:00:00', '2023-01-08 00:00:00', NULL, '20-89012345-6', true, 'laura.garcia@example.com', 011, 89012345),
    (9, 'Cliente', 'dni', '90123456', 'Diego', 'Hernández', '1994-09-05 00:00:00', '2023-01-09 00:00:00', NULL, '20-90123456-7', true, 'diego.hernandez@example.com', 011, 90123456),
    (10, 'Cliente', 'dni', '01234567', 'Camila', 'Martínez', '1991-01-12 00:00:00', '2023-01-10 00:00:00', NULL, '20-01234567-8', true, 'camila.martinez@example.com', 011, 01234567),
    (11, 'Cliente', 'dni', '12345679', 'Ignacio', 'Morales', '1983-06-23 00:00:00', '2023-01-11 00:00:00', NULL, '20-12345679-9', true, 'ignacio.morales@example.com', 011, 12345678),
    (12, 'Cliente', 'dni', '23456780', 'Gabriela', 'Ramírez', '1990-04-14 00:00:00', '2023-01-12 00:00:00', NULL, '20-23456780-0', true, 'gabriela.ramirez@example.com', 011, 23456789),
    (13, 'Cliente', 'dni', '34567891', 'Javier', 'Castro', '1989-03-02 00:00:00', '2023-01-13 00:00:00', NULL, '20-34567891-1', true, 'javier.castro@example.com', 011, 34567890),
    (14, 'Cliente', 'dni', '45678902', 'Valentina', 'Vázquez', '1995-01-28 00:00:00', '2023-01-14 00:00:00', NULL, '20-45678902-2', true, 'valentina.vazquez@example.com', 011, 45678901),
    (15, 'Cliente', 'dni', '56789013', 'Andrés', 'Molina', '1981-08-17 00:00:00', '2023-01-15 00:00:00', NULL, '20-56789013-3', true, 'andres.molina@example.com', 011, 56789012),
    (16, 'Cliente', 'dni', '67890124', 'Luciana', 'Jiménez', '1992-09-21 00:00:00', '2023-01-16 00:00:00', NULL, '20-67890124-4', true, 'luciana.jimenez@example.com', 011, 67890123),
    (17, 'Cliente', 'dni', '78901235', 'Rafael', 'Gonzalez', '1984-02-11 00:00:00', '2023-01-17 00:00:00', NULL, '20-78901235-5', true, 'rafael.gonzalez@example.com', 011, 78901234),
    (18, 'Cliente', 'dni', '89012346', 'Ana', 'Sánchez', '1994-11-20 00:00:00', '2023-01-18 00:00:00', NULL, '20-89012346-6', true, 'ana.sanchez@example.com', 011, 89012345),
    (19, 'Cliente', 'dni', '90123457', 'Nicolás', 'Reyes', '1986-06-15 00:00:00', '2023-01-19 00:00:00', NULL, '20-90123457-7', true, 'nicolas.reyes@example.com', 011, 90123456),
    (20, 'Cliente', 'dni', '01234568', 'Estefanía', 'Cruz', '1993-10-10 00:00:00', '2023-01-20 00:00:00', NULL, '20-01234568-8', true, 'estefania.cruz@example.com', 011, 01234567),
    (21, 'Personal', 'dni', '12345670', 'Fernando', 'Hugo', '1985-05-06 00:00:00', '2023-01-21 00:00:00', NULL, '20-12345670-9', true, 'fernando.hugo@example.com', 011, 12345678),
    (22, 'Personal', 'dni', '23456781', 'Carla', 'Méndez', '1987-12-14 00:00:00', '2023-01-22 00:00:00', NULL, '20-23456781-0', true, 'carla.mendez@example.com', 011, 23456789),
    (23, 'Personal', 'dni', '34567892', 'Guillermo', 'Silva', '1990-03-19 00:00:00', '2023-01-23 00:00:00', NULL, '20-34567892-1', true, 'guillermo.silva@example.com', 011, 34567890),
    (24, 'Personal', 'dni', '45678903', 'Paola', 'Torres', '1991-07-25 00:00:00', '2023-01-24 00:00:00', NULL, '20-45678903-2', true, 'paola.torres@example.com', 011, 45678901),
    (25, 'Personal', 'dni', '56789014', 'Hugo', 'Bermúdez', '1983-04-02 00:00:00', '2023-01-25 00:00:00', NULL, '20-56789014-3', true, 'hugo.bermudez@example.com', 011, 56789012),
    (26, 'Personal', 'dni', '67890125', 'Verónica', 'Núñez', '1986-08-12 00:00:00', '2023-01-26 00:00:00', NULL, '20-67890125-4', true, 'veronica.nunez@example.com', 011, 67890123),
    (27, 'Personal', 'dni', '78901236', 'Cristian', 'Córdoba', '1989-05-22 00:00:00', '2023-01-27 00:00:00', NULL, '20-78901236-5', true, 'cristian.cordoba@example.com', 011, 78901234),
    (28, 'Personal', 'dni', '89012347', 'Natalia', 'Cárdenas', '1992-10-30 00:00:00', '2023-01-28 00:00:00', NULL, '20-89012347-6', true, 'natalia.cardenas@example.com', 011, 89012345),
    (29, 'Personal', 'dni', '90123458', 'Mauricio', 'Rivas', '1984-11-18 00:00:00', '2023-01-29 00:00:00', NULL, '20-90123458-7', true, 'mauricio.rivas@example.com', 011, 90123456),
    (30, 'Personal', 'dni', '01234569', 'Lorena', 'Hurtado', '1981-01-21 00:00:00', '2023-01-30 00:00:00', NULL, '20-01234569-8', true, 'lorena.hurtado@example.com', 011, 01234567),
    (31, 'Cliente', 'dni', '12345680', 'Emilio', 'Vera', '1980-09-11 00:00:00', '2023-02-01 00:00:00', NULL, '20-12345680-9', true, 'emilio.vera@example.com', 011, 12345678),
    (32, 'Cliente', 'dni', '23456781', 'Marta', 'Salas', '1995-12-05 00:00:00', '2023-02-02 00:00:00', NULL, '20-23456781-0', true, 'marta.salas@example.com', 011, 23456789),
    (33, 'Cliente', 'dni', '34567892', 'Ricardo', 'Pineda', '1993-06-17 00:00:00', '2023-02-03 00:00:00', NULL, '20-34567892-1', true, 'ricardo.pineda@example.com', 011, 34567890),
    (34, 'Cliente', 'dni', '45678903', 'Claudia', 'Figueroa', '1988-03-26 00:00:00', '2023-02-04 00:00:00', NULL, '20-45678903-2', true, 'claudia.figueroa@example.com', 011, 45678901),
    (35, 'Cliente', 'dni', '56789014', 'Esteban', 'Acosta', '1992-11-30 00:00:00', '2023-02-05 00:00:00', NULL, '20-56789014-3', true, 'esteban.acosta@example.com', 011, 56789012),
    (36, 'Cliente', 'dni', '67890125', 'Gabriel', 'Bolaños', '1985-07-10 00:00:00', '2023-02-06 00:00:00', NULL, '20-67890125-4', true, 'gabriel.bolanos@example.com', 011, 67890123),
    (37, 'Cliente', 'dni', '78901236', 'Carolina', 'Jurado', '1990-05-05 00:00:00', '2023-02-07 00:00:00', NULL, '20-78901236-5', true, 'carolina.jurado@example.com', 011, 78901234),
    (38, 'Cliente', 'dni', '89012347', 'Mariano', 'Rojas', '1988-04-04 00:00:00', '2023-02-08 00:00:00', NULL, '20-89012347-6', true, 'mariano.rojas@example.com', 011, 89012345),
    (39, 'Cliente', 'dni', '90123458', 'Julián', 'Pérez', '1991-06-15 00:00:00', '2023-02-09 00:00:00', NULL, '20-90123458-7', true, 'julian.perez@example.com', 011, 90123456),
    (40, 'Cliente', 'dni', '01234569', 'Lidia', 'Aguilera', '1993-10-11 00:00:00', '2023-02-10 00:00:00', NULL, '20-01234569-8', true, 'lidia.aguilera@example.com', 011, 01234567),
    (41, 'Personal', 'dni', '12345690', 'Rosa', 'Díaz', '1984-02-23 00:00:00', '2023-02-11 00:00:00', NULL, '20-12345690-9', true, 'rosa.diaz@example.com', 011, 12345678),
    (42, 'Personal', 'dni', '23456791', 'Héctor', 'Bustos', '1987-09-10 00:00:00', '2023-02-12 00:00:00', NULL, '20-23456791-0', true, 'hector.bustos@example.com', 011, 23456789),
    (43, 'Personal', 'dni', '34567892', 'Pilar', 'Cáceres', '1991-03-18 00:00:00', '2023-02-13 00:00:00', NULL, '20-34567892-1', true, 'pilar.caceres@example.com', 011, 34567890),
    (44, 'Personal', 'dni', '45678903', 'Francisco', 'Salinas', '1986-05-20 00:00:00', '2023-02-14 00:00:00', NULL, '20-45678903-2', true, 'francisco.salinas@example.com', 011, 45678901),
    (45, 'Personal', 'dni', '56789014', 'Mercedes', 'Moreno', '1993-01-29 00:00:00', '2023-02-15 00:00:00', NULL, '20-56789014-3', true, 'mercedes.moreno@example.com', 011, 56789012),
    (46, 'Personal', 'dni', '67890125', 'Santiago', 'Reyes', '1988-08-05 00:00:00', '2023-02-16 00:00:00', NULL, '20-67890125-4', true, 'santiago.reyes@example.com', 011, 67890123),
    (47, 'Personal', 'dni', '78901236', 'Teresa', 'Vega', '1990-04-15 00:00:00', '2023-02-17 00:00:00', NULL, '20-78901236-5', true, 'teresa.vega@example.com', 011, 78901234),
    (48, 'Personal', 'dni', '89012347', 'Julio', 'Soto', '1985-12-30 00:00:00', '2023-02-18 00:00:00', NULL, '20-89012347-6', true, 'julio.soto@example.com', 011, 89012345),
    (49, 'Personal', 'dni', '90123458', 'Claudia', 'Bermúdez', '1983-11-02 00:00:00', '2023-02-19 00:00:00', NULL, '20-90123458-7', true, 'claudia.bermudez@example.com', 011, 90123456),
    (50, 'Personal', 'dni', '01234569', 'Rodolfo', 'Maldonado', '1989-05-10 00:00:00', '2023-02-20 00:00:00', NULL, '20-01234569-8', true, 'rodolfo.maldonado@example.com', 011, 01234567);


--Insercion de datos en la tabla rol
INSERT INTO rol (id_rol,nombre)
VALUES (1,'Tecnico de soporte'),
       (2,'Administrativo'),
       (3,'Ventas');

-- Inserción de datos en la tabla personal
INSERT INTO personal (id_personal, id_rol)
SELECT id_persona,
       CASE
           WHEN random() < 0.25 THEN 1  -- 25% serán técnicos de soporte
           WHEN random() < 0.5 THEN 2    -- 25% serán administrativos
           ELSE 3                        -- 50% serán ventas
           END AS id_rol
FROM persona

WHERE tipo = 'Personal';

-- Inserción de datos en la tabla cliente
INSERT INTO cliente (id_cliente, saldo)
SELECT id_persona, NULL AS saldo
FROM persona
WHERE tipo = 'Cliente';


-- Inserción de datos en la tabla lugar
INSERT INTO lugar (id_lugar, nombre)
VALUES
    (1, 'Oficina Central - Buenos Aires'),
    (2, 'Sucursal Norte - Rosario'),
    (3, 'Sucursal Sur - La Plata'),
    (4, 'Centro de Atención - Córdoba'),
    (5, 'Oficina de Soporte - Mendoza'),
    (6, 'Sucursal Oeste - San Juan'),
    (7, 'Centro de Servicio - Tucumán'),
    (8, 'Oficina Regional - Mar del Plata'),
    (9, 'Sucursal Este - Bahía Blanca'),
    (10, 'Centro de Atención - Salta');

-- Inserción de datos en la tabla tipo_comprobante
INSERT INTO tipocomprobante (id_tcomp, nombre,tipo)
VALUES
    (1, 'Factura','factura'),
    (2, 'Recibo','recibo'),
    (3, 'Remito','remito');


INSERT INTO turno (id_turno,desde,hasta,dinero_inicio,dinero_fin,id_personal,id_lugar)
VALUES
    (1,'2024-01-15 08:00:00', '2024-01-15 09:00:00',3000,null,21,1),
    (2,'2024-01-20 09:00:00', '2024-01-20 10:30:00',2400,null,29,1),
    (3,'2024-01-29 10:30:00', '2024-01-29 11:35:00',5600,null,49,7),
    (4,'2024-02-03 10:00:00', '2024-02-03 10:50:00',4000,null,21,4),
    (5,'2024-02-10 08:45:00', '2024-02-10 11:30:00',3100,null,41,2),
    (6,'2024-02-15 08:30:00', '2024-02-15 11:00:00',9900,null,28,4),
    (7,'2024-03-08 11:00:00', '2024-03-08 12:30:00',10000,null,49,7),
    (8,'2024-03-11 10:15:00', '2024-03-11 11:00:00',7500,null,26,10),
    (9,'2024-03-29 09:20:00', '2024-03-29 12:00:00',3200,null,45,9),
    (10,'2024-04-21 08:45:00', '2024-04-21 09:30:00',2000,null,41,5),
    (11,'2024-04-18 10:40:00', '2024-04-18 11:50:00',3000,null,50,5),
    (12,'2024-05-23 10:00:00', '2024-05-23 10:35:00',3500,null,43,3),
    (13,'2024-05-10 11:00:00', '2024-05-10 12:00:00',5500,null,44,3),
    (14,'2024-06-09 12:00:00', '2024-06-09 12:30:00',6200,null,49,1),
    (15,'2024-06-06 10:40:00', '2024-06-06 11:30:00',4300,null,23,9),
    (16,'2024-07-20 10:10:00', '2024-07-20 12:30:00',7900,null,25,8),
    (17,'2024-07-21 08:40:00', '2024-07-21 09:50:00',10000,null,29,7),
    (18,'2024-08-01 09:30:00', '2024-08-01 11:00:00',3405,null,30,4),
    (19,'2024-08-06 09:15:00', '2024-08-06 11:00:00',6500,null,26,6),
    (20,'2024-08-08 08:00:00', '2024-08-08 09:30:00',2300,null,49,3),
    (21,'2024-08-10 09:00:00', '2024-08-10 09:30:00',1700,null,46,2),
    (22,'2024-09-01 10:00:00', '2024-09-01 13:00:00',9820,null,45,9),
    ------------------------------------------------------------------
    (23,'2024-09-15 08:00:00', '2024-09-15 09:30:00',9000,null,23,1),
    (24,'2024-09-20 09:00:00', '2024-09-20 10:30:00',12400,null,28,1),
    (25,'2024-10-02 10:30:00', '2024-10-02 11:30:00',5600,null,43,7),
    (26,'2024-10-03 10:00:00', '2024-10-03 11:45:00',40000,null,24,4),
    (27,'2024-10-10 08:45:00', '2024-10-10 12:00:00',23100,null,42,2),
    (28,'2024-10-15 08:30:00', '2024-10-15 09:34:00',3400,null,21,4),
    (29,'2024-10-18 11:00:00', '2024-10-18 12:30:00',1000,null,44,7),
    (30,'2024-10-19 10:15:00', '2024-10-19 10:30:00',15000,null,29,10),
    (31,'2024-11-23 09:20:00', '2024-11-23 11:30:00',32000,null,30,9),
    (32,'2024-11-05 08:45:00', '2024-11-05 10:00:00',5000,null,21,5),
    (33,'2024-11-06 10:40:00', '2024-11-06 12:10:00',3000,null,30,5),
    (34,'2024-12-11 10:00:00', '2024-12-11 12:00:00',3500,null,50,3),
    (35,'2024-12-12 11:00:00', '2024-12-12 12:00:00',1200,null,22,3),
    (36,'2024-12-19 12:00:00', '2024-12-19 13:30:00',10000,null,23,1),
    (37,'2024-04-06 10:40:00', '2024-04-06 11:30:00',5600,null,46,9),
    (38,'2024-07-01 10:10:00', '2024-07-01 11:45:00',9800,null,47,8),
    (39,'2024-07-09 08:40:00', '2024-07-09 10:30:00',1000,null,25,7),
    (40,'2024-08-02 09:30:00', '2024-08-02 10:30:00',12000,null,30,4),
    (41,'2024-08-07 09:15:00', '2024-08-07 10:00:00',6500,null,49,6),
    (42,'2024-08-18 08:00:00', '2024-08-18 09:40:00',2300,null,24,3),
    (43,'2024-08-31 09:00:00', '2024-08-31 09:35:00',1700,null,21,2),
    (44,'2024-01-01 08:00:00', '2024-01-01 09:34:00',9800,null,42,1),
    (45,'2024-01-01 09:00:00', '2024-01-01 12:30:00',1000,null,44,1),
    (46,'2024-02-01 10:00:00', '2024-02-01 10:50:00',3400,null,48,10),
    (47,'2024-02-01 10:00:00', '2024-02-01 13:00:00',5200,null,47,9),
    (48,'2024-02-01 08:30:00', '2024-02-01 10:35:00',9400,null,46,8),
    (49,'2024-01-02 10:00:00', '2024-01-02 11:45:00',2100,null,26,6),
    (50,'2024-01-02 10:00:00', '2024-01-02 12:30:00',8500,null,21,4);


