import 'package:flutter/material.dart';
import 'register_page.dart';

class ChooseProfileTypePage extends StatelessWidget {
  const ChooseProfileTypePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileTypes = [
      {
        'id': 'player',
        'label': 'Joueur de Basket',
        'image': 'assets/player.png',
        'description':
            'Créez votre profil de joueur et trouvez des opportunités',
      },
      {
        'id': 'handibasket',
        'label': 'Joueur Handibasket',
        'image': 'assets/handibasket.png',
        'description':
            'Créez votre profil de joueur handibasket et rejoignez la communauté',
      },
      {
        'id': 'coach_pro',
        'label': 'Coach Sportif Professionnel',
        'image': 'assets/Maquette app mobile 5 mai 2025.png',
        'description':
            'Accédez à des opportunités professionnelles dans le coaching sportif',
      },
      {
        'id': 'coach_basket',
        'label': 'Coach de Basket',
        'image': 'assets/coach.png',
        'description': 'Spécialisez-vous dans le coaching de basketball',
      },
      {
        'id': 'club',
        'label': 'Club de Basketball',
        'image': 'assets/teams.png',
        'description': 'Gérez votre club et recrutez des talents',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        elevation: 0,
        title: const Text(
          'Choisir un type de profil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: profileTypes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final type = profileTypes[index];
          final String image = type['image'] ?? '';
          final String label = type['label'] ?? '';
          final String description = type['description'] ?? '';
          final String id = type['id'] ?? '';

          return Material(
            color: const Color(0xFF18171C),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        RegisterPage(profileType: label, profileId: id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage(image),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
