--
-- PostgreSQL database dump
--

\restrict 9mzzsyK901v4G9oi1GxOlKkPU8KWeIiCMPL96As7n2KwPv3u2mzy3KV8zMgU5J4

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
-- Data for Name: actividad; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.actividad (id_actividad, nombre, descripcion) FROM stdin;
1	especialidades	Gestión de especialidades médicas
2	profesionales	Gestión de profesionales
3	clientes	Gestión de clientes
4	servicios	Gestión de servicios
5	slots	Gestión de slots de disponibilidad
6	citas	Gestión de citas
7	notificaciones	Visualización de notificaciones
8	auditoria	Reporte de auditoría del sistema
\.


--
-- Data for Name: auditoria; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.auditoria (id_auditoria, tabla, operacion, usuario_bd, fecha_hora, datos_antes, datos_despues) FROM stdin;
1	especialidad	INSERT	reservas_user	2026-05-15 23:14:27.841444	\N	{"id_especialidad":1,"nombre":"Medicina General","descripcion":"Atención médica primaria y diagnóstico"}
2	especialidad	INSERT	reservas_user	2026-05-15 23:14:27.841444	\N	{"id_especialidad":2,"nombre":"Odontología","descripcion":"Salud bucal y tratamientos dentales"}
3	especialidad	INSERT	reservas_user	2026-05-15 23:14:27.841444	\N	{"id_especialidad":3,"nombre":"Psicología","descripcion":"Salud mental y terapia cognitiva"}
4	especialidad	INSERT	reservas_user	2026-05-15 23:14:27.841444	\N	{"id_especialidad":4,"nombre":"Nutrición","descripcion":"Planes alimentarios y asesoría dietética"}
5	especialidad	INSERT	reservas_user	2026-05-15 23:14:27.841444	\N	{"id_especialidad":5,"nombre":"Fisioterapia","descripcion":"Rehabilitación física y deportiva"}
6	profesional	INSERT	reservas_user	2026-05-15 23:14:27.844062	\N	{"id_profesional":1,"nombre":"Carlos","apellido":"Ramírez","email":"c.ramirez@clinica.com","id_especialidad":1,"activo":true}
7	profesional	INSERT	reservas_user	2026-05-15 23:14:27.844062	\N	{"id_profesional":2,"nombre":"Ana","apellido":"Torres","email":"a.torres@clinica.com","id_especialidad":2,"activo":true}
8	profesional	INSERT	reservas_user	2026-05-15 23:14:27.844062	\N	{"id_profesional":3,"nombre":"Luis","apellido":"Medina","email":"l.medina@clinica.com","id_especialidad":3,"activo":true}
9	profesional	INSERT	reservas_user	2026-05-15 23:14:27.844062	\N	{"id_profesional":4,"nombre":"Sofía","apellido":"Herrera","email":"s.herrera@clinica.com","id_especialidad":4,"activo":true}
10	profesional	INSERT	reservas_user	2026-05-15 23:14:27.844062	\N	{"id_profesional":5,"nombre":"Jorge","apellido":"Castro","email":"j.castro@clinica.com","id_especialidad":5,"activo":true}
11	cliente	INSERT	reservas_user	2026-05-15 23:14:27.845382	\N	{"id_cliente":1,"nombre":"María","apellido":"López","telefono":"3001112233","email":"maria.lopez@email.com","contrasena_hash":null,"fecha_registro":"2026-05-15T23:14:27.845382"}
12	cliente	INSERT	reservas_user	2026-05-15 23:14:27.845382	\N	{"id_cliente":2,"nombre":"Pedro","apellido":"González","telefono":"3104445566","email":"pedro.gonzalez@email.com","contrasena_hash":null,"fecha_registro":"2026-05-15T23:14:27.845382"}
13	cliente	INSERT	reservas_user	2026-05-15 23:14:27.845382	\N	{"id_cliente":3,"nombre":"Laura","apellido":"Jiménez","telefono":"3207778899","email":"laura.jimenez@email.com","contrasena_hash":null,"fecha_registro":"2026-05-15T23:14:27.845382"}
14	cliente	INSERT	reservas_user	2026-05-15 23:14:27.845382	\N	{"id_cliente":4,"nombre":"Andrés","apellido":"Morales","telefono":"3110001122","email":"andres.morales@email.com","contrasena_hash":null,"fecha_registro":"2026-05-15T23:14:27.845382"}
15	cliente	INSERT	reservas_user	2026-05-15 23:14:27.845382	\N	{"id_cliente":5,"nombre":"Camila","apellido":"Ruiz","telefono":"3153334455","email":"camila.ruiz@email.com","contrasena_hash":null,"fecha_registro":"2026-05-15T23:14:27.845382"}
16	servicio	INSERT	reservas_user	2026-05-15 23:14:27.845944	\N	{"id_servicio":1,"nombre":"Consulta general","duracion_min":30,"precio":80000.00,"id_especialidad":1}
17	servicio	INSERT	reservas_user	2026-05-15 23:14:27.845944	\N	{"id_servicio":2,"nombre":"Limpieza dental","duracion_min":45,"precio":120000.00,"id_especialidad":2}
18	servicio	INSERT	reservas_user	2026-05-15 23:14:27.845944	\N	{"id_servicio":3,"nombre":"Sesión de terapia","duracion_min":60,"precio":150000.00,"id_especialidad":3}
19	servicio	INSERT	reservas_user	2026-05-15 23:14:27.845944	\N	{"id_servicio":4,"nombre":"Plan nutricional","duracion_min":40,"precio":100000.00,"id_especialidad":4}
20	servicio	INSERT	reservas_user	2026-05-15 23:14:27.845944	\N	{"id_servicio":5,"nombre":"Rehabilitación muscular","duracion_min":50,"precio":90000.00,"id_especialidad":5}
21	slot	INSERT	reservas_user	2026-05-15 23:14:27.84674	\N	{"id_slot":1,"id_profesional":1,"fecha_hora_inicio":"2026-05-17T07:14:27.84674","fecha_hora_fin":"2026-05-17T07:44:27.84674","estado":"LIBRE"}
22	slot	INSERT	reservas_user	2026-05-15 23:14:27.84674	\N	{"id_slot":2,"id_profesional":1,"fecha_hora_inicio":"2026-05-17T08:14:27.84674","fecha_hora_fin":"2026-05-17T08:44:27.84674","estado":"LIBRE"}
23	slot	INSERT	reservas_user	2026-05-15 23:14:27.84674	\N	{"id_slot":3,"id_profesional":2,"fecha_hora_inicio":"2026-05-18T09:14:27.84674","fecha_hora_fin":"2026-05-18T09:59:27.84674","estado":"LIBRE"}
24	slot	INSERT	reservas_user	2026-05-15 23:14:27.84674	\N	{"id_slot":4,"id_profesional":3,"fecha_hora_inicio":"2026-05-18T13:14:27.84674","fecha_hora_fin":"2026-05-18T14:14:27.84674","estado":"LIBRE"}
25	slot	INSERT	reservas_user	2026-05-15 23:14:27.84674	\N	{"id_slot":5,"id_profesional":4,"fecha_hora_inicio":"2026-05-19T10:14:27.84674","fecha_hora_fin":"2026-05-19T10:54:27.84674","estado":"LIBRE"}
26	cita	INSERT	reservas_user	2026-05-15 23:14:27.847546	\N	{"id_cita":1,"id_cliente":1,"id_profesional":1,"id_servicio":1,"id_slot":1,"estado":"CONFIRMADA","fecha_creacion":"2026-05-15T23:14:27.847546","notas":"Primera consulta"}
27	cita	INSERT	reservas_user	2026-05-15 23:14:27.847546	\N	{"id_cita":2,"id_cliente":2,"id_profesional":2,"id_servicio":2,"id_slot":3,"estado":"CONFIRMADA","fecha_creacion":"2026-05-15T23:14:27.847546","notas":null}
28	cita	INSERT	reservas_user	2026-05-15 23:14:27.847546	\N	{"id_cita":3,"id_cliente":3,"id_profesional":3,"id_servicio":3,"id_slot":4,"estado":"CONFIRMADA","fecha_creacion":"2026-05-15T23:14:27.847546","notas":"Seguimiento mensual"}
29	cita	INSERT	reservas_user	2026-05-15 23:14:27.847546	\N	{"id_cita":4,"id_cliente":4,"id_profesional":4,"id_servicio":4,"id_slot":5,"estado":"CONFIRMADA","fecha_creacion":"2026-05-15T23:14:27.847546","notas":null}
30	slot	UPDATE	reservas_user	2026-05-15 23:14:27.84841	{"id_slot":1,"id_profesional":1,"fecha_hora_inicio":"2026-05-17T07:14:27.84674","fecha_hora_fin":"2026-05-17T07:44:27.84674","estado":"LIBRE"}	{"id_slot":1,"id_profesional":1,"fecha_hora_inicio":"2026-05-17T07:14:27.84674","fecha_hora_fin":"2026-05-17T07:44:27.84674","estado":"OCUPADO"}
31	slot	UPDATE	reservas_user	2026-05-15 23:14:27.84841	{"id_slot":3,"id_profesional":2,"fecha_hora_inicio":"2026-05-18T09:14:27.84674","fecha_hora_fin":"2026-05-18T09:59:27.84674","estado":"LIBRE"}	{"id_slot":3,"id_profesional":2,"fecha_hora_inicio":"2026-05-18T09:14:27.84674","fecha_hora_fin":"2026-05-18T09:59:27.84674","estado":"OCUPADO"}
32	slot	UPDATE	reservas_user	2026-05-15 23:14:27.84841	{"id_slot":4,"id_profesional":3,"fecha_hora_inicio":"2026-05-18T13:14:27.84674","fecha_hora_fin":"2026-05-18T14:14:27.84674","estado":"LIBRE"}	{"id_slot":4,"id_profesional":3,"fecha_hora_inicio":"2026-05-18T13:14:27.84674","fecha_hora_fin":"2026-05-18T14:14:27.84674","estado":"OCUPADO"}
33	slot	UPDATE	reservas_user	2026-05-15 23:14:27.84841	{"id_slot":5,"id_profesional":4,"fecha_hora_inicio":"2026-05-19T10:14:27.84674","fecha_hora_fin":"2026-05-19T10:54:27.84674","estado":"LIBRE"}	{"id_slot":5,"id_profesional":4,"fecha_hora_inicio":"2026-05-19T10:14:27.84674","fecha_hora_fin":"2026-05-19T10:54:27.84674","estado":"OCUPADO"}
34	notificacion	INSERT	reservas_user	2026-05-15 23:14:27.848924	\N	{"id_notif":1,"id_cita":1,"tipo":"CONFIRMACION","mensaje":"Cita confirmada exitosamente.","fecha_envio":"2026-05-15T23:14:27.848924"}
35	notificacion	INSERT	reservas_user	2026-05-15 23:14:27.848924	\N	{"id_notif":2,"id_cita":2,"tipo":"RECORDATORIO","mensaje":"Recuerde su cita mañana.","fecha_envio":"2026-05-15T23:14:27.848924"}
36	notificacion	INSERT	reservas_user	2026-05-15 23:14:27.848924	\N	{"id_notif":3,"id_cita":3,"tipo":"CONFIRMACION","mensaje":"Cita de terapia confirmada.","fecha_envio":"2026-05-15T23:14:27.848924"}
37	notificacion	INSERT	reservas_user	2026-05-15 23:14:27.848924	\N	{"id_notif":4,"id_cita":4,"tipo":"CONFIRMACION","mensaje":"Cita de nutrición confirmada.","fecha_envio":"2026-05-15T23:14:27.848924"}
38	notificacion	INSERT	reservas_user	2026-05-15 23:14:27.848924	\N	{"id_notif":5,"id_cita":1,"tipo":"RECORDATORIO","mensaje":"Su cita es en 24 horas.","fecha_envio":"2026-05-15T23:14:27.848924"}
39	perfil	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_perfil":1,"nombre":"admin"}
40	perfil	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_perfil":2,"nombre":"profesional"}
41	perfil	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_perfil":3,"nombre":"cliente"}
42	actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_actividad":1,"nombre":"especialidades","descripcion":"Gestión de especialidades médicas"}
43	actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_actividad":2,"nombre":"profesionales","descripcion":"Gestión de profesionales"}
44	actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_actividad":3,"nombre":"clientes","descripcion":"Gestión de clientes"}
45	actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_actividad":4,"nombre":"servicios","descripcion":"Gestión de servicios"}
46	actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_actividad":5,"nombre":"slots","descripcion":"Gestión de slots de disponibilidad"}
47	actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_actividad":6,"nombre":"citas","descripcion":"Gestión de citas"}
48	actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_actividad":7,"nombre":"notificaciones","descripcion":"Visualización de notificaciones"}
49	actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_actividad":8,"nombre":"auditoria","descripcion":"Reporte de auditoría del sistema"}
50	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":1,"id_perfil":1,"id_actividad":1,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":true}
51	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":2,"id_perfil":1,"id_actividad":2,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":true}
52	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":3,"id_perfil":1,"id_actividad":3,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":true}
53	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":4,"id_perfil":1,"id_actividad":4,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":true}
54	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":5,"id_perfil":1,"id_actividad":5,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":true}
55	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":6,"id_perfil":1,"id_actividad":6,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":true}
56	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":7,"id_perfil":1,"id_actividad":7,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":true}
57	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":8,"id_perfil":1,"id_actividad":8,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":true}
58	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":9,"id_perfil":2,"id_actividad":1,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
59	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":10,"id_perfil":2,"id_actividad":2,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
60	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":11,"id_perfil":2,"id_actividad":3,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
61	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":12,"id_perfil":2,"id_actividad":4,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
62	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":13,"id_perfil":2,"id_actividad":5,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":false}
63	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":14,"id_perfil":2,"id_actividad":6,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
64	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":15,"id_perfil":2,"id_actividad":7,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
65	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":16,"id_perfil":2,"id_actividad":8,"puede_ver":false,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
66	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":17,"id_perfil":3,"id_actividad":1,"puede_ver":false,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
67	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":18,"id_perfil":3,"id_actividad":2,"puede_ver":false,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
68	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":19,"id_perfil":3,"id_actividad":3,"puede_ver":false,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
69	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":20,"id_perfil":3,"id_actividad":4,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
70	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":21,"id_perfil":3,"id_actividad":5,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
71	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":22,"id_perfil":3,"id_actividad":6,"puede_ver":true,"puede_crear":true,"puede_editar":true,"puede_eliminar":false}
72	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":23,"id_perfil":3,"id_actividad":7,"puede_ver":true,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
73	gestion_actividad	INSERT	reservas_user	2026-05-15 23:15:46.312231	\N	{"id_gestion":24,"id_perfil":3,"id_actividad":8,"puede_ver":false,"puede_crear":false,"puede_editar":false,"puede_eliminar":false}
74	servicio	INSERT	reservas_user	2026-05-15 23:15:59.793774	\N	{"id_servicio":6,"nombre":"Consulta general","duracion_min":30,"precio":80000.00,"id_especialidad":1}
75	servicio	INSERT	reservas_user	2026-05-15 23:15:59.793774	\N	{"id_servicio":7,"nombre":"Limpieza dental","duracion_min":45,"precio":120000.00,"id_especialidad":2}
76	servicio	INSERT	reservas_user	2026-05-15 23:15:59.793774	\N	{"id_servicio":8,"nombre":"Sesión de terapia","duracion_min":60,"precio":150000.00,"id_especialidad":3}
77	servicio	INSERT	reservas_user	2026-05-15 23:15:59.793774	\N	{"id_servicio":9,"nombre":"Plan nutricional","duracion_min":40,"precio":100000.00,"id_especialidad":4}
78	servicio	INSERT	reservas_user	2026-05-15 23:15:59.793774	\N	{"id_servicio":10,"nombre":"Rehabilitación muscular","duracion_min":50,"precio":90000.00,"id_especialidad":5}
79	slot	INSERT	reservas_user	2026-05-15 23:15:59.795782	\N	{"id_slot":6,"id_profesional":1,"fecha_hora_inicio":"2026-05-17T07:15:59.795782","fecha_hora_fin":"2026-05-17T07:45:59.795782","estado":"LIBRE"}
80	slot	INSERT	reservas_user	2026-05-15 23:15:59.795782	\N	{"id_slot":7,"id_profesional":1,"fecha_hora_inicio":"2026-05-17T08:15:59.795782","fecha_hora_fin":"2026-05-17T08:45:59.795782","estado":"LIBRE"}
81	slot	INSERT	reservas_user	2026-05-15 23:15:59.795782	\N	{"id_slot":8,"id_profesional":2,"fecha_hora_inicio":"2026-05-18T09:15:59.795782","fecha_hora_fin":"2026-05-18T10:00:59.795782","estado":"LIBRE"}
82	slot	INSERT	reservas_user	2026-05-15 23:15:59.795782	\N	{"id_slot":9,"id_profesional":3,"fecha_hora_inicio":"2026-05-18T13:15:59.795782","fecha_hora_fin":"2026-05-18T14:15:59.795782","estado":"LIBRE"}
83	slot	INSERT	reservas_user	2026-05-15 23:15:59.795782	\N	{"id_slot":10,"id_profesional":4,"fecha_hora_inicio":"2026-05-19T10:15:59.795782","fecha_hora_fin":"2026-05-19T10:55:59.795782","estado":"LIBRE"}
84	slot	UPDATE	reservas_user	2026-05-15 23:15:59.796927	{"id_slot":1,"id_profesional":1,"fecha_hora_inicio":"2026-05-17T07:14:27.84674","fecha_hora_fin":"2026-05-17T07:44:27.84674","estado":"OCUPADO"}	{"id_slot":1,"id_profesional":1,"fecha_hora_inicio":"2026-05-17T07:14:27.84674","fecha_hora_fin":"2026-05-17T07:44:27.84674","estado":"OCUPADO"}
85	slot	UPDATE	reservas_user	2026-05-15 23:15:59.796927	{"id_slot":3,"id_profesional":2,"fecha_hora_inicio":"2026-05-18T09:14:27.84674","fecha_hora_fin":"2026-05-18T09:59:27.84674","estado":"OCUPADO"}	{"id_slot":3,"id_profesional":2,"fecha_hora_inicio":"2026-05-18T09:14:27.84674","fecha_hora_fin":"2026-05-18T09:59:27.84674","estado":"OCUPADO"}
86	slot	UPDATE	reservas_user	2026-05-15 23:15:59.796927	{"id_slot":4,"id_profesional":3,"fecha_hora_inicio":"2026-05-18T13:14:27.84674","fecha_hora_fin":"2026-05-18T14:14:27.84674","estado":"OCUPADO"}	{"id_slot":4,"id_profesional":3,"fecha_hora_inicio":"2026-05-18T13:14:27.84674","fecha_hora_fin":"2026-05-18T14:14:27.84674","estado":"OCUPADO"}
87	slot	UPDATE	reservas_user	2026-05-15 23:15:59.796927	{"id_slot":5,"id_profesional":4,"fecha_hora_inicio":"2026-05-19T10:14:27.84674","fecha_hora_fin":"2026-05-19T10:54:27.84674","estado":"OCUPADO"}	{"id_slot":5,"id_profesional":4,"fecha_hora_inicio":"2026-05-19T10:14:27.84674","fecha_hora_fin":"2026-05-19T10:54:27.84674","estado":"OCUPADO"}
88	notificacion	INSERT	reservas_user	2026-05-15 23:15:59.797755	\N	{"id_notif":6,"id_cita":1,"tipo":"CONFIRMACION","mensaje":"Cita confirmada exitosamente.","fecha_envio":"2026-05-15T23:15:59.797755"}
89	notificacion	INSERT	reservas_user	2026-05-15 23:15:59.797755	\N	{"id_notif":7,"id_cita":2,"tipo":"RECORDATORIO","mensaje":"Recuerde su cita mañana.","fecha_envio":"2026-05-15T23:15:59.797755"}
90	notificacion	INSERT	reservas_user	2026-05-15 23:15:59.797755	\N	{"id_notif":8,"id_cita":3,"tipo":"CONFIRMACION","mensaje":"Cita de terapia confirmada.","fecha_envio":"2026-05-15T23:15:59.797755"}
91	notificacion	INSERT	reservas_user	2026-05-15 23:15:59.797755	\N	{"id_notif":9,"id_cita":4,"tipo":"CONFIRMACION","mensaje":"Cita de nutrición confirmada.","fecha_envio":"2026-05-15T23:15:59.797755"}
92	notificacion	INSERT	reservas_user	2026-05-15 23:15:59.797755	\N	{"id_notif":10,"id_cita":1,"tipo":"RECORDATORIO","mensaje":"Su cita es en 24 horas.","fecha_envio":"2026-05-15T23:15:59.797755"}
93	usuario	INSERT	reservas_user	2026-05-15 23:18:51.973727	\N	{"id_usuario":1,"email":"admin@reservas.com","password_hash":"scrypt:32768:8:1$ON46EKg2GfiS0J8O$07cb3225701744bd5f43907ae71b50739d862a6dd4d769e5f6bf06fda71221fc883548aa01062c7259b0b5f42a51cec6d70579b5c37e69e879e5cde32056ab36","id_perfil":1,"id_cliente":null,"id_profesional":null}
94	usuario	INSERT	reservas_user	2026-05-15 23:18:51.973727	\N	{"id_usuario":2,"email":"c.ramirez@clinica.com","password_hash":"scrypt:32768:8:1$LQQ8kd8rMsBeH8Ha$69d6815c2b376c3e0c1bb8fedd523114c4c07b449ea1be598258d19032cbc553d7207bc45531e54e34f2b64b2289dbdeea822c18c7ab85813ff322837534a251","id_perfil":2,"id_cliente":null,"id_profesional":1}
95	usuario	INSERT	reservas_user	2026-05-15 23:18:51.973727	\N	{"id_usuario":3,"email":"maria.lopez@email.com","password_hash":"scrypt:32768:8:1$rLGGOfo5ZN59iqnS$02b038ebf1b4528f3d8ed3e5c9d71a2937453e1b14d6b58de3fca3bd0c8b8483979a7bbbc636b3129367c8461ddbe8e4a04d7ec87d3d94f45f27a66e5e084d36","id_perfil":3,"id_cliente":1,"id_profesional":null}
96	servicio	INSERT	reservas_user	2026-05-17 00:46:54.179382	\N	{"id_servicio":11,"nombre":"TEST","duracion_min":45,"precio":40000.00,"id_especialidad":3}
97	usuario	UPDATE	reservas_user	2026-05-17 01:46:57.563035	{"id_usuario":1,"email":"admin@reservas.com","password_hash":"scrypt:32768:8:1$ON46EKg2GfiS0J8O$07cb3225701744bd5f43907ae71b50739d862a6dd4d769e5f6bf06fda71221fc883548aa01062c7259b0b5f42a51cec6d70579b5c37e69e879e5cde32056ab36","id_perfil":1,"id_cliente":null,"id_profesional":null}	{"id_usuario":1,"email":"admin-TEST@reservas.com","password_hash":"scrypt:32768:8:1$ON46EKg2GfiS0J8O$07cb3225701744bd5f43907ae71b50739d862a6dd4d769e5f6bf06fda71221fc883548aa01062c7259b0b5f42a51cec6d70579b5c37e69e879e5cde32056ab36","id_perfil":1,"id_cliente":null,"id_profesional":null}
98	usuario	INSERT	reservas_user	2026-05-17 01:47:32.192302	\N	{"id_usuario":4,"email":"TEST@TEST-Admin.com","password_hash":"scrypt:32768:8:1$ZHpMbdTO5XSDmSWL$d92f976cf34b51a4d1b3c94a156ec64ec116e73d426326e8bcd4db1d7574454485ab33d0664b68bb79ddd6aa85ff0419e94ab6d1d0141690e7766ee32d132da3","id_perfil":2,"id_cliente":5,"id_profesional":null}
99	usuario	DELETE	reservas_user	2026-05-17 01:47:40.809605	{"id_usuario":4,"email":"TEST@TEST-Admin.com","password_hash":"scrypt:32768:8:1$ZHpMbdTO5XSDmSWL$d92f976cf34b51a4d1b3c94a156ec64ec116e73d426326e8bcd4db1d7574454485ab33d0664b68bb79ddd6aa85ff0419e94ab6d1d0141690e7766ee32d132da3","id_perfil":2,"id_cliente":5,"id_profesional":null}	\N
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.cita (id_cita, id_cliente, id_profesional, id_servicio, id_slot, estado, fecha_creacion, notas) FROM stdin;
1	1	1	1	1	CONFIRMADA	2026-05-15 23:14:27.847546	Primera consulta
2	2	2	2	3	CONFIRMADA	2026-05-15 23:14:27.847546	\N
3	3	3	3	4	CONFIRMADA	2026-05-15 23:14:27.847546	Seguimiento mensual
4	4	4	4	5	CONFIRMADA	2026-05-15 23:14:27.847546	\N
\.


