const pool = require('../config/db.config.js');

async function fixPremiumColumns() {
  try {
    console.log('🔧 Correction des colonnes premium...');
    
    // Fonction pour vérifier si une colonne existe
    async function columnExists(tableName, columnName) {
      const [rows] = await pool.execute(`
        SELECT COUNT(*) as count
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 'freeagent_db' 
        AND TABLE_NAME = ? 
        AND COLUMN_NAME = ?
      `, [tableName, columnName]);
      return rows[0].count > 0;
    }
    
    // Fonction pour vérifier si un index existe
    async function indexExists(tableName, indexName) {
      const [rows] = await pool.execute(`
        SELECT COUNT(*) as count
        FROM INFORMATION_SCHEMA.STATISTICS 
        WHERE TABLE_SCHEMA = 'freeagent_db' 
        AND TABLE_NAME = ? 
        AND INDEX_NAME = ?
      `, [tableName, indexName]);
      return rows[0].count > 0;
    }
    
    // Ajouter les colonnes manquantes à la table users
    const columnsToAdd = [
      {
        name: 'subscription_type',
        definition: "ENUM('free', 'premium_basic', 'premium_pro') DEFAULT 'free'"
      },
      {
        name: 'subscription_expiry',
        definition: 'DATETIME NULL'
      },
      {
        name: 'subscription_created_at',
        definition: 'DATETIME NULL'
      },
      {
        name: 'is_premium',
        definition: 'BOOLEAN DEFAULT FALSE'
      }
    ];
    
    for (const column of columnsToAdd) {
      const exists = await columnExists('users', column.name);
      if (!exists) {
        console.log(`➕ Ajout de la colonne ${column.name}...`);
        await pool.execute(`ALTER TABLE users ADD COLUMN ${column.name} ${column.definition}`);
        console.log(`✅ Colonne ${column.name} ajoutée`);
      } else {
        console.log(`⏭️  Colonne ${column.name} existe déjà`);
      }
    }
    
    // Ajouter les index manquants
    const indexesToAdd = [
      {
        table: 'users',
        name: 'idx_users_subscription',
        definition: 'CREATE INDEX idx_users_subscription ON users(subscription_type, subscription_expiry)'
      },
      {
        table: 'subscriptions',
        name: 'idx_subscriptions_user',
        definition: 'CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, status)'
      },
      {
        table: 'subscriptions',
        name: 'idx_subscriptions_dates',
        definition: 'CREATE INDEX idx_subscriptions_dates ON subscriptions(start_date, end_date)'
      },
      {
        table: 'user_limits',
        name: 'idx_user_limits_user',
        definition: 'CREATE INDEX idx_user_limits_user ON user_limits(user_id)'
      }
    ];
    
    for (const index of indexesToAdd) {
      const exists = await indexExists(index.table, index.name);
      if (!exists) {
        console.log(`📊 Ajout de l'index ${index.name}...`);
        try {
          await pool.execute(index.definition);
          console.log(`✅ Index ${index.name} ajouté`);
        } catch (error) {
          console.error(`❌ Erreur lors de l'ajout de l'index ${index.name}:`, error.message);
        }
      } else {
        console.log(`⏭️  Index ${index.name} existe déjà`);
      }
    }
    
    // Créer les triggers si nécessaire
    console.log('🔄 Création des triggers...');
    
    // Trigger pour initialiser les limites
    try {
      await pool.execute('DROP TRIGGER IF EXISTS after_user_insert_limits');
      await pool.execute(`
        CREATE TRIGGER after_user_insert_limits
        AFTER INSERT ON users
        FOR EACH ROW
        INSERT INTO user_limits (user_id) VALUES (NEW.id)
      `);
      console.log('✅ Trigger after_user_insert_limits créé');
    } catch (error) {
      console.error('❌ Erreur trigger limits:', error.message);
    }
    
    // Trigger pour mettre à jour le statut premium
    try {
      await pool.execute('DROP TRIGGER IF EXISTS before_user_update_premium');
      await pool.execute(`
        CREATE TRIGGER before_user_update_premium
        BEFORE UPDATE ON users
        FOR EACH ROW
        SET NEW.is_premium = IF(NEW.subscription_expiry IS NOT NULL AND NEW.subscription_expiry > NOW(), TRUE, FALSE)
      `);
      console.log('✅ Trigger before_user_update_premium créé');
    } catch (error) {
      console.error('❌ Erreur trigger premium:', error.message);
    }
    
    // Vérifier les colonnes ajoutées
    console.log('📋 Vérification des colonnes...');
    const [columns] = await pool.execute(`
      SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = 'freeagent_db' 
      AND TABLE_NAME = 'users' 
      AND COLUMN_NAME IN ('subscription_type', 'subscription_expiry', 'is_premium', 'subscription_created_at')
    `);
    
    console.log('📊 Colonnes premium dans users:', columns);
    
    // Créer les limites pour les utilisateurs existants
    console.log('👥 Initialisation des limites pour les utilisateurs existants...');
    await pool.execute(`
      INSERT IGNORE INTO user_limits (user_id) 
      SELECT id FROM users WHERE id NOT IN (SELECT user_id FROM user_limits)
    `);
    
    console.log('🎉 Correction terminée avec succès!');
    
  } catch (error) {
    console.error('❌ Erreur lors de la correction:', error);
  } finally {
    await pool.end();
  }
}

fixPremiumColumns(); 