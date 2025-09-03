const express = require('express');
const router = express.Router();
const MatchingService = require('../services/matching.service');
const authMiddleware = require('../middleware/auth.middleware');

const matchingService = new MatchingService();

// Middleware d'authentification pour toutes les routes
router.use(authMiddleware);

// GET /api/matching/suggestions - Obtenir des suggestions personnalisées
router.get('/suggestions', async (req, res) => {
  try {
    const { id: userId, profile_type: userType } = req.user;
    const { 
      minScore = 0.5, 
      maxResults = 20,
      includeReasons = true 
    } = req.query;

    console.log(`📊 Recherche de suggestions pour ${userId} (${userType})`);

    const suggestions = await matchingService.getPersonalizedSuggestions(
      userId,
      userType,
      {
        minScore: parseFloat(minScore) * 100, // Convertir 0.5 en 50
        maxResults: parseInt(maxResults),
        includeReasons: includeReasons === 'true'
      }
    );

    res.json({
      success: true,
      data: suggestions,
      total: suggestions.length,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des suggestions:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des suggestions',
      error: error.message
    });
  }
});

// GET /api/matching/profile/:targetUserId - Calculer la compatibilité avec un profil spécifique
router.get('/profile/:targetUserId', async (req, res) => {
  try {
    const { id: userId, profile_type: userType } = req.user;
    const { targetUserId } = req.params;
    const { targetUserType } = req.query;

    if (!targetUserType) {
      return res.status(400).json({
        success: false,
        message: 'Le type du profil cible est requis'
      });
    }

    console.log(`🎯 Calcul de compatibilité entre ${userId} et ${targetUserId}`);

    // Récupérer les profils
    const userProfile = await matchingService.getUserProfile(userId, userType);
    const targetProfile = await matchingService.getUserProfile(targetUserId, targetUserType);

    if (!userProfile || !targetProfile) {
      return res.status(404).json({
        success: false,
        message: 'Profil non trouvé'
      });
    }

    // Calculer la compatibilité
    const compatibilityScore = await matchingService.calculateCompatibilityScore(userProfile, targetProfile);
    const matchReasons = matchingService.getMatchReasons(userProfile, targetProfile, compatibilityScore);

    res.json({
      success: true,
      data: {
        targetProfile: {
          id: targetProfile.user_id,
          name: targetProfile.name,
          profile_image_url: targetProfile.profile_image_url,
          type: targetUserType
        },
        compatibilityScore,
        compatibilityPercentage: Math.round(compatibilityScore * 100),
        matchLevel: matchingService.getMatchLevel(compatibilityScore),
        matchReasons,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    console.error('Erreur lors du calcul de compatibilité:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors du calcul de compatibilité',
      error: error.message
    });
  }
});

// GET /api/matching/stats - Obtenir les statistiques de matching
router.get('/stats', async (req, res) => {
  try {
    const { id: userId, profile_type: userType } = req.user;

    console.log(`📈 Génération des statistiques de matching pour ${userId}`);

    const stats = await matchingService.getMatchingStats(userId, userType);

    res.json({
      success: true,
      data: {
        ...stats,
        userId,
        userType,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    console.error('Erreur lors de la génération des statistiques:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la génération des statistiques',
      error: error.message
    });
  }
});

// GET /api/matching/discover - Découvrir de nouveaux profils
router.get('/discover', async (req, res) => {
  try {
    const { id: userId, profile_type: userType } = req.user;
    const { 
      limit = 10,
      shuffle = true 
    } = req.query;

    console.log(`🌟 Découverte de nouveaux profils pour ${userId}`);

    let matches = await matchingService.findMatches(userId, userType, parseInt(limit) * 2);

    // Mélanger les résultats si demandé
    if (shuffle === 'true') {
      matches = matches.sort(() => Math.random() - 0.5);
    }

    // Limiter les résultats
    matches = matches.slice(0, parseInt(limit));

    res.json({
      success: true,
      data: matches.map(match => ({
        ...match,
        compatibilityPercentage: Math.round(match.compatibilityScore * 100),
        matchLevel: matchingService.getMatchLevel(match.compatibilityScore)
      })),
      total: matches.length,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Erreur lors de la découverte:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la découverte',
      error: error.message
    });
  }
});

// POST /api/matching/feedback - Donner un feedback sur un match
router.post('/feedback', async (req, res) => {
  try {
    const { id: userId } = req.user;
    const { targetUserId, feedback, rating } = req.body;

    if (!targetUserId || !feedback) {
      return res.status(400).json({
        success: false,
        message: 'targetUserId et feedback sont requis'
      });
    }

    console.log(`📝 Feedback reçu de ${userId} pour ${targetUserId}: ${feedback}`);

    // TODO: Sauvegarder le feedback en base de données
    // Cela permettra d'améliorer l'algorithme de matching

    res.json({
      success: true,
      message: 'Feedback enregistré avec succès',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Erreur lors de l\'enregistrement du feedback:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'enregistrement du feedback',
      error: error.message
    });
  }
});

// GET /api/matching/top-matches - Obtenir les meilleurs matches
router.get('/top-matches', async (req, res) => {
  try {
    const { id: userId, profile_type: userType } = req.user;
    const { limit = 5 } = req.query;

    console.log(`🏆 Recherche des meilleurs matches pour ${userId}`);

    const matches = await matchingService.findMatches(userId, userType, 50);
    
    // Prendre les meilleurs matches
    const topMatches = matches
      .filter(match => match.compatibilityScore >= 70)
      .slice(0, parseInt(limit));

    res.json({
      success: true,
      data: topMatches.map(match => ({
        id: match.id,
        name: match.name,
        profile_image_url: match.image,
        type: match.type,
        compatibilityScore: match.compatibilityScore,
        compatibilityPercentage: Math.round(match.compatibilityScore),
        matchLevel: match.matchLevel,
        matchReasons: match.reasons ? match.reasons.slice(0, 3) : [], // Limiter à 3 raisons
        // Ajouter quelques infos spécifiques selon le type
        ...(match.position && { position: match.position }),
        ...(match.level && { level: match.level }),
        ...(match.location && { location: match.location }),
        ...(match.age && { age: match.age })
      })),
      total: topMatches.length,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Erreur lors de la recherche des meilleurs matches:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la recherche des meilleurs matches',
      error: error.message
    });
  }
});

// GET /api/matching/recent - Obtenir les matches récents
router.get('/recent', async (req, res) => {
  try {
    const { id: userId, profile_type: userType } = req.user;
    const { limit = 10 } = req.query;

    console.log(`🕐 Recherche des matches récents pour ${userId}`);

    // Pour l'instant, retourner des matches aléatoires
    // TODO: Implementer un vrai système de "récents" basé sur les nouveaux profils
    const matches = await matchingService.findMatches(userId, userType, parseInt(limit) * 2);
    
    // Simuler des matches "récents" en prenant une sélection aléatoire
    const recentMatches = matches
      .sort(() => Math.random() - 0.5)
      .slice(0, parseInt(limit))
      .map(match => ({
        id: match.id,
        name: match.name,
        profile_image_url: match.image,
        type: match.type,
        compatibilityScore: match.compatibilityScore,
        compatibilityPercentage: Math.round(match.compatibilityScore),
        matchLevel: match.matchLevel,
        matchReasons: match.reasons ? match.reasons.slice(0, 3) : [],
        isNew: Math.random() > 0.5, // Simuler nouveaux profils
        // Ajouter quelques infos spécifiques selon le type
        ...(match.position && { position: match.position }),
        ...(match.level && { level: match.level }),
        ...(match.location && { location: match.location }),
        ...(match.age && { age: match.age })
      }));

    res.json({
      success: true,
      data: recentMatches,
      total: recentMatches.length,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Erreur lors de la recherche des matches récents:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la recherche des matches récents',
      error: error.message
    });
  }
});

module.exports = router; 