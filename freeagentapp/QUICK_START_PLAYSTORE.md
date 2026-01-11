# 🚀 Démarrage Rapide - Déploiement Play Store

## Étapes Rapides (15 minutes)

### 1. Créer une clé de signature (5 min)

```bash
cd android
./create_keystore.sh
```

Suivez les instructions et **notez les mots de passe** !

### 2. Créer le fichier key.properties (2 min)

Créez `android/key.properties` avec ce contenu :

```properties
storePassword=votre_mot_de_passe_keystore
keyPassword=votre_mot_de_passe_cle
keyAlias=freeagentapp
storeFile=../upload-keystore.jks
```

### 3. Construire l'AAB (5 min)

```bash
cd ..  # Retour au dossier freeagentapp
./build_release.sh
```

Le fichier AAB sera dans : `build/app/outputs/bundle/release/app-release.aab`

### 4. Créer un compte Play Console (3 min)

1. Allez sur [Google Play Console](https://play.google.com/console)
2. Créez un compte développeur (25$ USD, paiement unique)
3. Acceptez les conditions

### 5. Soumettre l'application

1. Créez une nouvelle application dans Play Console
2. Remplissez les métadonnées (titre, description, images)
3. Téléchargez le fichier `app-release.aab`
4. Soumettez pour examen

---

## ⚠️ Important Avant de Publier

1. **Changez l'Application ID** dans `android/app/build.gradle.kts` :
   ```kotlin
   applicationId = "com.votredomaine.freeagentapp"  // Remplacez par votre propre ID
   ```

2. **Mettez à jour le nom de l'app** dans `android/app/src/main/AndroidManifest.xml` :
   ```xml
   android:label="FreeAgent"
   ```

3. **Préparez les images** :
   - Icône 512x512 px
   - Au moins 2 captures d'écran (16:9 ou 9:16)

4. **Créez une politique de confidentialité** (obligatoire si vous collectez des données)

---

## 📚 Documentation Complète

Consultez `PLAYSTORE_DEPLOYMENT.md` pour le guide détaillé complet.

---

## 🆘 Besoin d'aide ?

- [Documentation Flutter Android](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)





