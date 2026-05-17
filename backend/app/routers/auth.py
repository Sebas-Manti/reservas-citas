# ============================================================
# ARCHIVO: backend/app/routers/auth.py
# ============================================================

from flask import (Blueprint, render_template, request,
                   redirect, url_for, flash, session)
from werkzeug.security import check_password_hash
from app.database import execute_query

auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if session.get("usuario_id"):
        return redirect(url_for("index"))

    if request.method == "POST":
        email    = request.form.get("email", "").strip()
        password = request.form.get("password", "")

        if not email or not password:
            flash("Email y contraseña son obligatorios.", "error")
            return redirect(url_for("auth.login"))

        usuario = execute_query(
            """
            SELECT u.*, p.nombre AS perfil_nombre
            FROM usuario u
            JOIN perfil p ON u.id_perfil = p.id_perfil
            WHERE u.email = %s
            """,
            (email,), fetch="one"
        )

        if not usuario or not check_password_hash(usuario["password_hash"], password):
            flash("Email o contraseña incorrectos.", "error")
            return redirect(url_for("auth.login"))

        # Guardar en sesión
        session["usuario_id"]     = usuario["id_usuario"]
        session["usuario_email"]  = usuario["email"]
        session["usuario_perfil"] = usuario["perfil_nombre"]
        session["id_cliente"]     = usuario["id_cliente"]
        session["id_profesional"] = usuario["id_profesional"]

        # Cargar permisos del perfil en sesión
        permisos = execute_query(
            """
            SELECT a.nombre AS actividad,
                   g.puede_ver, g.puede_crear,
                   g.puede_editar, g.puede_eliminar
            FROM gestion_actividad g
            JOIN actividad a ON g.id_actividad = a.id_actividad
            WHERE g.id_perfil = %s
            """,
            (usuario["id_perfil"],), fetch="all"
        )

        session["permisos"] = {
            p["actividad"]: {
                "ver":      p["puede_ver"],
                "crear":    p["puede_crear"],
                "editar":   p["puede_editar"],
                "eliminar": p["puede_eliminar"]
            }
            for p in permisos
        }

        flash(f"Bienvenido, {usuario['email']}", "success")
        return redirect(url_for("index"))

    return render_template("pages/auth/login.html")


@auth_bp.route("/logout")
def logout():
    session.clear()
    flash("Sesión cerrada.", "info")
    return redirect(url_for("auth.login"))