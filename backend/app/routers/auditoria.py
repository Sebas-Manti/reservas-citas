# ============================================================
# ARCHIVO: backend/app/routers/auditoria.py
# ============================================================

from flask import Blueprint, render_template, request
from app.database import execute_query

auditoria_bp = Blueprint("auditoria", __name__)


@auditoria_bp.route("/auditoria")
def listar():
    # Filtros opcionales
    fecha  = request.args.get("fecha", "")
    tabla  = request.args.get("tabla", "")
    operacion = request.args.get("operacion", "")

    query = """
        SELECT *
        FROM auditoria
        WHERE 1=1
    """
    params = []

    if fecha:
        query += " AND DATE(fecha_hora) = %s"
        params.append(fecha)

    if tabla:
        query += " AND tabla = %s"
        params.append(tabla)

    if operacion:
        query += " AND operacion = %s"
        params.append(operacion)

    query += " ORDER BY fecha_hora DESC LIMIT 200"

    rows = execute_query(query, params or None, fetch="all")

    # Tablas disponibles para el filtro
    tablas = execute_query(
        "SELECT DISTINCT tabla FROM auditoria ORDER BY tabla",
        fetch="all"
    )

    return render_template("pages/auditoria/lista.html",
                           registros=rows,
                           tablas=tablas,
                           filtro_fecha=fecha,
                           filtro_tabla=tabla,
                           filtro_operacion=operacion)