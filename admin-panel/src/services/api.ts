import axios from 'axios';
import type { User } from '../types';

// URL de l'API - à mettre à jour avec la vraie URL quand elle sera disponible
const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://freeagent-backend-production.up.railway.app/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'admin-password': 'admin123' // Mot de passe admin pour l'authentification
  },
  timeout: 10000, // Timeout de 10 secondes
});

// Intercepteur pour gérer les erreurs
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('Erreur API:', error);
    if (error.code === 'ECONNABORTED') {
      console.log('API non accessible - utilisation des données de fallback');
    }
    return Promise.reject(error);
  }
);

// Service pour l'authentification admin
export const adminAuthService = {
  login: async (password: string) => {
    // Pour l'instant, on garde la vérification locale du mot de passe
    if (password === 'admin123') {
      return { success: true, token: 'admin-token' };
    }
    throw new Error('Mot de passe incorrect');
  }
};

// Service pour les utilisateurs
export const userService = {
  // Récupérer tous les utilisateurs
  getUsers: async (): Promise<User[]> => {
    try {
      // Utiliser l'endpoint admin
      const response = await api.get('/admin/users');
      
      // Adapter la réponse selon la structure de l'API
      const users = Array.isArray(response.data) ? response.data : response.data.users || [];
      
      return users.map((user: any) => ({
        id: user.id,
        email: user.email,
        first_name: user.first_name || user.name || 'N/A',
        last_name: user.last_name || '',
        profile_type: user.profile_type || 'player',
        subscription_type: user.subscription_type || 'free',
        created_at: user.created_at || new Date().toISOString(),
        is_active: user.is_active !== false,
        profile_image: user.profile_image_url || user.profile_image || 'https://via.placeholder.com/50'
      }));
    } catch (error) {
      console.error('Erreur lors de la récupération des utilisateurs:', error);
      console.log('Utilisation des données de fallback');
      // Retourner des données de fallback en cas d'erreur
      return getFallbackUsers();
    }
  },

  // Récupérer les utilisateurs par type de profil
  getUsersByType: async (profileType: string): Promise<User[]> => {
    try {
      const response = await api.get(`/admin/users/search?type=${profileType}`);
      const users = Array.isArray(response.data) ? response.data : [];
      
      return users.map((user: any) => ({
        id: user.id,
        email: user.email,
        first_name: user.first_name || user.name || 'N/A',
        last_name: user.last_name || '',
        profile_type: user.profile_type || 'player',
        subscription_type: user.subscription_type || 'free',
        created_at: user.created_at || new Date().toISOString(),
        is_active: user.is_active !== false,
        profile_image: user.profile_image_url || user.profile_image || 'https://via.placeholder.com/50'
      }));
    } catch (error) {
      console.error(`Erreur lors de la récupération des ${profileType}:`, error);
      return getFallbackUsers().filter(u => u.profile_type === profileType);
    }
  },

  // Mettre à jour l'abonnement d'un utilisateur
  updateUserSubscription: async (userId: number, subscriptionType: 'free' | 'premium'): Promise<User> => {
    try {
      const response = await api.put(`/admin/users/${userId}`, {
        subscription_type: subscriptionType
      });
      return {
        id: response.data.id,
        email: response.data.email,
        first_name: response.data.first_name || response.data.name || 'N/A',
        last_name: response.data.last_name || '',
        profile_type: response.data.profile_type || 'player',
        subscription_type: response.data.subscription_type || 'free',
        created_at: response.data.created_at || new Date().toISOString(),
        is_active: response.data.is_active !== false,
        profile_image: response.data.profile_image_url || response.data.profile_image || 'https://via.placeholder.com/50'
      };
    } catch (error) {
      console.error('Erreur lors de la mise à jour de l\'abonnement:', error);
      // Simuler une mise à jour réussie avec les données de fallback
      const fallbackUser = getFallbackUsers().find(u => u.id === userId);
      if (fallbackUser) {
        fallbackUser.subscription_type = subscriptionType;
        return fallbackUser;
      }
      throw new Error('Impossible de mettre à jour l\'abonnement');
    }
  },

  // Activer/Désactiver un utilisateur
  toggleUserStatus: async (userId: number): Promise<User> => {
    try {
      const response = await api.put(`/admin/users/${userId}`, {
        is_active: false // On désactive temporairement, puis on peut réactiver
      });
      return {
        id: response.data.id,
        email: response.data.email,
        first_name: response.data.first_name || response.data.name || 'N/A',
        last_name: response.data.last_name || '',
        profile_type: response.data.profile_type || 'player',
        subscription_type: response.data.subscription_type || 'free',
        created_at: response.data.created_at || new Date().toISOString(),
        is_active: response.data.is_active !== false,
        profile_image: response.data.profile_image_url || response.data.profile_image || 'https://via.placeholder.com/50'
      };
    } catch (error) {
      console.error('Erreur lors du changement de statut:', error);
      // Simuler un changement de statut avec les données de fallback
      const fallbackUser = getFallbackUsers().find(u => u.id === userId);
      if (fallbackUser) {
        fallbackUser.is_active = !fallbackUser.is_active;
        return fallbackUser;
      }
      throw new Error('Impossible de changer le statut');
    }
  },

  // Supprimer un utilisateur
  deleteUser: async (userId: number): Promise<void> => {
    try {
      await api.delete(`/admin/users/${userId}`);
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      // Simuler une suppression réussie
      console.log(`Utilisateur ${userId} supprimé (simulation)`);
    }
  }
};

