# 🔧 Guide Rapide - Corriger l'Erreur 401 Vercel

## 🚨 **Problème : Écran blanc + Erreur 401**

```
Uncaught SyntaxError: Unexpected token '<'
manifest.json:1 Failed to load resource: the server responded with a status of 401
```

## ✅ **Solution 1 : Script Automatique**

```bash
./fix_vercel_401.sh
```

## 🔧 **Solution 2 : Manuel (Interface Web)**

### **Étapes :**

1. **Allez sur Vercel Dashboard**
   - https://vercel.com/dashboard
   - Connectez-vous si nécessaire

2. **Trouvez votre projet**
   - Cherchez `free-agen-app` ou similaire
   - Cliquez dessus

3. **Allez dans Settings**
   - Onglet **Settings** en haut
   - Section **Security** dans le menu

4. **Désactivez la protection**
   - Trouvez **"Deployment Protection"**
   - Changez de **"Standard Protection"** à **"No Protection"**
   - Cliquez **Save**

5. **Redéployez**
   - Allez dans **Deployments**
   - Cliquez **"Redeploy"** sur le dernier déploiement

## 🚀 **Solution 3 : Nouveau Déploiement**

```bash
# 1. Nettoyer et rebuild
./deploy_vercel_complete.sh

# 2. Déployer avec accès public
vercel --prod --public
```

## 📱 **Vérification**

Après avoir appliqué une solution :

```bash
# Vérifier le statut
vercel ls

# Tester l'URL
curl -I [VOTRE_URL_VERCEL]
```

**Attendu :** `HTTP/2 200` au lieu de `HTTP/2 401`

## 🎯 **URLs à tester**

- Page principale : `https://[votre-url].vercel.app/`
- Manifest : `https://[votre-url].vercel.app/manifest.json`
- Assets : `https://[votre-url].vercel.app/assets/`

## ⚠️ **Notes importantes**

- **La protection Vercel** bloque l'accès public par défaut
- **"No Protection"** = accès public complet
- **"Standard Protection"** = authentification requise
- **Redéploiement nécessaire** après changement de protection

## 🔄 **Workflow Recommandé**

1. **Développement** : Protection activée
2. **Test** : Protection désactivée temporairement
3. **Production** : Protection selon vos besoins

## 📞 **Support**

Si le problème persiste :
1. Vérifiez les logs : `vercel logs`
2. Testez localement : `vercel dev`
3. Contactez le support Vercel 