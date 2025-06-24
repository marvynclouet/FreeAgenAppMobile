import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/message_service.dart';
import 'new_message_page.dart';

class MessagesPage extends StatefulWidget {
  final int? selectedUserId;

  const MessagesPage({
    super.key,
    this.selectedUserId,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late MessageService _messageService;
  final TextEditingController _messageController = TextEditingController();
  int? _selectedUserId;
  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
    if (widget.selectedUserId != null) {
      _loadMessages(widget.selectedUserId!);
    }
  }

  Future<void> _initializeService() async {
    final prefs = await SharedPreferences.getInstance();
    _messageService = MessageService(prefs);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMessages(int userId) async {
    setState(() {
      _isLoading = true;
      _selectedUserId = userId;
    });

    try {
      final messages = await _messageService.getMessages(userId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des messages: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedUserId == null) {
      return;
    }

    try {
      final message = await _messageService.sendMessage(
        _selectedUserId!,
        _messageController.text.trim(),
      );
      setState(() {
        _messages.add(message);
      });
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedUserId == null
                ? _buildConversationsList()
                : _buildMessagesList(),
          ),
          if (_selectedUserId != null) _buildMessageInput(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewMessagePage(),
            ),
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildConversationsList() {
    return FutureBuilder<List<Conversation>>(
      future: _messageService.getConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        final conversations = snapshot.data ?? [];

        if (conversations.isEmpty) {
          return const Center(
            child: Text('Aucune conversation'),
          );
        }

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: conversation.otherUserImage != null
                    ? NetworkImage(conversation.otherUserImage!)
                    : null,
                child: conversation.otherUserImage == null
                    ? Text(conversation.otherUserName[0].toUpperCase())
                    : null,
              ),
              title: Text(conversation.otherUserName),
              subtitle: Text(
                conversation.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                _formatDate(conversation.lastMessageTime),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => _loadMessages(conversation.otherUserId),
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[_messages.length - 1 - index];
        final isMe = message.senderId == _messageService.token;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isMe ? Colors.white70 : null,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: Implémenter l'attachement de fichiers
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Écrivez votre message...',
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
