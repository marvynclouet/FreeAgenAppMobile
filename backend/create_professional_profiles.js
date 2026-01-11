const mysql = require('mysql2/promise');

const dbConfig = {
  host: 'hopper.proxy.rlwy.net',
  user: 'root',
  password: 'WkdwbGCWQjoQhjNdeGEumAVztCSRXvZn',
  database: 'railway',
  port: 24981
};

async function createProfessionalProfiles() {
  let connection;
  
  try {
    console.log('👨‍🏫 Création des profils professionnels...');
    console.log('========================================\n');
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion à la base de données établie');

    // Récupérer les utilisateurs existants
    const [users] = await connection.execute(`
      SELECT id, name, email, profile_type 
      FROM users 
      WHERE profile_type IN ('coach_pro', 'coach_basket', 'dieteticienne', 'juriste')
      ORDER BY profile_type, name
    `);

    console.log(`📋 ${users.length} utilisateurs professionnels trouvés:`);
    users.forEach(user => {
      console.log(`   - ${user.name} (${user.email}) - ${user.profile_type}`);
    });

    // Créer des profils pour chaque utilisateur
    for (const user of users) {
      let tableName = '';
      let profileData = {};

      switch (user.profile_type) {
        case 'coach_pro':
          tableName = 'coach_pro_profiles';
          profileData = {
            experience_years: Math.floor(Math.random() * 20) + 5,
            level: ['Débutant', 'Amateur', 'Semi-pro', 'Professionnel'][Math.floor(Math.random() * 4)],
            specialization: ['Entraînement individuel', 'Entraînement d\'équipe', 'Préparation physique', 'Tactique'][Math.floor(Math.random() * 4)],
            achievements: 'Palmarès impressionnant avec plusieurs équipes',
            description: `Coach professionnel expérimenté spécialisé dans ${profileData.specialization}`,
            phone: `0${Math.floor(Math.random() * 900000000) + 100000000}`,
            website: `https://${user.name.toLowerCase().replace(/\s+/g, '')}.com`
          };
          break;
        case 'coach_basket':
          tableName = 'coach_basket_profiles';
          profileData = {
            experience_years: Math.floor(Math.random() * 15) + 3,
            level: ['Amateur', 'Semi-pro', 'Professionnel'][Math.floor(Math.random() * 3)],
            specialization: ['Basketball', 'Entraînement technique', 'Développement des jeunes'][Math.floor(Math.random() * 3)],
            achievements: 'Formation de nombreux joueurs talentueux',
            description: `Coach de basketball passionné avec ${profileData.experience_years} ans d'expérience`,
            phone: `0${Math.floor(Math.random() * 900000000) + 100000000}`,
            website: `https://${user.name.toLowerCase().replace(/\s+/g, '')}-basket.com`
          };
          break;
        case 'dieteticienne':
          tableName = 'dieteticienne_profiles';
          profileData = {
            experience_years: Math.floor(Math.random() * 10) + 2,
            level: ['Diplômée', 'Spécialisée', 'Expert'][Math.floor(Math.random() * 3)],
            specialization: ['Nutrition sportive', 'Récupération', 'Performance'][Math.floor(Math.random() * 3)],
            achievements: 'Aide de nombreux athlètes à optimiser leur performance',
            description: `Diététicienne spécialisée en nutrition sportive`,
            phone: `0${Math.floor(Math.random() * 900000000) + 100000000}`,
            website: `https://${user.name.toLowerCase().replace(/\s+/g, '')}-nutrition.com`
          };
          break;
        case 'juriste':
          tableName = 'juriste_profiles';
          profileData = {
            experience_years: Math.floor(Math.random() * 15) + 5,
            level: ['Avocat', 'Avocat spécialisé', 'Expert'][Math.floor(Math.random() * 3)],
            specialization: ['Droit du sport', 'Contrats sportifs', 'Droit du travail sportif'][Math.floor(Math.random() * 3)],
            achievements: 'Accompagnement de nombreux sportifs et clubs',
            description: `Juriste spécialisé en droit du sport`,
            phone: `0${Math.floor(Math.random() * 900000000) + 100000000}`,
            website: `https://${user.name.toLowerCase().replace(/\s+/g, '')}-avocat.com`
          };
          break;
      }

      // Vérifier si le profil existe déjà
      const [existing] = await connection.execute(
        `SELECT id FROM ${tableName} WHERE user_id = ?`,
        [user.id]
      );

      if (existing.length === 0) {
        await connection.execute(
          `INSERT INTO ${tableName} (user_id, experience_years, level, specialization, achievements, description, phone, website) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [user.id, profileData.experience_years, profileData.level, profileData.specialization, 
           profileData.achievements, profileData.description, profileData.phone, profileData.website]
        );
        console.log(`✅ Profil créé pour ${user.name} (${user.profile_type})`);
      } else {
        console.log(`⚠️ Profil déjà existant pour ${user.name} (${user.profile_type})`);
      }
    }

    console.log('\n✅ Création des profils professionnels terminée!');

  } catch (error) {
    console.error('❌ Erreur lors de la création des profils:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

createProfessionalProfiles();
