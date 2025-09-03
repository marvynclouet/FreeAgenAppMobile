const pool = require('../config/db.config');

class MatchingService {
  constructor() {
    this.pool = pool;
  }

  // Système de matching basé sur les annonces
  // 1. Pour les équipes : trouver les joueurs qui correspondent à leurs annonces
  // 2. Pour les joueurs : trouver les annonces d'équipes qui leur correspondent

  /**
   * Trouve les matches pour un utilisateur selon son type
   * @param {number} userId - ID de l'utilisateur
   * @param {string} userType - Type d'utilisateur (player, club, etc.)
   * @param {number} limit - Limite de résultats
   */
  async findMatches(userId, userType, limit = 10) {
    try {
      switch (userType) {
        case 'player':
          // Un joueur cherche des annonces d'équipes qui lui correspondent
          return await this.findTeamAdsForPlayer(userId, limit);
        
        case 'handibasket':
          // Un joueur handibasket cherche des annonces d'équipes handibasket
          return await this.findHandibasketAdsForPlayer(userId, limit);
        
        case 'club':
          // Une équipe cherche des joueurs qui correspondent à ses annonces
          return await this.findPlayersForTeamAds(userId, limit);
        
        case 'coach_pro':
        case 'coach_basket':
          // Un coach cherche des annonces de coaching qui lui correspondent
          return await this.findCoachingAdsForCoach(userId, limit);
        
        case 'juriste':
        case 'dieteticienne':
          // Services professionnels cherchent des annonces de consultation
          return await this.findConsultationAdsForProfessional(userId, limit);
        
        default:
          return [];
      }
    } catch (error) {
      console.error('Erreur lors de la recherche de matches:', error);
      throw error;
    }
  }

  /**
   * Trouve les annonces handibasket qui correspondent à un joueur handibasket
   */
  async findHandibasketAdsForPlayer(playerId, limit = 10) {
    try {
      // Récupérer le profil du joueur handibasket
      const playerProfile = await this.getHandibasketProfile(playerId);
      if (!playerProfile) {
        throw new Error('Profil handibasket introuvable');
      }

      // Récupérer les annonces handibasket ouvertes
      const query = `
        SELECT 
          a.id, a.title, a.description, a.requirements, a.salary_range, 
          a.location, a.created_at, a.user_id as team_user_id,
          u.name as team_name, u.email as team_email, u.profile_image_url as team_image,
          cp.club_name, cp.level as team_level, cp.location as team_location
        FROM annonces a
        JOIN users u ON a.user_id = u.id
        LEFT JOIN club_profiles cp ON u.id = cp.user_id
        WHERE (a.type = 'recrutement' OR a.type = 'coaching')
          AND a.status = 'open'
          AND a.user_id != ?
          AND (a.title LIKE '%handibasket%' OR a.description LIKE '%handibasket%' OR a.requirements LIKE '%handibasket%')
        ORDER BY a.created_at DESC
        LIMIT ?
      `;

      const [rows] = await pool.execute(query, [playerId.toString(), limit.toString()]);

      // Calculer le score de compatibilité pour chaque annonce
      const matchesWithScores = await Promise.all(
        rows.map(async (ad) => {
          const compatibilityScore = this.calculateHandibasketAdCompatibility(playerProfile, ad);
          return {
            id: ad.id.toString(),
            type: 'club',
            name: ad.team_name,
            email: ad.team_email,
            image: ad.team_image,
            club_name: ad.club_name,
            level: ad.team_level,
            location: ad.team_location || ad.location,
            advertisement: {
              id: ad.id,
              title: ad.title,
              description: ad.description,
              requirements: ad.requirements,
              salary_range: ad.salary_range,
              location: ad.location
            },
            compatibilityScore,
            matchLevel: this.getMatchLevel(compatibilityScore),
            reasons: this.getHandibasketAdMatchReasons(playerProfile, ad, compatibilityScore)
          };
        })
      );

      // Trier par score de compatibilité
      return matchesWithScores.sort((a, b) => b.compatibilityScore - a.compatibilityScore);

    } catch (error) {
      console.error('Erreur lors de la recherche d\'annonces handibasket pour joueur:', error);
      throw error;
    }
  }

