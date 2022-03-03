--
-- PostgreSQL database dump
--

-- Dumped from database version 13.6 (Debian 13.6-1.pgdg110+1)
-- Dumped by pg_dump version 13.6 (Debian 13.6-1.pgdg110+1)

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

SET default_tablespace = '';

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.orders (
    id integer,
    title character varying(80),
    price integer
)
PARTITION BY RANGE (price);


ALTER TABLE public.orders OWNER TO postgresql;

SET default_table_access_method = heap;

--
-- Name: orders_simple; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.orders_simple (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);


ALTER TABLE public.orders_simple OWNER TO postgresql;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgresql
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO postgresql;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgresql
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders_simple.id;


--
-- Name: orders_less499; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.orders_less499 (
    id integer,
    title character varying(80),
    price integer
);
ALTER TABLE ONLY public.orders ATTACH PARTITION public.orders_less499 FOR VALUES FROM (0) TO (499);


ALTER TABLE public.orders_less499 OWNER TO postgresql;

--
-- Name: orders_more499; Type: TABLE; Schema: public; Owner: postgresql
--

CREATE TABLE public.orders_more499 (
    id integer,
    title character varying(80),
    price integer
);
ALTER TABLE ONLY public.orders ATTACH PARTITION public.orders_more499 FOR VALUES FROM (499) TO (999999999);


ALTER TABLE public.orders_more499 OWNER TO postgresql;

--
-- Name: orders_simple id; Type: DEFAULT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.orders_simple ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Data for Name: orders_less499; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.orders_less499 (id, title, price) FROM stdin;
1	War and peace	100
3	Adventure psql time	300
4	Server gravity falls	300
5	Log gossips	123
\.


--
-- Data for Name: orders_more499; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.orders_more499 (id, title, price) FROM stdin;
2	My little database	500
6	WAL never lies	900
7	Me and my bash-pet	499
8	Dbiezdmin	501
\.


--
-- Data for Name: orders_simple; Type: TABLE DATA; Schema: public; Owner: postgresql
--

COPY public.orders_simple (id, title, price) FROM stdin;
1	War and peace	100
2	My little database	500
3	Adventure psql time	300
4	Server gravity falls	300
5	Log gossips	123
6	WAL never lies	900
7	Me and my bash-pet	499
8	Dbiezdmin	501
\.


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgresql
--

SELECT pg_catalog.setval('public.orders_id_seq', 8, true);


--
-- Name: orders_simple orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgresql
--

ALTER TABLE ONLY public.orders_simple
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

