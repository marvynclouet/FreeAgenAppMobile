import 'package:flutter/material.dart';
import 'services/profile_service.dart';

class PlayersListPage extends StatelessWidget {
  const PlayersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Joueurs')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ProfileService().getPlayers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: \\${snapshot.error}'));
          }
          final players = snapshot.data ?? [];
          if (players.isEmpty) {
            return const Center(child: Text('Aucun joueur trouvé.'));
          }
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(player['name'] ?? ''),
                subtitle: Text(player['email'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
