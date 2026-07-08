const { Client } = require('pg');

const client = new Client({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: '123456',
  port: 5432,
});

client.connect()
  .then(() => {
    console.log('✅ نجح الاتصال! النظام جاهز للعمل.');
    client.end();
  })
  .catch(err => console.error('❌ خطأ في الاتصال:', err.message));