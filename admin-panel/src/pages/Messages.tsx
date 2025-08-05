import React, { useState, useEffect } from 'react';
import { messageService } from '../services/api';
import './Messages.css';

interface Message {
  id: number;
  sender: string;
  receiver: string;
  content: string;
  type: 'text' | 'image' | 'file';
  status: 'sent' | 'delivered' | 'read';
  created_at: string;
  conversation_id: number;
}

interface Conversation {
  id: number;
  participants: string[];
  last_message: string;
  unread_count: number;
  updated_at: string;
}

const Messages: React.FC = () => {
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [selectedConversation, setSelectedConversation] = useState<number | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    loadConversations();
  }, []);

  useEffect(() => {
    if (selectedConversation) {
      loadMessages(selectedConversation);
    }
  }, [selectedConversation]);

  const loadConversations = async () => {
    try {
      setLoading(true);
      const data = await messageService.getConversations();
      // Transformer les données de l'API pour correspondre à notre interface
      const transformedData = data.map((conv: any) => ({
        id: conv.id,
        participants: conv.participants || [conv.user1_name || 'Utilisateur 1', conv.user2_name || 'Utilisateur 2'],
        last_message: conv.last_message || conv.recent_message || 'Aucun message',
        unread_count: conv.unread_count || 0,
        updated_at: conv.updated_at || conv.last_activity || new Date().toISOString()
      }));
      setConversations(transformedData);
    } catch (error) {
      console.error('Erreur lors du chargement des conversations:', error);
      // Données de fallback
      setConversations([
        {
          id: 1,
          participants: ['Sarah Martin', 'Coach Jean'],
          last_message: 'Merci pour votre réponse, je suis très intéressé !',
          unread_count: 2,
          updated_at: '2024-01-15T10:30:00Z'
        }
      ]);
    } finally {
      setLoading(false);
    }
  };

  const loadMessages = async (conversationId: number) => {
    try {
      const data = await messageService.getMessages(conversationId);
      // Transformer les données de l'API pour correspondre à notre interface
      const transformedData = data.map((msg: any) => ({
        id: msg.id,
        sender: msg.sender_name || msg.from_user || 'Expéditeur',
        receiver: msg.receiver_name || msg.to_user || 'Destinataire',
        content: msg.content || msg.message || 'Contenu du message',
        type: msg.type || 'text',
        status: msg.status || 'sent',
        created_at: msg.created_at || new Date().toISOString(),
        conversation_id: msg.conversation_id || conversationId
      }));
      setMessages(transformedData);
    } catch (error) {
      console.error('Erreur lors du chargement des messages:', error);
      setMessages([]);
    }
  };

  const filteredConversations = conversations.filter(conv =>
    conv.participants.some(participant =>
      participant.toLowerCase().includes(searchTerm.toLowerCase())
    )
  );

  const getStatusBadge = (status: string) => {
    const badges = {
      sent: 'sent-badge',
      delivered: 'delivered-badge',
      read: 'read-badge'
    };
    return badges[status as keyof typeof badges] || '';
  };

  if (loading) {
    return (
      <div className="messages-container">
        <div className="loading">Chargement des messages...</div>
      </div>
    );
  }

  return (
    <div className="messages-container">
      <div className="messages-header">
        <h1>Gestion des Messages</h1>
        <p>Surveillez les conversations entre utilisateurs</p>
      </div>

      <div className="messages-layout">
        {/* Liste des conversations */}
        <div className="conversations-panel">
          <div className="conversations-header">
            <h3>Conversations</h3>
            <div className="search-box">
              <input
                type="text"
                placeholder="Rechercher des utilisateurs..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="search-input"
              />
            </div>
          </div>

          <div className="conversations-list">
            {filteredConversations.map(conv => (
              <div
                key={conv.id}
                className={`conversation-item ${selectedConversation === conv.id ? 'active' : ''}`}
                onClick={() => setSelectedConversation(conv.id)}
              >
                <div className="conversation-info">
                  <h4>{conv.participants.join(' & ')}</h4>
                  <p className="last-message">{conv.last_message}</p>
                  <span className="conversation-time">
                    {new Date(conv.updated_at).toLocaleDateString('fr-FR')}
                  </span>
                </div>
                {conv.unread_count > 0 && (
                  <div className="unread-badge">{conv.unread_count}</div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Messages de la conversation */}
        <div className="messages-panel">
          {selectedConversation ? (
            <>
              <div className="messages-header-panel">
                <h3>
                  {conversations.find(c => c.id === selectedConversation)?.participants.join(' & ')}
                </h3>
                <button 
                  className="close-btn"
                  onClick={() => setSelectedConversation(null)}
                >
                  ✕
                </button>
              </div>

              <div className="messages-list">
                {messages.length > 0 ? (
                  messages.map(msg => (
                    <div key={msg.id} className="message-item">
                      <div className="message-header">
                        <span className="message-sender">{msg.sender}</span>
                        <span className={`message-status ${getStatusBadge(msg.status)}`}>
                          {msg.status === 'sent' ? 'Envoyé' : 
                           msg.status === 'delivered' ? 'Livré' : 'Lu'}
                        </span>
                      </div>
                      <div className="message-content">
                        {msg.content}
                      </div>
                      <div className="message-time">
                        {new Date(msg.created_at).toLocaleString('fr-FR')}
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="no-messages">
                    <p>Aucun message dans cette conversation</p>
                  </div>
                )}
              </div>

              <div className="message-actions">
                <button className="action-btn">Marquer comme lu</button>
                <button className="action-btn">Archiver</button>
                <button className="action-btn danger">Supprimer</button>
              </div>
            </>
          ) : (
            <div className="no-conversation">
              <p>Sélectionnez une conversation pour voir les messages</p>
            </div>
          )}
        </div>
      </div>

      {/* Statistiques */}
      <div className="messages-stats">
        <div className="stat-card">
          <h3>Total Conversations</h3>
          <p>{conversations.length}</p>
        </div>
        <div className="stat-card">
          <h3>Messages Non Lus</h3>
          <p>{conversations.reduce((sum, conv) => sum + conv.unread_count, 0)}</p>
        </div>
        <div className="stat-card">
          <h3>Conversations Actives</h3>
          <p>{conversations.filter(conv => conv.unread_count > 0).length}</p>
        </div>
      </div>
    </div>
  );
};

export default Messages; 