  /**
   * Trouve les annonces d'équipes qui correspondent à un joueur
   */
  async findTeamAdsForPlayer(playerId, limit = 10) {
    try {
      // Récupérer le profil du joueur
      const playerProfile = await this.getPlayerProfile(playerId);
      if (!playerProfile) {
        throw new Error('Profil joueur introuvable');
      }

      // Récupérer les annonces de recrutement ouvertes
      const query = `
        SELECT 
          a.id, a.title, a.description, a.requirements, a.salary_range, 
          a.location, a.created_at, a.user_id as team_user_id,
          u.name as team_name, u.email as team_email, u.profile_image_url as team_image,
          cp.club_name, cp.level as team_level, cp.location as team_location
        FROM annonces a
        JOIN users u ON a.user_id = u.id
        LEFT JOIN club_profiles cp ON u.id = cp.user_id
        WHERE a.type = 'recrutement' 
          AND a.status = 'open'
          AND a.user_id != ?
        ORDER BY a.created_at DESC
        LIMIT ?
      `;

      const [rows] = await pool.execute(query, [playerId.toString(), limit.toString()]);

      // Calculer le score de compatibilité pour chaque annonce
      const matchesWithScores = await Promise.all(
        rows.map(async (ad) => {
          const compatibilityScore = this.calculatePlayerAdCompatibility(playerProfile, ad);
          return {
            id: ad.id.toString(),
            type: 'club',
            name: ad.team_name,
            email: ad.team_email,
            image: ad.team_image,
            club_name: ad.club_name,
            level: ad.team_level,
            location: ad.team_location || ad.location,
            advertisement: {
              id: ad.id,
              title: ad.title,
              description: ad.description,
              requirements: ad.requirements,
              salary_range: ad.salary_range,
              location: ad.location
            },
            compatibilityScore,
            matchLevel: this.getMatchLevel(compatibilityScore),
            reasons: this.getPlayerAdMatchReasons(playerProfile, ad, compatibilityScore)
          };
        })
      );

      // Trier par score de compatibilité
      return matchesWithScores.sort((a, b) => b.compatibilityScore - a.compatibilityScore);

    } catch (error) {
      console.error('Erreur lors de la recherche d\'annonces pour joueur:', error);
      throw error;
    }
  }

  /**
   * Trouve les joueurs qui correspondent aux annonces d'une équipe
   */
  async findPlayersForTeamAds(teamId, limit = 10) {
    try {
      // Récupérer les annonces de recrutement de l'équipe
      const teamAdsQuery = `
        SELECT id, title, description, requirements, salary_range, location
        FROM annonces 
        WHERE user_id = ? AND type = 'recrutement' AND status = 'open'
        ORDER BY created_at DESC
        LIMIT 5
      `;

      const [teamAds] = await pool.execute(teamAdsQuery, [teamId.toString()]);
      
      if (teamAds.length === 0) {
        return [];
      }

      // Récupérer tous les joueurs disponibles
      const playersQuery = `
        SELECT 
          p.*, u.name, u.email, u.profile_image_url,
          COALESCE(p.position, 'polyvalent') as position,
          COALESCE(p.level, 'departemental') as level,
          COALESCE(p.age, 25) as age,
          COALESCE(p.experience_years, 0) as experience_years
        FROM player_profiles p
        JOIN users u ON p.user_id = u.id
        WHERE p.user_id != ?
        LIMIT ?
      `;

      const [players] = await pool.execute(playersQuery, [teamId.toString(), (limit * 2).toString()]);

      // Calculer le score de compatibilité pour chaque joueur avec chaque annonce
      const matchesWithScores = [];

      for (const player of players) {
        let bestScore = 0;
        let bestAd = null;
        let bestReasons = [];

        // Tester chaque annonce avec ce joueur
        for (const ad of teamAds) {
          const score = this.calculatePlayerAdCompatibility(player, ad);
          if (score > bestScore) {
            bestScore = score;
            bestAd = ad;
            bestReasons = this.getPlayerAdMatchReasons(player, ad, score);
          }
        }

        if (bestScore > 30) { // Seuil minimum de compatibilité
          matchesWithScores.push({
            id: player.user_id.toString(),
            type: 'player',
            name: player.name,
            email: player.email,
            image: player.profile_image_url,
            position: player.position,
            level: player.level,
            age: player.age,
            experience_years: player.experience_years,
            bestMatchedAd: bestAd,
            compatibilityScore: bestScore,
            matchLevel: this.getMatchLevel(bestScore),
            reasons: bestReasons
          });
        }
      }

      // Trier par score de compatibilité
      return matchesWithScores.sort((a, b) => b.compatibilityScore - a.compatibilityScore);

    } catch (error) {
      console.error('Erreur lors de la recherche de joueurs pour équipe:', error);
      throw error;
    }
  }

