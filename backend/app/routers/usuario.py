# ============================================================
# ARCHIVO: backend/app/routers/usuario.py
# ============================================================

from flask import Blueprint, render_template, request, redirect, url_for, flash
from werkzeug.security import generate_password_hash
from app.database import execute_query
from app.utils import perfil_required

usuario_bp = Blueprint("usuario", __name__)


@usuario_bp.route("/usuarios")
@perfil_required("admin")
def listar():
    rows = execute_query(
        """
        SELECT u.id_usuario, u.email, p.nombre AS perfil_nombre,
               cl.nombre || ' ' || cl.apellido AS cliente_nombre,
               pr.nombre || ' ' || pr.apellido AS profesional_nombre
        FROM usuario u
        JOIN perfil p ON u.id_perfil = p.id_perfil
        LEFT JOIN cliente cl ON u.id_cliente = cl.id_cliente
        LEFT JOIN profesional pr ON u.id_profesional = pr.id_profesional
        ORDER BY u.id_usuario
        """,
        fetch="all"
    )
    return render_template("pages/usuario/lista.html", usuarios=rows)


@usuario_bp.route("/usuarios/nuevo", methods=["GET", "POST"])
@perfil_required("admin")
def crear():
    perfiles      = execute_query("SELECT * FROM perfil ORDER BY id_perfil", fetch="all")
    clientes      = execute_query(
        "SELECT id_cliente, nombre || ' ' || apellido AS nombre_completo FROM cliente ORDER BY nombre",
        fetch="all"
    )
    profesionales = execute_query(
        "SELECT id_profesional, nombre || ' ' || apellido AS nombre_completo FROM profesional ORDER BY nombre",
        fetch="all"
    )

    if request.method == "POST":
        email          = request.form.get("email", "").strip()
        password       = request.form.get("password", "").strip()
        id_perfil      = request.form.get("id_perfil") or None
        id_cliente     = request.form.get("id_cliente") or None
        id_profesional = request.form.get("id_profesional") or None

        if not email or not password or not id_perfil:
            flash("Email, contraseña y perfil son obligatorios.", "error")
            return redirect(url_for("usuario.crear"))

        try:
            execute_query(
                """
                INSERT INTO usuario (email, password_hash, id_perfil, id_cliente, id_profesional)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (email, generate_password_hash(password),
                 id_perfil, id_cliente, id_profesional)
            )
            flash("Usuario creado correctamente.", "success")
            return redirect(url_for("usuario.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")
            return redirect(url_for("usuario.crear"))

    return render_template("pages/usuario/form.html",
                           accion="Crear",
                           usuario=None,
                           perfiles=perfiles,
                           clientes=clientes,
                           profesionales=profesionales)


@usuario_bp.route("/usuarios/<int:id>/editar", methods=["GET", "POST"])
@perfil_required("admin")
def editar(id):
    usuario = execute_query(
        "SELECT * FROM usuario WHERE id_usuario = %s",
        (id,), fetch="one"
    )
    if not usuario:
        flash("Usuario no encontrado.", "error")
        return redirect(url_for("usuario.listar"))

    perfiles      = execute_query("SELECT * FROM perfil ORDER BY id_perfil", fetch="all")
    clientes      = execute_query(
        "SELECT id_cliente, nombre || ' ' || apellido AS nombre_completo FROM cliente ORDER BY nombre",
        fetch="all"
    )
    profesionales = execute_query(
        "SELECT id_profesional, nombre || ' ' || apellido AS nombre_completo FROM profesional ORDER BY nombre",
        fetch="all"
    )

    if request.method == "POST":
        email          = request.form.get("email", "").strip()
        password       = request.form.get("password", "").strip()
        id_perfil      = request.form.get("id_perfil") or None
        id_cliente     = request.form.get("id_cliente") or None
        id_profesional = request.form.get("id_profesional") or None

        if not email or not id_perfil:
            flash("Email y perfil son obligatorios.", "error")
            return redirect(url_for("usuario.editar", id=id))

        try:
            if password:
                execute_query(
                    """
                    UPDATE usuario
                    SET email=%s, password_hash=%s, id_perfil=%s,
                        id_cliente=%s, id_profesional=%s
                    WHERE id_usuario=%s
                    """,
                    (email, generate_password_hash(password),
                     id_perfil, id_cliente, id_profesional, id)
                )
            else:
                execute_query(
                    """
                    UPDATE usuario
                    SET email=%s, id_perfil=%s,
                        id_cliente=%s, id_profesional=%s
                    WHERE id_usuario=%s
                    """,
                    (email, id_perfil, id_cliente, id_profesional, id)
                )
            flash("Usuario actualizado correctamente.", "success")
            return redirect(url_for("usuario.listar"))
        except Exception as e:
            flash(f"Error: {e}", "error")

    return render_template("pages/usuario/form.html",
                           accion="Editar",
                           usuario=usuario,
                           perfiles=perfiles,
                           clientes=clientes,
                           profesionales=profesionales)


@usuario_bp.route("/usuarios/<int:id>/eliminar", methods=["POST"])
@perfil_required("admin")
def eliminar(id):
    try:
        execute_query(
            "DELETE FROM usuario WHERE id_usuario = %s",
            (id,)
        )
        flash("Usuario eliminado.", "success")
    except Exception as e:
        flash(f"No se puede eliminar: {e}", "error")
    return redirect(url_for("usuario.listar"))