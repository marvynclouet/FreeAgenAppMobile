const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const db = require('../database/db');
const verifyToken = require('../middleware/auth.middleware');

// Validation d'achat iOS (App Store)
router.post('/validate-ios-purchase', verifyToken, async (req, res) => {
  try {
    const { receipt, productId } = req.body;
    const userId = req.user.id;
    
    console.log('Validation achat iOS:', { userId, productId });
    
    // Valider le receipt auprès d'Apple
    const isValid = await validateAppleReceipt(receipt, productId);
    
    if (isValid.success) {
      // Activer l'abonnement premium
      await activatePremiumSubscription(userId, 'ios', receipt, productId);
      res.json({ success: true, message: 'Abonnement activé avec succès' });
    } else {
      res.status(400).json({ success: false, message: 'Receipt invalide: ' + isValid.error });
    }
  } catch (error) {
    console.error('Erreur validation iOS:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Validation d'achat Android (Google Play)
router.post('/validate-android-purchase', verifyToken, async (req, res) => {
  try {
    const { purchaseToken, productId } = req.body;
    const userId = req.user.id;
    
    console.log('Validation achat Android:', { userId, productId });
    
    // Valider le token auprès de Google Play
    const isValid = await validateGooglePlayPurchase(purchaseToken, productId);
    
    if (isValid.success) {
      // Activer l'abonnement premium
      await activatePremiumSubscription(userId, 'android', purchaseToken, productId);
      res.json({ success: true, message: 'Abonnement activé avec succès' });
    } else {
      res.status(400).json({ success: false, message: 'Token invalide: ' + isValid.error });
    }
  } catch (error) {
    console.error('Erreur validation Android:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Obtenir le statut d'abonnement
router.get('/subscription-status', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const [rows] = await db.execute(
      'SELECT * FROM subscriptions WHERE user_id = ? AND status = "active" ORDER BY created_at DESC LIMIT 1',
      [userId]
    );
    
    if (rows.length > 0) {
      const subscription = rows[0];
      res.json({
        success: true,
        subscription: {
          id: subscription.id,
          plan_id: subscription.plan_id,
          platform: subscription.platform,
          status: subscription.status,
          expires_at: subscription.expires_at,
          created_at: subscription.created_at
        }
      });
    } else {
      res.json({
        success: true,
        subscription: null
      });
    }
  } catch (error) {
    console.error('Erreur récupération statut:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Fonction pour valider un receipt Apple
async function validateAppleReceipt(receipt, productId) {
  try {
    // En mode développement, on peut simuler la validation
    if (process.env.NODE_ENV === 'development') {
      console.log('Mode développement: validation simulée');
      return { success: true, data: { productId, receipt } };
    }
    
    // Pour la production, utiliser le module node-apple-receipt-verify
    const iap = require('node-apple-receipt-verify');
    
    const result = await iap.verify(receipt, {
      secret: process.env.APPLE_SHARED_SECRET,
      environment: process.env.NODE_ENV === 'production' ? 'production' : 'sandbox',
      verbose: true
    });
    
    if (result && result.receipt) {
      // Vérifier que le produit acheté correspond
      const purchases = result.receipt.in_app || [];
      const purchase = purchases.find(p => p.product_id === productId);
      
      if (purchase) {
        return { success: true, data: result };
      } else {
        return { success: false, error: 'Produit non trouvé dans le receipt' };
      }
    }
    
    return { success: false, error: 'Receipt invalide' };
  } catch (error) {
    console.error('Erreur validation Apple:', error);
    return { success: false, error: error.message };
  }
}

// Fonction pour valider un achat Google Play
async function validateGooglePlayPurchase(purchaseToken, productId) {
  try {
    // En mode développement, on peut simuler la validation
    if (process.env.NODE_ENV === 'development') {
      console.log('Mode développement: validation simulée');
      return { success: true, data: { productId, purchaseToken } };
    }
    
    // Pour la production, utiliser l'API Google Play
    const { GoogleAuth } = require('google-auth-library');
    const { google } = require('googleapis');
    
    const auth = new GoogleAuth({
      keyFile: process.env.GOOGLE_APPLICATION_CREDENTIALS,
      scopes: ['https://www.googleapis.com/auth/androidpublisher']
    });
    
    const androidpublisher = google.androidpublisher({
      version: 'v3',
      auth: auth
    });
    
    const result = await androidpublisher.purchases.subscriptions.get({
      packageName: process.env.GOOGLE_PLAY_PACKAGE_NAME,
      subscriptionId: productId,
      token: purchaseToken
    });
    
    if (result.data && result.data.purchaseType !== undefined) {
      return { success: true, data: result.data };
    }
    
    return { success: false, error: 'Achat non trouvé' };
  } catch (error) {
    console.error('Erreur validation Google Play:', error);
    return { success: false, error: error.message };
  }
}

// Fonction pour activer l'abonnement premium
async function activatePremiumSubscription(userId, platform, receipt, productId) {
  try {
    // Mapper les IDs de produit vers les plans de la base de données
    const productToPlanMap = {
      'premium_basic_monthly': 1,
      'premium_basic_yearly': 2,
      'premium_pro_monthly': 3,
      'premium_pro_yearly': 4
    };
    
    const planId = productToPlanMap[productId];
    if (!planId) {
      throw new Error('Produit non reconnu: ' + productId);
    }
    
    // Calculer la date d'expiration
    const expiresAt = new Date();
    if (productId.includes('monthly')) {
      expiresAt.setMonth(expiresAt.getMonth() + 1);
    } else if (productId.includes('yearly')) {
      expiresAt.setFullYear(expiresAt.getFullYear() + 1);
    }
    
    // Désactiver les anciens abonnements
    await db.execute(
      'UPDATE subscriptions SET status = "cancelled" WHERE user_id = ? AND status = "active"',
      [userId]
    );
    
    // Créer le nouveau abonnement
    await db.execute(
      'INSERT INTO subscriptions (user_id, plan_id, platform, status, store_receipt, expires_at) VALUES (?, ?, ?, ?, ?, ?)',
      [userId, planId, platform, 'active', receipt, expiresAt]
    );
    
    // Mettre à jour le statut premium de l'utilisateur
    await db.execute(
      'UPDATE users SET is_premium = 1, premium_expires_at = ? WHERE id = ?',
      [expiresAt, userId]
    );
    
    console.log('Abonnement activé:', { userId, planId, platform, expiresAt });
    
  } catch (error) {
    console.error('Erreur activation abonnement:', error);
    throw error;
  }
}

module.exports = router; 