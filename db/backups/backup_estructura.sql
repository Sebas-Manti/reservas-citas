--
-- PostgreSQL database dump
--

\restrict C3vazmxSRwm9I5JxCXvZsoT9Z6qjCGnZCMNjxd1VzJOwzW1Hhxjaj6A8ktii7ay

-- Dumped from database version 15.17 (Debian 15.17-1.pgdg13+1)
-- Dumped by pg_dump version 15.17 (Debian 15.17-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fn_auditoria(); Type: FUNCTION; Schema: public; Owner: reservas_user
--

CREATE FUNCTION public.fn_auditoria() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (tabla, operacion, usuario_bd, datos_antes, datos_despues)
        VALUES (
            TG_TABLE_NAME,
            'INSERT',
            current_user,
            NULL,
            row_to_json(NEW)::TEXT
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (tabla, operacion, usuario_bd, datos_antes, datos_despues)
        VALUES (
            TG_TABLE_NAME,
            'UPDATE',
            current_user,
            row_to_json(OLD)::TEXT,
            row_to_json(NEW)::TEXT
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (tabla, operacion, usuario_bd, datos_antes, datos_despues)
        VALUES (
            TG_TABLE_NAME,
            'DELETE',
            current_user,
            row_to_json(OLD)::TEXT,
            NULL
        );
        RETURN OLD;
    END IF;
END;
$$;


ALTER FUNCTION public.fn_auditoria() OWNER TO reservas_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actividad; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.actividad (
    id_actividad integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text
);


ALTER TABLE public.actividad OWNER TO reservas_user;

--
-- Name: actividad_id_actividad_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.actividad_id_actividad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.actividad_id_actividad_seq OWNER TO reservas_user;

--
-- Name: actividad_id_actividad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.actividad_id_actividad_seq OWNED BY public.actividad.id_actividad;


--
-- Name: auditoria; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.auditoria (
    id_auditoria integer NOT NULL,
    tabla character varying(50) NOT NULL,
    operacion character varying(10) NOT NULL,
    usuario_bd character varying(100) NOT NULL,
    fecha_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    datos_antes text,
    datos_despues text,
    CONSTRAINT auditoria_operacion_check CHECK (((operacion)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE public.auditoria OWNER TO reservas_user;

--
-- Name: auditoria_id_auditoria_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.auditoria_id_auditoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auditoria_id_auditoria_seq OWNER TO reservas_user;

--
-- Name: auditoria_id_auditoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.auditoria_id_auditoria_seq OWNED BY public.auditoria.id_auditoria;


--
-- Name: cita; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.cita (
    id_cita integer NOT NULL,
    id_cliente integer,
    id_profesional integer,
    id_servicio integer,
    id_slot integer,
    estado character varying(15) DEFAULT 'PENDIENTE'::character varying,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notas text,
    CONSTRAINT cita_estado_check CHECK (((estado)::text = ANY ((ARRAY['PENDIENTE'::character varying, 'CONFIRMADA'::character varying, 'CANCELADA'::character varying, 'COMPLETADA'::character varying])::text[])))
);


ALTER TABLE public.cita OWNER TO reservas_user;

--
-- Name: cita_id_cita_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.cita_id_cita_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cita_id_cita_seq OWNER TO reservas_user;

--
-- Name: cita_id_cita_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.cita_id_cita_seq OWNED BY public.cita.id_cita;


--
-- Name: cliente; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.cliente (
    id_cliente integer NOT NULL,
    nombre character varying(80) NOT NULL,
    apellido character varying(80) NOT NULL,
    telefono character varying(20),
    email character varying(150) NOT NULL,
    contrasena_hash character varying(255),
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cliente OWNER TO reservas_user;

--
-- Name: cliente_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.cliente_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cliente_id_cliente_seq OWNER TO reservas_user;

--
-- Name: cliente_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.cliente_id_cliente_seq OWNED BY public.cliente.id_cliente;


--
-- Name: especialidad; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text
);


ALTER TABLE public.especialidad OWNER TO reservas_user;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.especialidad_id_especialidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.especialidad_id_especialidad_seq OWNER TO reservas_user;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.especialidad_id_especialidad_seq OWNED BY public.especialidad.id_especialidad;


--
-- Name: gestion_actividad; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.gestion_actividad (
    id_gestion integer NOT NULL,
    id_perfil integer NOT NULL,
    id_actividad integer NOT NULL,
    puede_ver boolean DEFAULT false,
    puede_crear boolean DEFAULT false,
    puede_editar boolean DEFAULT false,
    puede_eliminar boolean DEFAULT false
);


ALTER TABLE public.gestion_actividad OWNER TO reservas_user;

--
-- Name: gestion_actividad_id_gestion_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.gestion_actividad_id_gestion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gestion_actividad_id_gestion_seq OWNER TO reservas_user;

--
-- Name: gestion_actividad_id_gestion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.gestion_actividad_id_gestion_seq OWNED BY public.gestion_actividad.id_gestion;


--
-- Name: notificacion; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.notificacion (
    id_notif integer NOT NULL,
    id_cita integer,
    tipo character varying(30),
    mensaje text,
    fecha_envio timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notificacion OWNER TO reservas_user;

--
-- Name: notificacion_id_notif_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.notificacion_id_notif_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notificacion_id_notif_seq OWNER TO reservas_user;

--
-- Name: notificacion_id_notif_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.notificacion_id_notif_seq OWNED BY public.notificacion.id_notif;


--
-- Name: perfil; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.perfil (
    id_perfil integer NOT NULL,
    nombre character varying(20) NOT NULL,
    CONSTRAINT perfil_nombre_check CHECK (((nombre)::text = ANY ((ARRAY['admin'::character varying, 'profesional'::character varying, 'cliente'::character varying])::text[])))
);


ALTER TABLE public.perfil OWNER TO reservas_user;

--
-- Name: perfil_id_perfil_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.perfil_id_perfil_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.perfil_id_perfil_seq OWNER TO reservas_user;

--
-- Name: perfil_id_perfil_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.perfil_id_perfil_seq OWNED BY public.perfil.id_perfil;


--
-- Name: profesional; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.profesional (
    id_profesional integer NOT NULL,
    nombre character varying(80) NOT NULL,
    apellido character varying(80) NOT NULL,
    email character varying(150) NOT NULL,
    id_especialidad integer,
    activo boolean DEFAULT true
);


ALTER TABLE public.profesional OWNER TO reservas_user;

--
-- Name: profesional_id_profesional_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.profesional_id_profesional_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.profesional_id_profesional_seq OWNER TO reservas_user;

--
-- Name: profesional_id_profesional_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.profesional_id_profesional_seq OWNED BY public.profesional.id_profesional;


--
-- Name: servicio; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.servicio (
    id_servicio integer NOT NULL,
    nombre character varying(100) NOT NULL,
    duracion_min integer NOT NULL,
    precio numeric(10,2) NOT NULL,
    id_especialidad integer,
    CONSTRAINT servicio_duracion_min_check CHECK ((duracion_min > 0)),
    CONSTRAINT servicio_precio_check CHECK ((precio >= (0)::numeric))
);


ALTER TABLE public.servicio OWNER TO reservas_user;

--
-- Name: servicio_id_servicio_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.servicio_id_servicio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.servicio_id_servicio_seq OWNER TO reservas_user;

--
-- Name: servicio_id_servicio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.servicio_id_servicio_seq OWNED BY public.servicio.id_servicio;


--
-- Name: slot; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.slot (
    id_slot integer NOT NULL,
    id_profesional integer,
    fecha_hora_inicio timestamp without time zone NOT NULL,
    fecha_hora_fin timestamp without time zone NOT NULL,
    estado character varying(10) DEFAULT 'LIBRE'::character varying,
    CONSTRAINT slot_check CHECK ((fecha_hora_fin > fecha_hora_inicio)),
    CONSTRAINT slot_estado_check CHECK (((estado)::text = ANY ((ARRAY['LIBRE'::character varying, 'OCUPADO'::character varying])::text[])))
);


ALTER TABLE public.slot OWNER TO reservas_user;

--
-- Name: slot_id_slot_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.slot_id_slot_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.slot_id_slot_seq OWNER TO reservas_user;

--
-- Name: slot_id_slot_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.slot_id_slot_seq OWNED BY public.slot.id_slot;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: reservas_user
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    id_perfil integer NOT NULL,
    id_cliente integer,
    id_profesional integer
);


ALTER TABLE public.usuario OWNER TO reservas_user;

--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: reservas_user
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usuario_id_usuario_seq OWNER TO reservas_user;

--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reservas_user
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- Name: actividad id_actividad; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.actividad ALTER COLUMN id_actividad SET DEFAULT nextval('public.actividad_id_actividad_seq'::regclass);


--
-- Name: auditoria id_auditoria; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.auditoria ALTER COLUMN id_auditoria SET DEFAULT nextval('public.auditoria_id_auditoria_seq'::regclass);


--
-- Name: cita id_cita; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cita ALTER COLUMN id_cita SET DEFAULT nextval('public.cita_id_cita_seq'::regclass);


--
-- Name: cliente id_cliente; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cliente ALTER COLUMN id_cliente SET DEFAULT nextval('public.cliente_id_cliente_seq'::regclass);


--
-- Name: especialidad id_especialidad; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.especialidad ALTER COLUMN id_especialidad SET DEFAULT nextval('public.especialidad_id_especialidad_seq'::regclass);


--
-- Name: gestion_actividad id_gestion; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.gestion_actividad ALTER COLUMN id_gestion SET DEFAULT nextval('public.gestion_actividad_id_gestion_seq'::regclass);


--
-- Name: notificacion id_notif; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.notificacion ALTER COLUMN id_notif SET DEFAULT nextval('public.notificacion_id_notif_seq'::regclass);


--
-- Name: perfil id_perfil; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.perfil ALTER COLUMN id_perfil SET DEFAULT nextval('public.perfil_id_perfil_seq'::regclass);


--
-- Name: profesional id_profesional; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.profesional ALTER COLUMN id_profesional SET DEFAULT nextval('public.profesional_id_profesional_seq'::regclass);


--
-- Name: servicio id_servicio; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.servicio ALTER COLUMN id_servicio SET DEFAULT nextval('public.servicio_id_servicio_seq'::regclass);


--
-- Name: slot id_slot; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.slot ALTER COLUMN id_slot SET DEFAULT nextval('public.slot_id_slot_seq'::regclass);


--
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- Name: actividad actividad_nombre_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.actividad
    ADD CONSTRAINT actividad_nombre_key UNIQUE (nombre);


--
-- Name: actividad actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.actividad
    ADD CONSTRAINT actividad_pkey PRIMARY KEY (id_actividad);


--
-- Name: auditoria auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_pkey PRIMARY KEY (id_auditoria);


--
-- Name: cita cita_id_slot_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_slot_key UNIQUE (id_slot);


--
-- Name: cita cita_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_pkey PRIMARY KEY (id_cita);


--
-- Name: cliente cliente_email_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_email_key UNIQUE (email);


--
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- Name: especialidad especialidad_nombre_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_nombre_key UNIQUE (nombre);


--
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- Name: gestion_actividad gestion_actividad_id_perfil_id_actividad_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.gestion_actividad
    ADD CONSTRAINT gestion_actividad_id_perfil_id_actividad_key UNIQUE (id_perfil, id_actividad);


--
-- Name: gestion_actividad gestion_actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.gestion_actividad
    ADD CONSTRAINT gestion_actividad_pkey PRIMARY KEY (id_gestion);


--
-- Name: notificacion notificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_pkey PRIMARY KEY (id_notif);


--
-- Name: perfil perfil_nombre_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.perfil
    ADD CONSTRAINT perfil_nombre_key UNIQUE (nombre);


--
-- Name: perfil perfil_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.perfil
    ADD CONSTRAINT perfil_pkey PRIMARY KEY (id_perfil);


--
-- Name: profesional profesional_email_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.profesional
    ADD CONSTRAINT profesional_email_key UNIQUE (email);


--
-- Name: profesional profesional_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.profesional
    ADD CONSTRAINT profesional_pkey PRIMARY KEY (id_profesional);


--
-- Name: servicio servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT servicio_pkey PRIMARY KEY (id_servicio);


--
-- Name: slot slot_id_profesional_fecha_hora_inicio_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.slot
    ADD CONSTRAINT slot_id_profesional_fecha_hora_inicio_key UNIQUE (id_profesional, fecha_hora_inicio);


--
-- Name: slot slot_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.slot
    ADD CONSTRAINT slot_pkey PRIMARY KEY (id_slot);


--
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: actividad trg_auditoria_actividad; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_actividad AFTER INSERT OR DELETE OR UPDATE ON public.actividad FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: cita trg_auditoria_cita; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_cita AFTER INSERT OR DELETE OR UPDATE ON public.cita FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: cliente trg_auditoria_cliente; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_cliente AFTER INSERT OR DELETE OR UPDATE ON public.cliente FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: especialidad trg_auditoria_especialidad; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_especialidad AFTER INSERT OR DELETE OR UPDATE ON public.especialidad FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: gestion_actividad trg_auditoria_gestion_actividad; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_gestion_actividad AFTER INSERT OR DELETE OR UPDATE ON public.gestion_actividad FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: notificacion trg_auditoria_notificacion; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_notificacion AFTER INSERT OR DELETE OR UPDATE ON public.notificacion FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: perfil trg_auditoria_perfil; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_perfil AFTER INSERT OR DELETE OR UPDATE ON public.perfil FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: profesional trg_auditoria_profesional; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_profesional AFTER INSERT OR DELETE OR UPDATE ON public.profesional FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: servicio trg_auditoria_servicio; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_servicio AFTER INSERT OR DELETE OR UPDATE ON public.servicio FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: slot trg_auditoria_slot; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_slot AFTER INSERT OR DELETE OR UPDATE ON public.slot FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: usuario trg_auditoria_usuario; Type: TRIGGER; Schema: public; Owner: reservas_user
--

CREATE TRIGGER trg_auditoria_usuario AFTER INSERT OR DELETE OR UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_auditoria();


--
-- Name: cita cita_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente) ON DELETE RESTRICT;


--
-- Name: cita cita_id_profesional_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_profesional_fkey FOREIGN KEY (id_profesional) REFERENCES public.profesional(id_profesional) ON DELETE RESTRICT;


--
-- Name: cita cita_id_servicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES public.servicio(id_servicio) ON DELETE RESTRICT;


--
-- Name: cita cita_id_slot_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.cita
    ADD CONSTRAINT cita_id_slot_fkey FOREIGN KEY (id_slot) REFERENCES public.slot(id_slot) ON DELETE RESTRICT;


--
-- Name: gestion_actividad gestion_actividad_id_actividad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.gestion_actividad
    ADD CONSTRAINT gestion_actividad_id_actividad_fkey FOREIGN KEY (id_actividad) REFERENCES public.actividad(id_actividad) ON DELETE CASCADE;


--
-- Name: gestion_actividad gestion_actividad_id_perfil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.gestion_actividad
    ADD CONSTRAINT gestion_actividad_id_perfil_fkey FOREIGN KEY (id_perfil) REFERENCES public.perfil(id_perfil) ON DELETE CASCADE;


--
-- Name: notificacion notificacion_id_cita_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_id_cita_fkey FOREIGN KEY (id_cita) REFERENCES public.cita(id_cita) ON DELETE CASCADE;


--
-- Name: profesional profesional_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.profesional
    ADD CONSTRAINT profesional_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad) ON DELETE SET NULL;


--
-- Name: servicio servicio_id_especialidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.servicio
    ADD CONSTRAINT servicio_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad) ON DELETE SET NULL;


--
-- Name: slot slot_id_profesional_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.slot
    ADD CONSTRAINT slot_id_profesional_fkey FOREIGN KEY (id_profesional) REFERENCES public.profesional(id_profesional) ON DELETE CASCADE;


--
-- Name: usuario usuario_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente) ON DELETE SET NULL;


--
-- Name: usuario usuario_id_perfil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_perfil_fkey FOREIGN KEY (id_perfil) REFERENCES public.perfil(id_perfil) ON DELETE RESTRICT;


--
-- Name: usuario usuario_id_profesional_fkey; Type: FK CONSTRAINT; Schema: public; Owner: reservas_user
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_profesional_fkey FOREIGN KEY (id_profesional) REFERENCES public.profesional(id_profesional) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict C3vazmxSRwm9I5JxCXvZsoT9Z6qjCGnZCMNjxd1VzJOwzW1Hhxjaj6A8ktii7ay

