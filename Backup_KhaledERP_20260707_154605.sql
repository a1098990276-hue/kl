--
-- PostgreSQL database dump
--

\restrict f4XB3hWSaKG61eXPeOCf9RF7q7fybCudiyuiF2sWTL7skijY0si53DS7ZAxKJbd

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.accounts_id_seq OWNER TO postgres;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: cost_centers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cost_centers (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    status text DEFAULT 'ë¬ل'::text
);


ALTER TABLE public.cost_centers OWNER TO postgres;

--
-- Name: cost_centers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cost_centers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cost_centers_id_seq OWNER TO postgres;

--
-- Name: cost_centers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cost_centers_id_seq OWNED BY public.cost_centers.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    date text,
    total_amount real,
    tax_amount real,
    zatca_qr text,
    cost_center_id integer,
    zatca_qr_base64 text
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.invoices ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: journal_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_details (
    id integer NOT NULL,
    entry_id integer,
    account_id integer,
    debit numeric(12,2) DEFAULT 0,
    credit numeric(12,2) DEFAULT 0
);


ALTER TABLE public.journal_details OWNER TO postgres;

--
-- Name: journal_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.journal_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.journal_details_id_seq OWNER TO postgres;

--
-- Name: journal_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.journal_details_id_seq OWNED BY public.journal_details.id;


--
-- Name: journal_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_entries (
    id integer NOT NULL,
    transaction_id text,
    account_id integer,
    debit real,
    credit real
);


ALTER TABLE public.journal_entries OWNER TO postgres;

--
-- Name: journal_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.journal_entries ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.journal_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: journal_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_items (
    id integer NOT NULL,
    entry_id integer,
    account_id integer,
    debit real,
    credit real,
    cost_center_id integer
);


ALTER TABLE public.journal_items OWNER TO postgres;

--
-- Name: journal_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.journal_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.journal_items_id_seq OWNER TO postgres;

--
-- Name: journal_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.journal_items_id_seq OWNED BY public.journal_items.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    sku text,
    name text,
    stock_qty real,
    price real
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.products ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(200) NOT NULL,
    role character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: cost_centers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_centers ALTER COLUMN id SET DEFAULT nextval('public.cost_centers_id_seq'::regclass);


--
-- Name: journal_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_details ALTER COLUMN id SET DEFAULT nextval('public.journal_details_id_seq'::regclass);


--
-- Name: journal_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items ALTER COLUMN id SET DEFAULT nextval('public.journal_items_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts (id, code, name, type, created_at) FROM stdin;
1	1000	ط§ظ„طµظ†ط¯ظˆظ‚	ط£طµظˆظ„	2026-07-07 15:40:47.121954
2	1100	ط§ظ„ط¨ظ†ظƒ	ط£طµظˆظ„	2026-07-07 15:40:47.121954
3	2000	ط±ط£ط³ ط§ظ„ظ…ط§ظ„	ط­ظ‚ظˆظ‚ ظ…ظ„ظƒظٹط©	2026-07-07 15:40:47.121954
4	3000	ط§ظ„ظ…طµط§ط±ظٹظپ	ظ…طµط±ظˆظپط§طھ	2026-07-07 15:40:47.121954
5	4000	ط§ظ„ط¥ظٹط±ط§ط¯ط§طھ	ط¥ظٹط±ط§ط¯ط§طھ	2026-07-07 15:40:47.121954
\.


--
-- Data for Name: cost_centers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cost_centers (id, code, name, status) FROM stdin;
1	CC-01	ê¬©يم ںé¢ي«م، ںé¬êںéï،	ë¬ل
2	CC-02	ه©م ںéêëلç، ںéن© ï،	ë¬ل
3	CC-03	‌§ں©، ںé¢«يïç يںé¢¬نïé	ë¬ل
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, date, total_amount, tax_amount, zatca_qr, cost_center_id, zatca_qr_base64) FROM stdin;
1	\N	1500.5	\N	\N	1	\N
\.


--
-- Data for Name: journal_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal_details (id, entry_id, account_id, debit, credit) FROM stdin;
\.


--
-- Data for Name: journal_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal_entries (id, transaction_id, account_id, debit, credit) FROM stdin;
\.


--
-- Data for Name: journal_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal_items (id, entry_id, account_id, debit, credit, cost_center_id) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, sku, name, stock_qty, price) FROM stdin;
1	SKU001	مادة تجريبية	10	50
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, role, created_at) FROM stdin;
1	admin	admin	admin	2026-07-07 15:38:07.653724
\.


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.accounts_id_seq', 20, true);


--
-- Name: cost_centers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cost_centers_id_seq', 3, true);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoices_id_seq', 1, true);


--
-- Name: journal_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.journal_details_id_seq', 1, false);


--
-- Name: journal_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.journal_entries_id_seq', 1, false);


--
-- Name: journal_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.journal_items_id_seq', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 7, true);


--
-- Name: accounts accounts_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_code_key UNIQUE (code);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: cost_centers cost_centers_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_centers
    ADD CONSTRAINT cost_centers_code_key UNIQUE (code);


--
-- Name: cost_centers cost_centers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_centers
    ADD CONSTRAINT cost_centers_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: journal_details journal_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_details
    ADD CONSTRAINT journal_details_pkey PRIMARY KEY (id);


--
-- Name: journal_entries journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (id);


--
-- Name: journal_items journal_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_journal_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_journal_account_id ON public.journal_entries USING btree (account_id);


--
-- Name: idx_journal_transaction_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_journal_transaction_id ON public.journal_entries USING btree (transaction_id);


--
-- Name: invoices invoices_cost_center_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_cost_center_id_fkey FOREIGN KEY (cost_center_id) REFERENCES public.cost_centers(id);


--
-- Name: journal_details journal_details_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_details
    ADD CONSTRAINT journal_details_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.journal_entries(id) ON DELETE CASCADE;


--
-- Name: journal_items journal_items_cost_center_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_cost_center_id_fkey FOREIGN KEY (cost_center_id) REFERENCES public.cost_centers(id);


--
-- PostgreSQL database dump complete
--

\unrestrict f4XB3hWSaKG61eXPeOCf9RF7q7fybCudiyuiF2sWTL7skijY0si53DS7ZAxKJbd

