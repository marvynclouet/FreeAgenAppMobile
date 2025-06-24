import 'package:flutter/material.dart';
import 'messages_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({super.key});

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProfileType;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _profileTypes = [
    {
      'type': 'player',
      'label': 'Joueur',
      'icon': Icons.sports_soccer,
    },
    {
      'type': 'coach',
      'label': 'Coach',
      'icon': Icons.sports,
    },
    {
      'type': 'lawyer',
      'label': 'Avocat',
      'icon': Icons.gavel,
    },
    {
      'type': 'team',
      'label': 'Équipe',
      'icon': Icons.groups,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.length >= 2) {
      _searchUsers();
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _searchUsers() async {
    setState(() {
      _isSearching = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final query = _searchController.text.trim();
      String url = 'http://192.168.1.43:3000/api/users/search?query=$query';
      if (_selectedProfileType != null) {
        url += '&type=$_selectedProfileType';
      }
      final uri = Uri.parse(url);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List users = json.decode(response.body);
        setState(() {
          _searchResults = users
              .map<Map<String, dynamic>>((user) => {
                    'id': user['id'],
                    'name': user['name'],
                    'type': user['profile_type'],
                    'team': '', // À adapter si tu veux afficher l'équipe
                    'imageUrl':
                        'https://via.placeholder.com/50', // À adapter si tu as une vraie image
                  })
              .toList();
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Color get _backgroundColor => const Color(0xFF111014);
  Color get _cardColor => const Color(0xFF1A1822);
  Color get _accentViolet => const Color(0xFF7C3AED);
  Color get _textColor => Colors.white;
  Color get _subtitleColor => Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Nouveau message'),
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Type de profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _profileTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final type = _profileTypes[index];
                      final isSelected = _selectedProfileType == type['type'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedProfileType = null; // Désélectionner
                            } else {
                              _selectedProfileType = type['type'];
                            }
                            _searchResults = [];
                          });
                          if (_searchController.text.length >= 2) {
                            _searchUsers();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? _accentViolet : _cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                type['icon'],
                                color:
                                    isSelected ? Colors.white : _accentViolet,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                type['label'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: _textColor),
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                hintStyle: TextStyle(color: _subtitleColor),
                prefixIcon: Icon(Icons.search, color: _accentViolet),
                filled: true,
                fillColor: _cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Sélectionnez un type de profil et commencez à rechercher'
                              : 'Aucun résultat trouvé',
                          style: TextStyle(
                            color: _subtitleColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user['imageUrl']),
                                backgroundColor: _backgroundColor,
                              ),
                              title: Text(
                                user['name'],
                                style: TextStyle(
                                  color: _textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _accentViolet,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      user['type'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      user['team'],
                                      style: TextStyle(
                                        color: _subtitleColor,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: _accentViolet, size: 18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessagesPage(
                                      selectedUserId: user['id'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
