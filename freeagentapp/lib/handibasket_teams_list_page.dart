import 'package:flutter/material.dart';
import 'services/handibasket_team_service.dart';

class HandibasketTeamsListPage extends StatefulWidget {
  const HandibasketTeamsListPage({Key? key}) : super(key: key);

  @override
  _HandibasketTeamsListPageState createState() =>
      _HandibasketTeamsListPageState();
}

class _HandibasketTeamsListPageState extends State<HandibasketTeamsListPage> {
  final HandibasketTeamService _teamService = HandibasketTeamService();
  List<Map<String, dynamic>> _teams = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedLevel = '';
  String _selectedRegion = '';

  final List<String> _levels = [
    'Départemental',
    'Régional',
    'National',
    'International',
  ];

  final List<String> _regions = [
    'Île-de-France',
    'Auvergne-Rhône-Alpes',
    'Occitanie',
    'Nouvelle-Aquitaine',
    'Hauts-de-France',
    'Grand Est',
    'Pays de la Loire',
    'Bretagne',
    'Normandie',
    'Centre-Val de Loire',
    'Bourgogne-Franche-Comté',
    'Provence-Alpes-Côte d\'Azur',
    'Corse',
  ];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final teams = await _teamService.searchTeams(
        level: _selectedLevel.isNotEmpty ? _selectedLevel : null,
        region: _selectedRegion.isNotEmpty ? _selectedRegion : null,
        keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _teams = teams;
      });
    } catch (e) {
      print('Erreur lors du chargement des équipes: $e');
      _showErrorDialog('Erreur lors du chargement des équipes');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher une équipe...',
              prefixIcon: Icon(Icons.search, color: Colors.white),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Niveau',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLevel.isNotEmpty ? _selectedLevel : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value ?? '';
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Tous les niveaux'),
                    ),
                    ..._levels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Région',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedRegion.isNotEmpty ? _selectedRegion : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value ?? '';
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Toutes les régions'),
                    ),
                    ..._regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadTeams,
              child: const Text('Rechercher'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _showTeamDetails(team),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team['team_name'] ?? 'Nom inconnu',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${team['city'] ?? 'Ville inconnue'}, ${team['region'] ?? 'Région inconnue'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLevelColor(team['level']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      team['level'] ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (team['description'] != null &&
                  team['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  team['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              if (team['website'] != null &&
                  team['website'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.language, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        team['website'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String? level) {
    switch (level) {
      case 'International':
        return Colors.purple;
      case 'National':
        return Colors.red;
      case 'Régional':
        return Colors.orange;
      case 'Départemental':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showTeamDetails(Map<String, dynamic> team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(team['team_name'] ?? 'Équipe'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Ville', team['city']),
              _buildDetailRow('Région', team['region']),
              _buildDetailRow('Niveau', team['level']),
              _buildDetailRow('Division', team['division']),
              _buildDetailRow(
                  'Année de création', team['founded_year']?.toString()),
              _buildDetailRow('Description', team['description']),
              _buildDetailRow('Palmarès', team['achievements']),
              _buildDetailRow('Personne de contact', team['contact_person']),
              _buildDetailRow('Téléphone', team['phone']),
              _buildDetailRow('Email', team['email_contact']),
              _buildDetailRow('Site web', team['website']),
              _buildDetailRow('Installations', team['facilities']),
              _buildDetailRow(
                  'Horaires d\'entraînement', team['training_schedule']),
              _buildDetailRow(
                  'Besoins de recrutement', team['recruitment_needs']),
              _buildDetailRow('Budget', team['budget_range']),
              _buildDetailRow('Hébergement',
                  team['accommodation_offered'] == true ? 'Oui' : 'Non'),
              _buildDetailRow('Transport',
                  team['transport_offered'] == true ? 'Oui' : 'Non'),
              _buildDetailRow('Support médical',
                  team['medical_support'] == true ? 'Oui' : 'Non'),
              _buildDetailRow('Exigences joueurs', team['player_requirements']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Équipes Handibasket'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _teams.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune équipe trouvée',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _teams.length,
                        itemBuilder: (context, index) {
                          return _buildTeamCard(_teams[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