--
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.cliente (id_cliente, nombre, apellido, telefono, email, contrasena_hash, fecha_registro) FROM stdin;
1	María	López	3001112233	maria.lopez@email.com	\N	2026-05-15 23:14:27.845382
2	Pedro	González	3104445566	pedro.gonzalez@email.com	\N	2026-05-15 23:14:27.845382
3	Laura	Jiménez	3207778899	laura.jimenez@email.com	\N	2026-05-15 23:14:27.845382
4	Andrés	Morales	3110001122	andres.morales@email.com	\N	2026-05-15 23:14:27.845382
5	Camila	Ruiz	3153334455	camila.ruiz@email.com	\N	2026-05-15 23:14:27.845382
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.especialidad (id_especialidad, nombre, descripcion) FROM stdin;
1	Medicina General	Atención médica primaria y diagnóstico
2	Odontología	Salud bucal y tratamientos dentales
3	Psicología	Salud mental y terapia cognitiva
4	Nutrición	Planes alimentarios y asesoría dietética
5	Fisioterapia	Rehabilitación física y deportiva
\.


--
-- Data for Name: gestion_actividad; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.gestion_actividad (id_gestion, id_perfil, id_actividad, puede_ver, puede_crear, puede_editar, puede_eliminar) FROM stdin;
1	1	1	t	t	t	t
2	1	2	t	t	t	t
3	1	3	t	t	t	t
4	1	4	t	t	t	t
5	1	5	t	t	t	t
6	1	6	t	t	t	t
7	1	7	t	t	t	t
8	1	8	t	t	t	t
9	2	1	t	f	f	f
10	2	2	t	f	f	f
11	2	3	t	f	f	f
12	2	4	t	f	f	f
13	2	5	t	t	t	f
14	2	6	t	f	f	f
15	2	7	t	f	f	f
16	2	8	f	f	f	f
17	3	1	f	f	f	f
18	3	2	f	f	f	f
19	3	3	f	f	f	f
20	3	4	t	f	f	f
21	3	5	t	f	f	f
22	3	6	t	t	t	f
23	3	7	t	f	f	f
24	3	8	f	f	f	f
\.


