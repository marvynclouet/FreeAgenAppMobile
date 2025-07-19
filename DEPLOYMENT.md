# 🚀 Guide de Déploiement FreeAgent App

## 📋 Vue d'ensemble

Cette application utilise deux plateformes de déploiement :
- **Railway** : Backend Node.js/Express avec base de données MySQL
- **Vercel** : Frontend Flutter Web

## 🔧 Configuration Backend (Railway)

### Prérequis
- Compte Railway
- Base de données MySQL (Railwind)

### Variables d'environnement Railway
```env
DB_HOST=your-railwind-host
DB_USER=your-username
DB_PASSWORD=your-password
DB_NAME=your-database-name
JWT_SECRET=your-jwt-secret
```

### Déploiement
1. Connectez votre repository GitHub à Railway
2. Railway détectera automatiquement le dossier `backend/`
3. Le fichier `railway.json` configure le déploiement
4. Les variables d'environnement sont configurées dans l'interface Railway

### Test du Backend
```bash
# Test de toutes les routes API
node test_all_routes.js

# Test de la base de données via API
node test_database_via_api.js
```

## 🌐 Configuration Frontend (Vercel)

### Prérequis
- Compte Vercel
- Flutter SDK installé
- Compte GitHub

### Configuration Vercel
Le fichier `vercel.json` configure :
- Build command : `cd freeagentapp && flutter build web --release`
- Output directory : `freeagentapp/build/web`
- Routes pour servir l'application Flutter Web
- Headers de cache pour optimiser les performances

### Déploiement
1. Connectez votre repository GitHub à Vercel
2. Vercel détectera automatiquement la configuration `vercel.json`
3. Le déploiement se fait automatiquement à chaque push

### Test du Frontend
```bash
# Préparation du déploiement
./deploy_vercel.sh

# Build local pour test
cd freeagentapp
flutter build web --release
```

## 🔗 URLs de Déploiement

### Production
- **Backend** : https://freeagenappmobile-production.up.railway.app
- **Frontend** : https://web-seven-roan-79.vercel.app

### Développement
- **Backend Local** : http://localhost:3000
- **Frontend Local** : http://localhost:8080

## 📊 Monitoring

### Backend (Railway)
- Logs disponibles dans l'interface Railway
- Health check : `GET /api/auth/health`
- Métriques de performance dans le dashboard

### Frontend (Vercel)
- Analytics dans l'interface Vercel
- Performance monitoring automatique
- A/B testing disponible

## 🛠️ Scripts Utiles

### Test Complet
```bash
# Test du backend
node test_database_via_api.js

# Préparation Vercel
./deploy_vercel.sh
```

### Développement Local
```bash
# Backend
cd backend
npm install
npm start

# Frontend
cd freeagentapp
flutter pub get
flutter run -d chrome
```

## 🔒 Sécurité

### Backend
- JWT pour l'authentification
- Middleware de protection des routes
- Validation des données d'entrée
- Rate limiting (à implémenter)

### Frontend
- HTTPS obligatoire en production
- Headers de sécurité configurés
- Validation côté client

## 📈 Performance

### Optimisations Backend
- Connection pooling MySQL
- Compression des réponses
- Cache Redis (optionnel)

### Optimisations Frontend
- Tree-shaking des icônes
- Compression des assets
- Lazy loading des composants
- Service worker pour le cache

## 🚨 Troubleshooting

### Erreurs Courantes

#### Backend
- **Erreur de connexion DB** : Vérifiez les variables d'environnement Railway
- **Port déjà utilisé** : Changez le port dans `backend/src/app.js`
- **JWT invalide** : Vérifiez `JWT_SECRET` dans les variables d'environnement

#### Frontend
- **Build échoue** : Vérifiez que Flutter est installé et à jour
- **Assets manquants** : Vérifiez le dossier `freeagentapp/assets/`
- **CORS** : Configurez les origines autorisées dans le backend

### Logs
- **Railway** : Interface web → Logs
- **Vercel** : Interface web → Functions → Logs
- **Local** : `npm start` ou `flutter run`

## 📝 Maintenance

### Mises à jour
1. Modifiez le code localement
2. Testez avec les scripts fournis
3. Commit et push vers GitHub
4. Déploiement automatique sur Railway et Vercel

### Sauvegarde
- Base de données : Automatique avec Railway
- Code : Sauvegardé sur GitHub
- Assets : Inclus dans le repository

## 🎯 Prochaines Étapes

- [ ] Implémenter le monitoring avancé
- [ ] Ajouter des tests automatisés
- [ ] Configurer CI/CD complet
- [ ] Optimiser les performances
- [ ] Ajouter la documentation API 