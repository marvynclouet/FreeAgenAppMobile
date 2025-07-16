import 'package:flutter/material.dart';
import 'services/message_service.dart';
import 'services/profile_service.dart';
import 'widgets/user_avatar.dart';

class NewMessagePage extends StatefulWidget {
  final int? opportunityId;
  final String? opportunityTitle;
  final int? receiverId;
  final String? receiverName;

  const NewMessagePage({
    Key? key,
    this.opportunityId,
    this.opportunityTitle,
    this.receiverId,
    this.receiverName,
  }) : super(key: key);

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  final MessageService _messageService = MessageService();
  final ProfileService _profileService = ProfileService();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  Map<String, dynamic>? _selectedUser;
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.receiverId != null && widget.receiverName != null) {
      _selectedUser = {
        'id': widget.receiverId,
        'first_name': widget.receiverName?.split(' ').first ?? '',
        'last_name': widget.receiverName?.split(' ').skip(1).join(' ') ?? '',
      };
    } else {
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _profileService.getUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final name =
              '${user['first_name']} ${user['last_name']}'.toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_selectedUser == null || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Veuillez sélectionner un destinataire et saisir un message'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final result = await _messageService.createConversation(
        receiverId: _selectedUser!['id'],
        content: _messageController.text.trim(),
        opportunityId: widget.opportunityId,
        subject: widget.opportunityTitle,
      );

      if (result != null && result['success'] == true) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message envoyé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Échec de l\'envoi du message');
      }
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
        title: Text(
          widget.opportunityId != null ? 'Postuler' : 'Nouveau message',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSending ? null : _sendMessage,
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Envoyer',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.opportunityTitle != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E23),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Candidature pour:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.opportunityTitle!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Sélection du destinataire
            if (_selectedUser == null) ...[
              const Text(
                'Destinataire',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E1E23),
                ),
                onChanged: _filterUsers,
              ),
              const SizedBox(height: 16),

              // Liste des utilisateurs
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              'Aucun utilisateur trouvé',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return _buildUserItem(user);
                            },
                          ),
              ),
            ] else ...[
              // Destinataire sélectionné
              const Text(
                'Destinataire',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E23),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    UserAvatar(
                      name:
                          '${_selectedUser!['first_name']} ${_selectedUser!['last_name']}',
                      imageUrl: _selectedUser!['profile_image_url'],
                      hasCustomImage:
                          _selectedUser!['profile_image_url'] != null,
                      radius: 20,
                      profileType: _selectedUser!['profile_type'],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_selectedUser!['first_name']} ${_selectedUser!['last_name']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.receiverId == null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedUser = null;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Message
              const Text(
                'Message',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: widget.opportunityId != null
                        ? 'Présentez-vous et expliquez pourquoi vous êtes intéressé par cette opportunité...'
                        : 'Tapez votre message...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E23),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E23),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: UserAvatar(
          name: '${user['first_name']} ${user['last_name']}',
          imageUrl: user['profile_image_url'],
          hasCustomImage: user['profile_image_url'] != null,
          radius: 20,
          profileType: user['profile_type'],
        ),
        title: Text(
          '${user['first_name']} ${user['last_name']}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: user['profile_type'] != null
            ? Text(
                user['profile_type'],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              )
            : null,
        onTap: () {
          setState(() {
            _selectedUser = user;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
