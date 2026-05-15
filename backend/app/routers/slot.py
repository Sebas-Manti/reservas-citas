# ============================================================
# ARCHIVO: backend/app/routers/slot.py
# ============================================================

from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.database import execute_query

slot_bp = Blueprint("slot", __name__)


@slot_bp.route("/slots")
def listar():
    rows = execute_query(
        """
        SELECT s.*, p.nombre || ' ' || p.apellido AS profesional_nombre
        FROM slot s
        LEFT JOIN profesional p ON s.id_profesional = p.id_profesional
        ORDER BY s.fecha_hora_inicio DESC
        """,
        fetch="all"
    )
    return render_template("pages/slot/lista.html", slots=rows)


@slot_bp.route("/slots/nuevo", methods=["GET", "POST"])
def crear():
    profesionales = execute_query(
        "SELECT id_profesional, nombre || ' ' || apellido AS nombre_completo FROM profesional WHERE activo = TRUE ORDER BY nombre",
        fetch="all"
    )

    if request.method == "POST":
        id_profesional    = request.form.get("id_profesional") or None
        fecha_hora_inicio = request.form.get("fecha_hora_inicio", "").strip()
        fecha_hora_fin    = request.form.get("fecha_hora_fin", "").strip()

        if not id_profesional or not fecha_hora_inicio or not fecha_hora_fin:
            flash("Todos los campos son obligatorios.", "error")
            return redirect(url_for("slot.crear"))

        try:
            execute_query(
                """
                INSERT INTO slot (id_profesional, fecha_hora_inicio, fecha_hora_fin, estado)
                VALUES (%s, %s, %s, 'LIBRE')
                """,
                (id_profesional, fecha_hora_inicio, fecha_hora_fin)
            )
            flash("Slot creado correctamente.", "success")
            return redirect(url_for("slot.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")
            return redirect(url_for("slot.crear"))

    return render_template("pages/slot/form.html",
                           accion="Crear",
                           slot=None,
                           profesionales=profesionales)


@slot_bp.route("/slots/<int:id>/editar", methods=["GET", "POST"])
def editar(id):
    slot = execute_query(
        "SELECT * FROM slot WHERE id_slot = %s",
        (id,), fetch="one"
    )
    if not slot:
        flash("Slot no encontrado.", "error")
        return redirect(url_for("slot.listar"))

    profesionales = execute_query(
        "SELECT id_profesional, nombre || ' ' || apellido AS nombre_completo FROM profesional WHERE activo = TRUE ORDER BY nombre",
        fetch="all"
    )

    if request.method == "POST":
        id_profesional    = request.form.get("id_profesional") or None
        fecha_hora_inicio = request.form.get("fecha_hora_inicio", "").strip()
        fecha_hora_fin    = request.form.get("fecha_hora_fin", "").strip()
        estado            = request.form.get("estado", "LIBRE")

        if not id_profesional or not fecha_hora_inicio or not fecha_hora_fin:
            flash("Todos los campos son obligatorios.", "error")
            return redirect(url_for("slot.editar", id=id))

        try:
            execute_query(
                """
                UPDATE slot
                SET id_profesional=%s, fecha_hora_inicio=%s,
                    fecha_hora_fin=%s, estado=%s
                WHERE id_slot=%s
                """,
                (id_profesional, fecha_hora_inicio, fecha_hora_fin, estado, id)
            )
            flash("Slot actualizado correctamente.", "success")
            return redirect(url_for("slot.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")

    return render_template("pages/slot/form.html",
                           accion="Editar",
                           slot=slot,
                           profesionales=profesionales)


@slot_bp.route("/slots/<int:id>/eliminar", methods=["POST"])
def eliminar(id):
    try:
        execute_query(
            "DELETE FROM slot WHERE id_slot = %s",
            (id,)
        )
        flash("Slot eliminado.", "success")
    except Exception as e:
        flash(f"No se puede eliminar: {e}", "error")
    return redirect(url_for("slot.listar"))