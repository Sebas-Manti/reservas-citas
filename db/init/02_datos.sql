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