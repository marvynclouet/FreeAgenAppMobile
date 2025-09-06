const mysql = require('mysql2/promise');

// Configuration de la base de données
const dbConfig = {
  host: 'mysql.railway.internal',
  port: 3306,
  user: 'root',
  password: process.env.MYSQL_ROOT_PASSWORD,
  database: 'freeagent_db'
};

async function createHandibasketProfiles() {
  let connection;
  
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion à la base de données établie');

    // Supprimer les utilisateurs existants
    await connection.execute(`
      DELETE FROM handibasket_profiles WHERE user_id IN (
        SELECT id FROM users WHERE email IN (
          'handibasket1@freeagent.com',
          'handibasket2@freeagent.com',
          'handibasket3@freeagent.com',
          'handibasket4@freeagent.com',
          'handibasket5@freeagent.com'
        )
      )
    `);

    await connection.execute(`
      DELETE FROM users WHERE email IN (
        'handibasket1@freeagent.com',
        'handibasket2@freeagent.com',
        'handibasket3@freeagent.com',
        'handibasket4@freeagent.com',
        'handibasket5@freeagent.com'
      )
    `);

    console.log('✅ Anciens profils supprimés');

    // Créer les utilisateurs
    const users = [
      ['Marie Dubois', 'handibasket1@freeagent.com', 'F', 'Française'],
      ['Thomas Martin', 'handibasket2@freeagent.com', 'M', 'Français'],
      ['Sophie Leroy', 'handibasket3@freeagent.com', 'F', 'Française'],
      ['Alexandre Petit', 'handibasket4@freeagent.com', 'M', 'Français'],
      ['Camille Moreau', 'handibasket5@freeagent.com', 'F', 'Française']
    ];

    for (const [name, email, gender, nationality] of users) {
      await connection.execute(`
        INSERT INTO users (name, email, password, profile_type, gender, nationality) 
        VALUES (?, ?, ?, 'handibasket', ?, ?)
      `, [name, email, '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', gender, nationality]);
    }

    console.log('✅ Utilisateurs créés');

    // Récupérer les IDs
    const [userRows] = await connection.execute(`
      SELECT id, email FROM users WHERE email IN (
        'handibasket1@freeagent.com',
        'handibasket2@freeagent.com',
        'handibasket3@freeagent.com',
        'handibasket4@freeagent.com',
        'handibasket5@freeagent.com'
      )
    `);

    const userIds = {};
    userRows.forEach(row => {
      userIds[row.email] = row.id;
    });

    // Créer les profils handibasket
    const profiles = [
      {
        email: 'handibasket1@freeagent.com',
        data: {
          birth_date: '1995-03-15',
          handicap_type: 'Moteur',
          cat: 'I',
          residence: 'Paris',
          profession: 'Éducatrice spécialisée',
          position: 'Pivot',
          championship_level: 'Nationale 1',
          height: 175,
          weight: 68,
          passport_type: 'Français',
          experience_years: 8,
          level: 'Élite',
          classification: 'I',
          stats: JSON.stringify({
            points: 12.5,
            rebounds: 8.2,
            assists: 2.1,
            steals: 1.8,
            blocks: 1.2
          }),
          achievements: 'Championne de France 2023, Vice-championne d\'Europe 2022, 3 sélections en équipe de France',
          video_url: 'https://youtube.com/watch?v=marie_handibasket',
          bio: 'Passionnée de handibasket depuis l\'âge de 12 ans, je recherche une équipe compétitive pour continuer à progresser.',
          club: 'Paris Handibasket Club',
          coach: 'Jean-Pierre Durand'
        }
      },
      {
        email: 'handibasket2@freeagent.com',
        data: {
          birth_date: '1992-07-22',
          handicap_type: 'Moteur',
          cat: 'II',
          residence: 'Lyon',
          profession: 'Ingénieur informatique',
          position: 'Meneur',
          championship_level: 'Nationale 2',
          height: 168,
          weight: 65,
          passport_type: 'Français',
          experience_years: 10,
          level: 'Élite',
          classification: 'II',
          stats: JSON.stringify({
            points: 8.3,
            rebounds: 3.1,
            assists: 6.8,
            steals: 2.5,
            blocks: 0.3
          }),
          achievements: 'Meilleur passeur du championnat 2023, Finaliste coupe de France 2022',
          video_url: 'https://youtube.com/watch?v=thomas_handibasket',
          bio: 'Meneur de jeu expérimenté, je privilégie le collectif et la tactique.',
          club: 'Lyon Handibasket',
          coach: 'Marie-Claire Bernard'
        }
      },
      {
        email: 'handibasket3@freeagent.com',
        data: {
          birth_date: '1998-11-08',
          handicap_type: 'Moteur',
          cat: 'I',
          residence: 'Marseille',
          profession: 'Kinésithérapeute',
          position: 'Ailière',
          championship_level: 'Nationale 1',
          height: 165,
          weight: 58,
          passport_type: 'Français',
          experience_years: 5,
          level: 'Élite',
          classification: 'I',
          stats: JSON.stringify({
            points: 15.2,
            rebounds: 4.8,
            assists: 3.2,
            steals: 2.1,
            blocks: 0.8
          }),
          achievements: 'Révélation de l\'année 2023, Championne de France 2023',
          video_url: 'https://youtube.com/watch?v=sophie_handibasket',
          bio: 'Jeune joueuse dynamique et déterminée. Mon handicap moteur m\'a appris la persévérance.',
          club: 'Marseille Handibasket',
          coach: 'Pierre Lefebvre'
        }
      },
      {
        email: 'handibasket4@freeagent.com',
        data: {
          birth_date: '1990-12-03',
          handicap_type: 'Moteur',
          cat: 'II',
          residence: 'Toulouse',
          profession: 'Professeur d\'EPS',
          position: 'Intérieur',
          championship_level: 'Nationale 2',
          height: 180,
          weight: 75,
          passport_type: 'Français',
          experience_years: 12,
          level: 'Élite',
          classification: 'II',
          stats: JSON.stringify({
            points: 6.8,
            rebounds: 9.5,
            assists: 1.8,
            steals: 1.2,
            blocks: 2.3
          }),
          achievements: 'Meilleur défenseur 2022, Champion de France 2021, 5 sélections en équipe de France',
          video_url: 'https://youtube.com/watch?v=alexandre_handibasket',
          bio: 'Spécialiste de la défense et du rebond. Mon expérience et ma détermination font de moi un pilier défensif.',
          club: 'Toulouse Handibasket',
          coach: 'Claire Martin'
        }
      },
      {
        email: 'handibasket5@freeagent.com',
        data: {
          birth_date: '1996-05-18',
          handicap_type: 'Moteur',
          cat: 'I',
          residence: 'Nantes',
          profession: 'Architecte',
          position: 'Ailière forte',
          championship_level: 'Nationale 1',
          height: 170,
          weight: 62,
          passport_type: 'Français',
          experience_years: 7,
          level: 'Élite',
          classification: 'I',
          stats: JSON.stringify({
            points: 11.4,
            rebounds: 6.2,
            assists: 2.8,
            steals: 1.9,
            blocks: 1.1
          }),
          achievements: 'Vice-championne d\'Europe 2023, 2 sélections en équipe de France',
          video_url: 'https://youtube.com/watch?v=camille_handibasket',
          bio: 'Joueuse complète alliant technique et physique. Mon handicap moteur m\'a rendue plus forte mentalement.',
          club: 'Nantes Handibasket',
          coach: 'Michel Rousseau'
        }
      }
    ];

    for (const profile of profiles) {
      const userId = userIds[profile.email];
      if (!userId) {
        console.error(`❌ Utilisateur non trouvé pour ${profile.email}`);
        continue;
      }

      await connection.execute(`
        INSERT INTO handibasket_profiles (
          user_id, birth_date, handicap_type, cat, residence, profession,
          position, championship_level, height, weight, passport_type,
          experience_years, level, classification, stats, achievements,
          video_url, bio, club, coach
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        userId,
        profile.data.birth_date,
        profile.data.handicap_type,
        profile.data.cat,
        profile.data.residence,
        profile.data.profession,
        profile.data.position,
        profile.data.championship_level,
        profile.data.height,
        profile.data.weight,
        profile.data.passport_type,
        profile.data.experience_years,
        profile.data.level,
        profile.data.classification,
        profile.data.stats,
        profile.data.achievements,
        profile.data.video_url,
        profile.data.bio,
        profile.data.club,
        profile.data.coach
      ]);

      console.log(`✅ Profil créé pour ${profile.email}`);
    }

    // Créer les limites d'utilisation
    for (const userId of Object.values(userIds)) {
      await connection.execute(`
        INSERT INTO user_limits (user_id, messages_sent, opportunities_posted, applications_submitted, last_reset_date)
        VALUES (?, 0, 0, 0, CURDATE())
        ON DUPLICATE KEY UPDATE last_reset_date = CURDATE()
      `, [userId]);
    }

    console.log('✅ Limites d\'utilisation créées');

    // Afficher les profils créés
    const [result] = await connection.execute(`
      SELECT 
        u.name,
        u.email,
        u.gender,
        u.nationality,
        hp.position,
        hp.championship_level,
        hp.classification,
        hp.handicap_type,
        hp.experience_years,
        hp.club,
        hp.coach
      FROM users u
      JOIN handibasket_profiles hp ON u.id = hp.user_id
      WHERE u.profile_type = 'handibasket'
      ORDER BY u.name
    `);

    console.log('\n🎯 Profils handibasket créés :');
    result.forEach(profile => {
      console.log(`- ${profile.name} (${profile.email})`);
      console.log(`  Position: ${profile.position}, Niveau: ${profile.championship_level}`);
      console.log(`  Classification: ${profile.classification}, Handicap: ${profile.handicap_type}`);
      console.log(`  Club: ${profile.club}, Coach: ${profile.coach}`);
      console.log('');
    });

    console.log('🎉 Tous les profils handibasket ont été créés avec succès !');

  } catch (error) {
    console.error('❌ Erreur:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('✅ Connexion fermée');
    }
  }
}

// Exécuter le script
createHandibasketProfiles();
