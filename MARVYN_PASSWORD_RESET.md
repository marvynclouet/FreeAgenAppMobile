# 🔐 **Récupération du mot de passe Marvyn@gmail.com**

## ✅ **Votre compte existe !**

Le compte `Marvyn@gmail.com` est bien présent dans la base de données Railway.

## 🔧 **Solutions pour récupérer le mot de passe :**

### **Option 1 : Nouveau mot de passe (Recommandée)**

**Nouveaux identifiants :**
- **Email** : `Marvyn@gmail.com`
- **Mot de passe** : `Marvyn2024!`

**URL de connexion :**
https://web-na4p0oz7o-marvynshes-projects.vercel.app/

### **Option 2 : Via Dashboard Railway**

1. **Allez sur** : https://railway.app/dashboard
2. **Sélectionnez votre projet** FreeAgent
3. **Allez dans** : `Database` → `Query`
4. **Exécutez cette requête SQL :**

```sql
UPDATE users 
SET password = '$2b$10$YourHashedPasswordHere' 
WHERE email = 'Marvyn@gmail.com';
```

### **Option 3 : Créer un nouveau compte**

Si vous ne vous souvenez plus de l'ancien mot de passe :
1. **Allez sur** l'app
2. **Cliquez** "S'inscrire"
3. **Créez** un nouveau compte avec un nouvel email

## 📱 **Test de connexion :**

```bash
curl -X POST https://freeagenappmobile-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"Marvyn@gmail.com","password":"Marvyn2024!"}'
```

## 🎯 **Résultat attendu :**

- ✅ **Connexion réussie**
- ✅ **Token JWT généré**
- ✅ **Accès à toutes les fonctionnalités**

---

**💡 Conseil : Utilisez le nouveau mot de passe `Marvyn2024!` pour vous connecter !** 