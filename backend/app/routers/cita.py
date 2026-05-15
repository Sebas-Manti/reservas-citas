# ============================================================
# ARCHIVO: backend/app/routers/cita.py
# ============================================================

from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.database import get_connection, release_connection, execute_query

cita_bp = Blueprint("cita", __name__)


@cita_bp.route("/citas")
def listar():
    rows = execute_query(
        """
        SELECT c.*,
               cl.nombre || ' ' || cl.apellido AS cliente_nombre,
               p.nombre  || ' ' || p.apellido  AS profesional_nombre,
               s.nombre  AS servicio_nombre,
               sl.fecha_hora_inicio,
               sl.fecha_hora_fin
        FROM cita c
        JOIN cliente     cl ON c.id_cliente     = cl.id_cliente
        JOIN profesional p  ON c.id_profesional = p.id_profesional
        JOIN servicio    s  ON c.id_servicio    = s.id_servicio
        JOIN slot        sl ON c.id_slot        = sl.id_slot
        ORDER BY sl.fecha_hora_inicio DESC
        """,
        fetch="all"
    )
    return render_template("pages/cita/lista.html", citas=rows)


@cita_bp.route("/citas/nueva", methods=["GET", "POST"])
def crear():
    clientes = execute_query(
        "SELECT id_cliente, nombre || ' ' || apellido AS nombre_completo FROM cliente ORDER BY nombre",
        fetch="all"
    )
    servicios = execute_query(
        "SELECT id_servicio, nombre, precio FROM servicio ORDER BY nombre",
        fetch="all"
    )
    slots_libres = execute_query(
        """
        SELECT sl.id_slot,
               p.nombre || ' ' || p.apellido AS profesional_nombre,
               sl.fecha_hora_inicio,
               sl.fecha_hora_fin
        FROM slot sl
        JOIN profesional p ON sl.id_profesional = p.id_profesional
        WHERE sl.estado = 'LIBRE'
          AND sl.fecha_hora_inicio > NOW()
        ORDER BY sl.fecha_hora_inicio
        """,
        fetch="all"
    )

    if request.method == "POST":
        id_cliente  = request.form.get("id_cliente")  or None
        id_servicio = request.form.get("id_servicio") or None
        id_slot     = request.form.get("id_slot")     or None
        notas       = request.form.get("notas", "").strip()

        if not id_cliente or not id_servicio or not id_slot:
            flash("Cliente, servicio y slot son obligatorios.", "error")
            return redirect(url_for("cita.crear"))

        # Transacción manual con bloqueo FOR UPDATE
        conn = get_connection()
        try:
            with conn.cursor() as cur:
                # 1. Bloquear el slot para evitar doble reserva
                cur.execute(
                    "SELECT estado, id_profesional FROM slot WHERE id_slot = %s FOR UPDATE",
                    (id_slot,)
                )
                row = cur.fetchone()

                if not row:
                    raise Exception("El slot indicado no existe.")
                if row[0] != "LIBRE":
                    raise Exception("El slot ya está ocupado.")

                id_profesional = row[1]

                # 2. Crear la cita
                cur.execute(
                    """
                    INSERT INTO cita
                        (id_cliente, id_profesional, id_servicio, id_slot, estado, notas)
                    VALUES (%s, %s, %s, %s, 'CONFIRMADA', %s)
                    RETURNING id_cita
                    """,
                    (id_cliente, id_profesional, id_servicio, id_slot, notas or None)
                )
                id_cita = cur.fetchone()[0]

                # 3. Marcar slot como ocupado
                cur.execute(
                    "UPDATE slot SET estado = 'OCUPADO' WHERE id_slot = %s",
                    (id_slot,)
                )

                # 4. Registrar notificación
                cur.execute(
                    """
                    INSERT INTO notificacion (id_cita, tipo, mensaje)
                    VALUES (%s, 'CONFIRMACION', 'Cita reservada y confirmada exitosamente.')
                    """,
                    (id_cita,)
                )

                conn.commit()
                flash("Cita creada correctamente.", "success")
                return redirect(url_for("cita.listar"))

        except Exception as e:
            conn.rollback()
            flash(f"Error al reservar: {e}", "error")
            return redirect(url_for("cita.crear"))
        finally:
            release_connection(conn)

    return render_template("pages/cita/form.html",
                           accion="Crear",
                           cita=None,
                           clientes=clientes,
                           servicios=servicios,
                           slots_libres=slots_libres)


@cita_bp.route("/citas/<int:id>/cancelar", methods=["POST"])
def cancelar(id):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # 1. Obtener slot y estado actual
            cur.execute(
                "SELECT id_slot, estado FROM cita WHERE id_cita = %s",
                (id,)
            )
            row = cur.fetchone()
            if not row:
                raise Exception("Cita no encontrada.")
            if row[1] not in ("PENDIENTE", "CONFIRMADA"):
                raise Exception(f"La cita no puede cancelarse (estado: {row[1]}).")

            id_slot = row[0]

            # 2. Cancelar cita
            cur.execute(
                "UPDATE cita SET estado = 'CANCELADA' WHERE id_cita = %s",
                (id,)
            )

            # 3. Liberar slot
            cur.execute(
                "UPDATE slot SET estado = 'LIBRE' WHERE id_slot = %s",
                (id_slot,)
            )

            # 4. Registrar notificación
            cur.execute(
                """
                INSERT INTO notificacion (id_cita, tipo, mensaje)
                VALUES (%s, 'CANCELACION', 'Cita cancelada. El slot ha sido liberado.')
                """,
                (id,)
            )

            conn.commit()
            flash("Cita cancelada y slot liberado.", "success")

    except Exception as e:
        conn.rollback()
        flash(f"Error: {e}", "error")
    finally:
        release_connection(conn)

    return redirect(url_for("cita.listar"))


@cita_bp.route("/citas/<int:id>/completar", methods=["POST"])
def completar(id):
    try:
        execute_query(
            """
            UPDATE cita SET estado = 'COMPLETADA'
            WHERE id_cita = %s AND estado = 'CONFIRMADA'
            """,
            (id,)
        )
        flash("Cita marcada como completada.", "success")
    except Exception as e:
        flash(f"Error: {e}", "error")
    return redirect(url_for("cita.listar"))