-- Mettre à jour l'utilisateur premium@freeagent.com vers premium
UPDATE users 
SET subscription_type = 'premium', 
    is_premium = TRUE, 
    subscription_expiry = DATE_ADD(NOW(), INTERVAL 1 YEAR)
WHERE email = 'premium@freeagent.com';

-- Vérifier la mise à jour
SELECT id, email, name, subscription_type, is_premium, subscription_expiry 
FROM users 
WHERE email = 'premium@freeagent.com'; 