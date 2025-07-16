import 'package:flutter/material.dart';
import 'services/matching_service.dart';
import 'widgets/user_avatar.dart';
import 'players_page.dart';
import 'coaches_page.dart';
import 'clubs_list_page.dart';
import 'handibasket_page.dart';
import 'services/message_service.dart';
import 'messages_page.dart';
import 'services/subscription_service.dart';
import 'utils/premium_messages.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({Key? key}) : super(key: key);

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage>
    with TickerProviderStateMixin {
  final MatchingService _matchingService = MatchingService();
  final MessageService _messageService = MessageService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  late TabController _tabController;

  List<MatchProfile> _topMatches = [];
  List<MatchProfile> _recentMatches = [];
  List<MatchProfile> _allSuggestions = [];
  MatchingStats? _stats;

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSubscriptionStatus();
    _loadMatchingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMatchingData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger les données en parallèle
      final results = await Future.wait([
        _matchingService.getTopMatches(limit: 5),
        _matchingService.getRecentMatches(limit: 10),
        _matchingService.getPersonalizedSuggestions(maxResults: 30),
        _matchingService.getMatchingStats(),
      ]);

      setState(() {
        _topMatches = results[0] as List<MatchProfile>;
        _recentMatches = results[1] as List<MatchProfile>;
        _allSuggestions = results[2] as List<MatchProfile>;
        _stats = results[3] as MatchingStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadMatchingData();
    setState(() => _isRefreshing = false);
  }

  Future<void> _sendMessage(MatchProfile profile) async {
    try {
      final result = await _messageService.createConversation(
        receiverId: int.parse(profile.id),
        content:
            'Bonjour ! J\'ai vu votre profil sur FreeAgent et je pense que nous pourrions collaborer.',
        subject: 'Match FreeAgent - ${profile.name}',
      );

      if (result != null && result['conversationId'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(
              conversationId: result['conversationId'],
              contactName: profile.name,
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

  void _navigateToProfile(MatchProfile profile) {
    switch (profile.type) {
      case 'player':
        // Navigate to players page - could be enhanced to show specific player
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlayersPage()),
        );
        break;
      case 'coach':
        // Navigate to coaches page - could be enhanced to show specific coach
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoachesPage()),
        );
        break;
      case 'club':
        // Navigate to clubs list page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClubsListPage()),
        );
        break;
      case 'handibasket':
        // Navigate to handibasket page - could be enhanced to show specific player
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HandibasketPage()),
        );
        break;
      default:
        return;
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final subscriptionStatus =
          await _subscriptionService.getSubscriptionStatus();
      setState(() {
        _isPremium = subscriptionStatus.isPremium;
      });
    } catch (e) {
      setState(() {
        _isPremium = false;
      });
    }
  }

  void _showPremiumDialog() {
    PremiumMessages.showPremiumDialog(context, 'player', 'matching',
        onUpgrade: () {
      Navigator.of(context).pushNamed('/premium');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        elevation: 0,
        title: const Text(
          'Suggestions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du chargement',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Une erreur inconnue s\'est produite',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMatchingData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Statistiques en haut
        _buildStatsCard(),
        const SizedBox(height: 16),

        // Onglets
        Container(
          color: const Color(0xFF18171C),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF9B5CFF),
            unselectedLabelColor: Colors.white54,
            indicatorColor: const Color(0xFF9B5CFF),
            tabs: const [
              Tab(text: 'Top Matches'),
              Tab(text: 'Récents'),
              Tab(text: 'Tous'),
              Tab(text: 'Découvrir'),
            ],
          ),
        ),

        // Contenu des onglets
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTopMatchesTab(),
              _buildRecentMatchesTab(),
              _buildAllSuggestionsTab(),
              _buildDiscoverTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9B5CFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: Color(0xFF9B5CFF),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Vos statistiques de matching',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  _stats!.totalMatches.toString(),
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Excellents',
                  _stats!.excellentMatches.toString(),
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Bons',
                  _stats!.goodMatches.toString(),
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Score moyen',
                  '${(_stats!.averageScore * 100).round()}%',
                  const Color(0xFF9B5CFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTopMatchesTab() {
    if (_topMatches.isEmpty) {
      return _buildEmptyState(
        'Aucun match excellent trouvé',
        'Complétez votre profil pour améliorer vos suggestions',
        Icons.star_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _topMatches.length,
      itemBuilder: (context, index) {
        final match = _topMatches[index];
        return _buildMatchCard(match, showBadge: true);
      },
    );
  }

  Widget _buildRecentMatchesTab() {
    if (_recentMatches.isEmpty) {
      return _buildEmptyState(
        'Aucun match récent',
        'Revenez plus tard pour voir de nouveaux profils',
        Icons.access_time,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentMatches.length,
      itemBuilder: (context, index) {
        final match = _recentMatches[index];
        return _buildMatchCard(match, showNew: match.isNew);
      },
    );
  }

  Widget _buildAllSuggestionsTab() {
    if (_allSuggestions.isEmpty) {
      return _buildEmptyState(
        'Aucune suggestion disponible',
        'Vérifiez votre connexion et réessayez',
        Icons.search_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allSuggestions.length,
      itemBuilder: (context, index) {
        final match = _allSuggestions[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildDiscoverTab() {
    return FutureBuilder<List<MatchProfile>>(
      future: _matchingService.discoverProfiles(limit: 15, shuffle: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            'Erreur lors du chargement',
            snapshot.error.toString(),
            Icons.error_outline,
          );
        }

        final profiles = snapshot.data ?? [];
        if (profiles.isEmpty) {
          return _buildEmptyState(
            'Aucun profil à découvrir',
            'Tous les profils ont été explorés',
            Icons.explore_off,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final match = profiles[index];
            return _buildMatchCard(match, showDiscover: true);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchProfile match,
      {bool showBadge = false,
      bool showNew = false,
      bool showDiscover = false}) {
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: const Color(0xFF18171C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: _isPremium
                ? () => _navigateToProfile(match)
                : _showPremiumDialog,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec avatar et info
                  Row(
                    children: [
                      UserAvatar(
                        name: match.name,
                        imageUrl: match.profileImageUrl,
                        hasCustomImage: match.profileImageUrl != null,
                        radius: 30,
                        profileType: match.type,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _matchingService.formatCandidateType(match.type),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            if (match.position != null ||
                                match.level != null ||
                                match.location != null)
                              const SizedBox(height: 4),
                            if (match.position != null)
                              Text(
                                match.position!,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            if (match.level != null)
                              Text(
                                match.level!,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            if (match.location != null)
                              Text(
                                match.location!,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Score de compatibilité
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: match.matchColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: match.matchColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: match.matchColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${match.compatibilityPercentage}%',
                              style: TextStyle(
                                color: match.matchColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        match.compatibilityText,
                        style: TextStyle(
                          color: match.matchColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Raisons du match
                  if (match.matchReasons.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: match.matchReasons.take(3).map((reason) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reason,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Boutons d'action
                  Row(
                    children: [
                      if (_isPremium) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToProfile(match),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9B5CFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.person, size: 18),
                            label: const Text('Voir profil'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _sendMessage(match),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFF9B5CFF),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side:
                                    const BorderSide(color: Color(0xFF9B5CFF)),
                              ),
                            ),
                            icon: const Icon(Icons.message, size: 18),
                            label: const Text('Message'),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showPremiumDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.lock, size: 18),
                            label: const Text('Passer Premium'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!_isPremium)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock, color: Colors.white, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Profil correspondant flouté\nPassez Premium pour voir les matchs',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Badges
        if (showBadge && match.matchLevel == 'excellent')
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TOP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        if (showNew)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NOUVEAU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
