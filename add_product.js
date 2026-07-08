const { Client } = require('pg');

const client = new Client({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: '123456',
  port: 5432,
});

async function addProduct() {
  try {
    await client.connect();
    // هنا نقوم بإرسال أمر "إضافة" (INSERT) لقاعدة البيانات
    const query = 'INSERT INTO products (sku, name, stock_qty, price) VALUES ($1, $2, $3, $4)';
    const values = ['SKU001', 'مادة تجريبية', 10, 50.0];

    await client.query(query, values);
    console.log('✅ تم إضافة المنتج بنجاح إلى المخزون!');

    await client.end();
  } catch (err) {
    console.error('❌ حدث خطأ:', err.message);
  }
}

addProduct();