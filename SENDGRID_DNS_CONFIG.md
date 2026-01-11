# 🔍 Configuration DNS pour SendGrid

## 📋 Comment trouver votre DNS host

### Méthode 1 : Vérifier où est hébergé votre domaine

1. **Allez sur** : https://whois.net
2. **Entrez** votre nom de domaine (ex: `freeagent.app`)
3. **Regardez** la section "Name Servers" ou "DNS Servers"
4. **Identifiez** le fournisseur :
   - `ns1.google.com`, `ns2.google.com` → **Google Domains**
   - `ns1.namecheap.com` → **Namecheap**
   - `ns1.godaddy.com` → **GoDaddy**
   - `dns1.registrar-servers.com` → **Name.com** ou autre registrar
   - `ns1.railway.app` → **Railway** (si vous utilisez Railway DNS)

### Méthode 2 : Vérifier dans votre registrar

1. **Connectez-vous** à votre registrar (où vous avez acheté le domaine)
2. **Allez dans** les paramètres DNS
3. **Regardez** qui gère les DNS

### Méthode 3 : Commande en ligne

```bash
# Sur Mac/Linux
dig NS votre-domaine.com

# Ou
nslookup -type=NS votre-domaine.com
```

## 🎯 Options SendGrid

### Option A : Authentifier un seul expéditeur (RECOMMANDÉ pour commencer)

**Plus simple, pas besoin de DNS !**

1. Dans SendGrid, **cliquez sur** "Verify a Single Sender" (au lieu de "Authenticate Your Domain")
2. **Entrez** votre email (ex: `noreply@freeagent.app` ou votre email Gmail)
3. **Vérifiez** l'email reçu
4. **Utilisez** cet email dans `EMAIL_FROM`

**Avantages** :
- ✅ Pas besoin d'accès DNS
- ✅ Configuration en 2 minutes
- ✅ Fonctionne immédiatement

**Inconvénients** :
- ⚠️ Limité à un seul email expéditeur
- ⚠️ Les emails peuvent aller en spam (mais généralement OK)

### Option B : Authentifier un domaine complet

**Nécessite l'accès DNS, mais plus professionnel**

1. **Trouvez** votre DNS host (voir méthodes ci-dessus)
2. **Dans SendGrid**, sélectionnez votre DNS host dans la liste
3. **Ajoutez** les enregistrements DNS demandés par SendGrid
4. **Attendez** la vérification (peut prendre quelques heures)

**Avantages** :
- ✅ Plus professionnel
- ✅ Meilleure délivrabilité
- ✅ Peut utiliser n'importe quel email @votre-domaine.com

**Inconvénients** :
- ⚠️ Nécessite l'accès DNS
- ⚠️ Configuration plus complexe
- ⚠️ Peut prendre du temps

## 💡 Recommandation

**Pour commencer rapidement** : Utilisez **"Verify a Single Sender"** (Option A)

Vous pourrez toujours authentifier le domaine complet plus tard si nécessaire.

## 📝 Si vous choisissez d'authentifier le domaine

### DNS hosts courants dans SendGrid :

- **Google Domains** → Sélectionnez "Google"
- **Namecheap** → Sélectionnez "Namecheap"
- **GoDaddy** → Sélectionnez "GoDaddy"
- **Cloudflare** → Sélectionnez "Cloudflare"
- **AWS Route 53** → Sélectionnez "Amazon Route 53"
- **Autre** → Sélectionnez "Other" et suivez les instructions manuelles

### Après avoir sélectionné votre DNS host :

SendGrid vous donnera des enregistrements DNS à ajouter. Vous devrez :

1. **Aller** dans votre DNS host
2. **Ajouter** les enregistrements CNAME et TXT demandés
3. **Attendre** la vérification (quelques minutes à quelques heures)

## ✅ Configuration finale

Une fois l'authentification terminée (Single Sender ou Domain), utilisez dans Railway :

```
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=apikey
SMTP_PASSWORD=SG.votre-api-key
EMAIL_FROM=noreply@freeagent.app  (ou l'email vérifié)
FRONTEND_URL=https://free-agen-app.vercel.app
```


