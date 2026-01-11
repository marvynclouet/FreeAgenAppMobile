# ✅ Configuration Railway Corrigée

## 🔧 Modification effectuée

L'URL du backend a été mise à jour pour utiliser **Railway** au lieu de Vercel dans le fichier `config.dart`.

### Avant :
```
https://backend-8j28fyxhz-marvynshes-projects.vercel.app/api
```

### Après :
```
https://freeagenappmobile-production.up.railway.app/api
```

---

## 📱 Étapes pour publier la nouvelle version sur le Play Store

### 1. Recompiler l'application Android

```bash
cd freeagentapp
flutter build appbundle --release
```

Le fichier AAB sera généré dans :
```
freeagentapp/build/app/outputs/bundle/release/app-release.aab
```

### 2. Vérifier le fichier AAB

Assurez-vous que le fichier existe :
```bash
ls -lh freeagentapp/build/app/outputs/bundle/release/app-release.aab
```

### 3. Uploader sur Google Play Console

1. **Allez sur Google Play Console**
   - https://play.google.com/console
   - Sélectionnez votre application "FreeAgent"

2. **Créez une nouvelle version**
   - Menu de gauche → **"Production"** (ou **"Testing"** pour tester d'abord)
   - Cliquez sur **"Créer une nouvelle version"**

3. **Ajoutez le nouveau AAB**
   - Cliquez sur **"Uploader une nouvelle version"**
   - Sélectionnez le fichier `app-release.aab` depuis :
     ```
     freeagentapp/build/app/outputs/bundle/release/app-release.aab
     ```

4. **Remplissez les informations de version**
   - Version code : Incrémentez-le (ex: si c'était 1, mettez 2)
   - Notes de version : "Correction de l'URL du backend - utilisation de Railway"

5. **Sauvegardez et soumettez**
   - Cliquez sur **"Enregistrer"**
   - Puis **"Soumettre pour examen"**

---

## ✅ Vérification

Une fois la nouvelle version publiée :

1. **Désinstallez l'ancienne version** de votre téléphone
2. **Installez la nouvelle version** depuis le Play Store
3. **Testez la connexion** avec vos identifiants

L'erreur `FormatException: Unexpected character (at character 1) <!doctype html>` devrait être résolue car l'application se connecte maintenant directement à Railway qui renvoie du JSON.

---

## 🧪 Test de l'API Railway

Pour vérifier que l'API Railway fonctionne :

```bash
curl https://freeagenappmobile-production.up.railway.app/api/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test","password":"test"}'
```

Vous devriez recevoir :
```json
{"message":"Email ou mot de passe incorrect"}
```

C'est normal ! Cela signifie que l'API répond bien en JSON (pas en HTML).

---

## 📝 Notes

- ✅ L'URL Railway est maintenant configurée dans `freeagentapp/lib/services/config.dart`
- ✅ Tous les services utilisent automatiquement cette URL via `ApiConfig.baseUrl`
- ✅ Le build Android a été nettoyé (flutter clean)
- ✅ Prêt pour la recompilation et le redéploiement

---

## 🚀 Commande rapide pour rebuild et test

```bash
cd freeagentapp

# Nettoyer (déjà fait)
flutter clean

# Build l'AAB
flutter build appbundle --release

# Le fichier est prêt dans :
# build/app/outputs/bundle/release/app-release.aab
```

---

**Une fois l'AAB uploadé sur le Play Store, attendez que la version soit approuvée, puis testez la connexion !** 🎉



