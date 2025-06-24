import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';
import 'messages_page.dart';
import 'package:url_launcher/url_launcher.dart';

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

      final response = await _profileService.getPlayers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        title: const Text('Joueurs'),
        backgroundColor: const Color(0xFF111014),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlayers,
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
          'Aucun joueur trouvé',
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

  @override
  Widget build(BuildContext context) {
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
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                backgroundImage: player['photo_url'] != null
                    ? NetworkImage(player['photo_url'])
                    : null,
                child: player['photo_url'] == null
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player['name'] ?? 'Nom non spécifié',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player['position'] ?? 'Poste non spécifié',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${player['age']} ans • ${player['height']} cm',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white24,
                backgroundImage: player['photo_url'] != null
                    ? NetworkImage(player['photo_url'])
                    : null,
                child: player['photo_url'] == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Bouton Envoyer un email
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: player['email'] != null ? _sendEmail : null,
                icon: const Icon(Icons.email, color: Colors.white),
                label: const Text(
                  'Envoyer un email',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
            const SizedBox(height: 24),

            _buildInfoSection('Informations personnelles', [
              _buildInfoRow('Email', player['email'] ?? 'Non spécifié'),
              _buildInfoRow('Âge', '${player['age']} ans'),
              _buildInfoRow('Taille', '${player['height']} cm'),
              _buildInfoRow('Poids', '${player['weight']} kg'),
              _buildInfoRow('Poste', player['position'] ?? 'Non spécifié'),
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
