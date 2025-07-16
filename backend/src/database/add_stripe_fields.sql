-- Ajouter les champs Stripe à la table users
ALTER TABLE users ADD COLUMN stripe_customer_id VARCHAR(255) DEFAULT NULL;

-- Ajouter les champs Stripe à la table subscriptions
ALTER TABLE subscriptions ADD COLUMN stripe_subscription_id VARCHAR(255) DEFAULT NULL;
ALTER TABLE subscriptions ADD COLUMN stripe_customer_id VARCHAR(255) DEFAULT NULL;
ALTER TABLE subscriptions ADD COLUMN last_payment_date TIMESTAMP DEFAULT NULL;

-- Ajouter des index pour optimiser les requêtes
CREATE INDEX idx_users_stripe_customer ON users(stripe_customer_id);
CREATE INDEX idx_subscriptions_stripe_subscription ON subscriptions(stripe_subscription_id);
CREATE INDEX idx_subscriptions_stripe_customer ON subscriptions(stripe_customer_id); 