import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ProfileService {
  static const String baseUrl = 'http://192.168.1.43:3000/api';
  final _authService = AuthService();

  // Récupérer le profil selon le type
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _authService.getToken();
    final userData = await _authService.getUserData();

    if (token == null || userData == null) {
      throw Exception('Non authentifié');
    }

    final profileType = userData['profile_type'];
    print('Récupération du profil pour le type: $profileType');
    print('Token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/profiles/$profileType/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Réponse du serveur: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Retourner un objet vide pour un nouveau profil
      return {};
    } else {
      throw Exception(
          'Erreur lors de la récupération du profil: ${response.body}');
    }
  }

  // Mettre à jour le profil selon le type
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    final userData = await _authService.getUserData();

    if (token == null || userData == null) {
      throw Exception('Non authentifié');
    }

    final profileType = userData['profile_type'];
    print('Mise à jour du profil pour le type: $profileType');
    print('Données à envoyer: $data');

    final response = await http.put(
      Uri.parse('$baseUrl/profiles/$profileType/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    print('Réponse du serveur: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur lors de la mise à jour du profil: ${response.body}');
    }
  }

  // Obtenir les champs spécifiques selon le type de profil
  static Map<String, dynamic> getProfileFields(String profileType) {
    switch (profileType) {
      case 'player':
        return {
          'sections': [
            {
              'title': 'Informations personnelles',
              'fields': [
                {
                  'name': 'age',
                  'label': 'Âge',
                  'type': 'number',
                  'required': true,
                },
                {
                  'name': 'height',
                  'label': 'Taille (cm)',
                  'type': 'number',
                  'required': true,
                },
                {
                  'name': 'weight',
                  'label': 'Poids (kg)',
                  'type': 'number',
                  'required': true,
                },
                {
                  'name': 'position',
                  'label': 'Poste',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'Meneur',
                    'Arrière',
                    'Ailier',
                    'Ailier fort',
                    'Pivot'
                  ],
                },
                {
                  'name': 'experience_years',
                  'label': 'Années d\'expérience',
                  'type': 'number',
                  'required': true,
                },
                {
                  'name': 'level',
                  'label': 'Niveau',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'Débutant',
                    'Amateur',
                    'Semi-pro',
                    'Professionnel'
                  ],
                },
              ],
            },
            {
              'title': 'Statistiques (optionnelles)',
              'fields': [
                {
                  'name': 'stats.points',
                  'label': 'Points par match',
                  'type': 'number',
                  'required': false,
                },
                {
                  'name': 'stats.rebounds',
                  'label': 'Rebonds par match',
                  'type': 'number',
                  'required': false,
                },
                {
                  'name': 'stats.assists',
                  'label': 'Passes décisives par match',
                  'type': 'number',
                  'required': false,
                },
                {
                  'name': 'stats.steals',
                  'label': 'Interceptions par match',
                  'type': 'number',
                  'required': false,
                },
                {
                  'name': 'stats.blocks',
                  'label': 'Contres par match',
                  'type': 'number',
                  'required': false,
                },
              ],
            },
            {
              'title': 'Autres informations (optionnelles)',
              'fields': [
                {
                  'name': 'achievements',
                  'label': 'Palmarès',
                  'type': 'multiline',
                  'required': false,
                },
                {
                  'name': 'video_url',
                  'label': 'Lien vidéo',
                  'type': 'url',
                  'required': false,
                },
                {
                  'name': 'bio',
                  'label': 'Biographie',
                  'type': 'multiline',
                  'required': false,
                },
              ],
            },
          ],
        };

      case 'club':
        return {
          'sections': [
            {
              'title': 'Informations du club',
              'fields': [
                {
                  'name': 'club_name',
                  'label': 'Nom du club',
                  'type': 'text',
                  'required': true,
                },
                {
                  'name': 'address',
                  'label': 'Adresse',
                  'type': 'text',
                  'required': true,
                },
                {
                  'name': 'city',
                  'label': 'Ville',
                  'type': 'text',
                  'required': true,
                },
                {
                  'name': 'level',
                  'label': 'Niveau',
                  'type': 'text',
                  'required': true,
                  'options': ['National', 'Régional', 'Départemental', 'Local'],
                },
                {
                  'name': 'description',
                  'label': 'Description',
                  'type': 'multiline',
                  'required': true,
                },
              ],
            },
            {
              'title': 'Contact',
              'fields': [
                {
                  'name': 'phone',
                  'label': 'Téléphone',
                  'type': 'phone',
                  'required': true,
                },
                {
                  'name': 'website',
                  'label': 'Site web',
                  'type': 'url',
                  'required': false,
                },
                {
                  'name': 'social_media',
                  'label': 'Réseaux sociaux',
                  'type': 'multiline',
                  'required': false,
                },
              ],
            },
          ],
        };

      case 'coach_pro':
        return {
          'sections': [
            {
              'title': 'Informations professionnelles',
              'fields': [
                {
                  'name': 'speciality',
                  'label': 'Spécialité',
                  'type': 'text',
                  'required': true,
                },
                {
                  'name': 'experience_years',
                  'label': 'Années d\'expérience',
                  'type': 'number',
                  'required': true,
                },
                {
                  'name': 'certifications',
                  'label': 'Certifications',
                  'type': 'multiline',
                  'required': true,
                },
                {
                  'name': 'hourly_rate',
                  'label': 'Tarif horaire (€)',
                  'type': 'number',
                  'required': true,
                },
              ],
            },
            {
              'title': 'Services',
              'fields': [
                {
                  'name': 'services',
                  'label': 'Services proposés',
                  'type': 'multiline',
                  'required': true,
                },
                {
                  'name': 'availability',
                  'label': 'Disponibilités',
                  'type': 'multiline',
                  'required': true,
                },
              ],
            },
          ],
        };

      case 'juriste':
        return {
          'sections': [
            {
              'title': 'Informations professionnelles',
              'fields': [
                {
                  'name': 'speciality',
                  'label': 'Spécialité juridique',
                  'type': 'text',
                  'required': true,
                },
                {
                  'name': 'bar_number',
                  'label': 'Numéro du barreau',
                  'type': 'text',
                  'required': true,
                },
                {
                  'name': 'experience_years',
                  'label': 'Années d\'expérience',
                  'type': 'number',
                  'required': true,
                },
                {
                  'name': 'hourly_rate',
                  'label': 'Tarif horaire (€)',
                  'type': 'number',
                  'required': true,
                },
              ],
            },
            {
              'title': 'Services',
              'fields': [
                {
                  'name': 'services',
                  'label': 'Services proposés',
                  'type': 'multiline',
                  'required': true,
                },
                {
                  'name': 'availability',
                  'label': 'Disponibilités',
                  'type': 'multiline',
                  'required': true,
                },
              ],
            },
          ],
        };

      case 'dieteticienne':
        return {
          'sections': [
            {
              'title': 'Informations professionnelles',
              'fields': [
                {
                  'name': 'speciality',
                  'label': 'Spécialité',
                  'type': 'text',
                  'required': true,
                },
                {
                  'name': 'experience_years',
                  'label': 'Années d\'expérience',
                  'type': 'number',
                  'required': true,
                },
                {
                  'name': 'certifications',
                  'label': 'Certifications',
                  'type': 'multiline',
                  'required': true,
                },
                {
                  'name': 'hourly_rate',
                  'label': 'Tarif horaire (€)',
                  'type': 'number',
                  'required': true,
                },
              ],
            },
            {
              'title': 'Services',
              'fields': [
                {
                  'name': 'services',
                  'label': 'Services proposés',
                  'type': 'multiline',
                  'required': true,
                },
                {
                  'name': 'availability',
                  'label': 'Disponibilités',
                  'type': 'multiline',
                  'required': true,
                },
              ],
            },
          ],
        };

      default:
        return {
          'sections': [
            {
              'title': 'Informations de base',
              'fields': [
                {
                  'name': 'name',
                  'label': 'Nom',
                  'type': 'text',
                  'required': true,
                },
                {
                  'name': 'email',
                  'label': 'Email',
                  'type': 'email',
                  'required': true,
                },
              ],
            },
          ],
        };
    }
  }

  // Récupérer la liste des joueurs
  Future<List<Map<String, dynamic>>> getPlayers() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Non authentifié');
    }

    print('Récupération de la liste des joueurs');
    print('Token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/players'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Réponse du serveur: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
          'Erreur lors de la récupération des joueurs: ${response.body}');
    }
  }

  // Récupérer les utilisateurs par type
  Future<List<Map<String, dynamic>>> getUsersByType(String profileType) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Non authentifié');
    }

    print('Récupération des utilisateurs de type: $profileType');

    final response = await http.get(
      Uri.parse('$baseUrl/users/search?type=$profileType'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Réponse du serveur: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
          'Erreur lors de la récupération des utilisateurs: ${response.body}');
    }
  }

  // Récupérer les coachs
  Future<List<Map<String, dynamic>>> getCoaches() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/coaches'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
          'Erreur lors de la récupération des coachs: ${response.body}');
    }
  }

  // Récupérer les clubs
  Future<List<Map<String, dynamic>>> getClubs() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clubs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
          'Erreur lors de la récupération des clubs: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getOpportunities() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/opportunities'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur lors de la récupération des opportunités');
      }
    } catch (e) {
      print('Erreur lors de la récupération des opportunités: $e');
      rethrow;
    }
  }

  Future<void> createOpportunity(
      String title, String description, String type) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/opportunities'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'type': type,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Erreur lors de la création de l\'opportunité');
      }
    } catch (e) {
      print('Erreur lors de la création de l\'opportunité: $e');
      rethrow;
    }
  }

  Future<void> closeOpportunity(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/opportunities/$id/close'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la fermeture de l\'opportunité');
      }
    } catch (e) {
      print('Erreur lors de la fermeture de l\'opportunité: $e');
      rethrow;
    }
  }
}
