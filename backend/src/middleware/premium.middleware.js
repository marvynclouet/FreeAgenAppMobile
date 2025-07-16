const pool = require('../config/db.config');

/**
 * Middleware pour vérifier si l'utilisateur peut effectuer une action basée sur son plan
 */
const checkPremiumAccess = (requiredFeature) => {
  return async (req, res, next) => {
    try {
      const userId = req.user.id;
      
      // Récupérer les informations d'abonnement
      const [userRows] = await pool.execute(`
        SELECT subscription_type, subscription_expiry, is_premium
        FROM users 
        WHERE id = ?
      `, [userId]);
      
      if (userRows.length === 0) {
        return res.status(404).json({ message: 'Utilisateur non trouvé' });
      }
      
      const user = userRows[0];
      
      // Vérifier si l'abonnement est toujours valide
      if (user.subscription_expiry && new Date(user.subscription_expiry) < new Date()) {
        // Abonnement expiré, remettre en gratuit
        await pool.execute(`
          UPDATE users 
          SET subscription_type = 'free', subscription_expiry = NULL, is_premium = FALSE
          WHERE id = ?
        `, [userId]);
        user.subscription_type = 'free';
        user.is_premium = false;
      }
      
      // Récupérer les limites du plan
      let planLimits = {
        max_applications: 0, // Gratuit = 0 candidatures
        max_opportunities: 0,
        max_messages: 0,
        can_post_opportunities: false,
        has_profile_boost: false,
        has_priority_support: false
      };
      
      if (user.subscription_type !== 'free') {
        const [planRows] = await pool.execute(`
          SELECT 
            max_applications, max_opportunities, max_messages,
            can_post_opportunities, has_profile_boost, has_priority_support
          FROM subscription_plans 
          WHERE type = ? AND is_active = TRUE
          LIMIT 1
        `, [user.subscription_type]);
        
        if (planRows.length > 0) {
          planLimits = planRows[0];
        }
      }
      
      // Vérifier l'accès basé sur la fonctionnalité requise
      switch (requiredFeature) {
        case 'post_opportunities':
          if (!planLimits.can_post_opportunities) {
            return res.status(403).json({ 
              message: 'Fonctionnalité réservée aux abonnés premium',
              feature: 'post_opportunities',
              subscription_required: true
            });
          }
          break;
          
        case 'messaging':
          if (user.subscription_type === 'free') {
            return res.status(403).json({ 
              message: 'Messagerie réservée aux abonnés premium',
              feature: 'messaging',
              subscription_required: true
            });
          }
          break;
          
        case 'profile_boost':
          if (!planLimits.has_profile_boost) {
            return res.status(403).json({ 
              message: 'Mise en avant du profil réservée aux abonnés Pro',
              feature: 'profile_boost',
              subscription_required: true
            });
          }
          break;
          
        case 'priority_support':
          if (!planLimits.has_priority_support) {
            return res.status(403).json({ 
              message: 'Support prioritaire réservé aux abonnés Pro',
              feature: 'priority_support',
              subscription_required: true
            });
          }
          break;
      }
      
      // Ajouter les informations au request pour les routes suivantes
      req.user.subscription = {
        type: user.subscription_type,
        is_premium: user.is_premium,
        limits: planLimits
      };
      
      next();
      
    } catch (error) {
      console.error('Erreur dans checkPremiumAccess:', error);
      res.status(500).json({ message: 'Erreur serveur' });
    }
  };
};

/**
 * Middleware pour vérifier les limites d'utilisation
 */
