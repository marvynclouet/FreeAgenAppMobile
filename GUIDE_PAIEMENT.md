# Guide d'Implémentation du Système de Paiement Stripe

## 🚀 Configuration Initiale

### 1. Créer un compte Stripe
1. Allez sur [https://dashboard.stripe.com/register](https://dashboard.stripe.com/register)
2. Créez votre compte Stripe
3. Activez le mode Test pour les développements

### 2. Récupérer les clés API
1. Dans le dashboard Stripe, allez dans **Developers > API Keys**
2. Copiez :
   - **Publishable key** (commence par `pk_test_`)
   - **Secret key** (commence par `sk_test_`)

### 3. Configuration Backend

#### A. Variables d'environnement
Ajoutez dans votre fichier `.env` :
```bash
STRIPE_PUBLISHABLE_KEY=pk_test_votre-cle-publique
STRIPE_SECRET_KEY=sk_test_votre-cle-secrete
STRIPE_WEBHOOK_SECRET=whsec_votre-webhook-secret
```

#### B. Base de données
Exécutez le script SQL pour ajouter les colonnes Stripe :
```bash
mysql -u root -p freeagent_db < backend/src/database/add_stripe_fields.sql
```

#### C. Installer les dépendances
```bash
cd backend
npm install stripe
```

### 4. Configuration Frontend

#### A. Installer les dépendances Flutter
```bash
cd freeagentapp
flutter pub get
```

#### B. Mettre à jour la clé publique
Dans `freeagentapp/lib/services/payment_service.dart`, ligne 75 :
```dart
Stripe.publishableKey = 'pk_test_votre-cle-publique-stripe';
```

## 🔧 Configuration des Webhooks

### 1. Créer un webhook dans Stripe
1. Allez dans **Developers > Webhooks**
2. Cliquez sur **Add endpoint**
3. URL : `https://votre-domaine.com/api/payments/webhook`
4. Événements à écouter :
   - `checkout.session.completed`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
   - `customer.subscription.deleted`

### 2. Pour les tests locaux (ngrok)
```bash
# Installer ngrok
brew install ngrok  # macOS
# ou télécharger depuis https://ngrok.com/

# Exposer votre serveur local
ngrok http 3000

# Utiliser l'URL ngrok dans le webhook Stripe
# Exemple: https://abc123.ngrok.io/api/payments/webhook
```

## 💳 Flux de Paiement

### 1. Processus utilisateur
1. L'utilisateur clique sur "Choisir ce plan"
2. Une session Stripe Checkout est créée
3. L'utilisateur est redirigé vers Stripe
4. Après paiement, Stripe envoie un webhook
5. L'abonnement est activé automatiquement

### 2. Gestion des événements
- **checkout.session.completed** : Abonnement créé
- **invoice.payment_succeeded** : Paiement récurrent réussi
- **invoice.payment_failed** : Échec de paiement
- **customer.subscription.deleted** : Annulation

## 🧪 Tests

### 1. Cartes de test Stripe
```
Visa réussie : 4242 4242 4242 4242
Visa échouée : 4000 0000 0000 0002
Mastercard : 5555 5555 5555 4444
```

### 2. Test des webhooks
```bash
# Installer Stripe CLI
brew install stripe/stripe-cli/stripe

# Se connecter à Stripe
stripe login

# Écouter les webhooks localement
stripe listen --forward-to localhost:3000/api/payments/webhook

# Tester un webhook
stripe trigger checkout.session.completed
```

## 📱 Interface Utilisateur

### Plans d'abonnement
- **Premium Basic** : 5,99€/mois ou 59,99€/an
- **Premium Pro** : 9,99€/mois ou 99,99€/an

### Fonctionnalités par plan
- **Gratuit** : 0 candidatures, messages limités
- **Basic** : 10 candidatures/mois, messages illimités
- **Pro** : Candidatures illimitées, fonctionnalités avancées

## 🔒 Sécurité

### 1. Validation des webhooks
Le code vérifie automatiquement la signature Stripe pour sécuriser les webhooks.

### 2. Gestion des erreurs
- Transactions atomiques en base de données
- Rollback automatique en cas d'erreur
- Logs détaillés pour le debugging

## 🚀 Déploiement

### 1. Production
1. Remplacez les clés test par les clés production
2. Configurez l'URL de webhook en production
3. Testez les paiements avec de vraies cartes

### 2. Monitoring
- Surveillez les logs de webhook
- Vérifiez les échecs de paiement
- Configurez les alertes Stripe

## 📊 Analytics

### Dashboard Stripe
- Revenus en temps réel
- Taux de conversion
- Analyses des échecs de paiement
- Gestion des remboursements

### Métriques importantes
- Taux de conversion par plan
- Churn rate (taux d'annulation)
- Revenus récurrents mensuels (MRR)

## 🆘 Dépannage

### Erreurs courantes
1. **Webhook signature failed** : Vérifiez le webhook secret
2. **Invalid API key** : Vérifiez les clés Stripe
3. **Session expired** : Augmentez la durée de session

### Debug
```bash
# Logs backend
tail -f backend/logs/app.log

# Logs Stripe
stripe logs tail
```

## 📞 Support

Pour toute question :
- Documentation Stripe : [https://stripe.com/docs](https://stripe.com/docs)
- Support Stripe : [https://support.stripe.com](https://support.stripe.com)
- Tests API : [https://dashboard.stripe.com/test/apikeys](https://dashboard.stripe.com/test/apikeys)

---

✅ **Système de paiement prêt à l'emploi avec Stripe !** 