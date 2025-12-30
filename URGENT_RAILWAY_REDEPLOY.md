# 🚨 URGENT : Redéploiement Railway requis

## ❌ Problème actuel

La route `/api/auth/forgot-password` retourne **404** car Railway utilise encore une **ancienne version** du code qui ne contient pas les routes de réinitialisation.

## ✅ Vérifications effectuées

- ✅ Le code est présent dans le repository (commit `0323c19`)
- ✅ La route existe dans `backend/src/routes/auth.routes.js`
- ✅ La table `password_reset_tokens` existe dans la base de données
- ❌ Railway n'a **PAS** encore redéployé avec le nouveau code

## 🚀 ACTION IMMÉDIATE REQUISE

### Étape 1 : Allez sur Railway Dashboard

1. **Ouvrez** : https://railway.app/dashboard
2. **Connectez-vous** avec votre compte
3. **Sélectionnez** le projet backend (probablement "freeagenappmobile-production")

### Étape 2 : Vérifiez les déploiements

1. **Cliquez sur** l'onglet **"Deployments"** (en haut de la page)
2. **Regardez** le dernier déploiement :
   - **Date** : Quand a-t-il été fait ?
   - **Commit** : Quel commit est déployé ? (doit être `0323c19` ou plus récent)
   - **Statut** : Est-il "Active" ou "Building" ?

### Étape 3 : Forcez un redéploiement

**Option A : Si vous voyez un bouton "Redeploy"**
1. **Cliquez sur** les **3 points** (⋯) à droite du dernier déploiement
2. **Sélectionnez** **"Redeploy"**
3. **Attendez** 2-5 minutes

**Option B : Si vous voyez "Deploy Latest"**
1. **Cliquez sur** **"Deploy Latest"**
2. **Attendez** 2-5 minutes

**Option C : Via Settings**
1. **Allez dans** **Settings** → **Source**
2. **Vérifiez** que GitHub est connecté
3. **Vérifiez** que la branche `main` est sélectionnée
4. **Cliquez sur** **"Redeploy"** si disponible

### Étape 4 : Vérifiez le commit déployé

Après redéploiement, vérifiez que le commit déployé est **`0323c19`** ou plus récent (comme `7b5742e`).

## 🔍 Test après redéploiement

Une fois redéployé, testez immédiatement :

```bash
curl -X POST https://freeagenappmobile-production.up.railway.app/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

### ✅ Résultat attendu (succès) :
```json
{
  "message": "Si cet email existe, un lien de réinitialisation a été envoyé",
  "resetToken": "abc123def456..."
}
```

### ❌ Résultat actuel (erreur) :
```html
<!DOCTYPE html>
<pre>Cannot POST /api/auth/forgot-password</pre>
```

## ⚠️ Si le redéploiement ne fonctionne pas

1. **Vérifiez les logs** Railway pour voir s'il y a des erreurs
2. **Vérifiez** que le repository GitHub est bien connecté
3. **Essayez** de créer un nouveau commit pour forcer le redéploiement :
   ```bash
   echo "# Railway redeploy trigger" >> backend/README.md
   git add backend/README.md
   git commit -m "chore: Force Railway redeploy"
   git push origin main
   ```

## 📋 Checklist

- [ ] Allé sur Railway Dashboard
- [ ] Trouvé l'onglet "Deployments"
- [ ] Vérifié le commit actuellement déployé
- [ ] Cliqué sur "Redeploy" ou "Deploy Latest"
- [ ] Attendu 2-5 minutes
- [ ] Testé la route `/api/auth/forgot-password`
- [ ] Vérifié que ça retourne du JSON (pas de 404)

## 🎯 Objectif

Une fois Railway redéployé avec le commit `0323c19` ou plus récent, la fonctionnalité "Mot de passe oublié" fonctionnera dans l'application.

**ACTION REQUISE MAINTENANT : Allez sur Railway Dashboard et forcez un redéploiement !**

