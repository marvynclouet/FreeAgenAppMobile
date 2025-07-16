const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'freeagent_db',
  port: process.env.DB_PORT || 3306
};

async function createTestTeamAndOpportunities() {
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    // 1. Créer une équipe de test si aucune n'existe
    let [teams] = await connection.execute('SELECT id, name FROM teams LIMIT 1');
    let teamId;
    if (teams.length === 0) {
      const [result] = await connection.execute(
        `INSERT INTO teams (name, city, created_at) VALUES (?, ?, NOW())`,
        ['ASVEL Test', 'Lyon']
      );
      teamId = result.insertId;
      console.log('✅ Équipe de test créée (ASVEL Test)');
    } else {
      teamId = teams[0].id;
      console.log('ℹ️ Équipe existante trouvée (id=' + teamId + ')');
    }

    // 2. Créer un utilisateur de test si besoin
    let [users] = await connection.execute("SELECT id, email FROM users WHERE email = 'test@asvel.com' LIMIT 1");
    let userId;
    if (users.length === 0) {
      const [result] = await connection.execute(
        `INSERT INTO users (name, email, password, profile_type, created_at) VALUES (?, ?, ?, ?, NOW())`,
        ['ASVEL Manager', 'test@asvel.com', 'hashedpassword', 'club']
      );
      userId = result.insertId;
      console.log('✅ Utilisateur de test créé (test@asvel.com)');
    } else {
      userId = users[0].id;
      console.log('ℹ️ Utilisateur existant trouvé (id=' + userId + ')');
    }

    // 3. Créer des opportunités de test
    const testOpportunities = [
      {
        team_id: teamId,
        user_id: userId,
        title: 'Recrutement Joueur Pro',
        description: 'Le club ASVEL recherche un meneur de jeu pour la saison 2024-2025. Profil recherché : joueur expérimenté avec un bon leadership.',
        type: 'recrutement',
        image_url: 'https://via.placeholder.com/400x200',
        location: 'Lyon, France',
        salary_range: '5000-8000€/mois',
        requirements: 'Pro A, Leadership, Expérience',
        status: 'open'
      },
      {
        team_id: teamId,
        user_id: userId,
        title: 'Coach Assistant Recherché',
        description: 'Le club de Nanterre recherche un coach assistant pour accompagner l\'équipe première. Formation requise et expérience appréciée.',
        type: 'coaching',
        image_url: 'https://via.placeholder.com/400x200',
        location: 'Nanterre, France',
        salary_range: '3000-4500€/mois',
        requirements: 'Diplôme coach, Expérience, Disponibilité',
        status: 'open'
      }
    ];
    for (const opp of testOpportunities) {
      // Vérifier si une opportunité similaire existe déjà
      const [existing] = await connection.execute(
        'SELECT id FROM opportunities WHERE title = ? AND team_id = ? LIMIT 1',
        [opp.title, opp.team_id]
      );
      if (existing.length === 0) {
        await connection.execute(
          `INSERT INTO opportunities (team_id, user_id, title, description, type, image_url, location, salary_range, requirements, status, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
          [opp.team_id, opp.user_id, opp.title, opp.description, opp.type, opp.image_url, opp.location, opp.salary_range, opp.requirements, opp.status]
        );
        console.log('✅ Opportunité créée : ' + opp.title);
      } else {
        console.log('ℹ️ Opportunité déjà existante : ' + opp.title);
      }
    }
    console.log('\n🎉 Données de test prêtes pour le fil d\'actualité !');
  } catch (error) {
    console.error('❌ Erreur :', error);
  } finally {
    if (connection) await connection.end();
  }
}

createTestTeamAndOpportunities(); 