const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  // Récupérer le token du header Authorization
  const authHeader = req.headers['authorization'];
  
  console.log('Headers reçus:', req.headers);
  console.log('Authorization header:', authHeader);
  
  if (!authHeader) {
    console.log('Aucun header Authorization trouvé');
    return res.status(403).json({ message: 'Aucun token fourni' });
  }

  // Extraire le token du format "Bearer TOKEN"
  const token = authHeader.startsWith('Bearer ') 
    ? authHeader.slice(7) 
    : authHeader;
    
  console.log('Token extrait:', token ? `${token.substring(0, 20)}...` : 'null');

  if (!token) {
    console.log('Token vide après extraction');
    return res.status(403).json({ message: 'Token manquant' });
  }

  try {
    console.log('Tentative de vérification du token avec JWT_SECRET');
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Token décodé avec succès:', { id: decoded.id, email: decoded.email });
    req.user = decoded;
    next();
  } catch (error) {
    console.error('Erreur lors de la vérification du token:', error.message);
    return res.status(401).json({ message: 'Token invalide', error: error.message });
  }
};

module.exports = verifyToken; 