import React, { useState, useEffect } from 'react';
import { statsService } from '../services/api';
import './Dashboard.css';

interface DashboardStats {
  totalUsers: number;
  premiumUsers: number;
  activeUsers: number;
  totalOpportunities: number;
  activeOpportunities: number;
  totalConversations: number;
  recentActivity: any[];
}

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    premiumUsers: 0,
    activeUsers: 0,
    totalOpportunities: 0,
    activeOpportunities: 0,
    totalConversations: 0,
    recentActivity: []
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardStats();
  }, []);

  const loadDashboardStats = async () => {
    try {
      setLoading(true);
      const dashboardStats = await statsService.getDashboardStats();
      setStats(dashboardStats);
    } catch (error) {
      console.error('Erreur lors du chargement des statistiques:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="dashboard-container">
        <div className="loading">Chargement du tableau de bord...</div>
      </div>
    );
  }

  return (
    <div className="dashboard-container">
      <div className="dashboard-header">
        <h1>Tableau de Bord</h1>
        <p>Bienvenue dans le panneau d'administration FreeAgent</p>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon">👥</div>
          <div className="stat-content">
            <h3>Utilisateurs</h3>
            <p className="stat-number">{stats.totalUsers}</p>
            <p className="stat-change positive">Total inscrits</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">💎</div>
          <div className="stat-content">
            <h3>Abonnements Premium</h3>
            <p className="stat-number">{stats.premiumUsers}</p>
            <p className="stat-change positive">
              {stats.totalUsers > 0 ? Math.round((stats.premiumUsers / stats.totalUsers) * 100) : 0}% du total
            </p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">📢</div>
          <div className="stat-content">
            <h3>Annonces Actives</h3>
            <p className="stat-number">{stats.activeOpportunities}</p>
            <p className="stat-change positive">
              {stats.totalOpportunities > 0 ? Math.round((stats.activeOpportunities / stats.totalOpportunities) * 100) : 0}% actives
            </p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">💬</div>
          <div className="stat-content">
            <h3>Conversations</h3>
            <p className="stat-number">{stats.totalConversations}</p>
            <p className="stat-change positive">Total échanges</p>
          </div>
        </div>
      </div>

      <div className="quick-actions">
        <h2>Actions Rapides</h2>
        <div className="actions-grid">
          <div className="action-card">
            <h3>Gérer les Utilisateurs</h3>
            <p>Voir et modifier les profils utilisateurs</p>
            <a href="/users" className="action-btn">Accéder</a>
          </div>

          <div className="action-card">
            <h3>Gérer les Annonces</h3>
            <p>Modérer et gérer les opportunités</p>
            <a href="/opportunities" className="action-btn">Accéder</a>
          </div>

          <div className="action-card">
            <h3>Gérer les Messages</h3>
            <p>Surveiller les conversations</p>
            <a href="/messages" className="action-btn">Accéder</a>
          </div>

          <div className="action-card">
            <h3>Statistiques</h3>
            <p>Voir les rapports détaillés</p>
            <a href="/stats" className="action-btn">Accéder</a>
          </div>
        </div>
      </div>

      <div className="recent-activity">
        <h2>Activité Récente</h2>
        <div className="activity-list">
          {stats.recentActivity.length > 0 ? (
            stats.recentActivity.map((activity, index) => (
              <div key={index} className="activity-item">
                <div className="activity-icon">📊</div>
                <div className="activity-content">
                  <p><strong>{activity.title}</strong></p>
                  <p>{activity.description}</p>
                  <span className="activity-time">{activity.time}</span>
                </div>
              </div>
            ))
          ) : (
            <div className="activity-item">
              <div className="activity-icon">ℹ️</div>
              <div className="activity-content">
                <p><strong>Aucune activité récente</strong></p>
                <p>Les activités récentes apparaîtront ici</p>
                <span className="activity-time">En attente de données</span>
              </div>
            </div>
          )}
        </div>
      </div>

      <div className="api-status">
        <h2>Statut de l'API</h2>
        <div className="status-indicator">
          <span className="status-dot online"></span>
          <span>API connectée et fonctionnelle</span>
        </div>
        <p className="api-url">URL: https://freeagent-backend-production.up.railway.app/api</p>
      </div>
    </div>
  );
};

export default Dashboard; 