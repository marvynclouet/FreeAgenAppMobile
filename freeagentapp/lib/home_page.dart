import 'package:flutter/material.dart';
import 'opportunities_page.dart';
import 'contents_page.dart';
import 'profile_page.dart';
import 'players_page.dart';
import 'coaches_page.dart';
import 'teams_page.dart';
import 'dietitians_page.dart';
import 'lawyers_page.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';
import 'services/opportunity_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final OpportunityService _opportunityService = OpportunityService();
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _popularClubs = [];
  List<Map<String, dynamic>> _recentOpportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userData = await _authService.getUserData();
      final clubs = await _profileService.getClubs();
      final opportunities = await _opportunityService.getOpportunities();
      setState(() {
        _userData = userData;
        _popularClubs = clubs;
        _recentOpportunities =
            opportunities.take(3).toList(); // Les 3 plus récentes
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeContent(
        userData: _userData,
        popularClubs: _popularClubs,
        recentOpportunities: _recentOpportunities,
        isLoading: _isLoading,
        onRefresh: _loadData,
        onNavigateToOpportunities: () {
          setState(() {
            _selectedIndex = 1; // Index de l'onglet Opportunités
          });
        },
      ),
      const OpportunitiesPage(),
      const ContentsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Opportunités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: 'Contenus',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      body: SafeArea(child: pages[_selectedIndex]),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final List<Map<String, dynamic>> popularClubs;
  final List<Map<String, dynamic>> recentOpportunities;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onNavigateToOpportunities;

  const _HomeContent({
    required this.userData,
    required this.popularClubs,
    required this.recentOpportunities,
    required this.isLoading,
    required this.onRefresh,
    required this.onNavigateToOpportunities,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenue header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenue,',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          userData?['name'] ?? 'Utilisateur',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Icons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CategoryIcon(
                  icon: Icons.person,
                  label: 'Players',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlayersPage()),
                  ),
                ),
                _CategoryIcon(
                  icon: Icons.person_outline,
                  label: 'Coaches',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CoachesPage()),
                  ),
                ),
                _CategoryIcon(
                  icon: Icons.sports_basketball,
                  label: 'Clubs',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TeamsPage()),
                  ),
                ),
                _CategoryIcon(
                  icon: Icons.restaurant,
                  label: 'Dietitians',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DietitiansPage()),
                  ),
                ),
                _CategoryIcon(
                  icon: Icons.balance,
                  label: 'Lawyers',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LawyersPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Popular Clubs
            const Text(
              'Clubs populaires',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularClubs.length,
                  itemBuilder: (context, index) {
                    final club = popularClubs[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: PopularClubCard(
                        logo: 'assets/StadeRennaisBasket.png',
                        clubName: club['club_name'] ?? 'Club',
                        city: club['location'] ?? 'Ville',
                        description: club['description'] ?? 'Description',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TeamDetailPage(
                              logo: 'assets/StadeRennaisBasket.png',
                              clubName: club['club_name'] ?? 'Club',
                              city: club['location'] ?? 'Ville',
                              description: club['description'] ?? 'Description',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 32),
            // Contents
            const Text(
              'Contents',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ContentCard(
                    title: 'COACHS',
                    image: 'assets/coach.png',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CoachesPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContentCard(
                    title: 'DIETITIANS',
                    image: 'assets/dieat.png',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DietitiansPage()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ContentCard(
                    title: 'LAWYERS',
                    image: 'assets/lawyers.png',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LawyersPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContentCard(
                    title: 'PLAYER',
                    image: 'assets/players.png',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlayersPage()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ContentCard(
                    title: 'TEAMS',
                    image: 'assets/teams.png',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TeamsPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _ContentCard(
                    title: 'HIGHLIGHTS',
                    image: 'assets/highlights.png',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Opportunités',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            OpportunityCard(
              opportunities: recentOpportunities,
              onNavigateToOpportunities: onNavigateToOpportunities,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _CategoryIcon({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF9B5CFF), size: 32),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback? onTap;
  const _ContentCard({required this.title, required this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.45)),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopularClubCard extends StatelessWidget {
  final String logo;
  final String clubName;
  final String city;
  final String description;
  final VoidCallback? onTap;

  const PopularClubCard({
    required this.logo,
    required this.clubName,
    required this.city,
    required this.description,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF18171C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage(logo),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    clubName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    city,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OpportunityCard extends StatelessWidget {
  final List<Map<String, dynamic>> opportunities;
  final VoidCallback onNavigateToOpportunities;

  const OpportunityCard({
    required this.opportunities,
    required this.onNavigateToOpportunities,
    Key? key,
  }) : super(key: key);

  String getTypeLabel(String type) {
    switch (type) {
      case 'equipe_recherche_joueur':
        return 'Équipe cherche joueur';
      case 'joueur_recherche_equipe':
        return 'Joueur cherche équipe';
      case 'coach_recherche_equipe':
        return 'Coach cherche équipe';
      case 'coach_recherche_joueur':
        return 'Coach cherche joueur';
      case 'equipe_recherche_coach':
        return 'Équipe cherche coach';
      case 'service_professionnel':
        return 'Service professionnel';
      case 'autre':
        return 'Autre';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF18171C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Aucune opportunité récente',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onNavigateToOpportunities,
                child: const Text(
                  'Voir toutes les opportunités',
                  style: TextStyle(
                    color: Color(0xFF9B5CFF),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final opportunity = opportunities.first;

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B5CFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getTypeLabel(opportunity['type']).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    opportunity['title'] ?? 'Opportunité',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onNavigateToOpportunities,
                    child: Text(
                      'Voir ${opportunities.length} opportunité${opportunities.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Color(0xFF9B5CFF),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.work_outline,
              size: 40,
              color: Color(0xFF9B5CFF),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamDetailPage extends StatelessWidget {
  final String logo;
  final String clubName;
  final String city;
  final String description;
  const TeamDetailPage({
    required this.logo,
    required this.clubName,
    required this.city,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final players = [
      {
        'name': 'Victor Wembanyama',
        'position': 'Pivot',
        'image': 'assets/players.png',
      },
      {
        'name': 'Evan Fournier',
        'position': 'Arrière',
        'image': 'assets/players.png',
      },
      {
        'name': 'Nando De Colo',
        'position': 'Meneur',
        'image': 'assets/players.png',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(clubName),
        backgroundColor: const Color(0xFF111014),
      ),
      backgroundColor: const Color(0xFF111014),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(backgroundImage: AssetImage(logo), radius: 48),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              clubName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              city,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              description,
              style: const TextStyle(color: Color(0xFF9B5CFF), fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Joueurs de l\'équipe',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          ...players.map(
            (player) => Card(
              color: const Color(0xFF18171C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(player['image']!),
                  radius: 24,
                ),
                title: Text(
                  player['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  player['position']!,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
