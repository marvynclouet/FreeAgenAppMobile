import 'package:flutter/material.dart';
import 'players_page.dart';
import 'clubs_list_page.dart';
import 'coaches_page.dart';
import 'dietitians_page.dart';
import 'lawyers_page.dart';
import 'teams_page.dart';
import 'services/profile_service.dart';

class ContentsPage extends StatefulWidget {
  const ContentsPage({Key? key}) : super(key: key);

  @override
  State<ContentsPage> createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {
  final ProfileService _profileService = ProfileService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      // Rechercher dans tous les types d'utilisateurs
      final results = <Map<String, dynamic>>[];

      final players = await _profileService.getUsersByType('player');
      final coaches = await _profileService.getUsersByType('coach_pro');
      final coachesBasket =
          await _profileService.getUsersByType('coach_basket');
      final dietitians = await _profileService.getUsersByType('dieteticienne');
      final lawyers = await _profileService.getUsersByType('juriste');
      final clubs = await _profileService.getUsersByType('club');

      // Combiner tous les résultats
      results.addAll(players);
      results.addAll(coaches);
      results.addAll(coachesBasket);
      results.addAll(dietitians);
      results.addAll(lawyers);
      results.addAll(clubs);

      // Filtrer par nom
      final filteredResults = results.where((user) {
        final name = (user['name'] ?? '').toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();

      setState(() {
        _searchResults = filteredResults;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _navigateToUserDetail(Map<String, dynamic> user) {
    final profileType = user['profile_type'] ?? '';

    switch (profileType) {
      case 'player':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlayersPage(),
          ),
        );
        break;
      case 'coach_pro':
      case 'coach_basket':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CoachesPage(),
          ),
        );
        break;
      case 'dieteticienne':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DietitiansPage(),
          ),
        );
        break;
      case 'juriste':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LawyersPage(),
          ),
        );
        break;
      case 'club':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TeamsPage(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'title': 'Joueurs',
        'desc':
            'Découvrez des joueurs disponibles ou mettez en avant votre profil pour rejoindre une équipe.',
        'image': 'assets/players.png',
      },
      {
        'title': 'Équipes & Clubs',
        'desc':
            'Trouvez votre équipe idéale ou recrutez de nouveaux talents pour votre club.',
        'image': 'assets/teams.png',
      },
      {
        'title': 'Diététiciens',
        'desc':
            'Optimisez votre alimentation et récupérez plus efficacement grâce à nos experts en nutrition sportive.',
        'image': 'assets/dieat.png',
      },
      {
        'title': 'Agents sportifs',
        'desc':
            'Trouvez un représentant pour négocier vos contrats et gérer votre carrière.',
        'image': 'assets/lawyers.png',
      },
      {
        'title': 'Highlights',
        'desc':
            'Faites monter votre visibilité avec des monteurs pros qui valorisent vos meilleures actions.',
        'image': 'assets/highlights.png',
      },
      {
        'title': 'Avocats du sport',
        'desc': 'Soyez accompagné dans la gestion juridique de votre carrière.',
        'image': 'assets/lawyers.png',
      },
      {
        'title': 'Coachs',
        'desc':
            'Travaillez votre jeu, votre mental, ou rejoignez une équipe avec nos coachs spécialisés.',
        'image': 'assets/coach.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF18171C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _searchUsers,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Rechercher un utilisateur par nom...',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 16,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _showSearchResults = false;
                            _searchResults = [];
                          });
                        },
                        child: const Icon(Icons.clear, color: Colors.white38),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _showSearchResults
                    ? _buildSearchResults()
                    : _buildServicesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF9B5CFF)),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Aucun utilisateur trouvé',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final profileType = user['profile_type'] ?? '';

        String typeLabel = '';
        Color avatarColor = const Color(0xFF9B5CFF);

        switch (profileType) {
          case 'player':
            typeLabel = 'Joueur';
            avatarColor = const Color(0xFF2196F3);
            break;
          case 'coach_pro':
            typeLabel = 'Coach professionnel';
            avatarColor = const Color(0xFF9B5CFF);
            break;
          case 'coach_basket':
            typeLabel = 'Coach de basket';
            avatarColor = const Color(0xFF9B5CFF);
            break;
          case 'dieteticienne':
            typeLabel = 'Diététicienne';
            avatarColor = const Color(0xFF4CAF50);
            break;
          case 'juriste':
            typeLabel = 'Juriste';
            avatarColor = const Color(0xFFFF9800);
            break;
          case 'club':
            typeLabel = 'Club';
            avatarColor = const Color(0xFFE91E63);
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: avatarColor,
              radius: 24,
              child: Text(
                (user['name'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              user['name'] ?? 'Utilisateur',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              typeLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            tileColor: const Color(0xFF18171C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white70,
            ),
            onTap: () => _navigateToUserDetail(user),
          ),
        );
      },
    );
  }

  Widget _buildServicesList() {
    final services = [
      {
        'title': 'Joueurs',
        'desc':
            'Découvrez des joueurs disponibles ou mettez en avant votre profil pour rejoindre une équipe.',
        'image': 'assets/players.png',
        'page': 'players',
      },
      {
        'title': 'Équipes & Clubs',
        'desc':
            'Trouvez votre équipe idéale ou recrutez de nouveaux talents pour votre club.',
        'image': 'assets/teams.png',
        'page': 'teams',
      },
      {
        'title': 'Diététiciens',
        'desc':
            'Optimisez votre alimentation et récupérez plus efficacement grâce à nos experts en nutrition sportive.',
        'image': 'assets/dieat.png',
        'page': 'dietitians',
      },
      {
        'title': 'Agents sportifs',
        'desc':
            'Trouvez un représentant pour négocier vos contrats et gérer votre carrière.',
        'image': 'assets/lawyers.png',
        'page': 'lawyers',
      },
      {
        'title': 'Highlights',
        'desc':
            'Faites monter votre visibilité avec des monteurs pros qui valorisent vos meilleures actions.',
        'image': 'assets/highlights.png',
        'page': 'highlights',
      },
      {
        'title': 'Avocats du sport',
        'desc': 'Soyez accompagné dans la gestion juridique de votre carrière.',
        'image': 'assets/lawyers.png',
        'page': 'lawyers',
      },
      {
        'title': 'Coachs',
        'desc':
            'Travaillez votre jeu, votre mental, ou rejoignez une équipe avec nos coachs spécialisés.',
        'image': 'assets/coach.png',
        'page': 'coaches',
      },
    ];

    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        final s = services[index];
        return ServiceCard(
          image: s['image']!,
          title: s['title']!,
          desc: s['desc']!,
          onTap: () => _navigateToService(s['page']!),
        );
      },
    );
  }

  void _navigateToService(String page) {
    switch (page) {
      case 'players':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlayersPage()),
        );
        break;
      case 'teams':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TeamsPage()),
        );
        break;
      case 'dietitians':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DietitiansPage()),
        );
        break;
      case 'lawyers':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LawyersPage()),
        );
        break;
      case 'coaches':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CoachesPage()),
        );
        break;
      case 'highlights':
        // À implémenter si nécessaire
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Page Highlights à venir'),
            backgroundColor: Color(0xFF9B5CFF),
          ),
        );
        break;
    }
  }
}

class ServiceCard extends StatelessWidget {
  final String image;
  final String title;
  final String desc;
  final VoidCallback? onTap;

  const ServiceCard({
    required this.image,
    required this.title,
    required this.desc,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF18171C),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  Image.asset(image, width: 64, height: 64, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 28),
          ],
        ),
      ),
    );
  }
}
