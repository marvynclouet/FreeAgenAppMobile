# 📧 Configuration SendGrid - Créer un Sender

## 📋 Comment remplir le formulaire SendGrid

### From Name (Nom de l'expéditeur)
```
Free Agent
```
✅ **Déjà rempli** - C'est parfait !

### From Email Address (Email expéditeur)
**Choisissez l'une de ces options :**

**Option 1 : Utiliser votre email Gmail** (Recommandé pour commencer)
```
votre-email@gmail.com
```
Exemple : `contact@freeagent.app` ou `noreply@freeagent.app`

**Option 2 : Utiliser un email de votre domaine** (Si vous avez un domaine)
```
noreply@freeagent.app
```
ou
```
contact@freeagent.app
```

⚠️ **Important** : Si vous utilisez un email qui n'est pas d'un domaine authentifié, SendGrid enverra un email de vérification à cette adresse.

### Reply To (Répondre à)
**Mettez le même email que "From Email Address"** ou un email de support :
```
votre-email@gmail.com
```
ou
```
support@freeagent.app
```

### Company Address (Adresse de l'entreprise)
**Adresse physique requise** (obligatoire pour CAN-SPAM et CASL)

Exemple :
```
123 Rue de la République
```

### Company Address Line 2 (Ligne 2 - Optionnel)
```
Appartement 4B
```
ou laissez vide si pas nécessaire

### City (Ville)
```
Paris
```
ou votre ville

### State (État/Province)
**Si vous êtes en France** : Laissez vide ou sélectionnez "N/A" si disponible

**Si vous êtes aux États-Unis** : Sélectionnez votre état

### Zip Code (Code postal)
```
75001
```
ou votre code postal

### Country (Pays)
**Sélectionnez** : `France` (ou votre pays)

### Nickname (Surnom - Optionnel)
```
FreeAgent App
```
ou laissez vide

---

## ✅ Exemple complet

```
From Name: Free Agent
From Email Address: noreply@freeagent.app
Reply To: support@freeagent.app
Company Address: 123 Rue de la République
Company Address Line 2: (vide)
City: Paris
State: (vide ou N/A)
Zip Code: 75001
Country: France
Nickname: FreeAgent App
```

---

## 📧 Après la création

1. **SendGrid enverra un email de vérification** à l'adresse "From Email Address"
2. **Cliquez sur le lien** dans l'email pour vérifier
3. **Une fois vérifié**, vous pourrez utiliser cet expéditeur

---

## 🔧 Configuration dans Railway

Une fois le sender créé et vérifié, utilisez cet email dans Railway :

```
EMAIL_FROM=noreply@freeagent.app
```

(Remplacez par l'email que vous avez utilisé dans "From Email Address")

---

## ⚠️ Important

- **L'adresse physique est obligatoire** pour respecter les lois anti-spam
- **L'email doit être vérifié** avant de pouvoir l'utiliser
- **Vous pouvez créer plusieurs senders** si besoin

---

## 💡 Astuce

Si vous n'avez pas encore de domaine, utilisez votre email Gmail personnel pour commencer. Vous pourrez changer plus tard une fois que vous aurez un domaine.


