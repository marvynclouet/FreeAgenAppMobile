# 📦 Emplacement des fichiers Android

## 📱 App Bundle (AAB) - Pour Google Play Store

**Chemin complet :**
```
freeagentapp/build/app/outputs/bundle/release/app-release.aab
```

**Taille :** 84 Mo

**Utilisation :** Téléchargez ce fichier dans Google Play Console

---

## 📲 APK - Pour installation directe

**Chemin complet :**
```
freeagentapp/build/app/outputs/apk/release/app-release.apk
```

**Taille :** 68 Mo

**Utilisation :** Installation directe sur appareil Android

---

## 🚀 Accès rapide depuis le terminal

### Ouvrir le dossier AAB dans le Finder :
```bash
open freeagentapp/build/app/outputs/bundle/release/
```

### Ouvrir le dossier APK dans le Finder :
```bash
open freeagentapp/build/app/outputs/apk/release/
```

### Copier le chemin complet :
```bash
# AAB
realpath freeagentapp/build/app/outputs/bundle/release/app-release.aab

# APK
realpath freeagentapp/build/app/outputs/apk/release/app-release.apk
```

---

## 📤 Pour Google Play Console

1. Connectez-vous à [Google Play Console](https://play.google.com/console)
2. Sélectionnez votre application
3. Allez dans **Production** (ou Beta/Alpha)
4. Cliquez sur **Créer une version**
5. Cliquez sur **Télécharger les nouveaux bundles AAB**
6. Sélectionnez le fichier : `app-release.aab`

---

## ✅ Vérification

Le fichier AAB est :
- ✅ Signé avec votre clé de signature
- ✅ Prêt pour la production
- ✅ Format correct (Zip archive)

Vous pouvez le télécharger directement dans Google Play Console !




