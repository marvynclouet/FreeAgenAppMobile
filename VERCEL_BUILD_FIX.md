# 🔧 Correction du build Vercel

## 🚨 Problème

Vercel essaie de déployer depuis `freeagentapp/build/web` mais ce dossier n'existe pas dans le repository car :
- Il est dans `.gitignore` (normal, on ne commit pas les builds)
- Flutter doit être buildé avant le déploiement

## ✅ Solution

J'ai créé :
1. **`build.sh`** - Script qui build Flutter automatiquement
2. **`vercel.json`** mis à jour - Configuration pour utiliser le script de build

## 📋 Configuration Vercel

Dans le dashboard Vercel, pour le projet `free-agen-app`, configurez :

### Settings → General

- **Root Directory** : `.` (racine du projet)
- **Build Command** : `chmod +x build.sh && ./build.sh`
- **Output Directory** : `freeagentapp/build/web`
- **Install Command** : `echo 'Skipping install'` (Flutter gère ses propres dépendances)

### Alternative : Configuration via vercel.json

Le fichier `vercel.json` à la racine contient déjà cette configuration. Vercel devrait l'utiliser automatiquement.

## 🔍 Vérification

Après le prochain push, Vercel devrait :
1. Cloner le repository
2. Exécuter `build.sh`
3. Builder Flutter web
4. Déployer depuis `freeagentapp/build/web`

## ⚠️ Note importante

Vercel doit avoir Flutter installé. Si ce n'est pas le cas, vous devrez :
1. Utiliser un buildpack Flutter
2. Ou configurer un environnement avec Flutter pré-installé

## 🚀 Alternative : Build local et commit (non recommandé)

Si le build automatique ne fonctionne pas, vous pouvez builder localement :

```bash
cd freeagentapp
flutter build web --release
git add build/web
git commit -m "Add Flutter web build"
git push
```

Mais ce n'est **pas recommandé** car cela pollue le repository avec des fichiers générés.

