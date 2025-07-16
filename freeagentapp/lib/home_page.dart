import 'package:flutter/material.dart';
import 'opportunities_page.dart';
import 'contents_page.dart';
import 'profile_page.dart';
import 'messages_page.dart';
import 'matching_page.dart';
import 'players_page.dart';
import 'coaches_page.dart';
import 'teams_page.dart';
import 'dietitians_page.dart';
import 'lawyers_page.dart';
import 'handibasket_page.dart';
import 'subscription_page.dart';
import 'utils/premium_navigation.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';
import 'services/opportunity_service.dart';
import 'services/subscription_service.dart';
import 'services/profile_photo_service.dart';
import 'services/message_service.dart';
import 'widgets/user_avatar.dart';
import 'dart:async';

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
  final SubscriptionService _subscriptionService = SubscriptionService();
  final MessageService _messageService = MessageService();
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _popularClubs = [];
  List<Map<String, dynamic>> _recentOpportunities = [];
  bool _isLoading = true;
  bool _hasShownPremiumPopup = false;
  bool _isPremiumUser = false;
  int _unreadMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialiser l'authentification et nettoyer les données corrompues
      await _authService.initializeAuth();

      // Charger les données
      await _loadData();
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final userData = await _authService.getUserData();
      final clubs = await _profileService.getClubs();
      final opportunities = await _opportunityService.getOpportunities();
      final unreadCount = await _messageService.getUnreadMessagesCount();

      setState(() {
        _userData = userData;
        _popularClubs = clubs;
        _recentOpportunities =
            opportunities.take(3).toList(); // Les 3 plus récentes
        _unreadMessagesCount = unreadCount;
        _isLoading = false;
      });

      // Vérifier le statut premium et la popup
      await _checkPremiumStatus();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final subscriptionStatus =
          await _subscriptionService.getSubscriptionStatus();

      setState(() {
        _isPremiumUser = subscriptionStatus.isPremium;
      });

      // Si l'utilisateur n'est pas premium ET n'a pas encore vu le popup
      if (!subscriptionStatus.isPremium && !_hasShownPremiumPopup) {
        _hasShownPremiumPopup = true;

        // Attendre un peu pour que l'interface se charge complètement
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          _showPremiumPopup();
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut premium: $e');
    }
  }

  // Méthode pour rafraîchir le statut premium et les messages (utilisable depuis d'autres écrans)
  Future<void> refreshData() async {
    try {
      final subscriptionStatus =
          await _subscriptionService.getSubscriptionStatus();
      final unreadCount = await _messageService.getUnreadMessagesCount();

      setState(() {
        _isPremiumUser = subscriptionStatus.isPremium;
        _unreadMessagesCount = unreadCount;
      });
    } catch (e) {
      print('Erreur lors du rafraîchissement des données: $e');
    }
  }

  void _showPremiumPopup() {
    PremiumNavigation.showPremiumDialog(
      context,
      customMessage:
          'Accède à toutes les opportunités et fonctionnalités premium pour booster ta carrière !',
    );
  }

  Widget _buildBenefit(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeContent(
        userData: _userData,
        popularClubs: _popularClubs,
        recentOpportunities: _recentOpportunities,
        isLoading: _isLoading,
        isPremiumUser: _isPremiumUser,
        unreadMessagesCount: _unreadMessagesCount,
        onRefresh: _loadData,
        onNavigateToOpportunities: () {
          setState(() {
            _selectedIndex = 1; // Index de l'onglet Opportunités
          });
        },
        onNavigateToMessages: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessagesPage()),
          ).then((_) => refreshData()); // Rafraîchir après retour
        },
        onPremiumStatusChanged: refreshData,
      ),
      const OpportunitiesPage(),
      const ContentsPage(),
      const MatchingPage(),
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
        backgroundColor: const Color(0xFF111014),
        selectedItemColor: const Color(0xFF9B5CFF),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Opportunités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Contenus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Matching',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      body: SafeArea(child: pages[_selectedIndex]),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final List<Map<String, dynamic>> popularClubs;
  final List<Map<String, dynamic>> recentOpportunities;
  final bool isLoading;
  final bool isPremiumUser;
  final int unreadMessagesCount;
  final VoidCallback onRefresh;
  final VoidCallback onNavigateToOpportunities;
  final VoidCallback onNavigateToMessages;
  final VoidCallback onPremiumStatusChanged;

  const _HomeContent({
    required this.userData,
    required this.popularClubs,
    required this.recentOpportunities,
    required this.isLoading,
    required this.isPremiumUser,
    required this.unreadMessagesCount,
    required this.onRefresh,
    required this.onNavigateToOpportunities,
    required this.onNavigateToMessages,
    required this.onPremiumStatusChanged,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final ProfilePhotoService _profilePhotoService = ProfilePhotoService();
  String? _profileImageUrl;
  bool _hasCustomImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    try {
      final photoData = await _profilePhotoService.getCurrentProfileImage();
      if (photoData != null) {
        setState(() {
          _profileImageUrl = photoData['imageUrl'];
          _hasCustomImage = photoData['hasCustomImage'] ?? false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de la photo de profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
        widget.onPremiumStatusChanged();
        await _loadProfilePhoto();
      },
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
                    UserAvatar(
                      name: widget.userData?['name'],
                      imageUrl: _profileImageUrl,
                      hasCustomImage: _hasCustomImage,
                      radius: 28,
                      profileType: widget.userData?['profile_type'],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
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
                          widget.userData?['name'] ?? 'Utilisateur',
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 4),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.message_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: widget.onNavigateToMessages,
                        ),
                        if (widget.unreadMessagesCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9B5CFF),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                widget.unreadMessagesCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bouton Premium uniquement pour les utilisateurs gratuits
            if (!widget.isPremiumUser) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: () async {
                    PremiumNavigation.navigateToSubscription(context);
                    // Rafraîchir le statut premium après le retour
                    widget.onPremiumStatusChanged();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B5CFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFE66D),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Passer Premium',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE66D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Dès 5,99€',
                          style: TextStyle(
                            color: Color(0xFF111014),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Carousel
            const CarouselWidget(),
            const SizedBox(height: 32),

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
                  icon: Icons.accessible,
                  label: 'Handibasket',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HandibasketPage()),
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

            // Opportunités
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
              opportunities: widget.recentOpportunities,
              onNavigateToOpportunities: widget.onNavigateToOpportunities,
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
            if (widget.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.popularClubs.length,
                  itemBuilder: (context, index) {
                    final club = widget.popularClubs[index];
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

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({Key? key}) : super(key: key);

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image': 'assets/players.png',
      'title': 'Trouve ton équipe idéale',
      'subtitle': 'Connecte-toi avec les meilleurs clubs',
      'color': const Color(0xFF9B5CFF),
    },
    {
      'image': 'assets/coach.png',
      'title': 'Développe ton talent',
      'subtitle': 'Accède aux meilleurs coaches',
      'color': const Color(0xFFFF6B6B),
    },
    {
      'image': 'assets/teams.png',
      'title': 'Rejoins la communauté',
      'subtitle': 'Des milliers d\'opportunités t\'attendent',
      'color': const Color(0xFF4ECDC4),
    },
    {
      'image': 'assets/highlights.png',
      'title': 'Montre ton potentiel',
      'subtitle': 'Partage tes meilleurs moments',
      'color': const Color(0xFFFFE66D),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _carouselItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _carouselItems.length,
              itemBuilder: (context, index) {
                final item = _carouselItems[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        item['color'].withOpacity(0.8),
                        item['color'].withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background image
                      Positioned.fill(
                        child: Image.asset(
                          item['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Overlay
                      Container(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      // Content
                      Positioned(
                        left: 20,
                        bottom: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['subtitle'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _carouselItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF9B5CFF)
                    : Colors.white30,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
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
            child: UserAvatar(
              name: clubName,
              imageUrl: null, // Pas d'image URL pour ce cas statique
              hasCustomImage: false,
              radius: 48,
              profileType: 'club',
            ),
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
