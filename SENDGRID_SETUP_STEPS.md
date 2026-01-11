# 📧 Guide Étape par Étape - Configuration SendGrid

## 🎯 Objectif
Configurer SendGrid pour envoyer des emails de réinitialisation de mot de passe depuis votre application.

---

## 📋 ÉTAPE 1 : Créer un compte SendGrid

1. Allez sur [sendgrid.com](https://sendgrid.com)
2. Cliquez sur **"Start for free"** ou **"Sign Up"**
3. Remplissez le formulaire d'inscription
4. Vérifiez votre email

---

## 📋 ÉTAPE 2 : Obtenir une API Key

1. Une fois connecté à SendGrid, allez dans **Settings** → **API Keys**
2. Cliquez sur **"Create API Key"**
3. Donnez un nom : `FreeAgent API Key`
4. Sélectionnez les permissions : **"Full Access"** (ou au minimum "Mail Send")
5. Cliquez sur **"Create & View"**
6. **⚠️ IMPORTANT** : Copiez l'API Key immédiatement (vous ne pourrez plus la voir après)
7. Collez-la quelque part en sécurité

---

## 📋 ÉTAPE 3 : Authentifier un expéditeur (Sender)

### Option A : Vérifier un seul email (Plus simple)

1. Allez dans **Settings** → **Sender Authentication**
2. Cliquez sur **"Verify a Single Sender"**
3. Remplissez le formulaire :

```
From Name: Free Agent
From Email Address: votre-email@gmail.com (ou noreply@freeagent.app)
Reply To: votre-email@gmail.com (même email ou support email)
Company Address: Votre adresse complète
Company Address Line 2: (vide si pas nécessaire)
City: Votre ville
State: (vide pour la France, ou sélectionnez votre état)
Zip Code: Votre code postal
Country: France (ou votre pays)
Nickname: FreeAgent App (optionnel)
```

4. Cliquez sur **"Create"**
5. **Checkez votre email** et cliquez sur le lien de vérification
6. Une fois vérifié, notez l'email que vous avez utilisé

---

### Option B : Authentifier un domaine complet (Avancé)

**Si vous avez un domaine (ex: freeagent.app)** :

1. Allez dans **Settings** → **Sender Authentication**
2. Cliquez sur **"Authenticate Your Domain"**
3. Sélectionnez votre **DNS host** :
   - Si vous ne savez pas, allez sur [whois.net](https://whois.net) et cherchez votre domaine
   - Les DNS hosts courants : Cloudflare, Namecheap, GoDaddy, OVH, etc.
4. Choisissez si vous voulez "brand the links" : **Oui** (recommandé)
5. Suivez les instructions pour ajouter les enregistrements DNS
6. Attendez la vérification (peut prendre jusqu'à 48h)

---

## 📋 ÉTAPE 4 : Configurer les variables d'environnement sur Railway

1. Allez sur [railway.app](https://railway.app)
2. Sélectionnez votre projet **freeagenappmobile-production**
3. Allez dans **Variables** (ou **Environment Variables**)
4. Ajoutez ces variables :

```bash
# SendGrid Configuration
EMAIL_SERVICE=sendgrid
SENDGRID_API_KEY=votre-api-key-copiée-étape-2

# Email Configuration
EMAIL_FROM=votre-email-vérifié-étape-3
EMAIL_FROM_NAME=Free Agent

# SMTP (optionnel, si vous utilisez SendGrid via SMTP)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=votre-api-key-copiée-étape-2
```

5. Cliquez sur **"Save"** pour chaque variable

---

## 📋 ÉTAPE 5 : Vérifier le code backend

Vérifiez que votre backend utilise bien SendGrid. Le fichier `backend/src/services/email.service.js` devrait avoir ce code :

```javascript
const nodemailer = require('nodemailer');

// Si EMAIL_SERVICE=sendgrid, utilise SendGrid
if (process.env.EMAIL_SERVICE === 'sendgrid') {
  transporter = nodemailer.createTransport({
    host: 'smtp.sendgrid.net',
    port: 587,
    auth: {
      user: 'apikey',
      pass: process.env.SENDGRID_API_KEY
    }
  });
}
```

---

## 📋 ÉTAPE 6 : Redéployer sur Railway

1. Sur Railway, cliquez sur **"Deployments"**
2. Cliquez sur **"Redeploy"** pour forcer un nouveau déploiement
3. Attendez que le déploiement soit terminé

---

## 📋 ÉTAPE 7 : Tester

1. Ouvrez votre application mobile/web
2. Allez sur la page de connexion
3. Cliquez sur **"Mot de passe oublié ?"**
4. Entrez un email valide
5. Vérifiez votre boîte email (peut prendre quelques minutes)
6. Vous devriez recevoir un email avec un lien de réinitialisation

---

## ✅ Checklist finale

- [ ] Compte SendGrid créé
- [ ] API Key créée et copiée
- [ ] Sender vérifié (email ou domaine)
- [ ] Variables d'environnement configurées sur Railway
- [ ] Backend redéployé
- [ ] Test d'envoi d'email réussi

---

## 🆘 En cas de problème

### L'email n'arrive pas
- Vérifiez les **spams**
- Vérifiez que l'API Key est correcte
- Vérifiez que le sender est bien vérifié
- Vérifiez les logs Railway pour des erreurs

### Erreur "Sender not verified"
- Le sender n'est pas encore vérifié
- Vérifiez votre boîte email pour le lien de vérification
- Réessayez après vérification

### Erreur "Invalid API Key"
- L'API Key est incorrecte ou expirée
- Créez une nouvelle API Key dans SendGrid
- Mettez à jour la variable `SENDGRID_API_KEY` sur Railway

---

## 📚 Ressources

- [Documentation SendGrid](https://docs.sendgrid.com/)
- [Guide Railway Email](RAILWAY_EMAIL_CONFIG_PRODUCTION.md)
- [Guide Sender Configuration](SENDGRID_SENDER_CONFIG.md)

