# 🚀 Forcer le redéploiement Railway - Routes mot de passe oublié

## 🚨 Problème

La route `/api/auth/forgot-password` retourne **404** car Railway n'a **pas encore redéployé** le backend avec les nouvelles routes.

## ✅ Solution : Forcer le redéploiement

### Méthode 1 : Via Railway Dashboard (Recommandé)

1. **Allez sur** : https://railway.app/dashboard
2. **Sélectionnez** votre projet backend (probablement "freeagenappmobile-production")
3. **Cliquez sur** l'onglet **"Deployments"** (en haut)
4. **Trouvez** le dernier déploiement
5. **Cliquez sur** les **3 points** (⋯) à droite du déploiement
6. **Sélectionnez** **"Redeploy"** ou **"Deploy Latest"**
7. **Attendez** 2-5 minutes que le déploiement se termine

### Méthode 2 : Via un nouveau commit (Si GitHub est connecté)

Si Railway est connecté à GitHub, créez un commit qui force le redéploiement :

```bash
# Créer un fichier vide pour forcer le redéploiement
touch backend/.redeploy
git add backend/.redeploy
git commit -m "chore: Force Railway redeploy for password reset routes"
git push origin main
```

### Méthode 3 : Vérifier la connexion GitHub

1. **Allez sur** Railway Dashboard
2. **Sélectionnez** votre projet
3. **Allez dans** **Settings** → **Source**
4. **Vérifiez** que :
   - GitHub est bien connecté
   - La branche `main` est sélectionnée
   - Les déploiements automatiques sont activés

## 🔍 Vérification après redéploiement

Une fois redéployé, testez :

```bash
curl -X POST https://freeagenappmobile-production.up.railway.app/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

### Résultat attendu (succès) :
```json
{
  "message": "Si cet email existe, un lien de réinitialisation a été envoyé",
  "resetToken": "abc123..."
}
```

### Résultat actuel (erreur) :
```html
<!DOCTYPE html>
<html>
<body>
<pre>Cannot POST /api/auth/forgot-password</pre>
</body>
</html>
```

## 📋 Routes à vérifier après redéploiement

- ✅ `POST /api/auth/forgot-password` - Doit retourner JSON (pas 404)
- ✅ `POST /api/auth/reset-password` - Doit retourner JSON (pas 404)
- ✅ `POST /api/auth/login` - Devrait toujours fonctionner
- ✅ `GET /api/auth/version` - Devrait toujours fonctionner

## ⚠️ Important

**La table `password_reset_tokens` existe déjà** dans la base de données (vérifié ✅).

Le seul problème est que **Railway n'a pas encore redéployé** le code avec les nouvelles routes.

## 🎯 Action immédiate

**Allez sur Railway Dashboard et forcez un redéploiement maintenant !**

Une fois redéployé, la fonctionnalité "Mot de passe oublié" fonctionnera dans l'application.

