import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';
import 'services/message_service.dart';
import 'messages_page.dart';
import 'widgets/user_avatar.dart';

class HandibasketPage extends StatefulWidget {
  const HandibasketPage({Key? key}) : super(key: key);

  @override
  State<HandibasketPage> createState() => _HandibasketPageState();
}

class _HandibasketPageState extends State<HandibasketPage> {
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
  String _selectedClassification = 'all';

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

      final response = await _profileService.getUsersByType('handibasket');
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
      _selectedClassification = 'all';
    });
    _loadPlayers();
  }

  List<Map<String, dynamic>> _getFilteredPlayers() {
    return players.where((player) {
      if (_selectedChampionship != 'all' &&
          player['championship_level'] != _selectedChampionship) return false;
      if (_selectedGender != 'all' && player['gender'] != _selectedGender)
        return false;
      if (_selectedPosition != 'all' && player['position'] != _selectedPosition)
        return false;
      if (_selectedClassification != 'all' &&
          player['classification'] != _selectedClassification) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = _getFilteredPlayers();

    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        title: const Text('Joueurs Handibasket'),
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
          if (_showFilters) _buildFiltersSection(filteredPlayers.length),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPlayers,
              child: _buildContent(filteredPlayers),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(int resultCount) {
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
                  style: TextStyle(color: Colors.orange),
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
                },
              ),
              _buildFilterDropdown(
                label: 'Classification',
                value: _selectedClassification,
                items: [
                  {'value': 'all', 'label': 'Toutes'},
                  {'value': '1.0', 'label': '1.0'},
                  {'value': '1.5', 'label': '1.5'},
                  {'value': '2.0', 'label': '2.0'},
                  {'value': '2.5', 'label': '2.5'},
                  {'value': '3.0', 'label': '3.0'},
                  {'value': '3.5', 'label': '3.5'},
                  {'value': '4.0', 'label': '4.0'},
                  {'value': '4.5', 'label': '4.5'},
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedClassification = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Compteur de résultats
          Text(
            '$resultCount joueur(s) trouvé(s)',
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

  Widget _buildContent(List<Map<String, dynamic>> filteredPlayers) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
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

    if (filteredPlayers.isEmpty) {
      return const Center(
        child: Text(
          'Aucun joueur trouvé avec ces critères',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPlayers.length,
      itemBuilder: (context, index) {
        final player = filteredPlayers[index];
        return HandibasketPlayerCard(
          player: player,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HandibasketPlayerDetailPage(player: player),
            ),
          ),
        );
      },
    );
  }
}

class HandibasketPlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final VoidCallback onTap;

  const HandibasketPlayerCard({
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

  String _calculateAge(dynamic birthDate) {
    if (birthDate == null) return 'N/A';

    // Si c'est déjà un nombre (âge calculé)
    if (birthDate is int) return birthDate.toString();

    // Si c'est une chaîne de caractères (date)
    if (birthDate is String) {
      if (birthDate.isEmpty) return 'N/A';
      try {
        final birth = DateTime.parse(birthDate);
        final now = DateTime.now();
        final age = now.year - birth.year;
        return age.toString();
      } catch (e) {
        return 'N/A';
      }
    }

    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final genderIcon = _formatGender(player['gender']);
    final championship = _formatChampionship(player['championship_level']);
    final classification = player['cat'] ?? player['classification'] ?? '';
    final age = _calculateAge(player['age'] ?? player['birth_date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF18171C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange.withOpacity(0.2), width: 1),
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
                    profileType: 'handibasket',
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
                        if (classification.isNotEmpty &&
                            classification != 'a_definir')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'CAT $classification',
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
                        if (age != 'N/A')
                          Text(
                            '$age ans',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        if (championship.isNotEmpty && age != 'N/A')
                          const Text(
                            ' • ',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        if (championship.isNotEmpty)
                          Text(
                            championship,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
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

class HandibasketPlayerDetailPage extends StatelessWidget {
  final Map<String, dynamic> player;

  const HandibasketPlayerDetailPage({
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

  String _calculateAge(dynamic birthDate) {
    if (birthDate == null) return 'Non spécifié';

    // Si c'est déjà un nombre (âge calculé)
    if (birthDate is int) return '$birthDate ans';

    // Si c'est une chaîne de caractères (date)
    if (birthDate is String) {
      if (birthDate.isEmpty) return 'Non spécifié';
      try {
        final birth = DateTime.parse(birthDate);
        final now = DateTime.now();
        final age = now.year - birth.year;
        return '$age ans';
      } catch (e) {
        return 'Non spécifié';
      }
    }

    return 'Non spécifié';
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
              child: Stack(
                children: [
                  UserAvatar(
                    name: player['name'],
                    imageUrl: player['profile_image_url'],
                    hasCustomImage: player['profile_image_url'] != null,
                    radius: 60,
                    profileType: 'handibasket',
                  ),
                  if (player['cat'] != null && player['cat'] != 'a_definir')
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF111014), width: 2),
                        ),
                        child: Text(
                          'CAT ${player['cat']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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

            _buildInfoSection('Informations personnelles', [
              _buildInfoRow(
                  'Âge', _calculateAge(player['age'] ?? player['birth_date'])),
              _buildInfoRow('Genre', _formatGenderForDetail(player['gender'])),
              _buildInfoRow(
                  'Lieu de résidence', player['residence'] ?? 'Non spécifié'),
              _buildInfoRow(
                  'Profession', player['profession'] ?? 'Non spécifiée'),
            ]),

            const SizedBox(height: 24),
            _buildInfoSection('Informations sportives', [
              _buildInfoRow(
                  'Poste', _formatPositionForDetail(player['position'])),
              _buildInfoRow('Niveau championnat',
                  _formatChampionshipForDetail(player['championship_level'])),
              _buildInfoRow('Classification',
                  player['cat'] ?? player['classification'] ?? 'Non spécifiée'),
              _buildInfoRow('Type de handicap',
                  player['handicap_type'] ?? 'Non spécifié'),
              _buildInfoRow('Club', player['club'] ?? 'Non spécifié'),
              _buildInfoRow('Entraîneur', player['coach'] ?? 'Non spécifié'),
            ]),

            if (player['experience_years'] != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection('Expérience', [
                _buildInfoRow('Années d\'expérience',
                    '${player['experience_years']} années'),
              ]),
            ],

            if (player['bio'] != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection('À propos', [
                _buildInfoRow('Biographie', player['bio']),
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
            border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
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
