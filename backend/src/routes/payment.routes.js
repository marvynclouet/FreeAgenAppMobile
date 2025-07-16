const express = require('express');
const router = express.Router();
const stripe = require('../config/stripe.config');
const pool = require('../config/db.config');
const verifyToken = require('../middleware/auth.middleware');

// Middleware pour vérifier que Stripe est configuré
const checkStripeConfig = (req, res, next) => {
  if (!stripe) {
    return res.status(503).json({ 
      message: 'Service de paiement temporairement indisponible - Stripe non configuré' 
    });
  }
  next();
};

// POST /api/payments/create-checkout-session - Créer une session de paiement
router.post('/create-checkout-session', verifyToken, checkStripeConfig, async (req, res) => {
  try {
    const userId = req.user.id;
    const { planId, successUrl, cancelUrl } = req.body;

    // Récupérer les détails du plan
    const [planRows] = await pool.execute(`
      SELECT * FROM subscription_plans WHERE id = ? AND is_active = TRUE
    `, [planId]);

    if (planRows.length === 0) {
      return res.status(404).json({ message: 'Plan non trouvé' });
    }

    const plan = planRows[0];

    // Récupérer les informations utilisateur
    const [userRows] = await pool.execute(`
      SELECT email, name FROM users WHERE id = ?
    `, [userId]);

    if (userRows.length === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    const user = userRows[0];

    // Créer la session Stripe Checkout
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'eur',
            product_data: {
              name: plan.name,
              description: `Abonnement ${plan.name} - ${plan.duration_months} mois`,
            },
            unit_amount: Math.round(plan.price * 100), // Stripe utilise les centimes
            recurring: {
              interval: plan.duration_months === 1 ? 'month' : 'year',
            },
          },
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: successUrl || `${req.headers.origin}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl || `${req.headers.origin}/cancel`,
      customer_email: user.email,
      metadata: {
        user_id: userId.toString(),
        plan_id: planId.toString(),
      },
    });

    res.json({ sessionId: session.id, url: session.url });

  } catch (error) {
    console.error('Erreur lors de la création de la session:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST /api/payments/webhook - Webhook Stripe
router.post('/webhook', express.raw({ type: 'application/json' }), checkStripeConfig, async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.log(`Webhook signature verification failed.`, err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Gérer les événements Stripe
  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutSessionCompleted(event.data.object);
        break;
      case 'invoice.payment_succeeded':
        await handleInvoicePaymentSucceeded(event.data.object);
        break;
      case 'invoice.payment_failed':
        await handleInvoicePaymentFailed(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;
      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Erreur lors du traitement du webhook:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Fonction pour gérer la session de paiement terminée
async function handleCheckoutSessionCompleted(session) {
  const userId = parseInt(session.metadata.user_id);
  const planId = parseInt(session.metadata.plan_id);

  // Récupérer les détails du plan
  const [planRows] = await pool.execute(`
    SELECT * FROM subscription_plans WHERE id = ?
  `, [planId]);

  if (planRows.length === 0) {
    throw new Error('Plan non trouvé');
  }

  const plan = planRows[0];

  // Calculer les dates
  const startDate = new Date();
  const endDate = new Date();
  endDate.setMonth(endDate.getMonth() + plan.duration_months);

  const connection = await pool.getConnection();
  await connection.beginTransaction();

  try {
    // Créer l'abonnement
    await connection.execute(`
      INSERT INTO subscriptions 
      (user_id, subscription_type, price, duration_months, start_date, end_date, 
       stripe_subscription_id, stripe_customer_id, payment_method, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      userId,
      plan.type,
      plan.price,
      plan.duration_months,
      startDate,
      endDate,
      session.subscription,
      session.customer,
      'stripe',
      'active'
    ]);

    // Mettre à jour l'utilisateur
    await connection.execute(`
      UPDATE users 
      SET subscription_type = ?, subscription_expiry = ?, is_premium = TRUE, 
          subscription_created_at = ?, stripe_customer_id = ?
      WHERE id = ?
    `, [plan.type, endDate, startDate, session.customer, userId]);

    // Réinitialiser les limites
    await connection.execute(`
      UPDATE user_limits 
      SET applications_count = 0, opportunities_posted = 0, messages_sent = 0, 
          last_reset_date = CURRENT_DATE
      WHERE user_id = ?
    `, [userId]);

    await connection.commit();
    console.log(`Abonnement créé avec succès pour l'utilisateur ${userId}`);
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// Fonction pour gérer le paiement réussi
async function handleInvoicePaymentSucceeded(invoice) {
  const subscriptionId = invoice.subscription;
  
  // Mettre à jour le statut de l'abonnement
  await pool.execute(`
    UPDATE subscriptions 
    SET status = 'active', last_payment_date = CURRENT_TIMESTAMP
    WHERE stripe_subscription_id = ?
  `, [subscriptionId]);

  console.log(`Paiement réussi pour l'abonnement ${subscriptionId}`);
}

// Fonction pour gérer l'échec de paiement
async function handleInvoicePaymentFailed(invoice) {
  const subscriptionId = invoice.subscription;
  
  // Marquer l'abonnement comme en échec de paiement
  await pool.execute(`
    UPDATE subscriptions 
    SET status = 'payment_failed'
    WHERE stripe_subscription_id = ?
  `, [subscriptionId]);

  console.log(`Échec de paiement pour l'abonnement ${subscriptionId}`);
}

// Fonction pour gérer la suppression d'abonnement
async function handleSubscriptionDeleted(subscription) {
  const connection = await pool.getConnection();
  await connection.beginTransaction();

  try {
    // Mettre à jour l'abonnement
    await connection.execute(`
      UPDATE subscriptions 
      SET status = 'cancelled', end_date = CURRENT_TIMESTAMP
      WHERE stripe_subscription_id = ?
    `, [subscription.id]);

    // Remettre l'utilisateur en gratuit
    await connection.execute(`
      UPDATE users 
      SET subscription_type = 'free', subscription_expiry = NULL, is_premium = FALSE
      WHERE stripe_customer_id = ?
    `, [subscription.customer]);

    await connection.commit();
    console.log(`Abonnement annulé pour ${subscription.id}`);
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// GET /api/payments/plans - Récupérer les plans avec prix Stripe
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

    // Ajouter les informations de prix formatées
    const formattedPlans = plans.map(plan => ({
      ...plan,
      price_formatted: `${plan.price.toFixed(2)}€`,
      price_monthly: plan.duration_months === 12 ? (plan.price / 12).toFixed(2) : plan.price.toFixed(2),
      savings: plan.duration_months === 12 ? Math.round(((plan.price / 12) * 12 - plan.price) * 100 / ((plan.price / 12) * 12)) : 0
    }));

    res.json(formattedPlans);
  } catch (error) {
    console.error('Erreur lors de la récupération des plans:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 