const checkUsageLimit = (limitType) => {
  return async (req, res, next) => {
    try {
      const userId = req.user.id;
      
      // Récupérer les limites actuelles
      const [limitsRows] = await pool.execute(`
        SELECT 
          applications_count, opportunities_posted, messages_sent, last_reset_date
        FROM user_limits 
        WHERE user_id = ?
      `, [userId]);
      
      const limits = limitsRows[0] || {
        applications_count: 0,
        opportunities_posted: 0,
        messages_sent: 0,
        last_reset_date: new Date()
      };
      
      // Récupérer le type d'abonnement
      const [userRows] = await pool.execute(`
        SELECT subscription_type FROM users WHERE id = ?
      `, [userId]);
      
      const subscriptionType = userRows[0]?.subscription_type || 'free';
      
      // Récupérer les limites du plan
      let planLimits = {
        max_applications: 0, // Gratuit = 0 candidatures
        max_opportunities: 0,
        max_messages: 0
      };
      
      if (subscriptionType !== 'free') {
        const [planRows] = await pool.execute(`
          SELECT max_applications, max_opportunities, max_messages
          FROM subscription_plans 
          WHERE type = ? AND is_active = TRUE
          LIMIT 1
        `, [subscriptionType]);
        
        if (planRows.length > 0) {
          planLimits = planRows[0];
        }
      }
      
      // Vérifier les limites selon le type
      let currentCount = 0;
      let maxLimit = 0;
      let limitName = '';
      
      switch (limitType) {
        case 'applications':
          currentCount = limits.applications_count;
          maxLimit = planLimits.max_applications;
          limitName = 'candidatures';
          break;
        case 'opportunities':
          currentCount = limits.opportunities_posted;
          maxLimit = planLimits.max_opportunities;
          limitName = 'opportunités';
          break;
        case 'messages':
          currentCount = limits.messages_sent;
          maxLimit = planLimits.max_messages;
          limitName = 'messages';
          break;
      }
      
      // Si la limite est illimitée (-1), laisser passer
      if (maxLimit === -1) {
        next();
        return;
      }
      
      // Vérifier si la limite est atteinte
      if (currentCount >= maxLimit) {
        return res.status(403).json({
          message: `Limite de ${limitName} atteinte pour votre plan`,
          current: currentCount,
          limit: maxLimit,
          subscription_type: subscriptionType,
          upgrade_required: true
        });
      }
      
      // Ajouter les informations au request
      req.user.usage = {
        current: currentCount,
        limit: maxLimit,
        remaining: maxLimit - currentCount
      };
      
      next();
      
    } catch (error) {
      console.error('Erreur dans checkUsageLimit:', error);
      res.status(500).json({ message: 'Erreur serveur' });
    }
  };
};

/**
 * Middleware pour incrémenter l'utilisation après une action réussie
 */
const incrementUsage = (limitType) => {
  return async (req, res, next) => {
    try {
      const userId = req.user.id;
      
      const columnMap = {
        applications: 'applications_count',
        opportunities: 'opportunities_posted',
        messages: 'messages_sent'
      };
      
      const column = columnMap[limitType];
      
      if (column) {
        await pool.execute(`
          UPDATE user_limits 
          SET ${column} = ${column} + 1 
          WHERE user_id = ?
        `, [userId]);
        
        console.log(`Utilisation ${limitType} incrémentée pour l'utilisateur ${userId}`);
      }
      
      next();
      
    } catch (error) {
      console.error('Erreur dans incrementUsage:', error);
      next(); // Continuer même en cas d'erreur pour ne pas bloquer l'utilisateur
    }
  };
};

/**
 * Middleware pour vérifier si l'utilisateur peut voir les messages (notifications)
 */
const checkNotificationAccess = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    // Récupérer le type d'abonnement
    const [userRows] = await pool.execute(`
      SELECT subscription_type, is_premium FROM users WHERE id = ?
    `, [userId]);
    
    const user = userRows[0];
    
    // Les utilisateurs gratuits ne peuvent pas voir les notifications
    if (user.subscription_type === 'free') {
      return res.status(403).json({
        message: 'Notifications réservées aux abonnés premium',
        subscription_required: true
      });
    }
    
    next();
    
  } catch (error) {
    console.error('Erreur dans checkNotificationAccess:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = {
  checkPremiumAccess,
  checkUsageLimit,
  incrementUsage,
  checkNotificationAccess
}; 