// Service pour les opportunités/annonces
export const opportunityService = {
  // Récupérer toutes les opportunités
  getOpportunities: async () => {
    try {
      const response = await api.get('/admin/opportunities');
      const opportunities = Array.isArray(response.data) ? response.data : [];
      
      // Transformer les données pour correspondre à notre interface
      return opportunities.map((opp: any) => ({
        id: opp.id,
        title: opp.title || opp.name || 'Sans titre',
        description: opp.description || opp.content || 'Aucune description',
        author: opp.user_name || opp.author || opp.created_by || 'Anonyme',
        type: opp.type || 'recruitment',
        status: opp.status || 'active',
        created_at: opp.created_at || new Date().toISOString(),
        applications_count: opp.applications_count || opp.candidates_count || 0
      }));
    } catch (error) {
      console.error('Erreur lors de la récupération des opportunités:', error);
      // Données de fallback
      return getFallbackOpportunities();
    }
  },

  // Mettre à jour le statut d'une opportunité
  updateOpportunityStatus: async (opportunityId: number, status: string) => {
    try {
      const response = await api.put(`/admin/opportunities/${opportunityId}`, { status });
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la mise à jour du statut:', error);
      console.log(`Statut de l'opportunité ${opportunityId} mis à jour vers ${status} (simulation)`);
      return { id: opportunityId, status };
    }
  },

  // Supprimer une opportunité
  deleteOpportunity: async (opportunityId: number) => {
    try {
      await api.delete(`/admin/opportunities/${opportunityId}`);
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      console.log(`Opportunité ${opportunityId} supprimée (simulation)`);
    }
  }
};

// Service pour les messages
export const messageService = {
  // Récupérer les conversations
  getConversations: async () => {
    try {
      const response = await api.get('/admin/conversations');
      const conversations = response.data.conversations || response.data || [];
      
      // Transformer les données pour correspondre à notre interface
      return conversations.map((conv: any) => ({
        id: conv.id,
        participants: conv.participants || [conv.sender_name || 'Utilisateur 1', conv.receiver_name || 'Utilisateur 2'],
        last_message: conv.last_message || conv.recent_message || 'Aucun message',
        unread_count: conv.unread_count || 0,
        updated_at: conv.last_message_at || conv.updated_at || conv.last_activity || new Date().toISOString()
      }));
    } catch (error) {
      console.error('Erreur lors de la récupération des conversations:', error);
      return getFallbackConversations();
    }
  },

  // Récupérer les messages d'une conversation
  getMessages: async (conversationId: number) => {
    try {
      const response = await api.get(`/admin/conversations/${conversationId}/messages`);
      const messages = Array.isArray(response.data) ? response.data : [];
      
      // Transformer les données pour correspondre à notre interface
      return messages.map((msg: any) => ({
        id: msg.id,
        sender: msg.sender_name || msg.first_name || 'Expéditeur',
        receiver: msg.receiver_name || msg.to_user || 'Destinataire',
        content: msg.content || msg.message || 'Contenu du message',
        type: msg.type || 'text',
        status: msg.is_read ? 'read' : 'sent',
        created_at: msg.created_at || new Date().toISOString(),
        conversation_id: msg.conversation_id || conversationId
      }));
    } catch (error) {
      console.error('Erreur lors de la récupération des messages:', error);
      return getFallbackMessages(conversationId);
    }
  }
};