--
-- Data for Name: notificacion; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.notificacion (id_notif, id_cita, tipo, mensaje, fecha_envio) FROM stdin;
1	1	CONFIRMACION	Cita confirmada exitosamente.	2026-05-15 23:14:27.848924
2	2	RECORDATORIO	Recuerde su cita mañana.	2026-05-15 23:14:27.848924
3	3	CONFIRMACION	Cita de terapia confirmada.	2026-05-15 23:14:27.848924
4	4	CONFIRMACION	Cita de nutrición confirmada.	2026-05-15 23:14:27.848924
5	1	RECORDATORIO	Su cita es en 24 horas.	2026-05-15 23:14:27.848924
6	1	CONFIRMACION	Cita confirmada exitosamente.	2026-05-15 23:15:59.797755
7	2	RECORDATORIO	Recuerde su cita mañana.	2026-05-15 23:15:59.797755
8	3	CONFIRMACION	Cita de terapia confirmada.	2026-05-15 23:15:59.797755
9	4	CONFIRMACION	Cita de nutrición confirmada.	2026-05-15 23:15:59.797755
10	1	RECORDATORIO	Su cita es en 24 horas.	2026-05-15 23:15:59.797755
\.


--
-- Data for Name: perfil; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.perfil (id_perfil, nombre) FROM stdin;
1	admin
2	profesional
3	cliente
\.


