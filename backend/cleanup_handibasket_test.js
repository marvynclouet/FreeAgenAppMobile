const mysql = require('mysql2/promise');

const dbConfig = {
  host: 'hopper.proxy.rlwy.net',
  user: 'root',
  password: 'WkdwbGCWQjoQhjNdeGEumAVztCSRXvZn',
  database: 'railway',
  port: 24981
};

async function cleanupHandibasketTest() {
  let connection;
  
  try {
    console.log('🧹 Nettoyage des comptes de test handibasket...');
    console.log('==============================================\n');
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion à la base de données établie');

    // Identifier les utilisateurs de test handibasket à supprimer
    const [usersToDelete] = await connection.execute(`
      SELECT id, name, email FROM users 
      WHERE profile_type = 'handibasket' 
      AND (email LIKE '%@test.com' 
           OR email LIKE '%@handibasket.com'
           OR email LIKE '%@handibasket.fr'
           OR name LIKE 'Test%'
           OR name LIKE 'Joueur Test%'
           OR name LIKE 'Équipe Test%'
           OR name LIKE 'Alexandre%'
           OR name LIKE 'Emma%'
           OR name LIKE 'Thomas%'
           OR name LIKE 'Marc%'
           OR name LIKE 'Marie%'
           OR name LIKE 'Sophie%'
           OR name LIKE 'Camille%'
           OR name LIKE 'uzyeueye%'
           OR name LIKE 'keeueuej%'
           OR name LIKE 'tutapl%'
           OR name LIKE 'zetztzetez%'
           OR name LIKE 'efdhdf%'
           OR name LIKE 'hnfuibfiuezbfbeiu%'
           OR name LIKE 'Uaueydhd%'
           OR name LIKE 'egregergergergrg%'
           OR name LIKE 'ezefzfez%'
           OR name LIKE 'fefezfzefezf%'
           OR name LIKE 'tyuu%'
           OR name LIKE 'Debug User%'
           OR name LIKE 'hehehehe%'
           OR name LIKE 'hehifhzefiohez%'
           OR name LIKE 'effefz%'
           OR name LIKE 'ferfz%'
           OR name LIKE 'money%'
           OR name LIKE 'handiteam%'
           OR name LIKE 'le j c le s%'
           OR name LIKE 'testestandk%'
           OR name LIKE 'andiii%'
           OR name LIKE 'test56%'
           OR name LIKE 'birbergber%'
           OR name LIKE 'testteam%')
    `);

    console.log(`📋 ${usersToDelete.length} utilisateurs handibasket de test identifiés pour suppression:`);
    usersToDelete.forEach(user => {
      console.log(`   - ${user.name} (${user.email})`);
    });

    if (usersToDelete.length > 0) {
      const userIds = usersToDelete.map(u => u.id);
      
      console.log('\n🗑️ Suppression des profils associés...');
      
      // Supprimer les profils handibasket
      const [handibasketDeleted] = await connection.execute(
        `DELETE FROM handibasket_profiles WHERE user_id IN (${userIds.join(',')})`
      );
      console.log(`✅ ${handibasketDeleted.affectedRows} profils handibasket supprimés`);

      // Supprimer les profils d'équipes handibasket
      const [handibasketTeamsDeleted] = await connection.execute(
        `DELETE FROM handibasket_team_profiles WHERE user_id IN (${userIds.join(',')})`
      );
      console.log(`✅ ${handibasketTeamsDeleted.affectedRows} profils d'équipes handibasket supprimés`);

      // Supprimer les messages
      try {
        const [messagesDeleted] = await connection.execute(
          `DELETE FROM messages WHERE sender_id IN (${userIds.join(',')}) OR receiver_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${messagesDeleted.affectedRows} messages supprimés`);
      } catch (error) {
        console.log(`⚠️ Table messages n'existe pas, ignorée`);
      }

      // Supprimer les posts
      try {
        const [postsDeleted] = await connection.execute(
          `DELETE FROM posts WHERE user_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${postsDeleted.affectedRows} posts supprimés`);
      } catch (error) {
        console.log(`⚠️ Table posts n'existe pas, ignorée`);
      }

      // Supprimer les opportunités
      try {
        const [opportunitiesDeleted] = await connection.execute(
          `DELETE FROM opportunities WHERE user_id IN (${userIds.join(',')})`
        );
        console.log(`✅ ${opportunitiesDeleted.affectedRows} opportunités supprimées`);
      } catch (error) {
        console.log(`⚠️ Table opportunities n'existe pas, ignorée`);
      }

      // Supprimer les abonnements
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

    // Vérifier les résultats
    console.log('\n📊 RÉSULTATS FINAUX:');
    console.log('===================');
    
    try {
      const [finalStats] = await connection.execute(`
        SELECT 
          (SELECT COUNT(*) FROM users WHERE profile_type = 'handibasket') as handibasket_users,
          (SELECT COUNT(*) FROM users WHERE profile_type = 'handibasket_team') as handibasket_teams,
          (SELECT COUNT(*) FROM handibasket_profiles) as handibasket_profiles,
          (SELECT COUNT(*) FROM handibasket_team_profiles) as handibasket_team_profiles
      `);
      
      const stats = finalStats[0];
      console.log(`♿ Utilisateurs handibasket restants: ${stats.handibasket_users}`);
      console.log(`🏀 Équipes handibasket restantes: ${stats.handibasket_teams}`);
      console.log(`♿ Profils handibasket: ${stats.handibasket_profiles}`);
      console.log(`🏀 Profils d'équipes handibasket: ${stats.handibasket_team_profiles}`);
    } catch (error) {
      console.log('⚠️ Erreur lors de la récupération des statistiques finales');
    }

    console.log('\n✅ Nettoyage des comptes de test handibasket terminé!');

  } catch (error) {
    console.error('❌ Erreur lors du nettoyage:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

cleanupHandibasketTest();
