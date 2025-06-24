import 'package:flutter/material.dart';
import 'services/profile_service.dart';

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
                leading: const Icon(Icons.group),
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
