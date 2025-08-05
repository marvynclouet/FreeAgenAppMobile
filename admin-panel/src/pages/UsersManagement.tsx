import React, { useState, useEffect } from 'react';
import type { User, UserFilters } from '../types';
import { userService } from '../services/api';
import './UsersManagement.css';

const UsersManagement: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState<UserFilters>({
    search: '',
    profileType: '',
    subscriptionType: '',
    isActive: null
  });

  useEffect(() => {
    loadUsers();
  }, []);

  useEffect(() => {
    filterUsers();
  }, [users, filters]);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const data = await userService.getUsers();
      setUsers(data);
    } catch (error) {
      console.error('Erreur lors du chargement des utilisateurs:', error);
    } finally {
      setLoading(false);
    }
  };

  const filterUsers = () => {
    let filtered = [...users];

    // Filtre par recherche
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      filtered = filtered.filter(user =>
        user.first_name.toLowerCase().includes(searchLower) ||
        user.last_name.toLowerCase().includes(searchLower) ||
        user.email.toLowerCase().includes(searchLower)
      );
    }

    // Filtre par type de profil
    if (filters.profileType) {
      filtered = filtered.filter(user => user.profile_type === filters.profileType);
    }

    // Filtre par type d'abonnement
    if (filters.subscriptionType) {
      filtered = filtered.filter(user => user.subscription_type === filters.subscriptionType);
    }

    // Filtre par statut actif
    if (filters.isActive !== null) {
      filtered = filtered.filter(user => user.is_active === filters.isActive);
    }

    setFilteredUsers(filtered);
  };

  const handleSubscriptionChange = async (userId: number, newType: 'free' | 'premium') => {
    try {
      await userService.updateUserSubscription(userId, newType);
      await loadUsers(); // Recharger les données
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error);
    }
  };

  const handleStatusToggle = async (userId: number) => {
    try {
      await userService.toggleUserStatus(userId);
      await loadUsers(); // Recharger les données
    } catch (error) {
      console.error('Erreur lors du changement de statut:', error);
    }
  };

  const handleDeleteUser = async (userId: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) {
      try {
        await userService.deleteUser(userId);
        await loadUsers(); // Recharger les données
      } catch (error) {
        console.error('Erreur lors de la suppression:', error);
      }
    }
  };

  const getProfileTypeLabel = (type: string) => {
    const labels = {
      player: 'Joueur',
      coach: 'Coach',
      club: 'Club',
      team: 'Équipe'
    };
    return labels[type as keyof typeof labels] || type;
  };

  const getSubscriptionBadge = (type: string) => {
    return type === 'premium' ? 'premium-badge' : 'free-badge';
  };

  const getStatusBadge = (isActive: boolean) => {
    return isActive ? 'active-badge' : 'inactive-badge';
  };

  if (loading) {
    return (
      <div className="users-container">
        <div className="loading">Chargement des utilisateurs...</div>
      </div>
    );
  }

  return (
    <div className="users-container">
      <div className="users-header">
        <h1>Gestion des Utilisateurs</h1>
        <p>Gérez les utilisateurs et leurs abonnements</p>
      </div>

      {/* Filtres */}
      <div className="filters-section">
        <div className="search-box">
          <input
            type="text"
            placeholder="Rechercher par nom ou email..."
            value={filters.search}
            onChange={(e) => setFilters({ ...filters, search: e.target.value })}
            className="search-input"
          />
        </div>

        <div className="filter-controls">
          <select
            value={filters.profileType}
            onChange={(e) => setFilters({ ...filters, profileType: e.target.value })}
            className="filter-select"
          >
            <option value="">Tous les types de profil</option>
            <option value="player">Joueurs</option>
            <option value="coach">Coachs</option>
            <option value="club">Clubs</option>
            <option value="team">Équipes</option>
          </select>

          <select
            value={filters.subscriptionType}
            onChange={(e) => setFilters({ ...filters, subscriptionType: e.target.value })}
            className="filter-select"
          >
            <option value="">Tous les abonnements</option>
            <option value="free">Gratuit</option>
            <option value="premium">Premium</option>
          </select>

          <select
            value={filters.isActive === null ? '' : filters.isActive.toString()}
            onChange={(e) => setFilters({ 
              ...filters, 
              isActive: e.target.value === '' ? null : e.target.value === 'true' 
            })}
            className="filter-select"
          >
            <option value="">Tous les statuts</option>
            <option value="true">Actif</option>
            <option value="false">Inactif</option>
          </select>
        </div>
      </div>

      {/* Statistiques */}
      <div className="stats-section">
        <div className="stat-card">
          <h3>Total</h3>
          <p>{filteredUsers.length}</p>
        </div>
        <div className="stat-card">
          <h3>Premium</h3>
          <p>{filteredUsers.filter(u => u.subscription_type === 'premium').length}</p>
        </div>
        <div className="stat-card">
          <h3>Actifs</h3>
          <p>{filteredUsers.filter(u => u.is_active).length}</p>
        </div>
      </div>

      {/* Liste des utilisateurs */}
      <div className="users-list">
        {filteredUsers.length === 0 ? (
          <div className="no-results">
            Aucun utilisateur trouvé avec ces critères
          </div>
        ) : (
          filteredUsers.map(user => (
            <div key={user.id} className="user-card">
              <div className="user-info">
                <img 
                  src={user.profile_image || 'https://via.placeholder.com/50'} 
                  alt="Profile" 
                  className="user-avatar"
                />
                <div className="user-details">
                  <h3>{user.first_name} {user.last_name}</h3>
                  <p className="user-email">{user.email}</p>
                  <div className="user-badges">
                    <span className={`profile-badge ${user.profile_type}`}>
                      {getProfileTypeLabel(user.profile_type)}
                    </span>
                    <span className={`subscription-badge ${getSubscriptionBadge(user.subscription_type)}`}>
                      {user.subscription_type === 'premium' ? 'Premium' : 'Gratuit'}
                    </span>
                    <span className={`status-badge ${getStatusBadge(user.is_active)}`}>
                      {user.is_active ? 'Actif' : 'Inactif'}
                    </span>
                  </div>
                </div>
              </div>

              <div className="user-actions">
                <select
                  value={user.subscription_type}
                  onChange={(e) => handleSubscriptionChange(user.id, e.target.value as 'free' | 'premium')}
                  className="subscription-select"
                >
                  <option value="free">Gratuit</option>
                  <option value="premium">Premium</option>
                </select>

                <button
                  onClick={() => handleStatusToggle(user.id)}
                  className={`status-toggle ${user.is_active ? 'deactivate' : 'activate'}`}
                >
                  {user.is_active ? 'Désactiver' : 'Activer'}
                </button>

                <button
                  onClick={() => handleDeleteUser(user.id)}
                  className="delete-btn"
                >
                  Supprimer
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default UsersManagement; 