# ⚙️ Configuration Vercel pour FreeAgent App

## 🔧 Configuration requise dans Vercel Dashboard

Pour le projet **free-agen-app**, configurez les paramètres suivants :

### Settings → General

1. **Root Directory** : `.` (laisser vide ou mettre un point)
2. **Build Command** : `chmod +x build.sh && ./build.sh`
3. **Output Directory** : `freeagentapp/build/web`
4. **Install Command** : `echo 'Flutter dependencies will be installed by build.sh'`
5. **Framework Preset** : `Other` ou laisser vide

### Variables d'environnement

Aucune variable d'environnement spécifique n'est requise pour le build Flutter web.

## 📋 Comment ça fonctionne

1. Vercel clone le repository
2. Exécute `build.sh` qui :
   - Installe Flutter (si pas déjà présent)
   - Va dans `freeagentapp/`
   - Exécute `flutter pub get`
   - Build avec `flutter build web --release`
3. Vercel déploie depuis `freeagentapp/build/web`

## ⚠️ Note importante

Si le build échoue avec "Flutter not found", Vercel n'a peut-être pas les permissions pour installer Flutter. Dans ce cas :

### Alternative : Utiliser un environnement avec Flutter pré-installé

Vous pouvez utiliser un Dockerfile ou un buildpack qui inclut Flutter :

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .
RUN chmod +x build.sh && ./build.sh
```

## 🔍 Vérification

Après configuration, le prochain push devrait :
1. ✅ Détecter les changements
2. ✅ Exécuter le build
3. ✅ Déployer l'application

## 🚀 Test

Une fois déployé, testez :
- https://free-agen-app.vercel.app/
- Vérifiez que l'application Flutter se charge correctement


