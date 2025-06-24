const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const profileRoutes = require('./routes/profile.routes');
const teamRoutes = require('./routes/team.routes');
const playersRoutes = require('./routes/players.routes');
const clubsRoutes = require('./routes/clubs.routes');
const coachesRoutes = require('./routes/coaches.routes');
const annoncesRoutes = require('./routes/annonces.routes');
const messagesRoutes = require('./routes/messages.routes');

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/profiles', profileRoutes);
app.use('/api/teams', teamRoutes);
app.use('/api/players', playersRoutes);
app.use('/api/clubs', clubsRoutes);
app.use('/api/coaches', coachesRoutes);
app.use('/api/annonces', annoncesRoutes);
app.use('/api/messages', messagesRoutes);

// Gestion des erreurs
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Une erreur est survenue' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

module.exports = app; 