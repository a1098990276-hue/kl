const Database = require('better-sqlite3');
const db = new Database('khaled.db');

// حذف جميع الجداول القديمة
const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';").all();
for (const t of tables) {
    db.prepare(`DROP TABLE IF EXISTS ${t.name}`).run();
}

// إنشاء جداول جديدة بدون أخطاء DEFAULT
db.exec(`
CREATE TABLE accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE journal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    debit REAL NOT NULL,
    credit REAL NOT NULL,
    description TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    price REAL NOT NULL,
    qty REAL NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer TEXT,
    total REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE purchases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    supplier TEXT,
    total REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE assets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    value REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
`);

console.log("✔ تم إصلاح قاعدة البيانات بالكامل");
