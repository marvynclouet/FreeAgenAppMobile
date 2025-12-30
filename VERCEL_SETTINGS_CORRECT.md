# ⚙️ Configuration Vercel Correcte

## 🔧 Settings → General

### Root Directory
**Mettre :** `.` (un point) **OU laisser VIDE**

❌ **NE PAS mettre :** `freeagentapp/build/web`

Le Root Directory est l'endroit où Vercel cherche le code source. Puisque notre build est déjà dans le repo, on veut que Vercel parte de la racine.

### Output Directory
**Mettre :** `freeagentapp/build/web`

C'est ici que Vercel va chercher les fichiers à déployer.

### Build Command
**Mettre :** `echo 'Build already present'` **OU laisser VIDE**

Puisque le build est déjà commité, pas besoin de builder.

### Install Command
**Mettre :** `echo 'No install needed'` **OU laisser VIDE**

Pas besoin d'installer quoi que ce soit.

### Framework Preset
**Mettre :** `Other` **OU laisser VIDE**

## ✅ Configuration Recommandée

```
Root Directory: . (ou vide)
Output Directory: freeagentapp/build/web
Build Command: (vide ou echo 'Build present')
Install Command: (vide ou echo 'No install')
Framework Preset: Other (ou vide)
```

## 📝 Note

Le fichier `vercel.json` à la racine devrait déjà contenir ces paramètres. Vercel devrait les utiliser automatiquement, mais vous pouvez aussi les définir manuellement dans le dashboard.

