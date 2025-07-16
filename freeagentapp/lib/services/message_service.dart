import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? senderName;
  final String? senderImage;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.senderName,
    this.senderImage,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      isRead: json['is_read'] == 1,
      senderName: json['sender_name'],
      senderImage: json['sender_image'],
    );
  }
}

class Conversation {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final String lastMessage;
  final DateTime lastMessageTime;

  Conversation({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      otherUserId: json['sender_id'] == json['current_user_id']
          ? json['receiver_id']
          : json['sender_id'],
      otherUserName: json['other_user_name'],
      otherUserImage: json['other_user_image'],
      lastMessage: json['last_message'],
      lastMessageTime: DateTime.parse(json['last_message_time']),
    );
  }
}

class MessageService {
  static const String baseUrl = 'http://192.168.1.43:3000/api';
  final AuthService _authService = AuthService();

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    print(
        '🔑 Token récupéré via AuthService: ${token != null ? "OK" : "NULL"}');
    if (token != null) {
      print('🔑 Token preview: ${token.substring(0, 20)}...');
    }
    return token;
  }

  Future<int?> getCurrentUserId() async {
    final userData = await _authService.getUserData();
    final userId = userData?['id'];
    print('👤 User ID récupéré via AuthService: $userId');
    return userId;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      print('❌ Token manquant - utilisateur non connecté');
      throw Exception('Utilisateur non connecté');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Récupérer toutes les conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      print('🔄 Récupération des conversations...');

      // Vérifier d'abord si l'utilisateur est connecté
      final isLoggedIn = await _authService.isLoggedIn();
      print('🔐 Utilisateur connecté: $isLoggedIn');

      if (!isLoggedIn) {
        print(
            '❌ Utilisateur non connecté - impossible de récupérer les conversations');
        return [];
      }

      final headers = await _getHeaders();
      print('📡 Headers: $headers');

      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conversations =
            List<Map<String, dynamic>>.from(data['conversations'] ?? []);
        print('✅ ${conversations.length} conversations trouvées');
        return conversations;
      } else {
        print('❌ Erreur HTTP: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des conversations: $e');
      throw Exception('Error loading conversations: $e');
    }
  }

  // Récupérer les messages d'une conversation
  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations/$conversationId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }

  // Envoyer un message dans une conversation existante
  Future<bool> sendMessage(int conversationId, String content) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/messages/conversations/$conversationId/messages'),
        headers: headers,
        body: json.encode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Créer une nouvelle conversation (pour postuler à une annonce)
  Future<Map<String, dynamic>?> createConversation({
    required int receiverId,
    required String content,
    int? opportunityId,
    String? subject,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: headers,
        body: json.encode({
          'receiverId': receiverId,
          'content': content,
          'opportunityId': opportunityId,
          'subject': subject,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to create conversation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating conversation: $e');
    }
  }

  // Marquer une conversation comme lue
  Future<bool> markConversationAsRead(int conversationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/messages/conversations/$conversationId/read'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking conversation as read: $e');
      return false;
    }
  }

  // Récupérer le nombre de messages non lus
  Future<int> getUnreadMessagesCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/messages/unread-count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unread_count'] ?? 0;
      } else {
        print('Error getting unread count: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error getting unread messages count: $e');
      return 0;
    }
  }
}
