-- 1. الدليل المحاسبي
CREATE TABLE IF NOT EXISTS accounts (
    account_code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT -- (asset, liability, equity, revenue, expense)
);

-- 2. القيود المحاسبية (المحرك الرئيسي)
CREATE TABLE IF NOT EXISTS journal_entries (
    id SERIAL PRIMARY KEY,
    date DATE DEFAULT CURRENT_DATE,
    description TEXT,
    reference_number TEXT
);

CREATE TABLE IF NOT EXISTS journal_items (
    id SERIAL PRIMARY KEY,
    entry_id INT REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_code TEXT REFERENCES accounts(account_code),
    debit REAL DEFAULT 0,
    credit REAL DEFAULT 0
);

-- 3. المخزون والمنتجات
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    sku TEXT UNIQUE,
    stock_qty REAL DEFAULT 0,
    sale_price REAL,
    cost_price REAL
);

-- 4. الشركاء (عملاء وموردين)
CREATE TABLE IF NOT EXISTS partners (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT, -- 'customer' or 'supplier'
    balance REAL DEFAULT 0
);

-- 5. الفواتير (نظام المبيعات)
CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    partner_id INT REFERENCES partners(id),
    total_amount REAL,
    tax_amount REAL,
    zatca_qr_base64 TEXT,
    status TEXT DEFAULT 'draft'
);

-- 6. تهيئة الحسابات الأساسية
INSERT INTO accounts (account_code, name, type) VALUES 
('1000', 'الصندوق', 'asset'),
('2000', 'إيرادات المبيعات', 'revenue'),
('3000', 'المخزون', 'asset'),
('4000', 'حساب الموردين', 'liability')
ON CONFLICT (account_code) DO NOTHING;