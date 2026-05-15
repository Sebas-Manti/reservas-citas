# ============================================================
# ARCHIVO: backend/app/routers/especialidad.py
# ============================================================

from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.database import execute_query

especialidad_bp = Blueprint("especialidad", __name__)


@especialidad_bp.route("/especialidades")
def listar():
    rows = execute_query(
        "SELECT * FROM especialidad ORDER BY id_especialidad",
        fetch="all"
    )
    return render_template("pages/especialidad/lista.html", especialidades=rows)


@especialidad_bp.route("/especialidades/nueva", methods=["GET", "POST"])
def crear():
    if request.method == "POST":
        nombre      = request.form.get("nombre", "").strip()
        descripcion = request.form.get("descripcion", "").strip()

        if not nombre:
            flash("El nombre es obligatorio.", "error")
            return redirect(url_for("especialidad.crear"))

        try:
            execute_query(
                "INSERT INTO especialidad (nombre, descripcion) VALUES (%s, %s)",
                (nombre, descripcion or None)
            )
            flash("Especialidad creada correctamente.", "success")
            return redirect(url_for("especialidad.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")
            return redirect(url_for("especialidad.crear"))

    return render_template("pages/especialidad/form.html",
                           accion="Crear", especialidad=None)


@especialidad_bp.route("/especialidades/<int:id>/editar", methods=["GET", "POST"])
def editar(id):
    especialidad = execute_query(
        "SELECT * FROM especialidad WHERE id_especialidad = %s",
        (id,), fetch="one"
    )
    if not especialidad:
        flash("Especialidad no encontrada.", "error")
        return redirect(url_for("especialidad.listar"))

    if request.method == "POST":
        nombre      = request.form.get("nombre", "").strip()
        descripcion = request.form.get("descripcion", "").strip()

        if not nombre:
            flash("El nombre es obligatorio.", "error")
            return redirect(url_for("especialidad.editar", id=id))

        try:
            execute_query(
                "UPDATE especialidad SET nombre=%s, descripcion=%s WHERE id_especialidad=%s",
                (nombre, descripcion or None, id)
            )
            flash("Especialidad actualizada correctamente.", "success")
            return redirect(url_for("especialidad.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")

    return render_template("pages/especialidad/form.html",
                           accion="Editar", especialidad=especialidad)


@especialidad_bp.route("/especialidades/<int:id>/eliminar", methods=["POST"])
def eliminar(id):
    try:
        execute_query(
            "DELETE FROM especialidad WHERE id_especialidad = %s",
            (id,)
        )
        flash("Especialidad eliminada.", "success")
    except Exception as e:
        flash(f"No se puede eliminar: {e}", "error")
    return redirect(url_for("especialidad.listar"))