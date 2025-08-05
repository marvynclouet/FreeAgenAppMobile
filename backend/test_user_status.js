const mysql = require('mysql2/promise');

// Configuration de la base de données
const dbConfig = {
  host: 'monorail.proxy.rlwy.net',
  port: 45189,
  user: 'root',
  password: 'HhGgFfEeDdCcBbAa123456789',
  database: 'railway'
};

async function testUserStatus() {
  let connection;
  
  try {
    console.log('🔍 Test du statut utilisateur et restrictions\n');
    
    connection = await mysql.createConnection(dbConfig);
    
    // 1. Vérifier l'utilisateur marvyn
    console.log('1. Vérification de l\'utilisateur marvyn@gmail.com...');
    const [userRows] = await connection.execute(`
      SELECT id, email, name, subscription_type, subscription_expiry, is_premium
      FROM users 
      WHERE email = 'marvyn@gmail.com'
    `);
    
    if (userRows.length === 0) {
      console.log('❌ Utilisateur marvyn@gmail.com non trouvé');
      return;
    }
    
    const user = userRows[0];
    console.log('✅ Utilisateur trouvé:');
    console.log(`   ID: ${user.id}`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Nom: ${user.name}`);
    console.log(`   Type d'abonnement: ${user.subscription_type}`);
    console.log(`   Expiration: ${user.subscription_expiry}`);
    console.log(`   Premium: ${user.is_premium}\n`);
    
    // 2. Vérifier les limites actuelles
    console.log('2. Vérification des limites d\'utilisation...');
    const [limitsRows] = await connection.execute(`
      SELECT applications_count, opportunities_posted, messages_sent, last_reset_date
      FROM user_limits 
      WHERE user_id = ?
    `, [user.id]);
    
    const limits = limitsRows[0] || {
      applications_count: 0,
      opportunities_posted: 0,
      messages_sent: 0,
      last_reset_date: new Date()
    };
    
    console.log('📊 Limites actuelles:');
    console.log(`   Candidatures: ${limits.applications_count}`);
    console.log(`   Opportunités: ${limits.opportunities_posted}`);
    console.log(`   Messages: ${limits.messages_sent}`);
    console.log(`   Dernière réinitialisation: ${limits.last_reset_date}\n`);
    
    // 3. Vérifier les plans d'abonnement
    console.log('3. Vérification des plans d\'abonnement...');
    const [planRows] = await connection.execute(`
      SELECT type, max_applications, max_opportunities, max_messages, can_post_opportunities, has_profile_boost, has_priority_support
      FROM subscription_plans 
      WHERE is_active = TRUE
      ORDER BY type
    `);
    
    console.log('📋 Plans disponibles:');
    planRows.forEach(plan => {
      console.log(`   ${plan.type}:`);
      console.log(`     - Candidatures max: ${plan.max_applications}`);
      console.log(`     - Opportunités max: ${plan.max_opportunities}`);
      console.log(`     - Messages max: ${plan.max_messages}`);
      console.log(`     - Peut poster: ${plan.can_post_opportunities}`);
      console.log(`     - Boost profil: ${plan.has_profile_boost}`);
      console.log(`     - Support prioritaire: ${plan.has_priority_support}`);
    });
    console.log();
    
    // 4. Vérifier les conversations existantes
    console.log('4. Vérification des conversations...');
    const [convRows] = await connection.execute(`
      SELECT id, sender_id, receiver_id, subject, created_at
      FROM conversations 
      WHERE sender_id = ? OR receiver_id = ?
      ORDER BY created_at DESC
      LIMIT 5
    `, [user.id, user.id]);
    
    console.log(`📨 Conversations trouvées: ${convRows.length}`);
    convRows.forEach(conv => {
      console.log(`   ID: ${conv.id}, Sujet: ${conv.subject}, Créée: ${conv.created_at}`);
    });
    console.log();
    
    // 5. Test de restriction messaging
    console.log('5. Test de restriction messaging...');
    if (user.subscription_type === 'free') {
      console.log('❌ Utilisateur gratuit - Messagerie bloquée');
      console.log('   Raison: subscription_type = "free"');
    } else {
      console.log('✅ Utilisateur premium - Messagerie autorisée');
      console.log(`   Plan: ${user.subscription_type}`);
    }
    
    // 6. Vérifier si l'abonnement est expiré
    if (user.subscription_expiry && new Date(user.subscription_expiry) < new Date()) {
      console.log('⚠️  Abonnement expiré - devrait être remis en gratuit');
    }
    
    console.log('\n🔧 DIAGNOSTIC:');
    if (user.subscription_type === 'free') {
      console.log('   - L\'erreur 403 est NORMALE pour un utilisateur gratuit');
      console.log('   - Le frontend devrait afficher un pop-up premium');
      console.log('   - Le backend bloque correctement l\'accès');
    } else {
      console.log('   - L\'utilisateur est premium, l\'erreur 403 est ANORMALE');
      console.log('   - Vérifier les limites d\'utilisation');
      console.log('   - Vérifier l\'expiration de l\'abonnement');
    }
    
  } catch (error) {
    console.error('❌ Erreur lors du test:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

testUserStatus(); 