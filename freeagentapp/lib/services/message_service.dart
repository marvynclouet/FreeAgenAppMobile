import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  final SharedPreferences _prefs;

  MessageService(this._prefs);

  String? get token => _prefs.getString('token');

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      throw Exception('Error fetching conversations: $e');
    }
  }

  Future<List<Message>> getMessages(int otherUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$otherUserId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<Message> sendMessage(int receiverId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'receiverId': receiverId,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
