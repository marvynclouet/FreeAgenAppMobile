# 🚀 Redéploiement Railway pour activer les routes de réinitialisation

## 🚨 Problème

La route `/api/auth/forgot-password` retourne une 404 sur Railway car le backend n'a pas été redéployé avec les dernières modifications.

## ✅ Solution : Forcer un redéploiement Railway

### Option 1 : Via Railway Dashboard (Recommandé)

1. **Allez sur** : https://railway.app/dashboard
2. **Sélectionnez** votre projet backend
3. **Allez dans** l'onglet "Deployments"
4. **Cliquez sur** "Redeploy" ou "Deploy Latest"
5. **Attendez** la fin du déploiement (2-5 minutes)

### Option 2 : Via un commit vide (Force redeploy)

Si Railway est connecté à GitHub, vous pouvez forcer un redéploiement en créant un commit vide :

```bash
git commit --allow-empty -m "chore: Force Railway redeploy for password reset routes"
git push origin main
```

### Option 3 : Vérifier la connexion GitHub

1. **Allez sur** Railway Dashboard
2. **Sélectionnez** votre projet
3. **Allez dans** Settings → Source
4. **Vérifiez** que GitHub est bien connecté
5. **Vérifiez** que la branche `main` est sélectionnée

## 🔍 Vérification après redéploiement

Testez la route :

```bash
curl -X POST https://freeagenappmobile-production.up.railway.app/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

**Résultat attendu** : JSON avec `message` et `resetToken` (pas de 404)

## 📋 Routes à vérifier

Après redéploiement, ces routes devraient fonctionner :

- ✅ `POST /api/auth/forgot-password` - Demander une réinitialisation
- ✅ `POST /api/auth/reset-password` - Réinitialiser avec un token

## ⚠️ Important

Assurez-vous que la table `password_reset_tokens` existe dans votre base de données Railway. Si elle n'existe pas, exécutez :

```bash
cd backend/src/scripts
node create_password_reset_table.js
```

Ou exécutez directement le SQL dans Railway Dashboard → Database → Query.


