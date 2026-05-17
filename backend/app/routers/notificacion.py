from flask import Blueprint, render_template, session
from app.database import execute_query
from app.utils import permiso_required

notificacion_bp = Blueprint("notificacion", __name__)


@notificacion_bp.route("/notificaciones")
@permiso_required("notificaciones", "ver")
def listar():
    perfil = session.get("usuario_perfil")
    id_cliente = session.get("id_cliente")
    id_profesional = session.get("id_profesional")

    if perfil == "admin":
        # Admin ve todas
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
    elif perfil == "cliente":
        # Cliente ve solo las suyas
        rows = execute_query(
            """
            SELECT n.*,
                   cl.nombre || ' ' || cl.apellido AS cliente_nombre
            FROM notificacion n
            JOIN cita c ON n.id_cita = c.id_cita
            JOIN cliente cl ON c.id_cliente = cl.id_cliente
            WHERE c.id_cliente = %s
            ORDER BY n.fecha_envio DESC
            """,
            (id_cliente,), fetch="all"
        )
    elif perfil == "profesional":
        # Profesional ve las de sus citas
        rows = execute_query(
            """
            SELECT n.*,
                   cl.nombre || ' ' || cl.apellido AS cliente_nombre
            FROM notificacion n
            JOIN cita c ON n.id_cita = c.id_cita
            JOIN cliente cl ON c.id_cliente = cl.id_cliente
            WHERE c.id_profesional = %s
            ORDER BY n.fecha_envio DESC
            """,
            (id_profesional,), fetch="all"
        )
    else:
        rows = []

    return render_template("pages/notificacion/lista.html", notificaciones=rows)