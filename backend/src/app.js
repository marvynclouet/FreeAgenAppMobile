const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir les fichiers statiques uploadés
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

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
const handibasketRoutes = require('./routes/handibasket.routes');
const handibasketTeamsRoutes = require('./routes/handibasket_teams.routes');
const adminRoutes = require('./routes/admin.routes');
const subscriptionRoutes = require('./routes/subscription.routes');
// const paymentRoutes = require('./routes/payment.routes'); // Désactivé temporairement
const storeRoutes = require('./routes/store.routes');
const uploadRoutes = require('./routes/upload.routes');
const matchingRoutes = require('./routes/matching.routes');
const contentRoutes = require('./routes/content.routes');
const opportunityRoutes = require('./routes/opportunity.routes');

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/profiles', profileRoutes);
app.use('/api/teams', teamRoutes);
app.use('/api/players', playersRoutes);
app.use('/api/clubs', clubsRoutes);
app.use('/api/coaches', coachesRoutes);
app.use('/api/annonces', annoncesRoutes);
app.use('/api/messages', messagesRoutes);
app.use('/api/handibasket', handibasketRoutes);
app.use('/api/handibasket-teams', handibasketTeamsRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
// app.use('/api/payments', paymentRoutes); // Désactivé temporairement
app.use('/api/store', storeRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/matching', matchingRoutes);
app.use('/api/opportunities', opportunityRoutes);
app.use('/api/content', contentRoutes);
app.use('/api/admin', adminRoutes);

// Route de healthcheck pour Railway
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: '2.0-handibasket-fix'
  });
});

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: '2.0-handibasket-fix'
  });
});

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