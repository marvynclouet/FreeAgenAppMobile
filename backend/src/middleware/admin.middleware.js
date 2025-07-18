const jwt = require('jsonwebtoken');
const db = require('../database/db');

const adminMiddleware = async (req, res, next) => {
  try {
    // Vérifier le token JWT
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ message: 'Token manquant' });
    }

    // Décoder le token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    
    // Vérifier que l'utilisateur existe et est admin
    const [users] = await db.execute(
      'SELECT id, name, email, is_admin FROM users WHERE id = ?',
      [decoded.userId]
    );

    if (users.length === 0) {
      return res.status(401).json({ message: 'Utilisateur non trouvé' });
    }

    const user = users[0];
    
    if (!user.is_admin) {
      return res.status(403).json({ message: 'Accès refusé - Droits administrateur requis' });
    }

    // Ajouter les informations utilisateur à la requête
    req.user = user;
    next();
  } catch (error) {
    console.error('Erreur admin middleware:', error);
    res.status(401).json({ message: 'Token invalide' });
  }
};

module.exports = adminMiddleware; 