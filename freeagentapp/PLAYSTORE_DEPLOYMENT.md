# 📱 Guide de Déploiement sur Google Play Store

## 📋 Prérequis

1. **Compte Google Play Developer** : 
   - Créez un compte sur [Google Play Console](https://play.google.com/console)
   - Frais d'inscription : 25$ USD (paiement unique)

2. **Flutter SDK** installé et configuré
3. **Java JDK** installé (pour la signature)

---

## 🔐 Étape 1 : Créer une Clé de Signature

### 1.1 Générer la clé de signature

Exécutez cette commande dans le terminal (remplacez les informations par les vôtres) :

```bash
cd freeagentapp/android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias freeagentapp
```

**Informations à remplir :**
- **Mot de passe du keystore** : Choisissez un mot de passe fort (gardez-le en sécurité !)
- **Mot de passe de la clé** : Peut être le même que le keystore
- **Nom et prénom** : Votre nom
- **Unité organisationnelle** : Nom de votre organisation (ou votre nom)
- **Organisation** : Nom de votre organisation
- **Ville** : Votre ville
- **État/Région** : Votre région
- **Code pays** : FR (pour la France)

⚠️ **IMPORTANT** : Sauvegardez cette clé dans un endroit sûr. Vous en aurez besoin pour toutes les mises à jour futures !

### 1.2 Créer le fichier key.properties

Créez le fichier `freeagentapp/android/key.properties` avec ce contenu :

```properties
storePassword=votre_mot_de_passe_keystore
keyPassword=votre_mot_de_passe_cle
keyAlias=freeagentapp
storeFile=../upload-keystore.jks
```

⚠️ **Ne commitez JAMAIS ce fichier dans Git !** Ajoutez-le au `.gitignore`

---

## ⚙️ Étape 2 : Configurer le Build

### 2.1 Mettre à jour build.gradle.kts

Le fichier `android/app/build.gradle.kts` a été mis à jour pour utiliser la clé de signature.

### 2.2 Mettre à jour l'Application ID

Modifiez `android/app/build.gradle.kts` pour changer l'Application ID :

```kotlin
applicationId = "com.votreentreprise.freeagentapp"  // Remplacez par votre propre ID unique
```

**Règles pour l'Application ID :**
- Format : `com.votredomaine.nomapp`
- Doit être unique dans tout le Play Store
- Une fois publié, vous ne pouvez plus le changer !

### 2.3 Mettre à jour le nom de l'application

Modifiez `android/app/src/main/AndroidManifest.xml` :

```xml
<application
    android:label="FreeAgent"  <!-- Nom affiché sur le Play Store -->
    ...
```

---

## 📦 Étape 3 : Construire l'App Bundle (AAB)

Google Play Store requiert un **App Bundle (AAB)** et non un APK.

### 3.1 Construire l'AAB

```bash
cd freeagentapp
flutter build appbundle --release
```

L'AAB sera généré dans : `freeagentapp/build/app/outputs/bundle/release/app-release.aab`

### 3.2 Vérifier la taille

Vérifiez que le fichier a été créé :

```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

---

## 🎨 Étape 4 : Préparer les Métadonnées du Play Store

### 4.1 Icône de l'application

- **512x512 pixels** (PNG, sans transparence)
- Créez une icône haute qualité représentant votre application
- Placez-la dans `freeagentapp/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### 4.2 Images requises pour le Play Store

Préparez ces images (format PNG, JPG ou WebP) :

1. **Icône haute résolution** : 512x512 px
2. **Capture d'écran de téléphone** : 
   - Au moins 2, maximum 8
   - Ratio 16:9 ou 9:16
   - Résolution minimale : 320px
   - Résolution maximale : 3840px
3. **Graphique de présentation** (optionnel) : 1024x500 px
4. **Bannière promotionnelle** (optionnel) : 180x120 px

### 4.3 Texte pour la fiche Play Store

Préparez :
- **Titre de l'application** (max 50 caractères)
- **Description courte** (max 80 caractères)
- **Description complète** (max 4000 caractères)
- **Mots-clés** (pour améliorer la découvrabilité)

**Exemple :**
- **Titre** : FreeAgent - Plateforme de Basketball
- **Description courte** : Connectez-vous avec des joueurs, équipes et coachs de basketball
- **Description complète** : 
```
FreeAgent est la plateforme de référence pour les joueurs de basketball...
[Votre description complète ici]
```

---

## 📤 Étape 5 : Soumettre sur Google Play Console

### 5.1 Créer une nouvelle application

1. Connectez-vous à [Google Play Console](https://play.google.com/console)
2. Cliquez sur **"Créer une application"**
3. Remplissez les informations de base :
   - **Nom de l'application**
   - **Langue par défaut**
   - **Type d'application** : Application
   - **Distribution gratuite ou payante** : Choisissez selon votre modèle

### 5.2 Remplir le contenu de la fiche

Dans l'onglet **"Contenu de la fiche"** :

1. **Graphiques de l'application** :
   - Téléchargez l'icône haute résolution
   - Ajoutez vos captures d'écran (minimum 2)

2. **Titre et description** :
   - Ajoutez le titre (max 50 caractères)
   - Description courte (max 80 caractères)
   - Description complète (max 4000 caractères)

3. **Catégorie** :
   - Choisissez **Sport** ou **Social**

4. **Contact** :
   - Email de contact
   - URL du site web (si applicable)
   - Numéro de téléphone (optionnel)

### 5.3 Télécharger l'AAB

Dans l'onglet **"Production"** (ou "Bêta" / "Alpha" pour tester) :

1. Cliquez sur **"Créer une version"**
2. Cliquez sur **"Télécharger les nouveaux bundles AAB"**
3. Sélectionnez le fichier `app-release.aab`
4. Remplissez les **Notes de version** (description des changements)

### 5.4 Renseigner les Informations sur le contenu

- **Évaluation du contenu** : Répondez aux questions sur le contenu de votre application
- **Cible d'âge** : Sélectionnez la tranche d'âge appropriée
- **Politique de confidentialité** : URL vers votre politique de confidentialité (obligatoire si vous collectez des données)

### 5.5 Prix et distribution

- Choisissez si l'application est **gratuite** ou **payante**
- Sélectionnez les **pays de distribution**
- Configurez les **tarifs** (si payant)

### 5.6 Soumettre pour examen

1. Vérifiez que toutes les sections sont complétées (icônes vertes ✅)
2. Cliquez sur **"Examiner la version"**
3. Cliquez sur **"Lancer la production"**

---

## ⏱️ Temps d'Examen

- **Première soumission** : Généralement 1-3 jours
- **Mises à jour** : Généralement quelques heures à 1 jour
- Google vérifie que votre application respecte les [Politiques du Play Store](https://play.google.com/about/developer-content-policy/)

---

## 🔄 Mises à jour Futures

Pour chaque nouvelle version :

1. **Incrémentez le numéro de version** dans `pubspec.yaml` :
   ```yaml
   version: 1.0.1+2  # Version + Numéro de build
   ```

2. **Construisez le nouveau bundle** :
   ```bash
   flutter build appbundle --release
   ```

3. **Téléchargez sur Play Console** dans l'onglet Production > Nouvelle version

---

## ⚠️ Points Importants

### Sécurité de la Clé
- **Sauvegardez votre clé de signature** dans plusieurs endroits sûrs
- Si vous perdez la clé, vous ne pourrez plus mettre à jour votre application
- Considérez utiliser un service de gestion de clés (Google Cloud, AWS Secrets Manager)

### Politique de Confidentialité
- Obligatoire si vous collectez des données utilisateur
- Créez une page sur votre site web avec votre politique
- Ajoutez l'URL dans les paramètres de l'application

### Permissions
- Vérifiez que toutes les permissions demandées sont justifiées
- Documentez pourquoi votre application a besoin de chaque permission

### Tests
- Testez votre application sur différents appareils avant la soumission
- Utilisez le canal **Alpha** ou **Bêta** pour tester avec des utilisateurs réels

---

## 📚 Ressources Utiles

- [Documentation Flutter - Android Release](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [Politiques du Play Store](https://play.google.com/about/developer-content-policy/)
- [Checklist de Publication](https://support.google.com/googleplay/android-developer/answer/9888170)

---

## 🆘 Problèmes Courants

### Erreur : "App Bundle not signed"
→ Vérifiez que votre fichier `key.properties` est correct et que la clé existe

### Erreur : "Version code already used"
→ Incrémentez le `versionCode` dans `pubspec.yaml`

### Application rejetée
→ Lisez les commentaires de Google et corrigez les problèmes mentionnés

---

Bon courage pour votre publication ! 🚀





