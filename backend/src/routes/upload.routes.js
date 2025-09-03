const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pool = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');

const router = express.Router();

// Configuration du stockage pour multer
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadPath = path.join(__dirname, '../../uploads/profile-images');
    
    // Créer le dossier s'il n'existe pas
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    // Générer un nom de fichier unique avec timestamp
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    const filename = 'profile-' + uniqueSuffix + extension;
    cb(null, filename);
  }
});

// Configuration de multer avec filtres
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB maximum
  },
  fileFilter: function (req, file, cb) {
    console.log('FileFilter - mimetype:', file.mimetype);
    console.log('FileFilter - originalname:', file.originalname);
    
    // Extensions autorisées
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    const fileExtension = path.extname(file.originalname).toLowerCase();
    
    if (!allowedExtensions.includes(fileExtension)) {
      return cb(new Error('Extension de fichier non autorisée'));
    }
    
    // Vérifier le mimetype si disponible, sinon se fier à l'extension
    if (file.mimetype && !file.mimetype.startsWith('image/')) {
      return cb(new Error('Le fichier doit être une image'));
    }
    
    cb(null, true);
  }
});

// Configuration du stockage pour les images de post
const postImageStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadPath = path.join(__dirname, '../../uploads/post-images');
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    const filename = 'post-' + uniqueSuffix + extension;
    cb(null, filename);
  }
});

const postImageUpload = multer({
  storage: postImageStorage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max
  },
  fileFilter: function (req, file, cb) {
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    const fileExtension = path.extname(file.originalname).toLowerCase();
    if (!allowedExtensions.includes(fileExtension)) {
      return cb(new Error('Extension de fichier non autorisée'));
    }
    if (file.mimetype && !file.mimetype.startsWith('image/')) {
      return cb(new Error('Le fichier doit être une image'));
    }
    cb(null, true);
  }
});

// Route pour uploader une photo de profil
router.post('/profile-image', authMiddleware, (req, res, next) => {
  upload.single('profileImage')(req, res, (err) => {
    if (err) {
      console.error('Erreur Multer:', err.message);
      return res.status(400).json({ message: err.message });
    }
    next();
  });
}, async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Aucun fichier uploadé' });
    }
    
    console.log('Fichier uploadé:', {
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
      filename: req.file.filename
    });

    const userId = req.user.id;
    const profileType = req.user.profile_type;
    const fileName = req.file.filename;
    const imageUrl = `/uploads/profile-images/${fileName}`;

    // Supprimer l'ancienne photo si elle existe
    try {
      const [oldImageRows] = await pool.execute(
        'SELECT profile_image_url FROM users WHERE id = ?',
        [userId]
      );

      if (oldImageRows.length > 0 && oldImageRows[0].profile_image_url) {
        const oldImagePath = path.join(__dirname, '../../', oldImageRows[0].profile_image_url);
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
        }
      }
    } catch (error) {
      console.log('Erreur lors de la suppression de l\'ancienne image:', error);
    }

    // Mettre à jour l'URL de l'image dans la table users
    await pool.execute(
      'UPDATE users SET profile_image_url = ?, profile_image_uploaded_at = NOW() WHERE id = ?',
      [imageUrl, userId]
    );

    // Mettre à jour aussi dans la table du profil spécifique
    const profileTableMap = {
      'player': 'player_profiles',
      'coach_pro': 'coach_pro_profiles',
      'coach_basket': 'coach_basket_profiles',
      'juriste': 'juriste_profiles',
      'dieteticienne': 'dieteticienne_profiles',
      'club': 'club_profiles',
      'handibasket': 'handibasket_profiles'
    };

    const profileTable = profileTableMap[profileType];
    if (profileTable) {
      try {
        await pool.execute(
          `UPDATE ${profileTable} SET profile_image_url = ? WHERE user_id = ?`,
          [imageUrl, userId]
        );
      } catch (error) {
        console.log('Erreur lors de la mise à jour de la table de profil:', error);
      }
    }

    res.json({
      message: 'Photo de profil uploadée avec succès',
      imageUrl: imageUrl,
      fileName: fileName
    });

  } catch (error) {
    console.error('Erreur lors de l\'upload de la photo de profil:', error);
    res.status(500).json({ message: 'Erreur serveur lors de l\'upload' });
  }
});

// Route pour uploader une image de post
router.post('/post-image', authMiddleware, (req, res, next) => {
  postImageUpload.single('postImage')(req, res, (err) => {
    if (err) {
      console.error('Erreur Multer (post-image):', err.message);
      return res.status(400).json({ message: err.message });
    }
    next();
  });
}, async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Aucun fichier uploadé' });
    }
    const fileName = req.file.filename;
    const imageUrl = `/uploads/post-images/${fileName}`;
    res.json({
      message: 'Image de post uploadée avec succès',
      imageUrl: imageUrl,
      fileName: fileName
    });
  } catch (error) {
    console.error('Erreur lors de l\'upload de l\'image de post:', error);
    res.status(500).json({ message: 'Erreur serveur lors de l\'upload' });
  }
});

// Route pour récupérer la photo de profil actuelle
router.get('/profile-image', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    const [rows] = await pool.execute(
      'SELECT profile_image_url, profile_image_uploaded_at FROM users WHERE id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    const user = rows[0];
    
    res.json({
      imageUrl: user.profile_image_url,
      uploadedAt: user.profile_image_uploaded_at,
      hasCustomImage: !!user.profile_image_url
    });

  } catch (error) {
    console.error('Erreur lors de la récupération de la photo de profil:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour supprimer la photo de profil
router.delete('/profile-image', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const profileType = req.user.profile_type;

    // Récupérer l'URL de l'image actuelle
    const [rows] = await pool.execute(
      'SELECT profile_image_url FROM users WHERE id = ?',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    const currentImageUrl = rows[0].profile_image_url;

    // Supprimer le fichier physique
    if (currentImageUrl) {
      const imagePath = path.join(__dirname, '../../', currentImageUrl);
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }

    // Supprimer l'URL de la base de données
    await pool.execute(
      'UPDATE users SET profile_image_url = NULL, profile_image_uploaded_at = NULL WHERE id = ?',
      [userId]
    );

    // Supprimer aussi de la table du profil spécifique
    const profileTableMap = {
      'player': 'player_profiles',
      'coach_pro': 'coach_pro_profiles',
      'coach_basket': 'coach_basket_profiles',
      'juriste': 'juriste_profiles',
      'dieteticienne': 'dieteticienne_profiles',
      'club': 'club_profiles',
      'handibasket': 'handibasket_profiles'
    };

    const profileTable = profileTableMap[profileType];
    if (profileTable) {
      try {
        await pool.execute(
          `UPDATE ${profileTable} SET profile_image_url = NULL WHERE user_id = ?`,
          [userId]
        );
      } catch (error) {
        console.log('Erreur lors de la suppression dans la table de profil:', error);
      }
    }

    res.json({ message: 'Photo de profil supprimée avec succès' });

  } catch (error) {
    console.error('Erreur lors de la suppression de la photo de profil:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 