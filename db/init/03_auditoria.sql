-- ============================================================
-- PROYECTO: Reservas-Citas
-- ARCHIVO:  03_auditoria.sql
-- DESC:     Tabla de auditoría + función trigger + triggers
--           por tabla
-- AUTOR:    John Sebastian Mantilla Manzano
-- ============================================================

-- ------------------------------------------------------------
-- 1. TABLA DE AUDITORÍA
-- ------------------------------------------------------------
DROP TABLE IF EXISTS auditoria CASCADE;

CREATE TABLE auditoria (
    id_auditoria  SERIAL PRIMARY KEY,
    tabla         VARCHAR(50)  NOT NULL,
    operacion     VARCHAR(10)  NOT NULL CHECK (operacion IN ('INSERT','UPDATE','DELETE')),
    usuario_bd    VARCHAR(100) NOT NULL,
    fecha_hora    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    datos_antes   TEXT,   -- JSON del registro antes del cambio (NULL en INSERT)
    datos_despues TEXT    -- JSON del registro después del cambio (NULL en DELETE)
);

-- ------------------------------------------------------------
-- 2. FUNCIÓN GENÉRICA DE AUDITORÍA
-- Una sola función sirve para todas las tablas
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (tabla, operacion, usuario_bd, datos_antes, datos_despues)
        VALUES (
            TG_TABLE_NAME,
            'INSERT',
            current_user,
            NULL,
            row_to_json(NEW)::TEXT
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (tabla, operacion, usuario_bd, datos_antes, datos_despues)
        VALUES (
            TG_TABLE_NAME,
            'UPDATE',
            current_user,
            row_to_json(OLD)::TEXT,
            row_to_json(NEW)::TEXT
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (tabla, operacion, usuario_bd, datos_antes, datos_despues)
        VALUES (
            TG_TABLE_NAME,
            'DELETE',
            current_user,
            row_to_json(OLD)::TEXT,
            NULL
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ------------------------------------------------------------
-- 3. TRIGGERS — uno por tabla vigilada
-- AFTER: primero se ejecuta la operación, luego se audita
-- FOR EACH ROW: se audita cada fila afectada
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_auditoria_especialidad  ON especialidad;
DROP TRIGGER IF EXISTS trg_auditoria_profesional   ON profesional;
DROP TRIGGER IF EXISTS trg_auditoria_cliente       ON cliente;
DROP TRIGGER IF EXISTS trg_auditoria_servicio      ON servicio;
DROP TRIGGER IF EXISTS trg_auditoria_slot          ON slot;
DROP TRIGGER IF EXISTS trg_auditoria_cita          ON cita;
DROP TRIGGER IF EXISTS trg_auditoria_notificacion  ON notificacion;

CREATE TRIGGER trg_auditoria_especialidad
    AFTER INSERT OR UPDATE OR DELETE ON especialidad
    FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

CREATE TRIGGER trg_auditoria_profesional
    AFTER INSERT OR UPDATE OR DELETE ON profesional
    FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

CREATE TRIGGER trg_auditoria_cliente
    AFTER INSERT OR UPDATE OR DELETE ON cliente
    FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

CREATE TRIGGER trg_auditoria_servicio
    AFTER INSERT OR UPDATE OR DELETE ON servicio
    FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

CREATE TRIGGER trg_auditoria_slot
    AFTER INSERT OR UPDATE OR DELETE ON slot
    FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

CREATE TRIGGER trg_auditoria_cita
    AFTER INSERT OR UPDATE OR DELETE ON cita
    FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

CREATE TRIGGER trg_auditoria_notificacion
    AFTER INSERT OR UPDATE OR DELETE ON notificacion
    FOR EACH ROW EXECUTE FUNCTION fn_auditoria();

-- ------------------------------------------------------------
-- 4. PRUEBA — consulta de auditoría por fecha (bloque anónimo)
-- Entregable académico requerido
-- ------------------------------------------------------------
DO $$
DECLARE
    r RECORD;
    p_fecha DATE := CURRENT_DATE;
BEGIN
    RAISE NOTICE '=== REPORTE DE AUDITORÍA — Fecha: % ===', p_fecha;
    FOR r IN
        SELECT id_auditoria, tabla, operacion, usuario_bd,
               fecha_hora, datos_antes, datos_despues
        FROM auditoria
        WHERE DATE(fecha_hora) = p_fecha
        ORDER BY fecha_hora
    LOOP
        RAISE NOTICE '[%] Tabla: % | Op: % | Usuario: % | Hora: %',
            r.id_auditoria, r.tabla, r.operacion,
            r.usuario_bd, r.fecha_hora;
    END LOOP;
END;
$$;