  /**
   * Trouve les annonces de coaching pour un coach
   */
  async findCoachingAdsForCoach(coachId, limit = 10) {
    try {
      const query = `
        SELECT 
          a.id, a.title, a.description, a.requirements, a.salary_range, 
          a.location, a.created_at, a.user_id as team_user_id,
          u.name as team_name, u.email as team_email, u.profile_image_url as team_image,
          cp.club_name, cp.level as team_level, cp.location as team_location
        FROM annonces a
        JOIN users u ON a.user_id = u.id
        LEFT JOIN club_profiles cp ON u.id = cp.user_id
        WHERE a.type = 'coaching' 
          AND a.status = 'open'
          AND a.user_id != ?
        ORDER BY a.created_at DESC
        LIMIT ?
      `;

      const [rows] = await pool.execute(query, [coachId.toString(), limit.toString()]);

      return rows.map(ad => ({
        id: ad.id.toString(),
        type: 'club',
        name: ad.team_name,
        email: ad.team_email,
        image: ad.team_image,
        club_name: ad.club_name,
        level: ad.team_level,
        location: ad.team_location || ad.location,
        advertisement: {
          id: ad.id,
          title: ad.title,
          description: ad.description,
          requirements: ad.requirements,
          salary_range: ad.salary_range,
          location: ad.location
        },
        compatibilityScore: 75, // Score par défaut pour les coaches
        matchLevel: 'good',
        reasons: ['Annonce de coaching disponible']
      }));

    } catch (error) {
      console.error('Erreur lors de la recherche d\'annonces de coaching:', error);
      throw error;
    }
  }

  /**
   * Trouve les annonces de consultation pour les professionnels
   */
  async findConsultationAdsForProfessional(professionalId, limit = 10) {
    try {
      const query = `
        SELECT 
          a.id, a.title, a.description, a.requirements, a.salary_range, 
          a.location, a.created_at, a.user_id as client_user_id,
          u.name as client_name, u.email as client_email, u.profile_image_url as client_image
        FROM annonces a
        JOIN users u ON a.user_id = u.id
        WHERE a.type = 'consultation' 
          AND a.status = 'open'
          AND a.user_id != ?
        ORDER BY a.created_at DESC
        LIMIT ?
      `;

      const [rows] = await pool.execute(query, [professionalId.toString(), limit.toString()]);

      return rows.map(ad => ({
        id: ad.id.toString(),
        type: 'client',
        name: ad.client_name,
        email: ad.client_email,
        image: ad.client_image,
        advertisement: {
          id: ad.id,
          title: ad.title,
          description: ad.description,
          requirements: ad.requirements,
          salary_range: ad.salary_range,
          location: ad.location
        },
        compatibilityScore: 70, // Score par défaut pour les consultations
        matchLevel: 'good',
        reasons: ['Demande de consultation disponible']
      }));

    } catch (error) {
      console.error('Erreur lors de la recherche d\'annonces de consultation:', error);
      throw error;
    }
  }

