import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'services/message_service.dart';
import 'messages_page.dart';
import 'widgets/user_avatar.dart';

class DietitiansPage extends StatefulWidget {
  const DietitiansPage({Key? key}) : super(key: key);

  @override
  State<DietitiansPage> createState() => _DietitiansPageState();
}

class _DietitiansPageState extends State<DietitiansPage> {
  final ProfileService _profileService = ProfileService();
  List<Map<String, dynamic>> dietitians = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDietitians();
  }

  Future<void> _loadDietitians() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final dietitiansList = await _profileService.getDietitians();
      setState(() {
        dietitians = dietitiansList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les diététiciens'),
        backgroundColor: const Color(0xFF111014),
      ),
      backgroundColor: const Color(0xFF111014),
      body: RefreshIndicator(
        onRefresh: _loadDietitians,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDietitians,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (dietitians.isEmpty) {
      return const Center(
        child: Text(
          'Aucun diététicien trouvé',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: dietitians.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dietitian = dietitians[index];
        return ListTile(
          leading: UserAvatar(
            name: dietitian['name'],
            imageUrl: dietitian['profile_image_url'],
            hasCustomImage: dietitian['profile_image_url'] != null,
            radius: 28,
            profileType: 'dieteticienne',
          ),
          title: Text(
            dietitian['name'] ?? 'Diététicien',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Diététicien sportif',
            style: const TextStyle(color: Colors.white70),
          ),
          tileColor: const Color(0xFF18171C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DietitianDetailPage(dietitian: dietitian),
            ),
          ),
        );
      },
    );
  }
}

class DietitianDetailPage extends StatelessWidget {
  final Map<String, dynamic> dietitian;

  const DietitianDetailPage({
    Key? key,
    required this.dietitian,
  }) : super(key: key);

  Future<void> _sendMessage(BuildContext context) async {
    final messageController = TextEditingController();
    messageController.text =
        'Bonjour, je souhaiterais entrer en contact avec vous.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF18171C),
          title: Text(
            'Envoyer un message à ${dietitian['name'] ?? 'ce diététicien'}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Votre message:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tapez votre message ici...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && messageController.text.trim().isNotEmpty) {
      final messageService = MessageService();

      try {
        // Créer une nouvelle conversation
        final result = await messageService.createConversation(
          receiverId: dietitian['user_id'] ?? dietitian['id'],
          content: messageController.text.trim(),
          subject: 'Contact via FreeAgent App',
        );

        if (result != null && result['conversationId'] != null) {
          // Naviguer vers la page de conversation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationPage(
                conversationId: result['conversationId'],
                contactName: dietitian['name'] ?? 'Diététicien',
                opportunityTitle: '',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi du message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        title: Text(dietitian['name'] ?? 'Diététicien'),
        backgroundColor: const Color(0xFF111014),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: UserAvatar(
                name: dietitian['name'],
                imageUrl: dietitian['profile_image_url'],
                hasCustomImage: dietitian['profile_image_url'] != null,
                radius: 60,
                profileType: 'dieteticienne',
              ),
            ),
            const SizedBox(height: 24),

            // Bouton d'action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendMessage(context),
                icon: const Icon(Icons.message, color: Colors.white),
                label: const Text(
                  'Envoyer un message',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInfoSection('Informations générales', [
              _buildInfoRow('Nom', dietitian['name'] ?? 'Non spécifié'),
              _buildInfoRow('Spécialité', 'Diététicien sportif'),
              _buildInfoRow('Email', dietitian['email'] ?? 'Non spécifié'),
              if (dietitian['experience_years'] != null)
                _buildInfoRow(
                    'Expérience', '${dietitian['experience_years']} ans'),
              if (dietitian['level'] != null)
                _buildInfoRow('Niveau', dietitian['level']),
              if (dietitian['specialization'] != null)
                _buildInfoRow('Spécialisation', dietitian['specialization']),
            ]),

            if (dietitian['description'] != null &&
                dietitian['description'].toString().isNotEmpty)
              _buildInfoSection('Description', [
                _buildInfoRow('', dietitian['description']),
              ]),

            if (dietitian['achievements'] != null &&
                dietitian['achievements'].toString().isNotEmpty)
              _buildInfoSection('Palmarès', [
                _buildInfoRow('', dietitian['achievements']),
              ]),

            _buildInfoSection('Contact', [
              _buildInfoRow('Email', dietitian['email'] ?? 'Non spécifié'),
              if (dietitian['phone'] != null)
                _buildInfoRow('Téléphone', dietitian['phone']),
              if (dietitian['website'] != null)
                _buildInfoRow('Site web', dietitian['website']),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF18171C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
