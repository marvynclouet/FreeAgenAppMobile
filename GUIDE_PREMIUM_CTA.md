r# 🎯 Guide des Call-to-Action Premium

Ce guide explique comment utiliser les call-to-action premium pour pousser les utilisateurs gratuits vers l'abonnement premium.

## ✅ Système Premium Fonctionnel

Le système d'abonnement premium est **100% opérationnel** avec :

- **Serveur backend** : ✅ Opérationnel (port 3000)
- **Restrictions freemium** : ✅ Actives et fonctionnelles
- **Utilisateur de test** : ✅ Créé (`joueur.test@example.com` / `test123`)
- **API d'abonnement** : ✅ Tous les endpoints disponibles

### Restrictions Appliquées

**Utilisateurs GRATUITS (très limités)** :
- ❌ **0 candidatures** aux opportunités
- ❌ **Cannot post** d'opportunités  
- ❌ **Pas d'accès** aux messages
- ❌ **Pas d'accès** aux notifications

**Utilisateurs PREMIUM** :
- ✅ Candidatures selon leur plan (3 ou illimité)
- ✅ Peuvent poster des opportunités
- ✅ Messages illimités
- ✅ Accès aux notifications

## 🎨 Widgets Call-to-Action Disponibles

### 1. Dialog d'Upgrade
```dart
import 'utils/premium_utils.dart';

// Afficher quand l'utilisateur tente une action premium
PremiumUtils.showUpgradeDialog(context);
```

### 2. Bannière Premium
```dart
// Afficher en haut de la page pour les utilisateurs gratuits
if (PremiumUtils.isFreeUser(subscriptionStatus)) {
  PremiumUtils.buildFreeBanner(context)
}
```

### 3. Card CTA
```dart
// Afficher dans le contenu principal
if (PremiumUtils.isFreeUser(subscriptionStatus)) {
  PremiumUtils.buildUpgradeCard(context)
}
```

## 🔧 Exemples d'Utilisation

### Dans une page d'opportunités
```dart
// Quand l'utilisateur clique sur "Postuler"
if (PremiumUtils.isFreeUser(subscriptionStatus)) {
  PremiumUtils.showUpgradeDialog(context);
  return; // Bloquer l'action
}
// Continuer avec la candidature...
```

### Dans la page d'accueil
```dart
Column(
  children: [
    // Bannière en haut pour les utilisateurs gratuits
    if (PremiumUtils.isFreeUser(subscriptionStatus))
      PremiumUtils.buildFreeBanner(context),
    
    // Contenu principal...
    
    // Card CTA à la fin
    if (PremiumUtils.isFreeUser(subscriptionStatus))
      PremiumUtils.buildUpgradeCard(context),
  ],
)
```

### Dans les messages
```dart
// Quand l'utilisateur tente d'envoyer un message
if (PremiumUtils.isFreeUser(subscriptionStatus)) {
  PremiumUtils.showUpgradeDialog(context);
  return;
}
// Envoyer le message...
```

## 📱 Navigation vers Premium

Les call-to-action utilisent la navigation :
```dart
Navigator.pushNamed(context, '/premium');
```

Assurez-vous que la route `/premium` est définie dans votre `MaterialApp`.

## 🧪 Test du Système

### Utilisateur de Test Créé
- **Email** : `joueur.test@example.com`
- **Mot de passe** : `test123`
- **Type** : Joueur GRATUIT (toutes restrictions actives)

### Vérification des Restrictions
```bash
# Tester les restrictions (serveur doit être démarré)
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joueur.test@example.com","password":"test123"}'

# Puis tester les restrictions avec le token obtenu
```

## 🎯 Stratégie d'Implémentation

### Étape 1 : Pages Principales
1. **Page d'accueil** : Bannière + Card CTA
2. **Page opportunités** : Dialog lors du clic "Postuler"
3. **Page messages** : Dialog lors de la tentative d'envoi

### Étape 2 : Actions Bloquées
- Candidature aux opportunités → Dialog
- Création d'opportunités → Dialog
- Envoi de messages → Dialog
- Accès aux notifications → Dialog

### Étape 3 : Retour Utilisateur
- Messages clairs sur les limitations
- Avantages premium bien expliqués
- Appel à l'action immédiat

## 💡 Conseils d'UX

1. **Frustration contrôlée** : Laisser voir les opportunités mais bloquer l'action
2. **Valeur claire** : Expliquer les bénéfices du premium
3. **Simplicité** : Un seul bouton "Passer Premium"
4. **Persistance** : Bannière toujours visible pour les gratuits

## 🚀 Résultat Attendu

Les utilisateurs gratuits seront **poussés efficacement** vers l'abonnement premium car :
- Version gratuite = inutilisable (0 candidatures, pas de messages)
- Version premium = débloque toutes les fonctionnalités essentielles
- Call-to-action omniprésents et attractifs

Le système est prêt pour la production ! 🎉 