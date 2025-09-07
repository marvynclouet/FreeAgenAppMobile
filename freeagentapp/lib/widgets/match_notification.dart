import 'package:flutter/material.dart';
import '../services/matching_service.dart';
import '../widgets/user_avatar.dart';

class MatchNotification extends StatelessWidget {
  final MatchProfile match;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const MatchNotification({
    Key? key,
    required this.match,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9B5CFF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              UserAvatar(
                name: match.name,
                imageUrl: match.profileImageUrl,
                hasCustomImage: match.profileImageUrl != null,
                radius: 24,
                profileType: match.type,
              ),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Color(0xFF9B5CFF),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Nouveau match !',
                          style: TextStyle(
                            color: Color(0xFF9B5CFF),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${match.compatibilityPercentage}% compatible',
                      style: TextStyle(
                        color: match.matchColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (match.matchReasons.isNotEmpty)
                      Text(
                        match.matchReasons.first,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // Badge et actions
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: match.matchColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      match.matchLevel.toUpperCase(),
                      style: TextStyle(
                        color: match.matchColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (onDismiss != null)
                    GestureDetector(
                      onTap: onDismiss,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchNotificationBanner extends StatefulWidget {
  final List<MatchProfile> newMatches;
  final VoidCallback? onViewAll;

  const MatchNotificationBanner({
    Key? key,
    required this.newMatches,
    this.onViewAll,
  }) : super(key: key);

  @override
  State<MatchNotificationBanner> createState() =>
      _MatchNotificationBannerState();
}

class _MatchNotificationBannerState extends State<MatchNotificationBanner> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || widget.newMatches.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9B5CFF).withOpacity(0.2),
            const Color(0xFF9B5CFF).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9B5CFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFF9B5CFF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nouveaux matches !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.newMatches.length} nouveau${widget.newMatches.length > 1 ? 'x' : ''} profil${widget.newMatches.length > 1 ? 's' : ''} compatible${widget.newMatches.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = false;
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Aperçu des premiers matches
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.newMatches.take(5).length,
                itemBuilder: (context, index) {
                  final match = widget.newMatches[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        UserAvatar(
                          name: match.name,
                          imageUrl: match.profileImageUrl,
                          hasCustomImage: match.profileImageUrl != null,
                          radius: 20,
                          profileType: match.type,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${match.compatibilityPercentage}%',
                          style: TextStyle(
                            color: match.matchColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Bouton d'action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onViewAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B5CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Voir tous les matches',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchNotificationService {
  static const String _notificationKey = 'match_notifications';
  static const String _lastCheckKey = 'last_match_check';

  // Simuler des notifications de nouveaux matches
  static Future<List<MatchProfile>> getNewMatchNotifications() async {
    // Dans une vraie implémentation, cela viendrait du backend
    // Pour la démo, on simule avec des matches aléatoires
    return [];
  }

  // Marquer les notifications comme lues
  static Future<void> markNotificationsAsRead() async {
    // Sauvegarder la dernière vérification
    final now = DateTime.now().toIso8601String();
    // Utiliser SharedPreferences pour sauvegarder
    print('Notifications marquées comme lues à $now');
  }

  // Vérifier s'il y a de nouvelles notifications
  static Future<bool> hasNewNotifications() async {
    // Logique pour vérifier les nouvelles notifications
    return false; // Placeholder
  }
}
