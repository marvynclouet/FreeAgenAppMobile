# 📸 Guide - Système de Photos de Profil

## 🎯 Fonctionnalités

### ✅ **Système Complet Implémenté**
- ✅ Upload de photos de profil personnalisées
- ✅ Gestion des formats d'image (JPG, PNG, GIF, WebP)
- ✅ Limite de taille (5MB maximum)
- ✅ Suppression des photos existantes
- ✅ Interface utilisateur intuitive
- ✅ Intégration avec tous les types de profils

---

## 📱 **Utilisation dans l'App**

### **1. Accès à la Page de Photo de Profil**
- Depuis la page **Profil**, cliquez sur l'icône 📷 dans la barre d'outils
- Ou naviguez vers `ProfilePhotoPage` depuis votre code

### **2. Actions Disponibles**
- **Ajouter une photo** : Depuis galerie ou caméra
- **Changer la photo** : Remplacer l'image existante
- **Supprimer la photo** : Retirer l'image personnalisée

### **3. Sources d'Images**
- **Galerie** : Sélectionner depuis les photos existantes
- **Caméra** : Prendre une nouvelle photo instantanément

---

## 🛠 **Structure Technique**

### **Backend (Node.js)**
```
backend/src/routes/upload.routes.js    # Routes d'upload
backend/uploads/profile-images/        # Dossier de stockage
```

### **Frontend (Flutter)**
```
lib/profile_photo_page.dart           # Page de gestion des photos
lib/services/profile_photo_service.dart # Service de gestion
```

### **Base de Données**
```sql
-- Colonnes ajoutées automatiquement
users.profile_image_url               # URL de l'image
users.profile_image_uploaded_at       # Date d'upload
*_profiles.profile_image_url          # URL dans chaque table de profil
```

---

## 🔧 **API Endpoints**

### **Upload de Photo**
```
POST /api/upload/profile-image
Content-Type: multipart/form-data
Authorization: Bearer <token>

Body: profileImage (file)
```

### **Récupération de Photo**
```
GET /api/upload/profile-image
Authorization: Bearer <token>
```

### **Suppression de Photo**
```
DELETE /api/upload/profile-image
Authorization: Bearer <token>
```

---

## ⚠️ **Contraintes et Limitations**

### **Formats Acceptés**
- JPG / JPEG ✅
- PNG ✅
- GIF ✅
- WebP ✅

### **Taille Maximum**
- **5MB** par image
- Images automatiquement redimensionnées (800x800px)
- Qualité ajustée à 85%

### **Sécurité**
- Authentification obligatoire
- Validation des types de fichiers
- Nettoyage automatique des anciennes images

---

## 🚀 **Démarrage Rapide**

### **1. Backend**
```bash
cd backend
npm install multer  # Déjà installé
npm start
```

### **2. Flutter**
```bash
cd freeagentapp
flutter pub get     # Dépendances déjà ajoutées
flutter run
```

### **3. Base de Données**
Les colonnes ont été ajoutées automatiquement. Vérifiez avec :
```sql
DESCRIBE users;
DESCRIBE player_profiles;
```

---

## 🎨 **Personnalisation**

### **Changer la Taille Maximum**
```javascript
// backend/src/routes/upload.routes.js
limits: {
  fileSize: 10 * 1024 * 1024, // 10MB au lieu de 5MB
},
```

### **Ajouter de Nouveaux Formats**
```javascript
// backend/src/routes/upload.routes.js
const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
```

### **Modifier la Qualité d'Image**
```dart
// freeagentapp/lib/profile_photo_page.dart
imageQuality: 95, // Au lieu de 85
```

---

## 📊 **Utilisation des Photos**

### **Affichage dans l'Interface**
```dart
// Exemple d'utilisation dans une page
Widget buildProfileAvatar() {
  return FutureBuilder<Map<String, dynamic>?>(
    future: ProfilePhotoService.getCurrentProfileImage(),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data?['imageUrl'] != null) {
        return CircleAvatar(
          backgroundImage: NetworkImage(
            ProfilePhotoService.getFullImageUrl(snapshot.data?['imageUrl']),
          ),
        );
      }
      return CircleAvatar(
        child: Icon(Icons.person),
      );
    },
  );
}
```

### **Vérification d'Existence**
```dart
// Vérifier si l'utilisateur a une photo personnalisée
bool hasCustomPhoto = await ProfilePhotoService.hasCustomProfileImage();
```

---

## 🔍 **Dépannage**

### **Erreur d'Upload**
- Vérifiez que le serveur backend est démarré
- Vérifiez que le dossier `uploads/profile-images` existe
- Vérifiez la taille du fichier (< 5MB)

### **Image non Affichée**
- Vérifiez l'URL complète : `http://localhost:3000/uploads/profile-images/...`
- Vérifiez que les fichiers statiques sont servis correctement

### **Erreur de Base de Données**
- Vérifiez que les colonnes `profile_image_url` existent
- Exécutez le script SQL si nécessaire

---

## 📈 **Prochaines Améliorations**

### **Fonctionnalités Futures**
- [ ] Compression d'image côté client
- [ ] Stockage cloud (AWS S3, Google Cloud)
- [ ] Filtres et effets d'image
- [ ] Recadrage automatique
- [ ] Modération automatique du contenu

### **Optimisations**
- [ ] Cache des images
- [ ] Génération de miniatures
- [ ] Lazy loading
- [ ] Progressive loading

---

## 🎉 **Résumé**

Le système de photos de profil est maintenant **entièrement fonctionnel** ! 

### **✅ Fonctionnalités Opérationnelles**
- Upload depuis galerie ou caméra
- Gestion complète des images
- Intégration avec tous les profils
- Sécurité et validation des fichiers
- Interface utilisateur intuitive

### **🔧 Prêt à l'Emploi**
- Backend configuré et opérationnel
- Frontend intégré à l'application
- Base de données mise à jour
- API endpoints fonctionnels

**Votre app FreeAgent supporte maintenant les photos de profil personnalisées !** 🎯 