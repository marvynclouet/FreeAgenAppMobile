const mysql = require('mysql2/promise');

// Configuration de la base de données Railway
const dbConfig = {
  host: 'hopper.proxy.rlwy.net',
  user: 'root',
  password: 'WkdwbGCWQjoQhjNdeGEumAVztCSRXvZn',
  database: 'railway',
  port: 24981
};

// Utilisateurs réels à conserver (IDs et emails)
const REAL_USERS = [
  1,    // Marvyn
  29,   // Carole
  53,   // Sarah
  108,  // Joel Binguimale
  109,  // Daniel Antaya
  111,  // mamady traore
  112,  // sky
  113,  // Thuries
  128,  // Auxence
  129,  // Mz Workout
  130,  // Noé Urbaniak
  131,  // mamady
  133,  // Patrick Ndepe
  141,  // Marvyn (duplicate)
  142,  // Marvyn (duplicate)
  143,  // Marvyn (duplicate)
  144,  // Marvyn (duplicate)
  145,  // Marvyn (duplicate)
  146,  // Marvyn (duplicate)
  147,  // Marvyn (duplicate)
  148,  // Marvyn (duplicate)
  149,  // Marvyn (duplicate)
  150,  // Marvyn (duplicate)
  151,  // Marvyn (duplicate)
  152,  // Marvyn (duplicate)
  153,  // Marvyn (duplicate)
  154,  // Marvyn (duplicate)
  155,  // Marvyn (duplicate)
  156,  // Marvyn (duplicate)
  157,  // Marvyn (duplicate)
  158,  // Marvyn (duplicate)
  159,  // Marvyn (duplicate)
  160   // Marvyn (duplicate)
];

const REAL_EMAILS = [
  'marvyn@gmail.com',
  'carole@carole.fr',
  'sarah@gmail.com',
  'bengy5@msn.com',
  'danielantaya50@gmail.com',
  'mamadytraore93500@gmail.com',
  '4askya@gmail.com',
  'fred1thuries@yahoo.fr',
  'kouditeyauxence@gmail.com',
  'mzzinoa@gmail.com',
  'kinzu.vii@gmail.com',
  'mamadytraore93500@gmail.com',
  'ndp-8@hotmail.fr'
];

