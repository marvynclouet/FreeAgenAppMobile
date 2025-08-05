import React, { useState, useEffect } from 'react';
import { opportunityService } from '../services/api';
import './Opportunities.css';

interface Opportunity {
  id: number;
  title: string;
  description: string;
  author: string;
  type: 'recruitment' | 'event' | 'training';
  status: 'active' | 'inactive' | 'pending';
  created_at: string;
  applications_count: number;
}

const Opportunities: React.FC = () => {
  const [opportunities, setOpportunities] = useState<Opportunity[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('');

  useEffect(() => {
    loadOpportunities();
  }, []);

  const loadOpportunities = async () => {
    try {
      setLoading(true);
      const data = await opportunityService.getOpportunities();
      // Transformer les données de l'API pour correspondre à notre interface
      const transformedData = data.map((opp: any) => ({
        id: opp.id,
        title: opp.title || opp.name || 'Sans titre',
        description: opp.description || opp.content || 'Aucune description',
        author: opp.author || opp.user_name || opp.created_by || 'Anonyme',
        type: opp.type || 'recruitment',
        status: opp.status || 'active',
        created_at: opp.created_at || new Date().toISOString(),
        applications_count: opp.applications_count || opp.candidates_count || 0
      }));
      setOpportunities(transformedData);
    } catch (error) {
      console.error('Erreur lors du chargement des opportunités:', error);
      // Données de fallback
      setOpportunities([
        {
          id: 1,
          title: 'Recherche Meneur de Jeu',
          description: 'ASVEL recherche un meneur de jeu expérimenté pour la saison 2024-2025',
          author: 'ASVEL Basket',
          type: 'recruitment',
          status: 'active',
          created_at: '2024-01-15T10:30:00Z',
          applications_count: 12
        }
      ]);
    } finally {
      setLoading(false);
    }
  };

  const filteredOpportunities = opportunities.filter(opp => {
    const matchesSearch = opp.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         opp.author.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === '' || opp.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getTypeLabel = (type: string) => {
    const labels = {
      recruitment: 'Recrutement',
      event: 'Événement',
      training: 'Formation'
    };
    return labels[type as keyof typeof labels] || type;
  };

  const getStatusBadge = (status: string) => {
    const badges = {
      active: 'active-badge',
      inactive: 'inactive-badge',
      pending: 'pending-badge'
    };
    return badges[status as keyof typeof badges] || '';
  };

  const handleStatusChange = async (id: number, newStatus: string) => {
    try {
      await opportunityService.updateOpportunityStatus(id, newStatus);
      await loadOpportunities(); // Recharger les données
    } catch (error) {
      console.error('Erreur lors du changement de statut:', error);
      alert('Erreur lors du changement de statut');
    }
  };

  const handleDeleteOpportunity = async (id: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cette opportunité ?')) {
      try {
        await opportunityService.deleteOpportunity(id);
        await loadOpportunities(); // Recharger les données
      } catch (error) {
        console.error('Erreur lors de la suppression:', error);
        alert('Erreur lors de la suppression');
      }
    }
  };

  if (loading) {
    return (
      <div className="opportunities-container">
        <div className="loading">Chargement des annonces...</div>
      </div>
    );
  }

  return (
    <div className="opportunities-container">
      <div className="opportunities-header">
        <h1>Gestion des Annonces</h1>
        <p>Gérez les opportunités et annonces publiées</p>
      </div>

      {/* Filtres */}
      <div className="filters-section">
        <div className="search-box">
          <input
            type="text"
            placeholder="Rechercher par titre ou auteur..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>

        <div className="filter-controls">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="filter-select"
          >
            <option value="">Tous les statuts</option>
            <option value="active">Actif</option>
            <option value="inactive">Inactif</option>
            <option value="pending">En attente</option>
          </select>
        </div>
      </div>

      {/* Statistiques */}
      <div className="stats-section">
        <div className="stat-card">
          <h3>Total</h3>
          <p>{filteredOpportunities.length}</p>
        </div>
        <div className="stat-card">
          <h3>Actives</h3>
          <p>{filteredOpportunities.filter(o => o.status === 'active').length}</p>
        </div>
        <div className="stat-card">
          <h3>En attente</h3>
          <p>{filteredOpportunities.filter(o => o.status === 'pending').length}</p>
        </div>
      </div>

      {/* Liste des annonces */}
      <div className="opportunities-list">
        {filteredOpportunities.length === 0 ? (
          <div className="no-results">
            Aucune annonce trouvée avec ces critères
          </div>
        ) : (
          filteredOpportunities.map(opp => (
            <div key={opp.id} className="opportunity-card">
              <div className="opportunity-info">
                <div className="opportunity-header">
                  <h3>{opp.title}</h3>
                  <div className="opportunity-badges">
                    <span className={`type-badge ${opp.type}`}>
                      {getTypeLabel(opp.type)}
                    </span>
                    <span className={`status-badge ${getStatusBadge(opp.status)}`}>
                      {opp.status === 'active' ? 'Actif' : opp.status === 'inactive' ? 'Inactif' : 'En attente'}
                    </span>
                  </div>
                </div>
                
                <p className="opportunity-description">{opp.description}</p>
                
                <div className="opportunity-meta">
                  <span className="author">Par: {opp.author}</span>
                  <span className="applications">{opp.applications_count} candidatures</span>
                  <span className="date">
                    {new Date(opp.created_at).toLocaleDateString('fr-FR')}
                  </span>
                </div>
              </div>

              <div className="opportunity-actions">
                <select
                  value={opp.status}
                  onChange={(e) => handleStatusChange(opp.id, e.target.value)}
                  className="status-select"
                >
                  <option value="active">Actif</option>
                  <option value="inactive">Inactif</option>
                  <option value="pending">En attente</option>
                </select>

                <button className="view-btn">Voir détails</button>
                <button 
                  className="delete-btn"
                  onClick={() => handleDeleteOpportunity(opp.id)}
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

export default Opportunities; 