  /**
   * Récupère le profil d'un joueur
   */
  async getPlayerProfile(playerId) {
    try {
      const query = `
        SELECT 
          p.*, u.name, u.email, u.profile_image_url,
          COALESCE(p.position, 'polyvalent') as position,
          COALESCE(p.level, 'departemental') as level,
          COALESCE(p.age, 25) as age,
          COALESCE(p.experience_years, 0) as experience_years
        FROM player_profiles p
        JOIN users u ON p.user_id = u.id
        WHERE p.user_id = ?
      `;

      const [rows] = await pool.execute(query, [playerId.toString()]);
      return rows[0] || null;

    } catch (error) {
      console.error('Erreur lors de la récupération du profil joueur:', error);
      throw error;
    }
  }

  /**
   * Récupère le profil d'un joueur handibasket
   */
  async getHandibasketProfile(playerId) {
    try {
      const query = `
        SELECT 
          hp.*, u.name, u.email, u.profile_image_url, u.gender, u.nationality,
          COALESCE(hp.position, 'polyvalent') as position,
          COALESCE(hp.championship_level, 'non_specifie') as level,
          COALESCE(TIMESTAMPDIFF(YEAR, hp.birth_date, CURDATE()), 25) as age,
          COALESCE(hp.experience_years, 0) as experience_years,
          COALESCE(hp.residence, 'France') as location
        FROM handibasket_profiles hp
        JOIN users u ON hp.user_id = u.id
        WHERE hp.user_id = ?
      `;

      const [rows] = await pool.execute(query, [playerId.toString()]);
      return rows[0] || null;

    } catch (error) {
      console.error('Erreur lors de la récupération du profil handibasket:', error);
      throw error;
    }
  }

  /**
   * Calcule la compatibilité entre un joueur et une annonce
   */
  calculatePlayerAdCompatibility(playerProfile, advertisement) {
    let score = 0;
    const requirements = advertisement.requirements || '';
    const description = advertisement.description || '';
    const location = advertisement.location || '';

    // Analyse du texte pour détecter les critères
    const text = (requirements + ' ' + description).toLowerCase();

    // 1. Position (30% du score)
    if (playerProfile.position) {
      const playerPos = playerProfile.position.toLowerCase();
      if (text.includes(playerPos) || 
          (playerPos.includes('meneur') && text.includes('meneur')) ||
          (playerPos.includes('arrière') && text.includes('arrière')) ||
          (playerPos.includes('ailier') && text.includes('ailier')) ||
          (playerPos.includes('pivot') && text.includes('pivot'))) {
        score += 30;
      } else if (text.includes('polyvalent') || text.includes('tous postes')) {
        score += 20;
      }
    }

    // 2. Niveau (25% du score)
    if (playerProfile.level) {
      const playerLevel = playerProfile.level.toLowerCase();
      if (text.includes(playerLevel) ||
          (playerLevel.includes('pro') && (text.includes('pro a') || text.includes('pro b'))) ||
          (playerLevel.includes('national') && text.includes('national')) ||
          (playerLevel.includes('regional') && text.includes('regional'))) {
        score += 25;
      }
    }

    // 3. Expérience (20% du score)
    if (playerProfile.experience_years) {
      const experience = playerProfile.experience_years;
      if (text.includes(`${experience} ans`) || 
          text.includes(`${experience} années`) ||
          (experience >= 5 && text.includes('expérience')) ||
          (experience >= 3 && text.includes('expérient'))) {
        score += 20;
      }
    }

    // 4. Localisation (15% du score)
    if (location && playerProfile.location) {
      if (location.toLowerCase().includes(playerProfile.location.toLowerCase()) ||
          playerProfile.location.toLowerCase().includes(location.toLowerCase())) {
        score += 15;
      }
    }

    // 5. Age (10% du score)
    if (playerProfile.age) {
      const age = playerProfile.age;
      if ((age >= 18 && age <= 25 && text.includes('jeune')) ||
          (age >= 25 && age <= 35 && text.includes('expérience')) ||
          (age >= 20 && age <= 30 && !text.includes('senior'))) {
        score += 10;
      }
    }

    return Math.min(score, 100); // Limiter à 100%
  }

