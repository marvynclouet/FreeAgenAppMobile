const mysql = require('mysql2/promise');

// Configuration de la base de données Railway (même que dans db.config.js)
const dbConfig = {
  host: 'hopper.proxy.rlwy.net',
  user: 'root',
  password: 'WkdwbGCWQjoQhjNdeGEumAVztCSRXvZn',
  database: 'railway',
  port: 24981
};

async function listAllProfiles() {
  let connection;
  
  try {
    console.log('📋 Liste de tous les profils dans la base de données...');
    console.log('======================================================\n');
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion à la base de données établie');

    // 1. Lister tous les utilisateurs
    console.log('👥 UTILISATEURS:');
    console.log('================');
    const [users] = await connection.execute(`
      SELECT id, name, email, profile_type, created_at, is_premium, subscription_type
      FROM users 
      ORDER BY created_at DESC
    `);
    
    console.log(`Total: ${users.length} utilisateurs\n`);
    users.forEach((user, index) => {
      console.log(`${index + 1}. ID: ${user.id}`);
      console.log(`   Nom: ${user.name}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Type: ${user.profile_type}`);
      console.log(`   Premium: ${user.is_premium ? 'Oui' : 'Non'}`);
      console.log(`   Abonnement: ${user.subscription_type || 'Gratuit'}`);
      console.log(`   Créé: ${user.created_at}`);
      console.log('   ---');
    });

    // 2. Lister les équipes
    console.log('\n🏀 ÉQUIPES:');
    console.log('===========');
    const [teams] = await connection.execute(`
      SELECT id, name, city, description, level, division, founded_year, created_at
      FROM teams 
      ORDER BY created_at DESC
    `);
    
    console.log(`Total: ${teams.length} équipes\n`);
    teams.forEach((team, index) => {
      console.log(`${index + 1}. ID: ${team.id}`);
      console.log(`   Nom: ${team.name}`);
      console.log(`   Ville: ${team.city}`);
      console.log(`   Niveau: ${team.level || 'Non spécifié'}`);
      console.log(`   Division: ${team.division || 'Non spécifiée'}`);
      console.log(`   Année: ${team.founded_year || 'Non spécifiée'}`);
      console.log(`   Description: ${team.description ? team.description.substring(0, 100) + '...' : 'Aucune'}`);
      console.log(`   Créé: ${team.created_at}`);
      console.log('   ---');
    });

    // 3. Lister les profils de joueurs
    console.log('\n🏃 PROFILS JOUEURS:');
    console.log('==================');
    const [players] = await connection.execute(`
      SELECT pp.id, u.name, u.email, pp.age, pp.position, pp.height, pp.weight, pp.level, pp.created_at
      FROM player_profiles pp
      JOIN users u ON pp.user_id = u.id
      ORDER BY pp.created_at DESC
    `);
    
    console.log(`Total: ${players.length} profils joueurs\n`);
    players.forEach((player, index) => {
      console.log(`${index + 1}. ID: ${player.id}`);
      console.log(`   Joueur: ${player.name}`);
      console.log(`   Email: ${player.email}`);
      console.log(`   Âge: ${player.age || 'Non spécifié'}`);
      console.log(`   Poste: ${player.position || 'Non spécifié'}`);
      console.log(`   Taille: ${player.height || 'Non spécifiée'}`);
      console.log(`   Poids: ${player.weight || 'Non spécifié'}`);
      console.log(`   Niveau: ${player.level || 'Non spécifié'}`);
      console.log(`   Créé: ${player.created_at}`);
      console.log('   ---');
    });

    // 4. Lister les profils handibasket
    console.log('\n♿ PROFILS HANDIBASKET:');
    console.log('======================');
    const [handibasket] = await connection.execute(`
      SELECT hp.id, u.name, u.email, hp.age, hp.position, hp.handicap_type, hp.level, hp.created_at
      FROM handibasket_profiles hp
      JOIN users u ON hp.user_id = u.id
      ORDER BY hp.created_at DESC
    `);
    
    console.log(`Total: ${handibasket.length} profils handibasket\n`);
    handibasket.forEach((profile, index) => {
      console.log(`${index + 1}. ID: ${profile.id}`);
      console.log(`   Joueur: ${profile.name}`);
      console.log(`   Email: ${profile.email}`);
      console.log(`   Âge: ${profile.age || 'Non spécifié'}`);
      console.log(`   Poste: ${profile.position || 'Non spécifié'}`);
      console.log(`   Type handicap: ${profile.handicap_type || 'Non spécifié'}`);
      console.log(`   Niveau: ${profile.level || 'Non spécifié'}`);
      console.log(`   Créé: ${profile.created_at}`);
      console.log('   ---');
    });

    // 5. Lister les profils d'entraîneurs
    console.log('\n👨‍🏫 PROFILS ENTRAÎNEURS:');
    console.log('=========================');
    const [coaches] = await connection.execute(`
      SELECT cp.id, u.name, u.email, cp.experience_years, cp.level, cp.specialization, cp.created_at
      FROM coach_profiles cp
      JOIN users u ON cp.user_id = u.id
      ORDER BY cp.created_at DESC
    `);
    
    console.log(`Total: ${coaches.length} profils entraîneurs\n`);
    coaches.forEach((coach, index) => {
      console.log(`${index + 1}. ID: ${coach.id}`);
      console.log(`   Entraîneur: ${coach.name}`);
      console.log(`   Email: ${coach.email}`);
      console.log(`   Expérience: ${coach.experience_years || 'Non spécifiée'} ans`);
      console.log(`   Niveau: ${coach.level || 'Non spécifié'}`);
      console.log(`   Spécialisation: ${coach.specialization || 'Non spécifiée'}`);
      console.log(`   Créé: ${coach.created_at}`);
      console.log('   ---');
    });

    // 6. Lister les profils de clubs
    console.log('\n🏢 PROFILS CLUBS:');
    console.log('=================');
    const [clubs] = await connection.execute(`
      SELECT cp.id, u.name, u.email, cp.club_name, cp.city, cp.level, cp.division, cp.created_at
      FROM club_profiles cp
      JOIN users u ON cp.user_id = u.id
      ORDER BY cp.created_at DESC
    `);
    
    console.log(`Total: ${clubs.length} profils clubs\n`);
    clubs.forEach((club, index) => {
      console.log(`${index + 1}. ID: ${club.id}`);
      console.log(`   Club: ${club.club_name}`);
      console.log(`   Contact: ${club.name}`);
      console.log(`   Email: ${club.email}`);
      console.log(`   Ville: ${club.city || 'Non spécifiée'}`);
      console.log(`   Niveau: ${club.level || 'Non spécifié'}`);
      console.log(`   Division: ${club.division || 'Non spécifiée'}`);
      console.log(`   Créé: ${club.created_at}`);
      console.log('   ---');
    });

    // 7. Statistiques générales
    console.log('\n📊 STATISTIQUES GÉNÉRALES:');
    console.log('===========================');
    
    const [stats] = await connection.execute(`
      SELECT 
        (SELECT COUNT(*) FROM users) as total_users,
        (SELECT COUNT(*) FROM teams) as total_teams,
        (SELECT COUNT(*) FROM player_profiles) as total_players,
        (SELECT COUNT(*) FROM handibasket_profiles) as total_handibasket,
        (SELECT COUNT(*) FROM coach_profiles) as total_coaches,
        (SELECT COUNT(*) FROM club_profiles) as total_clubs,
        (SELECT COUNT(*) FROM messages) as total_messages,
        (SELECT COUNT(*) FROM posts) as total_posts,
        (SELECT COUNT(*) FROM opportunities) as total_opportunities
    `);
    
    const stat = stats[0];
    console.log(`👥 Utilisateurs: ${stat.total_users}`);
    console.log(`🏀 Équipes: ${stat.total_teams}`);
    console.log(`🏃 Joueurs: ${stat.total_players}`);
    console.log(`♿ Handibasket: ${stat.total_handibasket}`);
    console.log(`👨‍🏫 Entraîneurs: ${stat.total_coaches}`);
    console.log(`🏢 Clubs: ${stat.total_clubs}`);
    console.log(`💬 Messages: ${stat.total_messages}`);
    console.log(`📝 Posts: ${stat.total_posts}`);
    console.log(`🎯 Opportunités: ${stat.total_opportunities}`);

    console.log('\n✅ Liste terminée!');

  } catch (error) {
    console.error('❌ Erreur lors de la récupération des profils:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Exécuter le script
listAllProfiles();

