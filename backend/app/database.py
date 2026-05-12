# ============================================================
# PROYECTO: Reservas-Citas
# ARCHIVO:  backend/app/database.py
# DESC:     Conexión centralizada a PostgreSQL con psycopg2
# ============================================================

import psycopg2
from psycopg2 import pool
from dotenv import load_dotenv
import os

load_dotenv()

# Pool de conexiones: mínimo 1, máximo 10 conexiones simultáneas
connection_pool = psycopg2.pool.SimpleConnectionPool(
    minconn=1,
    maxconn=10,
    host=os.getenv("POSTGRES_HOST", "localhost"),
    port=os.getenv("POSTGRES_PORT", "5432"),
    dbname=os.getenv("POSTGRES_DB"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD")
)


def get_connection():
    """Obtiene una conexión del pool."""
    return connection_pool.getconn()


def release_connection(conn):
    """Devuelve la conexión al pool."""
    connection_pool.putconn(conn)


def execute_query(query, params=None, fetch=None):
    """
    Ejecuta un query y maneja la conexión automáticamente.

    Args:
        query  : SQL string con %s como placeholders
        params : tupla de parámetros (opcional)
        fetch  : 'one' | 'all' | None (para INSERT/UPDATE/DELETE)

    Returns:
        - fetch='one'  → dict con una fila
        - fetch='all'  → lista de dicts
        - fetch=None   → None (operaciones de escritura)
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(query, params)

            if fetch == "one":
                row = cur.fetchone()
                if row is None:
                    return None
                columns = [desc[0] for desc in cur.description]
                return dict(zip(columns, row))

            elif fetch == "all":
                rows = cur.fetchall()
                columns = [desc[0] for desc in cur.description]
                return [dict(zip(columns, row)) for row in rows]

            else:
                conn.commit()
                return None

    except Exception as e:
        conn.rollback()
        raise e

    finally:
        release_connection(conn)