  /**
   * Génère les raisons du match entre un joueur et une annonce
   */
  getPlayerAdMatchReasons(playerProfile, advertisement, score) {
    const reasons = [];
    const requirements = advertisement.requirements || '';
    const description = advertisement.description || '';
    const text = (requirements + ' ' + description).toLowerCase();

    if (playerProfile.position && text.includes(playerProfile.position.toLowerCase())) {
      reasons.push(`Poste recherché : ${playerProfile.position}`);
    }

    if (playerProfile.level && text.includes(playerProfile.level.toLowerCase())) {
      reasons.push(`Niveau correspondant : ${playerProfile.level}`);
    }

    if (playerProfile.experience_years && playerProfile.experience_years >= 3) {
      reasons.push(`Expérience : ${playerProfile.experience_years} ans`);
    }

    if (advertisement.location && playerProfile.location && 
        advertisement.location.toLowerCase().includes(playerProfile.location.toLowerCase())) {
      reasons.push(`Localisation : ${advertisement.location}`);
    }

    if (advertisement.salary_range) {
      reasons.push(`Rémunération : ${advertisement.salary_range}`);
    }

    if (reasons.length === 0) {
      reasons.push('Profil compatible avec l\'annonce');
    }

    return reasons;
  }

  /**
   * Calcule la compatibilité entre un joueur handibasket et une annonce
   */
  calculateHandibasketAdCompatibility(playerProfile, advertisement) {
    let score = 0;
    const requirements = advertisement.requirements || '';
    const description = advertisement.description || '';
    const text = (requirements + ' ' + description).toLowerCase();

    // 1. Vérifier que c'est une annonce handibasket (40% du score)
    if (text.includes('handibasket')) {
      score += 40;
    }

    // 2. Position (25% du score)
    if (playerProfile.position) {
      const playerPos = playerProfile.position.toLowerCase();
      if (text.includes(playerPos) || 
          (playerPos.includes('polyvalent') && text.includes('polyvalent'))) {
        score += 25;
      } else if (text.includes('polyvalent') || text.includes('tous postes')) {
        score += 15;
      }
    }

    // 3. Niveau (20% du score)
    if (playerProfile.level) {
      const playerLevel = playerProfile.level.toLowerCase();
      if (text.includes(playerLevel) ||
          (playerLevel.includes('regional') && text.includes('regional')) ||
          (playerLevel.includes('national') && text.includes('national'))) {
        score += 20;
      }
    }

    // 4. Expérience (10% du score)
    if (playerProfile.experience_years) {
      const experience = playerProfile.experience_years;
      if (text.includes(`${experience} ans`) || 
          text.includes(`${experience} années`) ||
          (experience >= 3 && text.includes('expérience'))) {
        score += 10;
      }
    }

    // 5. Localisation (5% du score)
    if (advertisement.location && playerProfile.location) {
      if (advertisement.location.toLowerCase().includes(playerProfile.location.toLowerCase()) ||
          playerProfile.location.toLowerCase().includes(advertisement.location.toLowerCase())) {
        score += 5;
      }
    }

    return Math.min(score, 100); // Limiter à 100%
  }

