# ============================================================
# ARCHIVO: backend/app/routers/cliente.py
# ============================================================

from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.database import execute_query

cliente_bp = Blueprint("cliente", __name__)


@cliente_bp.route("/clientes")
def listar():
    rows = execute_query(
        "SELECT * FROM cliente ORDER BY id_cliente",
        fetch="all"
    )
    return render_template("pages/cliente/lista.html", clientes=rows)


@cliente_bp.route("/clientes/nuevo", methods=["GET", "POST"])
def crear():
    if request.method == "POST":
        nombre   = request.form.get("nombre", "").strip()
        apellido = request.form.get("apellido", "").strip()
        telefono = request.form.get("telefono", "").strip()
        email    = request.form.get("email", "").strip()

        if not nombre or not apellido or not email:
            flash("Nombre, apellido y email son obligatorios.", "error")
            return redirect(url_for("cliente.crear"))

        try:
            execute_query(
                """
                INSERT INTO cliente (nombre, apellido, telefono, email)
                VALUES (%s, %s, %s, %s)
                """,
                (nombre, apellido, telefono or None, email)
            )
            flash("Cliente creado correctamente.", "success")
            return redirect(url_for("cliente.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")
            return redirect(url_for("cliente.crear"))

    return render_template("pages/cliente/form.html",
                           accion="Crear", cliente=None)


@cliente_bp.route("/clientes/<int:id>/editar", methods=["GET", "POST"])
def editar(id):
    cliente = execute_query(
        "SELECT * FROM cliente WHERE id_cliente = %s",
        (id,), fetch="one"
    )
    if not cliente:
        flash("Cliente no encontrado.", "error")
        return redirect(url_for("cliente.listar"))

    if request.method == "POST":
        nombre   = request.form.get("nombre", "").strip()
        apellido = request.form.get("apellido", "").strip()
        telefono = request.form.get("telefono", "").strip()
        email    = request.form.get("email", "").strip()

        if not nombre or not apellido or not email:
            flash("Nombre, apellido y email son obligatorios.", "error")
            return redirect(url_for("cliente.editar", id=id))

        try:
            execute_query(
                """
                UPDATE cliente
                SET nombre=%s, apellido=%s, telefono=%s, email=%s
                WHERE id_cliente=%s
                """,
                (nombre, apellido, telefono or None, email, id)
            )
            flash("Cliente actualizado correctamente.", "success")
            return redirect(url_for("cliente.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")

    return render_template("pages/cliente/form.html",
                           accion="Editar", cliente=cliente)


@cliente_bp.route("/clientes/<int:id>/eliminar", methods=["POST"])
def eliminar(id):
    try:
        execute_query(
            "DELETE FROM cliente WHERE id_cliente = %s",
            (id,)
        )
        flash("Cliente eliminado.", "success")
    except Exception as e:
        flash(f"No se puede eliminar: {e}", "error")
    return redirect(url_for("cliente.listar"))