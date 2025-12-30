# 📧 Configuration Email en Production - Railway

## 🚀 Configuration pour Production

### Option 1 : Gmail (Simple et rapide)

**Étapes :**

1. **Activez l'authentification à deux facteurs** sur votre compte Gmail
   - Allez sur : https://myaccount.google.com/security
   - Activez "Validation en deux étapes"

2. **Générez un mot de passe d'application** :
   - Allez sur : https://myaccount.google.com/apppasswords
   - Sélectionnez "Mail" et "Other (Custom name)"
   - Entrez "FreeAgent Backend"
   - Copiez le mot de passe généré (16 caractères, format : xxxx xxxx xxxx xxxx)

3. **Dans Railway Dashboard** :
   - Allez sur : https://railway.app/dashboard
   - Sélectionnez votre projet backend
   - Allez dans **Variables** (ou **Settings** → **Variables**)
   - Ajoutez ces variables :

```
GMAIL_USER=votre-email@gmail.com
GMAIL_APP_PASSWORD=xxxx xxxx xxxx xxxx
EMAIL_FROM=noreply@freeagent.app
FRONTEND_URL=https://free-agen-app.vercel.app
```

**Important** : Pour `GMAIL_APP_PASSWORD`, entrez les 16 caractères SANS les espaces (ex: `abcd efgh ijkl mnop` devient `abcdefghijklmnop`)

---

### Option 2 : SendGrid (Recommandé pour production - Plus professionnel)

**Étapes :**

1. **Créez un compte SendGrid** :
   - Allez sur : https://sendgrid.com
   - Créez un compte gratuit (100 emails/jour gratuits)

2. **Générez une API Key** :
   - Allez dans **Settings** → **API Keys**
   - Cliquez sur **Create API Key**
   - Nom : "FreeAgent Backend"
   - Permissions : **Full Access** (ou au minimum "Mail Send")
   - Copiez l'API Key (commence par `SG.`)

3. **Vérifiez votre expéditeur** :
   - Allez dans **Settings** → **Sender Authentication**
   - Vérifiez ou ajoutez votre domaine/email expéditeur

4. **Dans Railway Dashboard** :
   - Allez dans **Variables**
   - Ajoutez ces variables :

```
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=apikey
SMTP_PASSWORD=SG.votre-api-key-complete-ici
EMAIL_FROM=noreply@freeagent.app
FRONTEND_URL=https://free-agen-app.vercel.app
```

**Important** : Pour `SMTP_PASSWORD`, utilisez votre API Key SendGrid complète (commence par `SG.`)

---

## 📋 Variables à ajouter dans Railway

### Minimum requis (Gmail) :

| Variable | Valeur | Exemple |
|----------|--------|---------|
| `GMAIL_USER` | Votre email Gmail | `contact@freeagent.app` |
| `GMAIL_APP_PASSWORD` | Mot de passe d'application (16 caractères) | `abcdefghijklmnop` |
| `EMAIL_FROM` | Email expéditeur | `noreply@freeagent.app` |
| `FRONTEND_URL` | URL de votre frontend | `https://free-agen-app.vercel.app` |

### Ou SMTP (SendGrid) :

| Variable | Valeur | Exemple |
|----------|--------|---------|
| `SMTP_HOST` | Serveur SMTP | `smtp.sendgrid.net` |
| `SMTP_PORT` | Port SMTP | `587` |
| `SMTP_SECURE` | SSL/TLS | `false` |
| `SMTP_USER` | Utilisateur SMTP | `apikey` |
| `SMTP_PASSWORD` | API Key SendGrid | `SG.xxxxx...` |
| `EMAIL_FROM` | Email expéditeur | `noreply@freeagent.app` |
| `FRONTEND_URL` | URL de votre frontend | `https://free-agen-app.vercel.app` |

---

## 🔧 Comment ajouter les variables dans Railway

1. **Allez sur** : https://railway.app/dashboard
2. **Sélectionnez** votre projet backend
3. **Cliquez sur** votre service backend
4. **Allez dans** l'onglet **Variables** (ou **Settings** → **Variables**)
5. **Cliquez sur** **"New Variable"** pour chaque variable
6. **Entrez** le nom et la valeur
7. **Sauvegardez**

**Important** : Après avoir ajouté les variables, Railway redéploiera automatiquement.

---

## ✅ Vérification

Après avoir ajouté les variables :

1. **Attendez** 2-5 minutes que Railway redéploie
2. **Testez** la fonctionnalité "Mot de passe oublié" dans l'app
3. **Vérifiez** votre boîte email (et les spams)

---

## 🎯 Recommandation

**Pour commencer rapidement** : Utilisez **Gmail** (Option 1)
- Gratuit
- Facile à configurer
- 500 emails/jour gratuits

**Pour la production à long terme** : Utilisez **SendGrid** (Option 2)
- Plus professionnel
- Meilleure délivrabilité
- Analytics et tracking
- 100 emails/jour gratuits, puis payant

---

## ⚠️ Sécurité

- **Ne partagez jamais** vos mots de passe d'application
- **Ne commitez jamais** ces variables** dans Git
- Elles doivent rester dans Railway Variables uniquement

---

## 📝 Exemple complet (Gmail)

Dans Railway Variables, ajoutez exactement :

```
GMAIL_USER=contact@freeagent.app
GMAIL_APP_PASSWORD=abcdefghijklmnop
EMAIL_FROM=noreply@freeagent.app
FRONTEND_URL=https://free-agen-app.vercel.app
```

Puis redéployez et testez !