  /**
   * Génère les raisons du match entre un joueur handibasket et une annonce
   */
  getHandibasketAdMatchReasons(playerProfile, advertisement, score) {
    const reasons = [];
    const requirements = advertisement.requirements || '';
    const description = advertisement.description || '';
    const text = (requirements + ' ' + description).toLowerCase();

    // Raison principale : annonce handibasket
    if (text.includes('handibasket')) {
      reasons.push('Annonce handibasket');
    }

    if (playerProfile.position && text.includes(playerProfile.position.toLowerCase())) {
      reasons.push(`Poste recherché : ${playerProfile.position}`);
    }

    if (playerProfile.level && text.includes(playerProfile.level.toLowerCase())) {
      reasons.push(`Niveau correspondant : ${playerProfile.level}`);
    }

    if (playerProfile.experience_years && playerProfile.experience_years >= 3) {
      reasons.push(`Expérience : ${playerProfile.experience_years} ans`);
    }

    if (advertisement.location && playerProfile.location && 
        advertisement.location.toLowerCase().includes(playerProfile.location.toLowerCase())) {
      reasons.push(`Localisation : ${advertisement.location}`);
    }

    if (advertisement.salary_range) {
      reasons.push(`Rémunération : ${advertisement.salary_range}`);
    }

    if (reasons.length === 0) {
      reasons.push('Profil handibasket compatible');
    }

    return reasons;
  }

  /**
   * Détermine le niveau de match selon le score
   */
  getMatchLevel(score) {
    if (score >= 80) return 'excellent';
    if (score >= 60) return 'good';
    if (score >= 40) return 'fair';
    return 'poor';
  }

  /**
   * Récupère les statistiques de matching pour un utilisateur
   */
  async getMatchingStats(userId, userType) {
    try {
      const matches = await this.findMatches(userId, userType, 50);
      
      const stats = {
        totalMatches: matches.length,
        excellentMatches: matches.filter(m => m.matchLevel === 'excellent').length,
        goodMatches: matches.filter(m => m.matchLevel === 'good').length,
        fairMatches: matches.filter(m => m.matchLevel === 'fair').length,
        averageScore: matches.length > 0 ? 
          matches.reduce((sum, m) => sum + m.compatibilityScore, 0) / matches.length : 0,
        topMatches: matches.slice(0, 5)
      };

      return stats;

    } catch (error) {
      console.error('Erreur lors du calcul des statistiques:', error);
      throw error;
    }
  }

  /**
   * Récupère les suggestions personnalisées selon les préférences
   */
  async getPersonalizedSuggestions(userId, userType, options = {}) {
    const { 
      location, 
      minScore = 40, 
      maxResults = 10,
      sortBy = 'score' 
    } = options;

    try {
      let matches = await this.findMatches(userId, userType, maxResults * 2);

      // Filtrer selon les critères
      if (location) {
        matches = matches.filter(m => 
          m.location && m.location.toLowerCase().includes(location.toLowerCase())
        );
      }

      if (minScore) {
        matches = matches.filter(m => m.compatibilityScore >= minScore);
      }

      // Trier selon la préférence
      if (sortBy === 'date') {
        matches.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
      } else {
        matches.sort((a, b) => b.compatibilityScore - a.compatibilityScore);
      }

      return matches.slice(0, maxResults);

    } catch (error) {
      console.error('Erreur lors de la génération des suggestions:', error);
      throw error;
    }
  }

  /**
   * Récupère le profil d'un utilisateur selon son type
   */
  async getUserProfile(userId, userType) {
    try {
      let query = '';
      let params = [userId.toString()];

      switch (userType) {
        case 'player':
          query = `
            SELECT p.*, u.name, u.email, u.profile_image_url, u.gender, u.nationality
            FROM player_profiles p
            JOIN users u ON p.user_id = u.id
            WHERE p.user_id = ?
          `;
          break;
        case 'handibasket':
          query = `
            SELECT hp.*, u.name, u.email, u.profile_image_url, u.gender, u.nationality
            FROM handibasket_profiles hp
            JOIN users u ON hp.user_id = u.id
            WHERE hp.user_id = ?
          `;
          break;
        case 'club':
          query = `
            SELECT cp.*, u.name, u.email, u.profile_image_url
            FROM club_profiles cp
            JOIN users u ON cp.user_id = u.id
            WHERE cp.user_id = ?
          `;
          break;
        case 'coach_pro':
        case 'coach_basket':
          query = `
            SELECT c.*, u.name, u.email, u.profile_image_url
            FROM coach_profiles c
            JOIN users u ON c.user_id = u.id
            WHERE c.user_id = ?
          `;
          break;
        default:
          throw new Error(`Type de profil non supporté: ${userType}`);
      }

      const [rows] = await pool.execute(query, params);
      return rows[0] || null;

    } catch (error) {
      console.error('Erreur lors de la récupération du profil utilisateur:', error);
      throw error;
    }
  }

