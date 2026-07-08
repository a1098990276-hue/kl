DROP TABLE IF EXISTS payroll, pos_transactions, sales_order_items, sales_orders, products, invoices, partners, users, accounts CASCADE;

CREATE TABLE users (id SERIAL PRIMARY KEY, username TEXT UNIQUE, role TEXT);
CREATE TABLE accounts (account_code TEXT PRIMARY KEY, name TEXT NOT NULL, type TEXT);
CREATE TABLE partners (id SERIAL PRIMARY KEY, name TEXT NOT NULL, type TEXT, phone TEXT); 
CREATE TABLE products (id SERIAL PRIMARY KEY, name TEXT, sku TEXT UNIQUE, stock REAL, price REAL, cost REAL);
CREATE TABLE sales_orders (id SERIAL PRIMARY KEY, partner_id INT REFERENCES partners(id), date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, total REAL, status TEXT);
CREATE TABLE sales_order_items (id SERIAL PRIMARY KEY, order_id INT REFERENCES sales_orders(id), product_id INT REFERENCES products(id), qty REAL, price REAL);
CREATE TABLE invoices (id SERIAL PRIMARY KEY, customer_id INT REFERENCES partners(id), total_amount REAL, tax_amount REAL, date DATE DEFAULT CURRENT_DATE);
CREATE TABLE payroll (id SERIAL PRIMARY KEY, employee_name TEXT, salary REAL, month DATE);

INSERT INTO accounts (account_code, name, type) VALUES ('1000', 'الصندوق', 'asset'), ('2000', 'المبيعات', 'revenue'), ('3000', 'الموردين', 'liability');
