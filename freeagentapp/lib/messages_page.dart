import 'package:flutter/material.dart';
import 'services/message_service.dart';
import 'services/subscription_service.dart';
import 'utils/blur_widget.dart';
import 'utils/premium_navigation.dart';
import 'new_message_page.dart';
import 'subscription_page.dart';
import 'widgets/user_avatar.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final MessageService _messageService = MessageService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  bool _isPremium = false;
  SubscriptionStatus? _subscriptionStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Charger le statut d'abonnement
      final status = await _subscriptionService.getSubscriptionStatus();
      final conversations = await _messageService.getConversations();

      setState(() {
        _subscriptionStatus = status;
        _isPremium = status.isPremium;
        _conversations = conversations;
        _isLoading = false;
      });

      print('🔍 DEBUG Messages - isPremium: $_isPremium');
      print('🔍 DEBUG Messages - status.type: ${status.type}');
      print('🔍 DEBUG Messages - status.isPremium: ${status.isPremium}');
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubscriptionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _isPremium
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewMessagePage(),
                      ),
                    ).then((_) => _loadData());
                  }
                : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    if (!_isPremium) {
      return _buildBlurredMessages();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildConversationItem(conversation);
        },
      ),
    );
  }

  Widget _buildBlurredMessages() {
    return BlurWidget(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildConversationItem(conversation);
        },
      ),
      message: "Tu veux voir qui t'a envoyé un message ?\nAlors abonne-toi !",
      buttonText: "Voir Premium",
    );
  }

  Widget _buildEmptyState() {
    if (!_isPremium) {
      return BlurWidget(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 100,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 20),
              Text(
                'Aucune conversation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        message: "Tu veux voir qui t'a envoyé un message ?\nAlors abonne-toi !",
        buttonText: "Voir Premium",
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 100,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune conversation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Commencez une conversation en postulant\nà une annonce ou en contactant un profil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewMessagePage(),
                ),
              ).then((_) => _loadData());
            },
            icon: const Icon(Icons.add),
            label: const Text('Nouveau message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    final bool hasUnread = (conversation['unread_count'] ?? 0) > 0;
    final String lastMessage = conversation['last_message'] ?? '';
    final String contactName = conversation['contact_name'] ?? 'Inconnu';
    final String opportunityTitle = conversation['opportunity_title'] ?? '';
    final DateTime? lastMessageTime = conversation['last_message_at'] != null
        ? DateTime.tryParse(conversation['last_message_at'])
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E23),
        borderRadius: BorderRadius.circular(12),
        border: hasUnread
            ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            UserAvatar(
              name: contactName,
              radius: 25,
              hasCustomImage: false, // TODO: Ajouter la gestion des images
              imageUrl: null, // TODO: Ajouter l'URL d'image si disponible
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contactName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
            if (opportunityTitle.isNotEmpty)
              Text(
                'Re: $opportunityTitle',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lastMessage,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (lastMessageTime != null)
              Text(
                _formatDateTime(lastMessageTime),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: hasUnread
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${conversation['unread_count']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: _isPremium
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationPage(
                      conversationId: conversation['id'],
                      contactName: contactName,
                      opportunityTitle: opportunityTitle,
                      contactId:
                          conversation['contact_id'], // Ajout pour UserAvatar
                    ),
                  ),
                ).then((_) => _loadData());
              }
            : null,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class ConversationPage extends StatefulWidget {
  final int conversationId;
  final String contactName;
  final String opportunityTitle;
  final int? contactId; // Added for UserAvatar

  const ConversationPage({
    Key? key,
    required this.conversationId,
    required this.contactName,
    required this.opportunityTitle,
    this.contactId, // Added for UserAvatar
  }) : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _currentUserId;
  late VoidCallback _textListener;

  @override
  void initState() {
    super.initState();
    _textListener = () => setState(() {});
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _currentUserId = await _messageService.getCurrentUserId();
    _messageController.addListener(_textListener);
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _messageService.getMessages(widget.conversationId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Erreur lors du chargement des messages: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);
    try {
      await _messageService.sendMessage(widget.conversationId, content);
      await _loadMessages();
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi du message'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contactName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (widget.opportunityTitle.isNotEmpty)
              Text(
                'Re: ${widget.opportunityTitle}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageItem(message);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final bool isMe =
        _currentUserId != null && message['sender_id'] == _currentUserId;
    final DateTime createdAt = DateTime.parse(message['created_at']);
    final String messageType = message['message_type'] ?? 'text';
    final String senderName =
        message['first_name'] ?? message['sender_name'] ?? widget.contactName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar pour les autres utilisateurs (à gauche)
          if (!isMe) ...[
            UserAvatar(
              name: senderName,
              radius: 18,
              hasCustomImage: false, // TODO: Ajouter la gestion des images
              imageUrl: null, // TODO: Ajouter l'URL d'image si disponible
            ),
            const SizedBox(width: 8),
          ],

          // Bulle de message
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Indicateur de type de message
                  if (messageType == 'application')
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '📋 Candidature',
                        style: TextStyle(
                          color: const Color(0xFF4CAF50),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Bulle du message
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe ? null : const Color(0xFF2A2D3A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['content'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.done_all,
                                size: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar pour l'utilisateur actuel (à droite)
          if (isMe) ...[
            const SizedBox(width: 8),
            UserAvatar(
              name: "Moi", // TODO: Récupérer le nom de l'utilisateur actuel
              radius: 18,
              hasCustomImage: false, // TODO: Ajouter la gestion des images
              imageUrl: null, // TODO: Ajouter l'URL d'image si disponible
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        border: Border(
          top: BorderSide(color: const Color(0xFF2A2D3A), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF3E4651),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tapez votre message...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: _messageController.text.trim().isNotEmpty
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _messageController.text.trim().isEmpty
                    ? const Color(0xFF3E4651)
                    : null,
                shape: BoxShape.circle,
                boxShadow: _messageController.text.trim().isNotEmpty
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: IconButton(
                onPressed:
                    (_isSending || _messageController.text.trim().isEmpty)
                        ? null
                        : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_textListener);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
