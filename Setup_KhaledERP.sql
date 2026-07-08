-- إنشاء جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(200) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول الحسابات
CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول القيود اليومية
CREATE TABLE IF NOT EXISTS journal_entries (
    id SERIAL PRIMARY KEY,
    entry_date DATE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- تفاصيل القيود
CREATE TABLE IF NOT EXISTS journal_details (
    id SERIAL PRIMARY KEY,
    entry_id INT REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_id INT REFERENCES accounts(id),
    debit NUMERIC(12,2) DEFAULT 0,
    credit NUMERIC(12,2) DEFAULT 0
);

-- إدخال مستخدم افتراضي
INSERT INTO users (username, password, role)
VALUES ('admin', 'admin', 'admin')
ON CONFLICT (username) DO NOTHING;

-- إدخال شجرة حسابات بسيطة
INSERT INTO accounts (code, name, type) VALUES
('1000', 'الصندوق', 'أصول'),
('1100', 'البنك', 'أصول'),
('2000', 'رأس المال', 'حقوق ملكية'),
('3000', 'المصاريف', 'مصروفات'),
('4000', 'الإيرادات', 'إيرادات')
ON CONFLICT (code) DO NOTHING;
