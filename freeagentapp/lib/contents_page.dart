import 'package:flutter/material.dart';
import 'services/content_service.dart';
import 'services/subscription_service.dart';
import 'utils/premium_messages.dart';
import 'utils/premium_navigation.dart';
import 'widgets/create_post_widget.dart';
import 'widgets/feed_post_widget.dart';

class ContentsPage extends StatefulWidget {
  const ContentsPage({Key? key}) : super(key: key);

  @override
  State<ContentsPage> createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {
  final ContentService _contentService = ContentService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Map<String, dynamic>> _feed = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final subscriptionStatus =
          await _subscriptionService.getSubscriptionStatus();
      setState(() {
        _isPremium = subscriptionStatus.isPremium;
      });
    } catch (e) {
      print('Erreur lors du chargement du statut d\'abonnement: $e');
      setState(() {
        _isPremium = false;
      });
    }
  }

  Future<void> _loadFeed() async {
    try {
      final feed = await _contentService.getFeed();
      setState(() {
        _feed = feed;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement du fil d\'actualités: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadFeed();
    setState(() {
      _isRefreshing = false;
    });
  }

  void _openCreatePostModal() async {
    // Vérifier le statut premium AVANT d'ouvrir le modal
    try {
      final subscriptionStatus =
          await _subscriptionService.getSubscriptionStatus();
      final isFreemium =
          subscriptionStatus == null || subscriptionStatus.type == 'free';

      if (isFreemium) {
        // Afficher le pop-up premium pour la création de posts
        PremiumMessages.showPremiumDialog(context, 'player', 'create_post',
            onUpgrade: () {
          PremiumNavigation.navigateToSubscription(context);
        });
        return; // Bloquer la création de post
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut premium: $e');
      // En cas d'erreur, on affiche le dialog par sécurité
      PremiumMessages.showPremiumDialog(context, 'player', 'create_post',
          onUpgrade: () {
        PremiumNavigation.navigateToSubscription(context);
      });
      return;
    }

    // Si l'utilisateur est premium, ouvrir le modal de création
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF18171C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: CreatePostWidget(
            onPostCreated: () {
              Navigator.of(context).pop();
              _refreshFeed();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePostModal,
        backgroundColor:
            _isPremium ? const Color(0xFF9B5CFF) : const Color(0xFF666666),
        child: Icon(
          _isPremium ? Icons.edit : Icons.lock,
          color: Colors.white,
        ),
        tooltip: _isPremium ? 'Publier' : 'Publier (Premium requis)',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Fil d\'actualités',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _refreshFeed,
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Fil d'actualités
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF9B5CFF)),
                      ),
                    )
                  : _feed.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _refreshFeed,
                          color: const Color(0xFF9B5CFF),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _feed.length,
                            itemBuilder: (context, index) {
                              return FeedPostWidget(
                                post: _feed[index],
                                onRefresh: _refreshFeed,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feed,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun contenu pour le moment',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isPremium
                ? 'Soyez le premier à partager quelque chose !'
                : 'Connectez-vous pour voir le contenu et interagir avec la communauté !',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!_isPremium) ...[
            ElevatedButton(
              onPressed: () {
                PremiumNavigation.navigateToSubscription(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B5CFF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Devenir Premium'),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _refreshFeed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            child: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }
}
