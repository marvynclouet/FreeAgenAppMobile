const express = require('express');
const router = express.Router();
const pool = require('../config/db.config');
const verifyToken = require('../middleware/auth.middleware');

// GET /api/subscriptions/plans - Obtenir tous les plans d'abonnement
router.get('/plans', async (req, res) => {
  try {
    const [plans] = await pool.execute(`
      SELECT 
        id, name, type, price, duration_months,
        max_applications, max_opportunities, max_messages,
        can_post_opportunities, has_profile_boost, has_priority_support
      FROM subscription_plans 
      WHERE is_active = TRUE 
      ORDER BY price ASC
    `);
    
    res.json(plans);
  } catch (error) {
    console.error('Erreur lors de la récupération des plans:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// GET /api/subscriptions/status - Obtenir le statut d'abonnement de l'utilisateur
router.get('/status', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Récupérer les informations d'abonnement
    const [userRows] = await pool.execute(`
      SELECT 
        subscription_type, subscription_expiry, is_premium, subscription_created_at
      FROM users 
      WHERE id = ?
    `, [userId]);
    
    if (userRows.length === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    
    const user = userRows[0];
    
    // Récupérer les limites d'utilisation
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
    
    // Récupérer les limites du plan actuel
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
    
    res.json({
      subscription: {
        type: user.subscription_type,
        expiry: user.subscription_expiry,
        is_premium: user.is_premium,
        created_at: user.subscription_created_at
      },
      limits: {
        current: limits,
        plan: planLimits
      }
    });
    
  } catch (error) {
    console.error('Erreur lors de la récupération du statut:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST /api/subscriptions/subscribe - S'abonner à un plan
router.post('/subscribe', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { planId, paymentMethod = 'manual' } = req.body;
    
    if (!planId) {
      return res.status(400).json({ message: 'Plan ID requis' });
    }
    
    // Récupérer les détails du plan
    const [planRows] = await pool.execute(`
      SELECT * FROM subscription_plans WHERE id = ? AND is_active = TRUE
    `, [planId]);
    
    if (planRows.length === 0) {
      return res.status(404).json({ message: 'Plan non trouvé' });
    }
    
    const plan = planRows[0];
    
    // Calculer les dates de début et fin
    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + plan.duration_months);
    
    // Commencer une transaction
    const connection = await pool.getConnection();
    await connection.beginTransaction();
    
    try {
      // Créer l'abonnement
      const [subscriptionResult] = await connection.execute(`
        INSERT INTO subscriptions 
        (user_id, subscription_type, price, duration_months, start_date, end_date, payment_method)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `, [
        userId, 
        plan.type, 
        plan.price, 
        plan.duration_months,
        startDate,
        endDate,
        paymentMethod
      ]);
      
      // Mettre à jour l'utilisateur
      await connection.execute(`
        UPDATE users 
        SET subscription_type = ?, subscription_expiry = ?, is_premium = TRUE, subscription_created_at = ?
        WHERE id = ?
      `, [plan.type, endDate, startDate, userId]);
      
      // Réinitialiser les compteurs de limite
      await connection.execute(`
        UPDATE user_limits 
        SET applications_count = 0, opportunities_posted = 0, messages_sent = 0, last_reset_date = CURRENT_DATE
        WHERE user_id = ?
      `, [userId]);
      
      await connection.commit();
      
      res.json({
        message: 'Abonnement créé avec succès',
        subscription: {
          id: subscriptionResult.insertId,
          type: plan.type,
          expiry: endDate,
          price: plan.price
        }
      });
      
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
    
  } catch (error) {
    console.error('Erreur lors de l\'abonnement:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST /api/subscriptions/cancel - Annuler l'abonnement
router.post('/cancel', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const connection = await pool.getConnection();
    await connection.beginTransaction();
    
    try {
      // Marquer l'abonnement actuel comme annulé
      await connection.execute(`
        UPDATE subscriptions 
        SET status = 'cancelled' 
        WHERE user_id = ? AND status = 'active'
      `, [userId]);
      
      // Remettre l'utilisateur en gratuit
      await connection.execute(`
        UPDATE users 
        SET subscription_type = 'free', subscription_expiry = NULL, is_premium = FALSE
        WHERE id = ?
      `, [userId]);
      
      await connection.commit();
      
      res.json({ message: 'Abonnement annulé avec succès' });
      
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
    
  } catch (error) {
    console.error('Erreur lors de l\'annulation:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// GET /api/subscriptions/limits - Obtenir les limites d'utilisation
router.get('/limits', verifyToken, async (req, res) => {
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
      max_messages: 0,
      can_post_opportunities: false
    };
    
    if (subscriptionType !== 'free') {
      const [planRows] = await pool.execute(`
        SELECT 
          max_applications, max_opportunities, max_messages, can_post_opportunities
        FROM subscription_plans 
        WHERE type = ? AND is_active = TRUE
        LIMIT 1
      `, [subscriptionType]);
      
      if (planRows.length > 0) {
        planLimits = planRows[0];
      }
    }
    
    res.json({
      current: limits,
      plan: planLimits,
      remaining: {
        applications: planLimits.max_applications === -1 ? -1 : Math.max(0, planLimits.max_applications - limits.applications_count),
        opportunities: planLimits.max_opportunities === -1 ? -1 : Math.max(0, planLimits.max_opportunities - limits.opportunities_posted),
        messages: planLimits.max_messages === -1 ? -1 : Math.max(0, planLimits.max_messages - limits.messages_sent)
      }
    });
    
  } catch (error) {
    console.error('Erreur lors de la récupération des limites:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST /api/subscriptions/increment-usage - Incrémenter l'utilisation (utilisé par d'autres routes)
router.post('/increment-usage', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { type } = req.body; // 'applications', 'opportunities', 'messages'
    
    if (!['applications', 'opportunities', 'messages'].includes(type)) {
      return res.status(400).json({ message: 'Type d\'utilisation invalide' });
    }
    
    const columnMap = {
      applications: 'applications_count',
      opportunities: 'opportunities_posted',
      messages: 'messages_sent'
    };
    
    const column = columnMap[type];
    
    await pool.execute(`
      UPDATE user_limits 
      SET ${column} = ${column} + 1 
      WHERE user_id = ?
    `, [userId]);
    
    res.json({ message: 'Utilisation mise à jour' });
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'utilisation:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 