--
-- Data for Name: profesional; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.profesional (id_profesional, nombre, apellido, email, id_especialidad, activo) FROM stdin;
1	Carlos	Ramírez	c.ramirez@clinica.com	1	t
2	Ana	Torres	a.torres@clinica.com	2	t
3	Luis	Medina	l.medina@clinica.com	3	t
4	Sofía	Herrera	s.herrera@clinica.com	4	t
5	Jorge	Castro	j.castro@clinica.com	5	t
\.


--
-- Data for Name: servicio; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.servicio (id_servicio, nombre, duracion_min, precio, id_especialidad) FROM stdin;
1	Consulta general	30	80000.00	1
2	Limpieza dental	45	120000.00	2
3	Sesión de terapia	60	150000.00	3
4	Plan nutricional	40	100000.00	4
5	Rehabilitación muscular	50	90000.00	5
6	Consulta general	30	80000.00	1
7	Limpieza dental	45	120000.00	2
8	Sesión de terapia	60	150000.00	3
9	Plan nutricional	40	100000.00	4
10	Rehabilitación muscular	50	90000.00	5
11	TEST	45	40000.00	3
\.


--
-- Data for Name: slot; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.slot (id_slot, id_profesional, fecha_hora_inicio, fecha_hora_fin, estado) FROM stdin;
2	1	2026-05-17 08:14:27.84674	2026-05-17 08:44:27.84674	LIBRE
6	1	2026-05-17 07:15:59.795782	2026-05-17 07:45:59.795782	LIBRE
7	1	2026-05-17 08:15:59.795782	2026-05-17 08:45:59.795782	LIBRE
8	2	2026-05-18 09:15:59.795782	2026-05-18 10:00:59.795782	LIBRE
9	3	2026-05-18 13:15:59.795782	2026-05-18 14:15:59.795782	LIBRE
10	4	2026-05-19 10:15:59.795782	2026-05-19 10:55:59.795782	LIBRE
1	1	2026-05-17 07:14:27.84674	2026-05-17 07:44:27.84674	OCUPADO
3	2	2026-05-18 09:14:27.84674	2026-05-18 09:59:27.84674	OCUPADO
4	3	2026-05-18 13:14:27.84674	2026-05-18 14:14:27.84674	OCUPADO
5	4	2026-05-19 10:14:27.84674	2026-05-19 10:54:27.84674	OCUPADO
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: reservas_user
--

