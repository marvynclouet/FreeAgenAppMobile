const mysql = require('mysql2/promise');
const config = require('../config/db.config');

const pool = mysql.createPool(config);

module.exports = pool; 