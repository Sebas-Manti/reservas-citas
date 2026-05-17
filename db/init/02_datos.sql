-- ============================================================
-- PROYECTO: Reservas-Citas
-- ARCHIVO:  02_datos.sql
-- DESC:     DML — Datos semilla para pruebas
-- AUTOR:    John Sebastian Mantilla Manzano
-- ============================================================

-- ------------------------------------------------------------
-- 1. ESPECIALIDAD (5 registros)
-- ------------------------------------------------------------
INSERT INTO especialidad (nombre, descripcion) VALUES
    ('Medicina General',  'Atención médica primaria y diagnóstico'),
    ('Odontología',       'Salud bucal y tratamientos dentales'),
    ('Psicología',        'Salud mental y terapia cognitiva'),
    ('Nutrición',         'Planes alimentarios y asesoría dietética'),
    ('Fisioterapia',      'Rehabilitación física y deportiva');

-- ------------------------------------------------------------
-- 2. PROFESIONAL (5 registros)
-- ------------------------------------------------------------
INSERT INTO profesional (nombre, apellido, email, id_especialidad, activo) VALUES
    ('Carlos', 'Ramírez', 'c.ramirez@clinica.com', 1, TRUE),
    ('Ana',    'Torres',  'a.torres@clinica.com',  2, TRUE),
    ('Luis',   'Medina',  'l.medina@clinica.com',  3, TRUE),
    ('Sofía',  'Herrera', 's.herrera@clinica.com', 4, TRUE),
    ('Jorge',  'Castro',  'j.castro@clinica.com',  5, TRUE);

-- ------------------------------------------------------------
-- 3. CLIENTE (5 registros)
-- ------------------------------------------------------------
INSERT INTO cliente (nombre, apellido, telefono, email) VALUES
    ('María',   'López',    '3001112233', 'maria.lopez@email.com'),
    ('Pedro',   'González', '3104445566', 'pedro.gonzalez@email.com'),
    ('Laura',   'Jiménez',  '3207778899', 'laura.jimenez@email.com'),
    ('Andrés',  'Morales',  '3110001122', 'andres.morales@email.com'),
    ('Camila',  'Ruiz',     '3153334455', 'camila.ruiz@email.com');

-- ------------------------------------------------------------
-- 4. SERVICIO (5 registros)
-- ------------------------------------------------------------
INSERT INTO servicio (nombre, duracion_min, precio, id_especialidad) VALUES
    ('Consulta general',       30, 80000.00,  1),
    ('Limpieza dental',        45, 120000.00, 2),
    ('Sesión de terapia',      60, 150000.00, 3),
    ('Plan nutricional',       40, 100000.00, 4),
    ('Rehabilitación muscular',50, 90000.00,  5);

-- ------------------------------------------------------------
-- 5. SLOT (5 registros)
-- Usamos fechas futuras relativas para que siempre sean válidas
-- ------------------------------------------------------------
INSERT INTO slot (id_profesional, fecha_hora_inicio, fecha_hora_fin, estado) VALUES
    (1, NOW() + INTERVAL '1 day' + INTERVAL '8 hours',
        NOW() + INTERVAL '1 day' + INTERVAL '8 hours 30 minutes',  'LIBRE'),
    (1, NOW() + INTERVAL '1 day' + INTERVAL '9 hours',
        NOW() + INTERVAL '1 day' + INTERVAL '9 hours 30 minutes',  'LIBRE'),
    (2, NOW() + INTERVAL '2 days' + INTERVAL '10 hours',
        NOW() + INTERVAL '2 days' + INTERVAL '10 hours 45 minutes','LIBRE'),
    (3, NOW() + INTERVAL '2 days' + INTERVAL '14 hours',
        NOW() + INTERVAL '2 days' + INTERVAL '15 hours',           'LIBRE'),
    (4, NOW() + INTERVAL '3 days' + INTERVAL '11 hours',
        NOW() + INTERVAL '3 days' + INTERVAL '11 hours 40 minutes','LIBRE');

-- ------------------------------------------------------------
-- 6. CITA (4 registros — el slot 5 queda libre a propósito)
-- ------------------------------------------------------------
INSERT INTO cita (id_cliente, id_profesional, id_servicio, id_slot, estado, notas) VALUES
    (1, 1, 1, 1, 'CONFIRMADA',  'Primera consulta'),
    (2, 2, 2, 3, 'CONFIRMADA',  NULL),
    (3, 3, 3, 4, 'CONFIRMADA',  'Seguimiento mensual'),
    (4, 4, 4, 5, 'CONFIRMADA',  NULL);

