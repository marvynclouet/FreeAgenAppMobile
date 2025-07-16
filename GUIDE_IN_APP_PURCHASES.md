# Guide Configuration In-App Purchases - FreeAgenApp

## 📱 Vue d'ensemble

Ce guide vous accompagne dans la configuration complète des In-App Purchases pour FreeAgenApp, permettant aux utilisateurs d'acheter des abonnements premium directement depuis l'application mobile.

## 🔧 1. Configuration Backend

### 1.1 Ajout des endpoints de validation

Créez le fichier `backend/src/routes/store.routes.js` pour gérer la validation des achats :

```javascript
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const db = require('../database/db');

// Validation d'achat iOS (App Store)
router.post('/validate-ios-purchase', async (req, res) => {
  try {
    const { receipt, userId } = req.body;
    
    // Valider le receipt auprès d'Apple
    const isValid = await validateAppleReceipt(receipt);
    
    if (isValid) {
      // Activer l'abonnement premium
      await activatePremiumSubscription(userId, 'ios', receipt);
      res.json({ success: true, message: 'Abonnement activé' });
    } else {
      res.status(400).json({ success: false, message: 'Receipt invalide' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Validation d'achat Android (Google Play)
router.post('/validate-android-purchase', async (req, res) => {
  try {
    const { purchaseToken, productId, userId } = req.body;
    
    // Valider le token auprès de Google Play
    const isValid = await validateGooglePlayPurchase(purchaseToken, productId);
    
    if (isValid) {
      // Activer l'abonnement premium
      await activatePremiumSubscription(userId, 'android', purchaseToken);
      res.json({ success: true, message: 'Abonnement activé' });
    } else {
      res.status(400).json({ success: false, message: 'Token invalide' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
```

### 1.2 Installation des dépendances

```bash
npm install googleapis apple-app-store-receipt-verify
```

### 1.3 Configuration des variables d'environnement

Ajoutez dans votre `.env` :

```env
# Apple Store Connect
APPLE_SHARED_SECRET=your_apple_shared_secret
APPLE_BUNDLE_ID=com.example.freeagentapp

# Google Play Console
GOOGLE_PLAY_PRIVATE_KEY=your_google_private_key
GOOGLE_PLAY_CLIENT_EMAIL=your_service_account_email
GOOGLE_PLAY_PROJECT_ID=your_project_id
```

## 🍎 2. Configuration Apple Store Connect

### 2.1 Créer les produits In-App

