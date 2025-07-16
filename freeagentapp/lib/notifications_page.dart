import 'package:flutter/material.dart';
import 'services/opportunity_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final OpportunityService _opportunityService = OpportunityService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final opportunities = await _opportunityService.getOpportunities();

      // Convertir les opportunités en notifications avec timestamp simulé
      final notifications = opportunities.map((opportunity) {
        return {
          'id': opportunity['id'],
          'type': 'nouvelle_opportunite',
          'title': 'Nouvelle opportunité postée',
          'message': opportunity['title'] ?? 'Opportunité sans titre',
          'opportunityType': opportunity['type'] ?? 'autre',
          'location': opportunity['location'] ?? 'Non spécifié',
          'description': opportunity['description'] ?? 'Aucune description',
          'timestamp': DateTime.now().subtract(Duration(
            hours: (opportunity['id'] ?? 0) % 72, // Simulation timestamp
          )),
          'isRead': false,
        };
      }).toList();

      // Trier par timestamp décroissant (plus récent en premier)
      notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        return 'Autre opportunité';
      default:
        return type;
    }
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'equipe_recherche_joueur':
        return const Color(0xFF4CAF50);
      case 'joueur_recherche_equipe':
        return const Color(0xFF2196F3);
      case 'coach_recherche_equipe':
        return const Color(0xFFFF9800);
      case 'coach_recherche_joueur':
        return const Color(0xFFE91E63);
      case 'equipe_recherche_coach':
        return const Color(0xFF9C27B0);
      case 'service_professionnel':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF9B5CFF);
    }
  }

  IconData getTypeIcon(String type) {
    switch (type) {
      case 'equipe_recherche_joueur':
        return Icons.person_add;
      case 'joueur_recherche_equipe':
        return Icons.search;
      case 'coach_recherche_equipe':
        return Icons.sports;
      case 'coach_recherche_joueur':
        return Icons.supervisor_account;
      case 'equipe_recherche_coach':
        return Icons.group_add;
      case 'service_professionnel':
        return Icons.business;
      default:
        return Icons.work;
    }
  }

  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Maintenant';
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (int i = 0; i < _notifications.length; i++) {
                  _notifications[i]['isRead'] = true;
                }
              });
            },
            child: const Text(
              'Tout marquer lu',
              style: TextStyle(
                color: Color(0xFF9B5CFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF9B5CFF),
                ),
              )
            : _notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucune notification',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Les nouvelles opportunités apparaîtront ici',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['isRead'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isRead
                              ? const Color(0xFF18171C)
                              : const Color(0xFF1F1E24),
                          borderRadius: BorderRadius.circular(16),
                          border: !isRead
                              ? Border.all(
                                  color:
                                      const Color(0xFF9B5CFF).withOpacity(0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  getTypeColor(notification['opportunityType'])
                                      .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              getTypeIcon(notification['opportunityType']),
                              color:
                                  getTypeColor(notification['opportunityType']),
                              size: 24,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isRead
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                getTimeAgo(notification['timestamp']),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getTypeColor(
                                      notification['opportunityType']),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  getTypeLabel(notification['opportunityType']),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification['message'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (notification['location'] !=
                                  'Non spécifié') ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white54,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      notification['location'],
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            _markAsRead(index);
                            // Ici vous pouvez naviguer vers les détails de l'opportunité
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Opportunité: ${notification['message']}'),
                                backgroundColor: const Color(0xFF9B5CFF),
                              ),
                            );
                          },
                          trailing: !isRead
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF9B5CFF),
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
