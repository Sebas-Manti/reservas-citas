-- ============================================================
-- PROYECTO: Reservas-Citas
-- ARCHIVO:  01_estructura.sql
-- DESC:     DDL — Creación de tablas y relaciones
-- AUTOR:    John Sebastian Mantilla Manzano
-- ============================================================

-- Limpiar si ya existen (orden inverso por dependencias)
DROP TABLE IF EXISTS notificacion   CASCADE;
DROP TABLE IF EXISTS cita           CASCADE;
DROP TABLE IF EXISTS slot           CASCADE;
DROP TABLE IF EXISTS servicio       CASCADE;
DROP TABLE IF EXISTS cliente        CASCADE;
DROP TABLE IF EXISTS profesional    CASCADE;
DROP TABLE IF EXISTS especialidad   CASCADE;

-- ------------------------------------------------------------
-- 1. ESPECIALIDAD
-- ------------------------------------------------------------
CREATE TABLE especialidad (
    id_especialidad SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     TEXT
);

-- ------------------------------------------------------------
-- 2. PROFESIONAL
-- ------------------------------------------------------------
CREATE TABLE profesional (
    id_profesional  SERIAL PRIMARY KEY,
    nombre          VARCHAR(80)  NOT NULL,
    apellido        VARCHAR(80)  NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    id_especialidad INT REFERENCES especialidad(id_especialidad)
                        ON DELETE SET NULL,
    activo          BOOLEAN DEFAULT TRUE
);

-- ------------------------------------------------------------
-- 3. CLIENTE
-- ------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente      SERIAL PRIMARY KEY,
    nombre          VARCHAR(80)  NOT NULL,
    apellido        VARCHAR(80)  NOT NULL,
    telefono        VARCHAR(20),
    email           VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255),
    fecha_registro  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 4. SERVICIO
-- ------------------------------------------------------------
CREATE TABLE servicio (
    id_servicio     SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    duracion_min    INT          NOT NULL CHECK (duracion_min > 0),
    precio          DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    id_especialidad INT REFERENCES especialidad(id_especialidad)
                        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 5. SLOT
-- ------------------------------------------------------------
CREATE TABLE slot (
    id_slot           SERIAL PRIMARY KEY,
    id_profesional    INT REFERENCES profesional(id_profesional)
                          ON DELETE CASCADE,
    fecha_hora_inicio TIMESTAMP NOT NULL,
    fecha_hora_fin    TIMESTAMP NOT NULL,
    estado            VARCHAR(10) DEFAULT 'LIBRE'
                          CHECK (estado IN ('LIBRE','OCUPADO')),
    UNIQUE (id_profesional, fecha_hora_inicio),
    CHECK (fecha_hora_fin > fecha_hora_inicio)
);

-- ------------------------------------------------------------
-- 6. CITA
-- ------------------------------------------------------------
CREATE TABLE cita (
    id_cita        SERIAL PRIMARY KEY,
    id_cliente     INT REFERENCES cliente(id_cliente)
                       ON DELETE RESTRICT,
    id_profesional INT REFERENCES profesional(id_profesional)
                       ON DELETE RESTRICT,
    id_servicio    INT REFERENCES servicio(id_servicio)
                       ON DELETE RESTRICT,
    id_slot        INT UNIQUE REFERENCES slot(id_slot)
                       ON DELETE RESTRICT,
    estado         VARCHAR(15) DEFAULT 'PENDIENTE'
                       CHECK (estado IN (
                           'PENDIENTE','CONFIRMADA',
                           'CANCELADA','COMPLETADA'
                       )),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notas          TEXT
);

-- ------------------------------------------------------------
-- 7. NOTIFICACION
-- ------------------------------------------------------------
CREATE TABLE notificacion (
    id_notif    SERIAL PRIMARY KEY,
    id_cita     INT REFERENCES cita(id_cita)
                    ON DELETE CASCADE,
    tipo        VARCHAR(30),
    mensaje     TEXT,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 8. PERFIL
-- ------------------------------------------------------------
CREATE TABLE perfil (
    id_perfil SERIAL PRIMARY KEY,
    nombre    VARCHAR(20) NOT NULL UNIQUE
             CHECK (nombre IN ('admin','profesional','cliente'))
);

-- ------------------------------------------------------------
-- 9. ACTIVIDAD
-- ------------------------------------------------------------
CREATE TABLE actividad (
    id_actividad SERIAL PRIMARY KEY,
    nombre       VARCHAR(50) NOT NULL UNIQUE,
    descripcion  TEXT
);

-- ------------------------------------------------------------
-- 10. GESTION_ACTIVIDAD
-- ------------------------------------------------------------
CREATE TABLE gestion_actividad (
    id_gestion      SERIAL PRIMARY KEY,
    id_perfil       INT NOT NULL REFERENCES perfil(id_perfil) ON DELETE CASCADE,
    id_actividad    INT NOT NULL REFERENCES actividad(id_actividad) ON DELETE CASCADE,
    puede_ver       BOOLEAN DEFAULT FALSE,
    puede_crear     BOOLEAN DEFAULT FALSE,
    puede_editar    BOOLEAN DEFAULT FALSE,
    puede_eliminar  BOOLEAN DEFAULT FALSE,
    UNIQUE (id_perfil, id_actividad)
);

-- ------------------------------------------------------------
-- 11. USUARIO
-- ------------------------------------------------------------
CREATE TABLE usuario (
    id_usuario     SERIAL PRIMARY KEY,
    email          VARCHAR(150) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    id_perfil      INT NOT NULL REFERENCES perfil(id_perfil) ON DELETE RESTRICT,
    id_cliente     INT REFERENCES cliente(id_cliente) ON DELETE SET NULL,
    id_profesional INT REFERENCES profesional(id_profesional) ON DELETE SET NULL
);