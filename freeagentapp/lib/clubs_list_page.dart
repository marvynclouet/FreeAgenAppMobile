import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'widgets/user_avatar.dart';

class ClubsListPage extends StatelessWidget {
  const ClubsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Équipes & Clubs')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ProfileService().getClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: \\${snapshot.error}'));
          }
          final clubs = snapshot.data ?? [];
          if (clubs.isEmpty) {
            return const Center(child: Text('Aucun club trouvé.'));
          }
          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return ListTile(
                leading: UserAvatar(
                  name: club['name'],
                  imageUrl: club['profile_image_url'],
                  hasCustomImage: club['profile_image_url'] != null,
                  radius: 24,
                  profileType: 'club',
                ),
                title: Text(club['name'] ?? ''),
                subtitle: Text(club['email'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
