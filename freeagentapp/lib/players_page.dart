import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';
import 'messages_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/user_avatar.dart';
import 'services/message_service.dart'; // Added import for MessageService

class PlayersPage extends StatefulWidget {
  const PlayersPage({Key? key}) : super(key: key);

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> players = [];
  bool isLoading = true;
  String? error;
  bool _showFilters = false;

  // Filtres
  String _selectedChampionship = 'all';
  String _selectedGender = 'all';
  String _selectedPosition = 'all';
  String _selectedPassport = 'all';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await _profileService.getPlayersWithFilters(
        championshipLevel: _selectedChampionship,
        gender: _selectedGender,
        position: _selectedPosition,
        passportType: _selectedPassport,
      );
      setState(() {
        players = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedChampionship = 'all';
      _selectedGender = 'all';
      _selectedPosition = 'all';
      _selectedPassport = 'all';
    });
    _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        title: const Text('Joueurs'),
        backgroundColor: const Color(0xFF111014),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFiltersSection(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPlayers,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF18171C),
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text(
                  'Réinitialiser',
                  style: TextStyle(color: Color(0xFF9B5CFF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filtres en ligne
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterDropdown(
                label: 'Championnat',
                value: _selectedChampionship,
                items: [
                  {'value': 'all', 'label': 'Tous'},
                  {'value': 'nationale', 'label': 'Nationale'},
                  {'value': 'regional', 'label': 'Régional'},
                  {'value': 'departemental', 'label': 'Départemental'},
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedChampionship = value!;
                  });
                  _loadPlayers();
                },
              ),
              _buildFilterDropdown(
                label: 'Genre',
                value: _selectedGender,
                items: [
                  {'value': 'all', 'label': 'Tous'},
                  {'value': 'masculin', 'label': 'Masculin'},
                  {'value': 'feminin', 'label': 'Féminin'},
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                  _loadPlayers();
                },
              ),
              _buildFilterDropdown(
                label: 'Poste',
                value: _selectedPosition,
                items: [
                  {'value': 'all', 'label': 'Tous'},
                  {'value': 'meneur', 'label': 'Meneur'},
                  {'value': 'arriere', 'label': 'Arrière'},
                  {'value': 'ailier', 'label': 'Ailier'},
                  {'value': 'ailier_fort', 'label': 'Ailier fort'},
                  {'value': 'pivot', 'label': 'Pivot'},
                  {'value': 'polyvalent', 'label': 'Polyvalent'},
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPosition = value!;
                  });
                  _loadPlayers();
                },
              ),
              _buildFilterDropdown(
                label: 'Passeport',
                value: _selectedPassport,
                items: [
                  {'value': 'all', 'label': 'Tous'},
                  {'value': 'france', 'label': 'France'},
                  {'value': 'europe_ue', 'label': 'Europe U.E'},
                  {'value': 'europe_hors_ue', 'label': 'Europe hors U.E'},
                  {'value': 'afrique', 'label': 'Afrique'},
                  {'value': 'amerique', 'label': 'Amérique'},
                  {'value': 'canada', 'label': 'Canada'},
                  {'value': 'autres', 'label': 'Autres'},
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPassport = value!;
                  });
                  _loadPlayers();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Compteur de résultats
          Text(
            '${players.length} joueur(s) trouvé(s)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111014),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF18171C),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.white70),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['value'],
                    child: Text(
                      item['label']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
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
              onPressed: _loadPlayers,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (players.isEmpty) {
      return const Center(
        child: Text(
          'Aucun joueur trouvé avec ces critères',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return PlayerCard(
          player: player,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerDetailPage(player: player),
            ),
          ),
        );
      },
    );
  }
}

class PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final VoidCallback onTap;

  const PlayerCard({
    Key? key,
    required this.player,
    required this.onTap,
  }) : super(key: key);

  String _formatPosition(String? position) {
    if (position == null) return 'Poste non spécifié';
    switch (position.toLowerCase()) {
      case 'meneur':
        return 'Meneur';
      case 'arriere':
        return 'Arrière';
      case 'ailier':
        return 'Ailier';
      case 'ailier_fort':
        return 'Ailier fort';
      case 'pivot':
        return 'Pivot';
      case 'polyvalent':
        return 'Polyvalent';
      default:
        return position;
    }
  }

  String _formatChampionship(String? championship) {
    if (championship == null) return '';
    switch (championship.toLowerCase()) {
      case 'nationale':
        return 'Nationale';
      case 'regional':
        return 'Régional';
      case 'departemental':
        return 'Départemental';
      default:
        return championship;
    }
  }

  String _formatGender(String? gender) {
    if (gender == null) return '';
    switch (gender.toLowerCase()) {
      case 'masculin':
        return 'H';
      case 'feminin':
        return 'F';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final genderIcon = _formatGender(player['gender']);
    final championship = _formatChampionship(player['championship_level']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF18171C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  UserAvatar(
                    name: player['name'],
                    imageUrl: player['profile_image_url'],
                    hasCustomImage: player['profile_image_url'] != null,
                    radius: 30,
                    profileType: 'player',
                  ),
                  if (genderIcon.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: genderIcon == 'H' ? Colors.blue : Colors.pink,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF18171C), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            genderIcon,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            player['name'] ?? 'Nom non spécifié',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (championship.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B5CFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              championship,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPosition(player['position']),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${player['age']} ans • ${player['height']} cm',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        if (player['nationality'] != null) ...[
                          const Text(
                            ' • ',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            player['nationality'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerDetailPage extends StatelessWidget {
  final Map<String, dynamic> player;

  const PlayerDetailPage({
    Key? key,
    required this.player,
  }) : super(key: key);

  String _formatGenderForDetail(String? gender) {
    if (gender == null) return 'Non spécifié';
    switch (gender.toLowerCase()) {
      case 'masculin':
        return 'Masculin';
      case 'feminin':
        return 'Féminin';
      default:
        return gender;
    }
  }

  String _formatPositionForDetail(String? position) {
    if (position == null) return 'Non spécifié';
    switch (position.toLowerCase()) {
      case 'meneur':
        return 'Meneur';
      case 'arriere':
        return 'Arrière';
      case 'ailier':
        return 'Ailier';
      case 'ailier_fort':
        return 'Ailier fort';
      case 'pivot':
        return 'Pivot';
      case 'polyvalent':
        return 'Polyvalent';
      default:
        return position;
    }
  }

  String _formatChampionshipForDetail(String? championship) {
    if (championship == null) return 'Non spécifié';
    switch (championship.toLowerCase()) {
      case 'nationale':
        return 'Nationale';
      case 'regional':
        return 'Régional';
      case 'departemental':
        return 'Départemental';
      default:
        return championship;
    }
  }

  String _formatPassportForDetail(String? passport) {
    if (passport == null) return 'Non spécifié';
    switch (passport.toLowerCase()) {
      case 'france':
        return 'France';
      case 'europe_ue':
        return 'Europe U.E';
      case 'europe_hors_ue':
        return 'Europe hors U.E';
      case 'afrique':
        return 'Afrique';
      case 'amerique':
        return 'Amérique';
      case 'canada':
        return 'Canada';
      case 'autres':
        return 'Autres';
      default:
        return passport;
    }
  }

  Future<void> _sendEmail() async {
    final email = player['email'] ?? '';
    if (email.isEmpty) {
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Contact depuis FreeAgent App',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

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
            'Envoyer un message à ${player['name'] ?? 'ce joueur'}',
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
          receiverId: player['user_id'] ?? player['id'],
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
                contactName: player['name'] ?? 'Joueur',
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
        title: Text(player['name'] ?? 'Joueur'),
        backgroundColor: const Color(0xFF111014),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: UserAvatar(
                name: player['name'],
                imageUrl: player['profile_image_url'],
                hasCustomImage: player['profile_image_url'] != null,
                radius: 60,
                profileType: 'player',
              ),
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                // Bouton Envoyer un email
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: player['email'] != null ? _sendEmail : null,
                    icon: const Icon(Icons.email, color: Colors.white),
                    label: const Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B5CFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bouton Envoyer un message
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendMessage(context),
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text(
                      'Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInfoSection('Informations personnelles', [
              _buildInfoRow('Email', player['email'] ?? 'Non spécifié'),
              _buildInfoRow('Âge', '${player['age']} ans'),
              _buildInfoRow('Genre', _formatGenderForDetail(player['gender'])),
              _buildInfoRow('Taille', '${player['height']} cm'),
              _buildInfoRow('Poids', '${player['weight']} kg'),
              _buildInfoRow(
                  'Nationalité', player['nationality'] ?? 'Non spécifié'),
              _buildInfoRow(
                  'Poste', _formatPositionForDetail(player['position'])),
              _buildInfoRow('Niveau championnat',
                  _formatChampionshipForDetail(player['championship_level'])),
              _buildInfoRow('Type de passeport',
                  _formatPassportForDetail(player['passport_type'])),
              _buildInfoRow('Niveau', player['level'] ?? 'Non spécifié'),
              _buildInfoRow(
                  'Expérience', '${player['experience_years']} années'),
            ]),
            if (player['stats'] != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection('Statistiques', [
                _buildInfoRow(
                    'Points par match', '${player['stats']['points'] ?? 0}'),
                _buildInfoRow(
                    'Rebonds par match', '${player['stats']['rebounds'] ?? 0}'),
                _buildInfoRow(
                    'Passes par match', '${player['stats']['assists'] ?? 0}'),
                _buildInfoRow('Interceptions par match',
                    '${player['stats']['steals'] ?? 0}'),
                _buildInfoRow(
                    'Contres par match', '${player['stats']['blocks'] ?? 0}'),
              ]),
            ],
            if (player['achievements'] != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection('Palmarès', [
                _buildInfoRow('Réalisations', player['achievements']),
              ]),
            ],
            if (player['bio'] != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection('Biographie', [
                _buildInfoRow('À propos', player['bio']),
              ]),
            ],
            if (player['video_url'] != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection('Vidéo', [
                _buildInfoRow('Lien vidéo', player['video_url']),
              ]),
            ],
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
