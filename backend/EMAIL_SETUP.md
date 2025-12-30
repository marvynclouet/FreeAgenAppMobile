# 📧 Configuration de l'envoi d'emails

## ✅ Fonctionnalité implémentée

L'envoi d'email pour la réinitialisation de mot de passe est maintenant configuré. Les utilisateurs recevront un email avec un lien pour réinitialiser leur mot de passe.

## 🔧 Configuration requise

### Option 1 : Gmail (Recommandé pour commencer)

1. **Activez l'authentification à deux facteurs** sur votre compte Gmail
2. **Générez un mot de passe d'application** :
   - Allez sur : https://myaccount.google.com/apppasswords
   - Sélectionnez "Mail" et "Other (Custom name)"
   - Entrez "FreeAgent Backend"
   - Copiez le mot de passe généré (16 caractères)

3. **Ajoutez dans Railway** (Variables d'environnement) :
   ```
   GMAIL_USER=votre-email@gmail.com
   GMAIL_APP_PASSWORD=votre-mot-de-passe-application-16-caracteres
   EMAIL_FROM=noreply@freeagent.app
   FRONTEND_URL=https://free-agen-app.vercel.app
   ```

### Option 2 : SMTP générique

Si vous utilisez un autre service email (SendGrid, Mailgun, etc.) :

1. **Ajoutez dans Railway** (Variables d'environnement) :
   ```
   SMTP_HOST=smtp.votre-service.com
   SMTP_PORT=587
   SMTP_SECURE=false
   SMTP_USER=votre-email@votre-domaine.com
   SMTP_PASSWORD=votre-mot-de-passe-smtp
   EMAIL_FROM=noreply@freeagent.app
   FRONTEND_URL=https://free-agen-app.vercel.app
   ```

### Option 3 : SendGrid (Recommandé pour production)

1. **Créez un compte** sur https://sendgrid.com
2. **Générez une API Key**
3. **Configurez** :
   ```
   SMTP_HOST=smtp.sendgrid.net
   SMTP_PORT=587
   SMTP_SECURE=false
   SMTP_USER=apikey
   SMTP_PASSWORD=votre-api-key-sendgrid
   EMAIL_FROM=noreply@freeagent.app
   FRONTEND_URL=https://free-agen-app.vercel.app
   ```

## 📋 Variables d'environnement à ajouter dans Railway

Allez sur Railway Dashboard → Votre projet → Variables et ajoutez :

### Minimum requis (Gmail) :
- `GMAIL_USER` : Votre email Gmail
- `GMAIL_APP_PASSWORD` : Mot de passe d'application Gmail
- `EMAIL_FROM` : Email expéditeur (peut être le même que GMAIL_USER)
- `FRONTEND_URL` : URL de votre frontend (pour les liens dans les emails)

### Ou SMTP :
- `SMTP_HOST` : Serveur SMTP
- `SMTP_PORT` : Port SMTP (587 pour TLS, 465 pour SSL)
- `SMTP_SECURE` : true pour SSL (port 465), false pour TLS (port 587)
- `SMTP_USER` : Utilisateur SMTP
- `SMTP_PASSWORD` : Mot de passe SMTP
- `EMAIL_FROM` : Email expéditeur
- `FRONTEND_URL` : URL de votre frontend

## 🎨 Template d'email

L'email envoyé contient :
- Un design professionnel avec le logo FreeAgent
- Un bouton cliquable pour réinitialiser le mot de passe
- Un lien de secours (texte)
- Des instructions de sécurité
- Un avertissement sur la validité (1 heure)

## 🔒 Sécurité

- Le token n'est **jamais** retourné dans la réponse API
- Le token expire après **1 heure**
- Le token ne peut être utilisé qu'**une seule fois**
- Même si l'email échoue, on ne révèle pas si l'email existe

## 🧪 Test

Pour tester l'envoi d'email :

1. **Configurez** les variables d'environnement dans Railway
2. **Redéployez** le backend
3. **Testez** la fonctionnalité "Mot de passe oublié" dans l'app
4. **Vérifiez** votre boîte email (et les spams)

## 📱 Lien de réinitialisation

Le lien dans l'email pointe vers :
```
${FRONTEND_URL}/reset-password?token=${resetToken}
```

Assurez-vous que votre frontend peut gérer ce lien. La page `reset_password_page.dart` existe déjà et peut être adaptée pour recevoir le token depuis l'URL.

## ⚠️ Mode développement

En mode développement (`NODE_ENV=development`), si aucune configuration email n'est fournie, le système utilise un transporter de test qui ne renvoie pas d'emails réels mais affiche l'URL de prévisualisation dans les logs.

## 🚀 Déploiement

Après avoir configuré les variables d'environnement dans Railway :

1. **Redéployez** le backend
2. **Testez** la fonctionnalité
3. **Vérifiez** que les emails arrivent bien

## 📝 Notes

- Les emails sont envoyés de manière asynchrone
- Si l'envoi échoue, l'erreur est loggée mais ne bloque pas la réponse
- Pour la production, utilisez un service professionnel (SendGrid, Mailgun, etc.)