COPY public.usuario (id_usuario, email, password_hash, id_perfil, id_cliente, id_profesional) FROM stdin;
2	c.ramirez@clinica.com	scrypt:32768:8:1$LQQ8kd8rMsBeH8Ha$69d6815c2b376c3e0c1bb8fedd523114c4c07b449ea1be598258d19032cbc553d7207bc45531e54e34f2b64b2289dbdeea822c18c7ab85813ff322837534a251	2	\N	1
3	maria.lopez@email.com	scrypt:32768:8:1$rLGGOfo5ZN59iqnS$02b038ebf1b4528f3d8ed3e5c9d71a2937453e1b14d6b58de3fca3bd0c8b8483979a7bbbc636b3129367c8461ddbe8e4a04d7ec87d3d94f45f27a66e5e084d36	3	1	\N
1	admin-TEST@reservas.com	scrypt:32768:8:1$ON46EKg2GfiS0J8O$07cb3225701744bd5f43907ae71b50739d862a6dd4d769e5f6bf06fda71221fc883548aa01062c7259b0b5f42a51cec6d70579b5c37e69e879e5cde32056ab36	1	\N	\N
\.


--
-- Name: actividad_id_actividad_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.actividad_id_actividad_seq', 8, true);


--
-- Name: auditoria_id_auditoria_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.auditoria_id_auditoria_seq', 99, true);


--
-- Name: cita_id_cita_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.cita_id_cita_seq', 5, true);


--
-- Name: cliente_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.cliente_id_cliente_seq', 6, true);


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.especialidad_id_especialidad_seq', 6, true);


--
-- Name: gestion_actividad_id_gestion_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.gestion_actividad_id_gestion_seq', 24, true);


--
-- Name: notificacion_id_notif_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.notificacion_id_notif_seq', 10, true);


--
-- Name: perfil_id_perfil_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.perfil_id_perfil_seq', 3, true);


--
-- Name: profesional_id_profesional_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.profesional_id_profesional_seq', 6, true);


--
-- Name: servicio_id_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.servicio_id_servicio_seq', 11, true);


--
-- Name: slot_id_slot_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.slot_id_slot_seq', 10, true);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: reservas_user
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 4, true);


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

\unrestrict 9mzzsyK901v4G9oi1GxOlKkPU8KWeIiCMPL96As7n2KwPv3u2mzy3KV8zMgU5J4

