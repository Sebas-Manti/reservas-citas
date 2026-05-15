# ============================================================
# ARCHIVO: backend/app/routers/profesional.py
# ============================================================

from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.database import execute_query

profesional_bp = Blueprint("profesional", __name__)


@profesional_bp.route("/profesionales")
def listar():
    rows = execute_query(
        """
        SELECT p.*, e.nombre AS especialidad_nombre
        FROM profesional p
        LEFT JOIN especialidad e ON p.id_especialidad = e.id_especialidad
        ORDER BY p.id_profesional
        """,
        fetch="all"
    )
    return render_template("pages/profesional/lista.html", profesionales=rows)


@profesional_bp.route("/profesionales/nuevo", methods=["GET", "POST"])
def crear():
    especialidades = execute_query(
        "SELECT id_especialidad, nombre FROM especialidad ORDER BY nombre",
        fetch="all"
    )

    if request.method == "POST":
        nombre          = request.form.get("nombre", "").strip()
        apellido        = request.form.get("apellido", "").strip()
        email           = request.form.get("email", "").strip()
        id_especialidad = request.form.get("id_especialidad") or None

        if not nombre or not apellido or not email:
            flash("Nombre, apellido y email son obligatorios.", "error")
            return redirect(url_for("profesional.crear"))

        try:
            execute_query(
                """
                INSERT INTO profesional (nombre, apellido, email, id_especialidad, activo)
                VALUES (%s, %s, %s, %s, TRUE)
                """,
                (nombre, apellido, email, id_especialidad)
            )
            flash("Profesional creado correctamente.", "success")
            return redirect(url_for("profesional.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")
            return redirect(url_for("profesional.crear"))

    return render_template("pages/profesional/form.html",
                           accion="Crear",
                           profesional=None,
                           especialidades=especialidades)


@profesional_bp.route("/profesionales/<int:id>/editar", methods=["GET", "POST"])
def editar(id):
    profesional = execute_query(
        "SELECT * FROM profesional WHERE id_profesional = %s",
        (id,), fetch="one"
    )
    if not profesional:
        flash("Profesional no encontrado.", "error")
        return redirect(url_for("profesional.listar"))

    especialidades = execute_query(
        "SELECT id_especialidad, nombre FROM especialidad ORDER BY nombre",
        fetch="all"
    )

    if request.method == "POST":
        nombre          = request.form.get("nombre", "").strip()
        apellido        = request.form.get("apellido", "").strip()
        email           = request.form.get("email", "").strip()
        id_especialidad = request.form.get("id_especialidad") or None
        activo          = request.form.get("activo") == "on"

        if not nombre or not apellido or not email:
            flash("Nombre, apellido y email son obligatorios.", "error")
            return redirect(url_for("profesional.editar", id=id))

        try:
            execute_query(
                """
                UPDATE profesional
                SET nombre=%s, apellido=%s, email=%s,
                    id_especialidad=%s, activo=%s
                WHERE id_profesional=%s
                """,
                (nombre, apellido, email, id_especialidad, activo, id)
            )
            flash("Profesional actualizado correctamente.", "success")
            return redirect(url_for("profesional.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")

    return render_template("pages/profesional/form.html",
                           accion="Editar",
                           profesional=profesional,
                           especialidades=especialidades)


@profesional_bp.route("/profesionales/<int:id>/eliminar", methods=["POST"])
def eliminar(id):
    try:
        execute_query(
            "DELETE FROM profesional WHERE id_profesional = %s",
            (id,)
        )
        flash("Profesional eliminado.", "success")
    except Exception as e:
        flash(f"No se puede eliminar: {e}", "error")
    return redirect(url_for("profesional.listar"))