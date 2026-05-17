# ============================================================
# ARCHIVO: backend/app/utils.py
# ============================================================

from functools import wraps
from flask import session, redirect, url_for, flash


def login_required(f):
    """Requiere que el usuario esté logueado."""
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get("usuario_id"):
            flash("Debes iniciar sesión.", "error")
            return redirect(url_for("auth.login"))
        return f(*args, **kwargs)
    return decorated


def perfil_required(*perfiles):
    """Requiere que el usuario tenga uno de los perfiles indicados."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not session.get("usuario_id"):
                flash("Debes iniciar sesión.", "error")
                return redirect(url_for("auth.login"))
            if session.get("usuario_perfil") not in perfiles:
                flash("No tienes permiso para acceder a esta sección.", "error")
                return redirect(url_for("index"))
            return f(*args, **kwargs)
        return decorated
    return decorator


def permiso_required(actividad, accion):
    """
    Requiere permiso específico sobre una actividad.
    accion: 'ver' | 'crear' | 'editar' | 'eliminar'
    """
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not session.get("usuario_id"):
                flash("Debes iniciar sesión.", "error")
                return redirect(url_for("auth.login"))
            permisos = session.get("permisos", {})
            if not permisos.get(actividad, {}).get(accion, False):
                flash("No tienes permiso para realizar esta acción.", "error")
                return redirect(url_for("index"))
            return f(*args, **kwargs)
        return decorated
    return decorator