# ============================================================
# ARCHIVO: backend/app/main.py
# ============================================================

from flask import Flask, render_template, redirect, url_for, session
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "dev-secret-key")

# ── Blueprints ──────────────────────────────────────────────
from app.routers.auth          import auth_bp
from app.routers.especialidad  import especialidad_bp
from app.routers.profesional   import profesional_bp
from app.routers.cliente       import cliente_bp
from app.routers.servicio      import servicio_bp
from app.routers.slot          import slot_bp
from app.routers.cita          import cita_bp
from app.routers.notificacion  import notificacion_bp
from app.routers.auditoria     import auditoria_bp
from app.routers.usuario import usuario_bp

app.register_blueprint(auth_bp)
app.register_blueprint(especialidad_bp)
app.register_blueprint(profesional_bp)
app.register_blueprint(cliente_bp)
app.register_blueprint(servicio_bp)
app.register_blueprint(slot_bp)
app.register_blueprint(cita_bp)
app.register_blueprint(notificacion_bp)
app.register_blueprint(auditoria_bp)
app.register_blueprint(usuario_bp)


@app.route("/")
def index():
    if not session.get("usuario_id"):
        return redirect(url_for("auth.login"))
    return render_template("index.html")


if __name__ == "__main__":
    app.run(debug=True)