  /**
   * Calcule le score de compatibilité entre deux profils
   */
  async calculateCompatibilityScore(userProfile, targetProfile) {
    try {
      // Algorithme simple de compatibilité basé sur les critères communs
      let score = 0;
      let totalCriteria = 0;

      // Comparer les positions (pour les joueurs)
      if (userProfile.position && targetProfile.position) {
        totalCriteria++;
        if (userProfile.position === targetProfile.position || 
            userProfile.position === 'polyvalent' || 
            targetProfile.position === 'polyvalent') {
          score += 1;
        }
      }

      // Comparer les niveaux
      if (userProfile.level && targetProfile.level) {
        totalCriteria++;
        if (userProfile.level === targetProfile.level) {
          score += 1;
        }
      }

      // Comparer les localisations
      if (userProfile.location && targetProfile.location) {
        totalCriteria++;
        if (userProfile.location.toLowerCase().includes(targetProfile.location.toLowerCase()) ||
            targetProfile.location.toLowerCase().includes(userProfile.location.toLowerCase())) {
          score += 1;
        }
      }

      // Comparer les âges (pour les joueurs)
      if (userProfile.age && targetProfile.age) {
        totalCriteria++;
        const ageDiff = Math.abs(userProfile.age - targetProfile.age);
        if (ageDiff <= 5) {
          score += 1;
        } else if (ageDiff <= 10) {
          score += 0.5;
        }
      }

      // Retourner le score normalisé (0-1)
      return totalCriteria > 0 ? score / totalCriteria : 0.5;

    } catch (error) {
      console.error('Erreur lors du calcul de compatibilité:', error);
      return 0.5; // Score par défaut
    }
  }

  /**
   * Génère les raisons du match entre deux profils
   */
  getMatchReasons(userProfile, targetProfile, compatibilityScore) {
    const reasons = [];

    // Position compatible
    if (userProfile.position && targetProfile.position) {
      if (userProfile.position === targetProfile.position) {
        reasons.push(`Même poste : ${userProfile.position}`);
      } else if (userProfile.position === 'polyvalent' || targetProfile.position === 'polyvalent') {
        reasons.push('Poste polyvalent compatible');
      }
    }

    // Niveau compatible
    if (userProfile.level && targetProfile.level && userProfile.level === targetProfile.level) {
      reasons.push(`Même niveau : ${userProfile.level}`);
    }

    // Localisation proche
    if (userProfile.location && targetProfile.location) {
      if (userProfile.location.toLowerCase().includes(targetProfile.location.toLowerCase()) ||
          targetProfile.location.toLowerCase().includes(userProfile.location.toLowerCase())) {
        reasons.push(`Localisation : ${targetProfile.location}`);
      }
    }

    // Âge compatible
    if (userProfile.age && targetProfile.age) {
      const ageDiff = Math.abs(userProfile.age - targetProfile.age);
      if (ageDiff <= 5) {
        reasons.push('Âge similaire');
      }
    }

    // Si aucune raison spécifique, ajouter une raison générique
    if (reasons.length === 0) {
      if (compatibilityScore >= 0.8) {
        reasons.push('Profil très compatible');
      } else if (compatibilityScore >= 0.6) {
        reasons.push('Profil compatible');
      } else {
        reasons.push('Profil potentiellement intéressant');
      }
    }

    return reasons;
  }
}

module.exports = MatchingService; 