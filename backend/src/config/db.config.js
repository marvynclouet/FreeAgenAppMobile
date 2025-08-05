const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'hopper.proxy.rlwy.net',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'WkdwbGCWQjoQhjNdeGEumAVztCSRXvZn',
  database: process.env.DB_NAME || 'railway',
  port: process.env.DB_PORT || 24981,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool; 