-- Actualizar slots ocupados
UPDATE slot SET estado = 'OCUPADO'
WHERE id_slot IN (1, 3, 4, 5);

-- ------------------------------------------------------------
-- 7. NOTIFICACION (5 registros)
-- ------------------------------------------------------------
INSERT INTO notificacion (id_cita, tipo, mensaje) VALUES
    (1, 'CONFIRMACION', 'Cita confirmada exitosamente.'),
    (2, 'RECORDATORIO', 'Recuerde su cita mañana.'),
    (3, 'CONFIRMACION', 'Cita de terapia confirmada.'),
    (4, 'CONFIRMACION', 'Cita de nutrición confirmada.'),
    (1, 'RECORDATORIO', 'Su cita es en 24 horas.');

-- ------------------------------------------------------------
-- 8. PERFIL (3 roles)
-- ------------------------------------------------------------
INSERT INTO perfil (nombre) VALUES
    ('admin'),
    ('profesional'),
    ('cliente');

-- ------------------------------------------------------------
-- 9. ACTIVIDAD (8 módulos del sistema)
-- ------------------------------------------------------------
INSERT INTO actividad (nombre, descripcion) VALUES
    ('especialidades',  'Gestión de especialidades médicas'),
    ('profesionales',   'Gestión de profesionales'),
    ('clientes',        'Gestión de clientes'),
    ('servicios',       'Gestión de servicios'),
    ('slots',           'Gestión de slots de disponibilidad'),
    ('citas',           'Gestión de citas'),
    ('notificaciones',  'Visualización de notificaciones'),
    ('auditoria',       'Reporte de auditoría del sistema');

-- ------------------------------------------------------------
-- 10. GESTION_ACTIVIDAD — permisos por perfil
-- admin: todo
-- profesional: ver todo su ámbito, sin eliminar
-- cliente: solo citas (ver, crear, cancelar vía update)
-- ------------------------------------------------------------

-- ADMIN — acceso total
INSERT INTO gestion_actividad (id_perfil, id_actividad, puede_ver, puede_crear, puede_editar, puede_eliminar)
SELECT 1, id_actividad, TRUE, TRUE, TRUE, TRUE FROM actividad;

-- PROFESIONAL
INSERT INTO gestion_actividad (id_perfil, id_actividad, puede_ver, puede_crear, puede_editar, puede_eliminar)
VALUES
    (2, 1, TRUE,  FALSE, FALSE, FALSE), -- especialidades: solo ver
    (2, 2, TRUE,  FALSE, FALSE, FALSE), -- profesionales: solo ver
    (2, 3, TRUE,  FALSE, FALSE, FALSE), -- clientes: solo ver (los que tienen citas con él)
    (2, 4, TRUE,  FALSE, FALSE, FALSE), -- servicios: solo ver
    (2, 5, TRUE,  TRUE,  TRUE,  FALSE), -- slots: ver, crear, editar
    (2, 6, TRUE,  FALSE, FALSE, FALSE), -- citas: solo ver las suyas
    (2, 7, TRUE,  FALSE, FALSE, FALSE), -- notificaciones: solo ver
    (2, 8, FALSE, FALSE, FALSE, FALSE); -- auditoria: sin acceso

-- CLIENTE
INSERT INTO gestion_actividad (id_perfil, id_actividad, puede_ver, puede_crear, puede_editar, puede_eliminar)
VALUES
    (3, 1, FALSE, FALSE, FALSE, FALSE), -- especialidades: sin acceso
    (3, 2, FALSE, FALSE, FALSE, FALSE), -- profesionales: sin acceso
    (3, 3, FALSE, FALSE, FALSE, FALSE), -- clientes: sin acceso
    (3, 4, TRUE,  FALSE, FALSE, FALSE), -- servicios: solo ver
    (3, 5, TRUE,  FALSE, FALSE, FALSE), -- slots: solo ver disponibles
    (3, 6, TRUE,  TRUE,  TRUE,  FALSE), -- citas: ver, crear, editar (cancelar)
    (3, 7, TRUE,  FALSE, FALSE, FALSE), -- notificaciones: solo ver las suyas
    (3, 8, FALSE, FALSE, FALSE, FALSE); -- auditoria: sin acceso

-- ------------------------------------------------------------
-- 11. USUARIOS de prueba
-- Passwords hasheadas con werkzeug (valor: "admin123", "prof123", "cliente123")
-- Las generamos desde Python — por ahora las dejamos pendientes
-- ------------------------------------------------------------