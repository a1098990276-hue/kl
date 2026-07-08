-- ===========================
-- ÃœÊ· «·„” Œœ„Ì‰
-- ===========================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(200) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, password, role)
VALUES ('admin', 'admin', 'admin')
ON CONFLICT (username) DO NOTHING;

-- ===========================
-- ÃœÊ· «·Õ”«»«  «·„Õ«”»Ì…
-- ===========================
CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ‘Ã—… Õ”«»«  »”Ìÿ…
INSERT INTO accounts (code, name, type) VALUES
('1000', '«·’‰œÊﬁ', '√’Ê·'),
('1100', '«·»‰ﬂ', '√’Ê·'),
('2000', '—√” «·„«·', 'ÕﬁÊﬁ „·ﬂÌ…'),
('3000', '«·„’«—Ì›', '„’—Ê›« '),
('4000', '«·≈Ì—«œ« ', '≈Ì—«œ« ')
ON CONFLICT (code) DO NOTHING;

-- ===========================
-- ÃœÊ· «·⁄„·«¡
-- ===========================
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- ÃœÊ· «·„Ê—œÌ‰
-- ===========================
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- ÃœÊ· «·√’‰«› («·„Œ“Ê‰)
-- ===========================
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    barcode VARCHAR(50),
    cost NUMERIC(12,2) DEFAULT 0,
    price NUMERIC(12,2) DEFAULT 0,
    stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- ÃœÊ· «·›Ê« Ì—
-- ===========================
CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total NUMERIC(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
--  ›«’Ì· «·›Ê« Ì—
-- ===========================
CREATE TABLE IF NOT EXISTS invoice_details (
    id SERIAL PRIMARY KEY,
    invoice_id INT REFERENCES invoices(id) ON DELETE CASCADE,
    item_id INT REFERENCES items(id),
    qty INT NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    total NUMERIC(12,2) NOT NULL
);

-- ===========================
-- ÃœÊ· «·œ›⁄« 
-- ===========================
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    amount NUMERIC(12,2) NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- «·ﬁÌÊœ «·ÌÊ„Ì…
-- ===========================
CREATE TABLE IF NOT EXISTS journal_entries (
    id SERIAL PRIMARY KEY,
    entry_date DATE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--  ›«’Ì· «·ﬁÌÊœ
CREATE TABLE IF NOT EXISTS journal_details (
    id SERIAL PRIMARY KEY,
    entry_id INT REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_id INT REFERENCES accounts(id),
    debit NUMERIC(12,2) DEFAULT 0,
    credit NUMERIC(12,2) DEFAULT 0
);