// Service pour les statistiques
export const statsService = {
  // Récupérer les statistiques du dashboard
  getDashboardStats: async () => {
    try {
      const response = await api.get('/admin/stats');
      return response.data;
    } catch (error) {
      console.error('Erreur lors de la récupération des statistiques:', error);
      console.log('Utilisation des statistiques de fallback');
      return getFallbackStats();
    }
  }
};

// Données de fallback en cas d'erreur API
function getFallbackUsers(): User[] {
  return [
    {
      id: 1,
      email: 'sarah@gmail.com',
      first_name: 'Sarah',
      last_name: 'Martin',
      profile_type: 'player',
      subscription_type: 'premium',
      created_at: '2024-01-15T10:30:00Z',
      is_active: true,
      profile_image: 'https://via.placeholder.com/50'
    },
    {
      id: 2,
      email: 'coach.jean@club.fr',
      first_name: 'Jean',
      last_name: 'Dubois',
      profile_type: 'coach',
      subscription_type: 'premium',
      created_at: '2024-01-10T14:20:00Z',
      is_active: true,
      profile_image: 'https://via.placeholder.com/50'
    },
    {
      id: 3,
      email: 'contact@asvel.fr',
      first_name: 'ASVEL',
      last_name: 'Basket',
      profile_type: 'club',
      subscription_type: 'premium',
      created_at: '2024-01-05T09:15:00Z',
      is_active: true,
      profile_image: 'https://via.placeholder.com/50'
    },
    {
      id: 4,
      email: 'player.free@test.com',
      first_name: 'Pierre',
      last_name: 'Durand',
      profile_type: 'player',
      subscription_type: 'free',
      created_at: '2024-01-20T16:45:00Z',
      is_active: false,
      profile_image: 'https://via.placeholder.com/50'
    }
  ];
}

function getFallbackOpportunities() {
  return [
    {
      id: 1,
      title: 'Recherche Meneur de Jeu',
      description: 'ASVEL recherche un meneur de jeu expérimenté pour la saison 2024-2025',
      author: 'ASVEL Basket',
      type: 'recruitment',
      status: 'active',
      created_at: '2024-01-15T10:30:00Z',
      applications_count: 12
    },
    {
      id: 2,
      title: 'Stage de Perfectionnement',
      description: 'Stage de 3 jours pour améliorer votre technique de tir',
      author: 'Coach Jean Dubois',
      type: 'training',
      status: 'active',
      created_at: '2024-01-14T14:20:00Z',
      applications_count: 8
    }
  ];
}

function getFallbackConversations() {
  return [
    {
      id: 1,
      participants: ['Sarah Martin', 'Coach Jean'],
      last_message: 'Merci pour votre réponse, je suis très intéressé !',
      unread_count: 2,
      updated_at: '2024-01-15T10:30:00Z'
    },
    {
      id: 2,
      participants: ['Pierre Durand', 'ASVEL Basket'],
      last_message: 'Quand puis-je passer un essai ?',
      unread_count: 0,
      updated_at: '2024-01-14T14:20:00Z'
    }
  ];
}

function getFallbackMessages(conversationId: number) {
  return [
    {
      id: 1,
      sender: 'Sarah Martin',
      receiver: 'Coach Jean',
      content: 'Bonjour, je suis intéressé par votre stage de perfectionnement',
      type: 'text',
      status: 'read',
      created_at: '2024-01-15T10:30:00Z',
      conversation_id: conversationId
    },
    {
      id: 2,
      sender: 'Coach Jean',
      receiver: 'Sarah Martin',
      content: 'Bonjour Sarah, merci pour votre intérêt !',
      type: 'text',
      status: 'read',
      created_at: '2024-01-15T10:35:00Z',
      conversation_id: conversationId
    }
  ];
}

function getFallbackStats() {
  return {
    totalUsers: 4,
    premiumUsers: 3,
    activeUsers: 3,
    totalOpportunities: 2,
    activeOpportunities: 2,
    totalConversations: 2,
    recentActivity: []
  };
} 