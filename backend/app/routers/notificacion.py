# ============================================================
# ARCHIVO: backend/app/routers/notificacion.py
# ============================================================

from flask import Blueprint, render_template, request, redirect, url_for, flash
from app.database import execute_query

notificacion_bp = Blueprint("notificacion", __name__)


@notificacion_bp.route("/notificaciones")
def listar():
    rows = execute_query(
        """
        SELECT n.*,
               cl.nombre || ' ' || cl.apellido AS cliente_nombre
        FROM notificacion n
        JOIN cita c ON n.id_cita = c.id_cita
        JOIN cliente cl ON c.id_cliente = cl.id_cliente
        ORDER BY n.fecha_envio DESC
        """,
        fetch="all"
    )
    return render_template("pages/notificacion/lista.html", notificaciones=rows)