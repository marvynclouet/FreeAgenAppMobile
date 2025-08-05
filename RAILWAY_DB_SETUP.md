# 🔧 **Configuration de la base de données Railway**

## 📋 **Étapes pour configurer MYSQL_URL :**

### **1. Allez sur Railway Dashboard**
https://railway.app/dashboard

### **2. Sélectionnez votre projet FreeAgent**

### **3. Allez dans "Variables"**
- Cliquez sur l'onglet "Variables" dans votre projet

### **4. Ajoutez la variable MYSQL_URL**
- **Nom de la variable** : `MYSQL_URL`
- **Valeur** : `${{ MySQL.MYSQL_URL }}`

### **5. Sauvegardez et redéployez**
- Cliquez "Save"
- Railway redéploiera automatiquement votre service

## 🔍 **Vérification :**

Après avoir ajouté la variable, vous devriez voir :
- ✅ **Variable MYSQL_URL** dans la liste
- ✅ **Service redéployé** automatiquement
- ✅ **Connexion à la base de données** établie

## 🚀 **Mise à jour du mot de passe :**

Une fois MYSQL_URL configurée :

```bash
# Exécuter le script de mise à jour
node update_password_with_env.js
```

## 📧 **Identifiants finaux :**
- **Email** : `marvyn@gmail.com`
- **Mot de passe** : `Marvyn2024!`

## 🔗 **URL de connexion :**
https://web-na4p0oz7o-marvynshes-projects.vercel.app/

---

**💡 Cette configuration permettra à votre service de se connecter directement à la base de données MySQL de Railway.** 