require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const morgan = require('morgan');
const Database = require('better-sqlite3');

const app = express();
const PORT = process.env.PORT || 5000;

// Database
const db = new Database(process.env.DB_PATH || './database/saqr.db');
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(morgan('dev'));

// Make db accessible
app.use((req, res, next) => {
    req.db = db;
    next();
});

// Auth middleware
const auth = require('./middleware/auth');

// ==================== API ROUTES ====================

// Auth Routes
app.post('/api/auth/login', (req, res) => {
    try {
        const { username, password } = req.body;
        const bcrypt = require('bcryptjs');
        const jwt = require('jsonwebtoken');
        
        const user = db.prepare('SELECT * FROM users WHERE username = ? AND is_active = 1').get(username);
        
        if (!user || !bcrypt.compareSync(password, user.password_hash)) {
            return res.status(401).json({ success: false, error: 'خطأ في اسم المستخدم أو كلمة المرور' });
        }
        
        const token = jwt.sign(
            { id: user.id, username: user.username, role: user.role, full_name: user.full_name },
            process.env.JWT_SECRET || 'saqr_erp_secret',
            { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
        );
        
        db.prepare('UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?').run(user.id);
        
        res.json({
            success: true,
            token,
            user: {
                id: user.id,
                username: user.username,
                full_name: user.full_name,
                role: user.role
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/api/auth/logout', auth, (req, res) => {
    res.json({ success: true, message: 'تم تسجيل الخروج' });
});

// Dashboard
app.get('/api/dashboard', auth, (req, res) => {
    try {
        const totalSales = db.prepare("SELECT COALESCE(SUM(total), 0) as total FROM sales_invoices WHERE status = 'posted'").get();
        const totalPurchases = db.prepare("SELECT COALESCE(SUM(total), 0) as total FROM purchase_invoices WHERE status = 'posted'").get();
        const customerCount = db.prepare('SELECT COUNT(*) as count FROM customers WHERE is_active = 1').get();
        const vendorCount = db.prepare('SELECT COUNT(*) as count FROM vendors WHERE is_active = 1').get();
        const productCount = db.prepare('SELECT COUNT(*) as count FROM products WHERE is_active = 1').get();
        
        res.json({
            success: true,
            data: {
                total_sales: totalSales.total,
                total_purchases: totalPurchases.total,
                total_customers: customerCount.count,
                total_vendors: vendorCount.count,
                total_products: productCount.count,
                today_sales: 0,
                bank_balance: 0
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Accounts
app.get('/api/accounts', auth, (req, res) => {
    try {
        const accounts = db.prepare('SELECT * FROM accounts ORDER BY code').all();
        res.json({ success: true, data: accounts });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Customers
app.get('/api/customers', auth, (req, res) => {
    try {
        const customers = db.prepare('SELECT * FROM customers WHERE is_active = 1 ORDER BY name').all();
        res.json({ success: true, data: customers });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/api/customers', auth, (req, res) => {
    try {
        const { name, phone, email, tax_number } = req.body;
        const code = 'CUS-' + String(Date.now()).slice(-6);
        db.prepare('INSERT INTO customers (code, name, phone, email, tax_number) VALUES (?, ?, ?, ?, ?)').run(code, name, phone || '', email || '', tax_number || '');
        res.json({ success: true, message: 'تم إضافة العميل' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Vendors
app.get('/api/vendors', auth, (req, res) => {
    try {
        const vendors = db.prepare('SELECT * FROM vendors WHERE is_active = 1 ORDER BY name').all();
        res.json({ success: true, data: vendors });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/api/vendors', auth, (req, res) => {
    try {
        const { name, phone } = req.body;
        const code = 'VEN-' + String(Date.now()).slice(-6);
        db.prepare('INSERT INTO vendors (code, name, phone) VALUES (?, ?, ?)').run(code, name, phone || '');
        res.json({ success: true, message: 'تم إضافة المورد' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Products
app.get('/api/products', auth, (req, res) => {
    try {
        const products = db.prepare('SELECT * FROM products WHERE is_active = 1 ORDER BY name').all();
        res.json({ success: true, data: products });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/api/products', auth, (req, res) => {
    try {
        const { name, barcode, cost_price, sell_price, stock, min_stock } = req.body;
        const code = 'PRD-' + String(Date.now()).slice(-6);
        db.prepare('INSERT INTO products (code, name, barcode, cost_price, sell_price, stock, min_stock) VALUES (?, ?, ?, ?, ?, ?, ?)').run(code, name, barcode || '', cost_price || 0, sell_price || 0, stock || 0, min_stock || 0);
        res.json({ success: true, message: 'تم إضافة المنتج' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Settings
app.get('/api/settings', auth, (req, res) => {
    try {
        const settings = db.prepare('SELECT * FROM settings ORDER BY group_name, key').all();
        res.json({ success: true, data: settings });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.put('/api/settings/:key', auth, (req, res) => {
    try {
        const { value } = req.body;
        db.prepare('UPDATE settings SET value = ? WHERE key = ?').run(value, req.params.key);
        res.json({ success: true, message: 'تم تحديث الإعداد' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Serve static files
app.use(express.static(path.join(__dirname, 'frontend', 'public')));
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'frontend', 'public', 'index.html'));
});

// Error handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ success: false, error: 'Internal server error' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log('========================================');
    console.log('  Saqr ERP System v4.0');
    console.log('  Running on http://localhost:' + PORT);
    console.log('  Login: admin / admin123');
    console.log('========================================');
});
