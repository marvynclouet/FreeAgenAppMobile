import 'package:flutter/material.dart';

class PremiumMessages {
  // Messages personnalisés selon le profil et l'action
  static Map<String, Map<String, Map<String, String>>> messages = {
    'player': {
      'apply': {
        'title': '🏀 Débloque ton potentiel !',
        'subtitle': 'En tant que joueur, tu es limité à 0 candidatures',
        'description':
            'Les clubs cherchent des talents comme toi ! Ne rate pas tes opportunités.',
        'cta': 'Débloquer mes candidatures'
      },
      'message': {
        'title': '💬 Connecte-toi avec les clubs !',
        'subtitle': 'La messagerie est réservée aux membres premium',
        'description': 'Échange directement avec les recruteurs et coaches.',
        'cta': 'Activer la messagerie'
      },
      'post': {
        'title': '📢 Fais-toi remarquer !',
        'subtitle': 'Créer des annonces est réservé au premium',
        'description':
            'Poste tes propres recherches d\'équipe et attire les clubs.',
        'cta': 'Créer mon annonce'
      }
    },
    'coach': {
      'apply': {
        'title': '🎯 Trouve ton équipe idéale !',
        'subtitle': 'En tant que coach, tu es limité à 0 candidatures',
        'description':
            'Les meilleures équipes t\'attendent. Ne limite pas tes options.',
        'cta': 'Débloquer mes candidatures'
      },
      'message': {
        'title': '📞 Contacte tes futurs joueurs !',
        'subtitle': 'La messagerie est réservée aux membres premium',
        'description':
            'Recrute les meilleurs talents en communiquant directement.',
        'cta': 'Activer la messagerie'
      },
      'post': {
        'title': '🏆 Recrute ton équipe !',
        'subtitle': 'Créer des annonces est réservé au premium',
        'description':
            'Poste tes recherches de joueurs et constitue ton équipe.',
        'cta': 'Créer mon annonce'
      }
    },
    'club': {
      'apply': {
        'title': '⭐ Accède aux meilleurs talents !',
        'subtitle': 'Votre club est limité à 0 candidatures',
        'description':
            'Recrutez les joueurs et coaches d\'exception sans limites.',
        'cta': 'Débloquer les candidatures'
      },
      'message': {
        'title': '🤝 Négociez directement !',
        'subtitle': 'La messagerie est réservée aux membres premium',
        'description':
            'Contactez joueurs et coaches pour finaliser vos recrutements.',
        'cta': 'Activer la messagerie'
      },
      'post': {
        'title': '📈 Développez votre club !',
        'subtitle': 'Créer des annonces est réservé au premium',
        'description':
            'Publiez vos offres de recrutement et attirez les talents.',
        'cta': 'Créer votre annonce'
      }
    }
  };

  // Avantages premium selon le profil
  static Map<String, List<String>> benefits = {
    'player': [
      '🏀 Candidatures illimitées aux équipes',
      '💬 Messages directs avec les clubs',
      '📢 Créer tes propres annonces',
      '🔔 Notifications prioritaires',
      '⭐ Boost de visibilité de profil'
    ],
    'coach': [
      '🎯 Candidatures illimitées aux équipes',
      '📞 Messages directs avec les clubs',
      '🏆 Créer tes annonces de recrutement',
      '🔔 Notifications prioritaires',
      '⭐ Boost de visibilité de profil'
    ],
    'club': [
      '⭐ Candidatures illimitées aux talents',
      '🤝 Messages directs avec joueurs/coaches',
      '📈 Créer vos offres de recrutement',
      '🔔 Notifications prioritaires',
      '🏆 Support prioritaire'
    ]
  };

  // Obtenir le message selon le profil et l'action
  static Map<String, String> getMessage(String profileType, String action) {
    // Normaliser le type de profil
    String normalizedProfile = profileType.toLowerCase();
    if (normalizedProfile == 'player')
      normalizedProfile = 'player';
    else if (normalizedProfile == 'coach')
      normalizedProfile = 'coach';
    else
      normalizedProfile = 'club'; // Par défaut

    return messages[normalizedProfile]?[action] ?? messages['player']![action]!;
  }

  // Obtenir les avantages selon le profil
  static List<String> getBenefits(String profileType) {
    String normalizedProfile = profileType.toLowerCase();
    if (normalizedProfile == 'player')
      normalizedProfile = 'player';
    else if (normalizedProfile == 'coach')
      normalizedProfile = 'coach';
    else
      normalizedProfile = 'club';

    return benefits[normalizedProfile] ?? benefits['player']!;
  }

  // Pop-up premium personnalisé
  static void showPremiumDialog(
      BuildContext context, String profileType, String action,
      {VoidCallback? onUpgrade}) {
    final message = getMessage(profileType, action);
    final profileBenefits = getBenefits(profileType);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.diamond, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      message['subtitle']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message['description']!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade50, Colors.orange.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Avec Premium, débloquez :',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...profileBenefits.map((benefit) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offre limitée : -20% sur votre premier mois !',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Plus tard',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onUpgrade != null) {
                    onUpgrade();
                  } else {
                    Navigator.pushNamed(context, '/premium');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  message['cta']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Bannière flottante moins intrusive
  static Widget buildFloatingBanner(BuildContext context, String profileType) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚀 Version gratuite',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profileType == 'player'
                      ? 'Débloquez vos candidatures !'
                      : profileType == 'coach'
                          ? 'Recrutez sans limites !'
                          : 'Accédez aux meilleurs talents !',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/premium'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'Premium',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