async function cleanupTestData() {
  let connection;
  
  try {
    console.log('🧹 Nettoyage de la base de données...');
    console.log('=====================================\n');
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion à la base de données établie');

    // 1. Supprimer les équipes de test
    console.log('🏀 Suppression des équipes de test...');
    const [teamsDeleted] = await connection.execute(
      'DELETE FROM teams WHERE name LIKE "%Test%" OR name LIKE "%ASVEL%"'
    );
    console.log(`✅ ${teamsDeleted.affectedRows} équipes supprimées`);

    // 2. Supprimer les utilisateurs de test (en gardant les vrais)
    console.log('\n👥 Suppression des utilisateurs de test...');
    
    // D'abord, identifier les utilisateurs à supprimer
    const [usersToDelete] = await connection.execute(`
      SELECT id, name, email FROM users 
      WHERE id NOT IN (${REAL_USERS.join(',')})
      AND (email LIKE '%@example.com' 
           OR email LIKE '%@test.com' 
           OR email LIKE '%@basketeur.com'
           OR email LIKE '%@handibasket.fr'
           OR email LIKE '%@asvel.com'
           OR email LIKE '%@parisbasketball.com'
           OR email LIKE '%@monacobasket.com'
           OR email LIKE '%@blmetropole92.com'
           OR email LIKE '%@strasbourg-ig.com'
           OR email LIKE '%@lemansbasket.com'
           OR email LIKE '%@staderennaisbasket.com'
           OR email LIKE '%@handiparis.fr'
           OR email LIKE '%@sfhandibasket.fr'
           OR email LIKE '%@handimarseille.fr'
           OR email LIKE '%@freeagent.com'
           OR email LIKE '%@freeagentapp.com'
           OR name LIKE 'Test%'
           OR name LIKE 'Victor%'
           OR name LIKE 'Evan%'
           OR name LIKE 'Nando%'
           OR name LIKE 'Rudy%'
           OR name LIKE 'Nicolas%'
           OR name LIKE 'Vincent%'
           OR name LIKE 'Pascal%'
           OR name LIKE 'Laurent%'
           OR name LIKE 'Frederic%'
           OR name LIKE 'Jean-Aime%'
           OR name LIKE 'Marie%'
           OR name LIKE 'Pierre%'
           OR name LIKE 'Sophie%'
           OR name LIKE 'Julie%'
           OR name LIKE 'Camille%'
           OR name LIKE 'Lea%'
           OR name LIKE 'Stade Rennais%'
           OR name LIKE 'ASVEL%'
           OR name LIKE 'Paris Basketball%'
           OR name LIKE 'Monaco Basket%'
           OR name LIKE 'Boulogne-Levallois%'
           OR name LIKE 'Strasbourg IG%'
           OR name LIKE 'Le Mans Sarthe%'
           OR name LIKE 'Club Handibasket%'
           OR name LIKE 'Stade Francais%'
           OR name LIKE 'Handibasket Marseille%'
           OR name LIKE 'LeChesnay%'
           OR name LIKE 'GSB%'
           OR name LIKE 'FCB%'
           OR name LIKE 'TFFC%'
           OR name LIKE 'Drancy%'
           OR name LIKE 'Thomas Joueur%'
           OR name LIKE 'B%'
           OR name LIKE 'coach carter%'
           OR name LIKE 'Carter%'
           OR name LIKE 'henry%'
           OR name LIKE 'salut%'
           OR name LIKE 'Gege%'
           OR name LIKE 'testons%'
           OR name LIKE 'testtt%'
           OR name LIKE 'prenium%'
           OR name LIKE 'tetstete%'
           OR name LIKE 'Jmy G%'
           OR name LIKE 'idhohdv%'
           OR name LIKE 'ninho%'
           OR name LIKE 'bbb%'
           OR name LIKE 'andiii%'
           OR name LIKE 'testestandk%'
           OR name LIKE 'le j c le s%'
           OR name LIKE 'mamady%'
           OR name LIKE 'Administrateur%')
    `);

    console.log(`📋 ${usersToDelete.length} utilisateurs identifiés pour suppression:`);
    usersToDelete.forEach(user => {
      console.log(`   - ${user.name} (${user.email})`);
    });

    if (usersToDelete.length > 0) {
      // Supprimer les profils associés d'abord
      const userIds = usersToDelete.map(u => u.id);
      
      console.log('\n🗑️ Suppression des profils associés...');
      
      // Supprimer les profils de joueurs
      const [playersDeleted] = await connection.execute(
        `DELETE FROM player_profiles WHERE user_id IN (${userIds.join(',')})`
      );
      console.log(`✅ ${playersDeleted.affectedRows} profils joueurs supprimés`);

      // Supprimer les profils handibasket
      const [handibasketDeleted] = await connection.execute(
        `DELETE FROM handibasket_profiles WHERE user_id IN (${userIds.join(',')})`
      );
      console.log(`✅ ${handibasketDeleted.affectedRows} profils handibasket supprimés`);

      // Supprimer les profils d'entraîneurs (si la table existe)
      try {
        const [coachesDeleted] = await connection.execute(
          `DELETE FROM coach_profiles WHERE user_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${coachesDeleted.affectedRows} profils entraîneurs supprimés`);
      } catch (error) {
        console.log(`⚠️ Table coach_profiles n'existe pas, ignorée`);
      }

      // Supprimer les profils de clubs (si la table existe)
      try {
        const [clubsDeleted] = await connection.execute(
          `DELETE FROM club_profiles WHERE user_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${clubsDeleted.affectedRows} profils clubs supprimés`);
      } catch (error) {
        console.log(`⚠️ Table club_profiles n'existe pas, ignorée`);
      }

      // Supprimer les messages (si la table existe)
      try {
        const [messagesDeleted] = await connection.execute(
          `DELETE FROM messages WHERE sender_id IN (${userIds.join(',')}) OR receiver_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${messagesDeleted.affectedRows} messages supprimés`);
      } catch (error) {
        console.log(`⚠️ Table messages n'existe pas, ignorée`);
      }

      // Supprimer les posts (si la table existe)
      try {
        const [postsDeleted] = await connection.execute(
          `DELETE FROM posts WHERE user_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${postsDeleted.affectedRows} posts supprimés`);
      } catch (error) {
        console.log(`⚠️ Table posts n'existe pas, ignorée`);
      }

      // Supprimer les opportunités (si la table existe)
      try {
        const [opportunitiesDeleted] = await connection.execute(
          `DELETE FROM opportunities WHERE user_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${opportunitiesDeleted.affectedRows} opportunités supprimées`);
      } catch (error) {
        console.log(`⚠️ Table opportunities n'existe pas, ignorée`);
      }

      // Supprimer les abonnements (si la table existe)
      try {
        const [subscriptionsDeleted] = await connection.execute(
          `DELETE FROM subscriptions WHERE user_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${subscriptionsDeleted.affectedRows} abonnements supprimés`);
      } catch (error) {
        console.log(`⚠️ Table subscriptions n'existe pas, ignorée`);
      }

      // Supprimer les utilisateurs
      const [usersDeleted] = await connection.execute(
        `DELETE FROM users WHERE id IN (${userIds.join(',')})`
      );
      console.log(`✅ ${usersDeleted.affectedRows} utilisateurs supprimés`);
    }

    // 3. Vérifier les résultats
    console.log('\n📊 RÉSULTATS FINAUX:');
    console.log('===================');
    
    try {
      const [finalStats] = await connection.execute(`
        SELECT 
          (SELECT COUNT(*) FROM users) as total_users,
          (SELECT COUNT(*) FROM teams) as total_teams,
          (SELECT COUNT(*) FROM player_profiles) as total_players,
          (SELECT COUNT(*) FROM handibasket_profiles) as total_handibasket,
          (SELECT COUNT(*) FROM club_profiles) as total_clubs,
          (SELECT COUNT(*) FROM posts) as total_posts,
          (SELECT COUNT(*) FROM opportunities) as total_opportunities
      `);
      
      const stats = finalStats[0];
      console.log(`👥 Utilisateurs restants: ${stats.total_users}`);
      console.log(`🏀 Équipes restantes: ${stats.total_teams}`);
      console.log(`🏃 Profils joueurs: ${stats.total_players}`);
      console.log(`♿ Profils handibasket: ${stats.total_handibasket}`);
      console.log(`🏢 Profils clubs: ${stats.total_clubs}`);
      console.log(`📝 Posts: ${stats.total_posts}`);
      console.log(`🎯 Opportunités: ${stats.total_opportunities}`);
    } catch (error) {
      console.log('⚠️ Erreur lors de la récupération des statistiques finales');
    }

    console.log('\n✅ Nettoyage terminé avec succès!');

  } catch (error) {
    console.error('❌ Erreur lors du nettoyage:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Exécuter le script
cleanupTestData();
