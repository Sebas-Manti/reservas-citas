# ============================================================
# ARCHIVO: backend/app/routers/servicio.py
# ============================================================

from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.database import execute_query
from app.utils import permiso_required

servicio_bp = Blueprint("servicio", __name__)


@servicio_bp.route("/servicios")
@permiso_required("servicios", "ver")
def listar():
    rows = execute_query(
        """
        SELECT s.*, e.nombre AS especialidad_nombre
        FROM servicio s
        LEFT JOIN especialidad e ON s.id_especialidad = e.id_especialidad
        ORDER BY s.id_servicio
        """,
        fetch="all"
    )
    return render_template("pages/servicio/lista.html", servicios=rows)


@servicio_bp.route("/servicios/nuevo", methods=["GET", "POST"])
@permiso_required("servicios", "crear")
def crear():
    especialidades = execute_query(
        "SELECT id_especialidad, nombre FROM especialidad ORDER BY nombre",
        fetch="all"
    )

    if request.method == "POST":
        nombre          = request.form.get("nombre", "").strip()
        duracion_min    = request.form.get("duracion_min", "").strip()
        precio          = request.form.get("precio", "").strip()
        id_especialidad = request.form.get("id_especialidad") or None

        if not nombre or not duracion_min or not precio:
            flash("Nombre, duración y precio son obligatorios.", "error")
            return redirect(url_for("servicio.crear"))

        try:
            execute_query(
                """
                INSERT INTO servicio (nombre, duracion_min, precio, id_especialidad)
                VALUES (%s, %s, %s, %s)
                """,
                (nombre, int(duracion_min), float(precio), id_especialidad)
            )
            flash("Servicio creado correctamente.", "success")
            return redirect(url_for("servicio.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")
            return redirect(url_for("servicio.crear"))

    return render_template("pages/servicio/form.html",
                           accion="Crear",
                           servicio=None,
                           especialidades=especialidades)


@servicio_bp.route("/servicios/<int:id>/editar", methods=["GET", "POST"])
@permiso_required("servicios", "editar")
def editar(id):
    servicio = execute_query(
        "SELECT * FROM servicio WHERE id_servicio = %s",
        (id,), fetch="one"
    )
    if not servicio:
        flash("Servicio no encontrado.", "error")
        return redirect(url_for("servicio.listar"))

    especialidades = execute_query(
        "SELECT id_especialidad, nombre FROM especialidad ORDER BY nombre",
        fetch="all"
    )

    if request.method == "POST":
        nombre          = request.form.get("nombre", "").strip()
        duracion_min    = request.form.get("duracion_min", "").strip()
        precio          = request.form.get("precio", "").strip()
        id_especialidad = request.form.get("id_especialidad") or None

        if not nombre or not duracion_min or not precio:
            flash("Nombre, duración y precio son obligatorios.", "error")
            return redirect(url_for("servicio.editar", id=id))

        try:
            execute_query(
                """
                UPDATE servicio
                SET nombre=%s, duracion_min=%s, precio=%s, id_especialidad=%s
                WHERE id_servicio=%s
                """,
                (nombre, int(duracion_min), float(precio), id_especialidad, id)
            )
            flash("Servicio actualizado correctamente.", "success")
            return redirect(url_for("servicio.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")

    return render_template("pages/servicio/form.html",
                           accion="Editar",
                           servicio=servicio,
                           especialidades=especialidades)


@servicio_bp.route("/servicios/<int:id>/eliminar", methods=["POST"])
@permiso_required("servicios", "eliminar")
def eliminar(id):
    try:
        execute_query(
            "DELETE FROM servicio WHERE id_servicio = %s",
            (id,)
        )
        flash("Servicio eliminado.", "success")
    except Exception as e:
        flash(f"No se puede eliminar: {e}", "error")
    return redirect(url_for("servicio.listar"))