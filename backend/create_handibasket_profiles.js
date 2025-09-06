const https = require('https');

// Fonction pour faire une requête POST
function makeRequest(url, data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: 'freeagenappmobile-production.up.railway.app',
      port: 443,
      path: url,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(responseData);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (e) {
          resolve({ status: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

// Fonction pour faire une requête PUT
function makePutRequest(url, data, token) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: 'freeagenappmobile-production.up.railway.app',
      port: 443,
      path: url,
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(responseData);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (e) {
          resolve({ status: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

// Fonction pour créer un profil handibasket complet
async function createHandibasketProfile(userData) {
  console.log(`📝 Création du profil pour ${userData.name}...`);
  
  try {
    // 1. Inscription
    const registerData = {
      name: userData.name,
      email: userData.email,
      password: userData.password,
      profile_type: 'handibasket',
      gender: userData.gender,
      nationality: userData.nationality
    };

    const registerResponse = await makeRequest('/api/auth/register', registerData);
    
    if (registerResponse.status !== 201) {
      console.log(`❌ Erreur d'inscription pour ${userData.name}:`);
      console.log(`   Status: ${registerResponse.status}`);
      console.log(`   Message: ${registerResponse.data.message || registerResponse.data}`);
      return;
    }

    const token = registerResponse.data.token;
    console.log(`✅ ${userData.name} inscrit avec succès`);

    // 2. Mise à jour du profil handibasket
    const profileData = {
      age: userData.age,
      handicap_type: userData.handicap_type,
      classification: userData.classification,
      nationality: userData.residence,
      profession: userData.profession,
      position: userData.position,
      championship_level: userData.championship_level,
      height: userData.height,
      weight: userData.weight,
      passport_type: userData.passport_type,
      experience_years: userData.experience_years,
      level: userData.level,
      stats: userData.stats,
      achievements: userData.achievements,
      video_url: userData.video_url,
      bio: userData.bio,
      club: userData.club,
      coach: userData.coach
    };

    const profileResponse = await makePutRequest('/api/handibasket/profile', profileData, token);
    
    if (profileResponse.status === 200) {
      console.log(`✅ Profil handibasket mis à jour pour ${userData.name}`);
    } else {
      console.log(`⚠️ Erreur lors de la mise à jour du profil pour ${userData.name}:`);
      console.log(`   Status: ${profileResponse.status}`);
      console.log(`   Message: ${profileResponse.data.message || profileResponse.data}`);
    }

  } catch (error) {
    console.log(`❌ Erreur pour ${userData.name}: ${error.message}`);
  }
  
  console.log('');
}

// Fonction principale
async function createAllHandibasketProfiles() {
  console.log('🎯 Création des profils handibasket...\n');

  const profiles = [
    {
      name: 'Marie Dubois',
      email: 'marie.dubois@handibasket.com',
      password: 'Test123!',
      gender: 'F',
      nationality: 'Française',
      age: 29,
      handicap_type: 'Moteur',
      classification: 'I',
      residence: 'Paris',
      profession: 'Éducatrice spécialisée',
      position: 'Pivot',
      championship_level: 'Nationale 1',
      height: 175,
      weight: 68,
      passport_type: 'Français',
      experience_years: 8,
      level: 'Élite',
      stats: {
        points: 12.5,
        rebounds: 8.2,
        assists: 2.1,
        steals: 1.8,
        blocks: 1.2
      },
      achievements: 'Championne de France 2023, Vice-championne d\'Europe 2022, 3 sélections en équipe de France',
      video_url: 'https://youtube.com/watch?v=marie_handibasket',
      bio: 'Passionnée de handibasket depuis l\'âge de 12 ans, je recherche une équipe compétitive pour continuer à progresser. Mon handicap moteur ne m\'empêche pas de donner le meilleur de moi-même sur le terrain.',
      club: 'Paris Handibasket Club',
      coach: 'Jean-Pierre Durand'
    },
    {
      name: 'Thomas Martin',
      email: 'thomas.martin@handibasket.com',
      password: 'Test123!',
      gender: 'M',
      nationality: 'Français',
      age: 32,
      handicap_type: 'Moteur',
      classification: 'II',
      residence: 'Lyon',
      profession: 'Ingénieur informatique',
      position: 'Meneur',
      championship_level: 'Nationale 2',
      height: 168,
      weight: 65,
      passport_type: 'Français',
      experience_years: 10,
      level: 'Élite',
      stats: {
        points: 8.3,
        rebounds: 3.1,
        assists: 6.8,
        steals: 2.5,
        blocks: 0.3
      },
      achievements: 'Meilleur passeur du championnat 2023, Finaliste coupe de France 2022',
      video_url: 'https://youtube.com/watch?v=thomas_handibasket',
      bio: 'Meneur de jeu expérimenté, je privilégie le collectif et la tactique. Je recherche une équipe qui partage mes valeurs de fair-play et d\'excellence.',
      club: 'Lyon Handibasket',
      coach: 'Marie-Claire Bernard'
    },
    {
      name: 'Sophie Leroy',
      email: 'sophie.leroy@handibasket.com',
      password: 'Test123!',
      gender: 'F',
      nationality: 'Française',
      age: 26,
      handicap_type: 'Moteur',
      classification: 'I',
      residence: 'Marseille',
      profession: 'Kinésithérapeute',
      position: 'Ailière',
      championship_level: 'Nationale 1',
      height: 165,
      weight: 58,
      passport_type: 'Français',
      experience_years: 5,
      level: 'Élite',
      stats: {
        points: 15.2,
        rebounds: 4.8,
        assists: 3.2,
        steals: 2.1,
        blocks: 0.8
      },
      achievements: 'Révélation de l\'année 2023, Championne de France 2023',
      video_url: 'https://youtube.com/watch?v=sophie_handibasket',
      bio: 'Jeune joueuse dynamique et déterminée. Mon handicap moteur m\'a appris la persévérance. Je cherche une équipe ambitieuse pour continuer ma progression.',
      club: 'Marseille Handibasket',
      coach: 'Pierre Lefebvre'
    },
    {
      name: 'Alexandre Petit',
      email: 'alexandre.petit@handibasket.com',
      password: 'Test123!',
      gender: 'M',
      nationality: 'Français',
      age: 34,
      handicap_type: 'Moteur',
      classification: 'II',
      residence: 'Toulouse',
      profession: 'Professeur d\'EPS',
      position: 'Intérieur',
      championship_level: 'Nationale 2',
      height: 180,
      weight: 75,
      passport_type: 'Français',
      experience_years: 12,
      level: 'Élite',
      stats: {
        points: 6.8,
        rebounds: 9.5,
        assists: 1.8,
        steals: 1.2,
        blocks: 2.3
      },
      achievements: 'Meilleur défenseur 2022, Champion de France 2021, 5 sélections en équipe de France',
      video_url: 'https://youtube.com/watch?v=alexandre_handibasket',
      bio: 'Spécialiste de la défense et du rebond. Mon expérience et ma détermination font de moi un pilier défensif. Je recherche une équipe qui valorise le travail défensif.',
      club: 'Toulouse Handibasket',
      coach: 'Claire Martin'
    },
    {
      name: 'Camille Moreau',
      email: 'camille.moreau@handibasket.com',
      password: 'Test123!',
      gender: 'F',
      nationality: 'Française',
      age: 28,
      handicap_type: 'Moteur',
      classification: 'I',
      residence: 'Nantes',
      profession: 'Architecte',
      position: 'Ailière forte',
      championship_level: 'Nationale 1',
      height: 170,
      weight: 62,
      passport_type: 'Français',
      experience_years: 7,
      level: 'Élite',
      stats: {
        points: 11.4,
        rebounds: 6.2,
        assists: 2.8,
        steals: 1.9,
        blocks: 1.1
      },
      achievements: 'Vice-championne d\'Europe 2023, 2 sélections en équipe de France',
      video_url: 'https://youtube.com/watch?v=camille_handibasket',
      bio: 'Joueuse complète alliant technique et physique. Mon handicap moteur m\'a rendue plus forte mentalement. Je cherche une équipe de haut niveau pour relever de nouveaux défis.',
      club: 'Nantes Handibasket',
      coach: 'Michel Rousseau'
    }
  ];

  for (const profile of profiles) {
    await createHandibasketProfile(profile);
  }

  console.log('🎉 Tous les profils handibasket ont été créés !');
  console.log('\n📋 Résumé des comptes créés :');
  profiles.forEach(profile => {
    console.log(`- ${profile.name} (${profile.email}) - Mot de passe: Test123!`);
  });
}

// Exécuter le script
createAllHandibasketProfiles();
