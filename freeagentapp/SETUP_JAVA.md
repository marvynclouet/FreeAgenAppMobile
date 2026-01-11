# ☕ Installation de Java pour créer la clé de signature

## Option 1 : Installer Java directement (Recommandé)

### Sur macOS :
```bash
# Installer avec Homebrew
brew install openjdk@11

# Ou télécharger depuis Oracle
# https://www.oracle.com/java/technologies/downloads/
```

### Vérifier l'installation :
```bash
java -version
keytool -help
```

## Option 2 : Utiliser Android Studio (Plus simple)

Android Studio inclut déjà Java. Si vous avez Android Studio installé :

1. Ouvrez Android Studio
2. Allez dans **File > Settings > Appearance & Behavior > System Settings > Android SDK**
3. Java est déjà configuré !

Vous pouvez alors créer la clé depuis le terminal d'Android Studio ou utiliser la commande complète depuis votre terminal.

---

## Créer la clé manuellement

Une fois Java installé, vous pouvez créer la clé avec :

```bash
cd freeagentapp/android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias freeagentapp -storepass FreeAgent2024!Secure -keypass FreeAgent2024!Secure -dname "CN=FreeAgent App, OU=FreeAgent, O=FreeAgent, L=Paris, ST=France, C=FR"
```

Ou utilisez le script automatisé :
```bash
./create_keystore_auto.sh
```