1. Connectez-vous à [App Store Connect](https://appstoreconnect.apple.com)
2. Sélectionnez votre app
3. Allez dans **Fonctionnalités** > **Achats intégrés et abonnements**
4. Cliquez sur **Gérer** à côté d'**Abonnements automatiquement renouvelables**

### 2.2 Créer les groupes d'abonnements

Créez un groupe d'abonnements appelé "Premium Plans" :

1. Cliquez sur **Créer un groupe d'abonnements**
2. Nom de référence : `premium_plans`
3. Nom d'affichage : `Plans Premium`

### 2.3 Ajouter les produits

Pour chaque plan, créez un produit :

#### Plan Basic Monthly
- **ID de produit** : `premium_basic_monthly`
- **Nom de référence** : `Premium Basic Monthly`
- **Durée** : 1 mois
- **Prix** : 4.99 €

#### Plan Basic Yearly
- **ID de produit** : `premium_basic_yearly`
- **Nom de référence** : `Premium Basic Yearly`
- **Durée** : 1 an
- **Prix** : 49.99 €

#### Plan Pro Monthly
- **ID de produit** : `premium_pro_monthly`
- **Nom de référence** : `Premium Pro Monthly`
- **Durée** : 1 mois
- **Prix** : 9.99 €

#### Plan Pro Yearly
- **ID de produit** : `premium_pro_yearly`
- **Nom de référence** : `Premium Pro Yearly`
- **Durée** : 1 an
- **Prix** : 99.99 €

### 2.4 Configuration des métadonnées

Pour chaque produit, ajoutez :
- **Nom d'affichage** : Nom visible par l'utilisateur
- **Description** : Description des fonctionnalités
- **Captures d'écran** : Images promotionnelles (optionnel)

### 2.5 Obtenir le Shared Secret

1. Allez dans **Utilisateurs et accès** > **Clés**
2. Cliquez sur **Clés d'accès In-App Purchase**
3. Cliquez sur **Générer une clé d'accès maître partagée**
4. Copiez la clé dans votre `.env`

## 🤖 3. Configuration Google Play Console

### 3.1 Créer les produits

1. Connectez-vous à [Google Play Console](https://play.google.com/console)
2. Sélectionnez votre app
3. Allez dans **Monétisation** > **Produits** > **Abonnements**
4. Cliquez sur **Créer un abonnement**

### 3.2 Créer les abonnements

Pour chaque plan, créez un abonnement :

#### Plan Basic Monthly
- **ID de produit** : `premium_basic_monthly`
- **Nom** : `Premium Basic Monthly`
- **Période de facturation** : 1 mois
- **Prix** : 4.99 €

#### Plan Basic Yearly
- **ID de produit** : `premium_basic_yearly`
- **Nom** : `Premium Basic Yearly`
- **Période de facturation** : 1 an
- **Prix** : 49.99 €

#### Plan Pro Monthly
- **ID de produit** : `premium_pro_monthly`
- **Nom** : `Premium Pro Monthly`
- **Période de facturation** : 1 mois
- **Prix** : 9.99 €

#### Plan Pro Yearly
- **ID de produit** : `premium_pro_yearly`
- **Nom** : `Premium Pro Yearly`
- **Période de facturation** : 1 an
- **Prix** : 99.99 €

### 3.3 Configuration de l'API Google Play

1. Allez dans **Configuration** > **Accès à l'API**
2. Créez un compte de service ou utilisez un existant
3. Téléchargez la clé JSON
4. Activez l'API Google Play Android Developer

### 3.4 Permissions requises

Assurez-vous que votre compte de service a les permissions :
- **Afficher les données financières**
- **Gérer les commandes et abonnements**

## 🔧 4. Intégration Frontend

### 4.1 Mise à jour du service de subscription

Ajoutez la méthode de validation dans `subscription_service.dart` :

```dart
// Valider un achat store
Future<Map<String, dynamic>> validateStorePurchase({
  required String productId,
  required String purchaseToken,
  required String platform,
}) async {
  try {
    final userData = await _authService.getUserData();
    final userId = userData?['id'];

    final response = await http.post(
      Uri.parse('$baseUrl/store/validate-${platform}-purchase'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _authService.getToken()}',
      },
      body: json.encode({
        'userId': userId,
        'productId': productId,
        platform == 'ios' ? 'receipt' : 'purchaseToken': purchaseToken,
      }),
    );

    return json.decode(response.body);
  } catch (e) {
    throw Exception('Erreur validation achat: $e');
  }
}
```

### 4.2 Mise à jour de la page d'abonnement

Modifiez `subscription_page.dart` pour intégrer les In-App Purchases :

```dart
import 'services/in_app_purchase_service.dart';

class _SubscriptionPageState extends State<SubscriptionPage> {
  final InAppPurchaseService _iapService = InAppPurchaseService();
  
  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    await _iapService.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing code ...
      body: Column(
        children: [
          // Toggle entre Stripe et In-App Purchases
          _buildPaymentMethodToggle(),
          
          // Plans avec prix appropriés
          ..._buildPlanCards(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodToggle() {
    return SegmentedButton(
      segments: const [
        ButtonSegment(value: 'stripe', label: Text('Web')),
        ButtonSegment(value: 'iap', label: Text('Mobile')),
      ],
      selected: {_paymentMethod},
      onSelectionChanged: (Set<String> selection) {
        setState(() {
          _paymentMethod = selection.first;
        });
      },
    );
  }
}
```

## 🧪 5. Tests et Validation

### 5.1 Tests sur iOS

1. **Mode Sandbox** : Créez un compte de test dans App Store Connect
2. **TestFlight** : Testez avec une version beta
3. **Compte de test** : Utilisez un compte Apple de test

### 5.2 Tests sur Android

1. **Pistes de test** : Utilisez la piste de test interne
2. **Licence de test** : Configurez des comptes de test
3. **Carte de test** : Utilisez une carte de crédit de test

### 5.3 Validation des achats

Vérifiez que :
- ✅ Les achats sont correctement validés côté serveur
- ✅ L'abonnement est activé dans la base de données
- ✅ L'interface utilisateur se met à jour
- ✅ Les fonctionnalités premium sont débloquées

## 🚀 6. Déploiement

### 6.1 Checklist avant production

- [ ] Tous les produits sont créés dans les stores
- [ ] Les prix sont configurés pour tous les marchés
- [ ] Les métadonnées sont traduites
- [ ] Les tests sont réussis
- [ ] L'API de validation est sécurisée
- [ ] Les webhooks sont configurés

### 6.2 Surveillance

Surveillez :
- **Taux de conversion** : Nombre d'abonnements vs visites
- **Taux d'abandon** : Abandons pendant l'achat
- **Revenus** : Revenus générés par plan
- **Erreurs** : Erreurs de validation côté serveur

## 📊 7. Métriques et Analytics

### 7.1 Événements à tracker

```dart
// Exemple d'événements analytics
Analytics.logEvent('subscription_page_viewed');
Analytics.logEvent('subscription_purchase_started', parameters: {
  'plan_id': planId,
  'platform': Platform.isIOS ? 'ios' : 'android',
});
Analytics.logEvent('subscription_purchase_completed', parameters: {
  'plan_id': planId,
  'amount': amount,
});
```

### 7.2 KPIs importants

- **ARPU** : Revenu moyen par utilisateur
- **LTV** : Valeur vie client
- **Churn Rate** : Taux de désabonnement
- **Retention** : Taux de rétention par période

## 🛠️ 8. Maintenance

### 8.1 Mises à jour régulières

- **Prices** : Ajustez les prix selon les marchés
- **Métadonnées** : Mettez à jour les descriptions
- **Promotions** : Créez des offres spéciales
- **A/B Testing** : Testez différentes présentations

### 8.2 Support client

Préparez la gestion :
- **Remboursements** : Processus de remboursement
- **Résiliation** : Aide à la résiliation
- **Facturation** : Questions de facturation
- **Technique** : Problèmes d'achat

---

## 📞 Support

Pour toute question sur cette configuration, consultez :
- [Documentation Apple](https://developer.apple.com/in-app-purchase/)
- [Documentation Google Play](https://developer.android.com/google/play/billing)
- [Plugin Flutter](https://pub.dev/packages/in_app_purchase) 