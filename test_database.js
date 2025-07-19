#!/usr/bin/env node

const mysql = require('mysql2/promise');
const colors = require('colors');

// Configuration de la base de données Railway
const dbConfig = {
  host: 'mysql',
  user: 'root',
  password: 'WkdwbGCWQjoQhjNdeGEumAVztCSRXvZn',
  database: 'railway',
  port: 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

// Couleurs pour les logs
colors.enable();

// Fonction pour tester une requête
async function testQuery(connection, query, description, expectedRows = null) {
  try {
    console.log(`\n🔍 Testing: ${description}`.cyan);
    console.log(`   SQL: ${query.substring(0, 100)}${query.length > 100 ? '...' : ''}`.gray);
    
    const [rows] = await connection.execute(query);
    
    if (expectedRows !== null && rows.length !== expectedRows) {
      console.log(`   ⚠️  UNEXPECTED ROWS (${rows.length}, expected ${expectedRows})`.yellow);
    } else {
      console.log(`   ✅ SUCCESS (${rows.length} rows)`.green);
    }
    
    if (rows.length > 0 && rows.length <= 5) {
      console.log(`   📄 Sample data: ${JSON.stringify(rows, null, 2).substring(0, 300)}...`.gray);
    } else if (rows.length > 5) {
      console.log(`   📄 First row: ${JSON.stringify(rows[0], null, 2).substring(0, 200)}...`.gray);
    }
    
    return { success: true, rows: rows.length, data: rows };
  } catch (error) {
    console.log(`   ❌ FAILED: ${error.message}`.red);
    return { success: false, error: error.message };
  }
}

// Tests de base de données
const databaseTests = [
  // Test de connexion
  {
    query: 'SELECT 1 as test',
    description: 'Database Connection Test',
    expectedRows: 1
  },
  
  // Test des tables principales
  {
    query: 'SHOW TABLES',
    description: 'List All Tables',
    expectedRows: null
  },
  
  // Test de la table users
  {
    query: 'SELECT COUNT(*) as user_count FROM users',
    description: 'Users Table - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT id, name, email, profile_type, created_at FROM users LIMIT 5',
    description: 'Users Table - Sample Data',
    expectedRows: null
  },
  
  // Test des profils
  {
    query: 'SELECT COUNT(*) as profile_count FROM handibasket_profiles',
    description: 'Handibasket Profiles - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT COUNT(*) as profile_count FROM coach_pro_profiles',
    description: 'Coach Pro Profiles - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT COUNT(*) as profile_count FROM coach_basket_profiles',
    description: 'Coach Basket Profiles - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT COUNT(*) as profile_count FROM juriste_profiles',
    description: 'Juriste Profiles - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT COUNT(*) as profile_count FROM dieteticienne_profiles',
    description: 'Dieteticienne Profiles - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT COUNT(*) as profile_count FROM club_profiles',
    description: 'Club Profiles - Count',
    expectedRows: 1
  },
  
  // Test des équipes
  {
    query: 'SELECT COUNT(*) as team_count FROM teams',
    description: 'Teams Table - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT id, name, city, division FROM teams LIMIT 5',
    description: 'Teams Table - Sample Data',
    expectedRows: null
  },
  
  // Test des annonces
  {
    query: 'SELECT COUNT(*) as annonce_count FROM annonces',
    description: 'Annonces Table - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT id, title, description, status, created_at FROM annonces LIMIT 5',
    description: 'Annonces Table - Sample Data',
    expectedRows: null
  },
  
  // Test des opportunités
  {
    query: 'SELECT COUNT(*) as opportunity_count FROM opportunities',
    description: 'Opportunities Table - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT id, title, description, type, team_id FROM opportunities LIMIT 5',
    description: 'Opportunities Table - Sample Data',
    expectedRows: null
  },
  
  // Test des conversations
  {
    query: 'SELECT COUNT(*) as conversation_count FROM conversations',
    description: 'Conversations Table - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT id, sender_id, receiver_id, subject, created_at FROM conversations LIMIT 5',
    description: 'Conversations Table - Sample Data',
    expectedRows: null
  },
  
  // Test des messages
  {
    query: 'SELECT COUNT(*) as message_count FROM messages',
    description: 'Messages Table - Count',
    expectedRows: 1
  },
  {
    query: 'SELECT id, conversation_id, sender_id, content, created_at FROM messages LIMIT 5',
    description: 'Messages Table - Sample Data',
    expectedRows: null
  },
  
  // Test des abonnements
  {
    query: 'SELECT COUNT(*) as subscription_count FROM subscriptions',
    description: 'Subscriptions Table - Count',
    expectedRows: 1
  },
  
  // Test des paiements
  {
    query: 'SELECT COUNT(*) as payment_count FROM payments',
    description: 'Payments Table - Count',
    expectedRows: 1
  },
  
  // Test des limites utilisateur
  {
    query: 'SELECT COUNT(*) as limit_count FROM user_limits',
    description: 'User Limits Table - Count',
    expectedRows: 1
  },
  
  // Test des relations
  {
    query: `
      SELECT 
        u.name as user_name,
        u.profile_type,
        COUNT(a.id) as annonce_count
      FROM users u
      LEFT JOIN annonces a ON u.id = a.user_id
      GROUP BY u.id, u.name, u.profile_type
      LIMIT 10
    `,
    description: 'Users with Annonces - Relationship Test',
    expectedRows: null
  },
  
  // Test des contraintes d'intégrité
  {
    query: `
      SELECT 
        'users' as table_name,
        COUNT(*) as total_rows
      FROM users
      UNION ALL
      SELECT 
        'annonces' as table_name,
        COUNT(*) as total_rows
      FROM annonces
      UNION ALL
      SELECT 
        'teams' as table_name,
        COUNT(*) as total_rows
      FROM teams
      UNION ALL
      SELECT 
        'conversations' as table_name,
        COUNT(*) as total_rows
      FROM conversations
      UNION ALL
      SELECT 
        'messages' as table_name,
        COUNT(*) as total_rows
      FROM messages
    `,
    description: 'Database Summary - All Tables Count',
    expectedRows: null
  },
  
  // Test des index
  {
    query: `
      SELECT 
        TABLE_NAME,
        INDEX_NAME,
        COLUMN_NAME
      FROM INFORMATION_SCHEMA.STATISTICS 
      WHERE TABLE_SCHEMA = 'railway'
      ORDER BY TABLE_NAME, INDEX_NAME
    `,
    description: 'Database Indexes',
    expectedRows: null
  },
  
  // Test des contraintes
  {
    query: `
      SELECT 
        TABLE_NAME,
        CONSTRAINT_NAME,
        CONSTRAINT_TYPE
      FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
      WHERE TABLE_SCHEMA = 'railway'
      ORDER BY TABLE_NAME, CONSTRAINT_TYPE
    `,
    description: 'Database Constraints',
    expectedRows: null
  }
];

// Fonction principale
async function testDatabase() {
  console.log('🚀 Starting Railway Database Tests'.bold);
  console.log(`📍 Database: ${dbConfig.database}@${dbConfig.host}:${dbConfig.port}`.gray);
  console.log(`⏰ Started at: ${new Date().toISOString()}`.gray);
  console.log('='.repeat(80));

  let connection;
  
  try {
    // Connexion à la base de données
    console.log('🔌 Connecting to Railway database...'.cyan);
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Database connection successful!'.green);
    
    const results = {
      total: databaseTests.length,
      success: 0,
      failed: 0,
      details: []
    };

    // Exécution des tests
    for (const test of databaseTests) {
      const result = await testQuery(
        connection,
        test.query,
        test.description,
        test.expectedRows
      );
      
      results.details.push({
        ...test,
        result
      });
      
      if (result.success) {
        results.success++;
      } else {
        results.failed++;
      }
    }

    // Résumé
    console.log('\n' + '='.repeat(80));
    console.log('📊 DATABASE TEST RESULTS SUMMARY'.bold);
    console.log(`✅ Successful: ${results.success}/${results.total}`.green);
    console.log(`❌ Failed: ${results.failed}/${results.total}`.red);
    console.log(`📈 Success Rate: ${((results.success / results.total) * 100).toFixed(1)}%`.cyan);
    
    if (results.failed > 0) {
      console.log('\n❌ FAILED TESTS:'.red);
      results.details.forEach((test, index) => {
        if (!test.result.success) {
          console.log(`   ${index + 1}. ${test.description}`.red);
          console.log(`      Error: ${test.result.error}`.gray);
        }
      });
    }

    // Recommandations
    console.log('\n💡 RECOMMENDATIONS:'.yellow);
    if (results.success === results.total) {
      console.log('   ✅ Database is fully functional!'.green);
    } else {
      console.log('   ⚠️  Some database issues detected. Check failed tests above.'.yellow);
    }
    
    console.log(`\n⏰ Finished at: ${new Date().toISOString()}`.gray);
    
    return results;
    
  } catch (error) {
    console.error('❌ Database connection failed:'.red, error.message);
    return { success: false, error: error.message };
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Database connection closed.'.gray);
    }
  }
}

// Gestion des erreurs
process.on('unhandledRejection', (error) => {
  console.error('❌ Unhandled Promise Rejection:'.red, error);
  process.exit(1);
});

// Exécution
if (require.main === module) {
  testDatabase()
    .then((results) => {
      process.exit(results.failed > 0 ? 1 : 0);
    })
    .catch((error) => {
      console.error('❌ Test runner failed:'.red, error);
      process.exit(1);
    });
}

module.exports = { testDatabase, testQuery }; 