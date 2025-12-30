import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'config.dart';

class ProfileService {
  static String get baseUrl => ApiConfig.baseUrl;
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

    // Utiliser l'URL correcte pour handibasket
    String url;
    if (profileType == 'handibasket') {
      url = '$baseUrl/handibasket/profile';
    } else {
      url = '$baseUrl/profiles/$profileType/profile';
    }

    final response = await http.get(
      Uri.parse(url),
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

    // Mapper les données pour handibasket
    Map<String, dynamic> mappedData = data;
    if (profileType == 'handibasket') {
      mappedData = _mapHandibasketData(data);
      print('Données mappées pour handibasket: $mappedData');
    }

    // Utiliser l'URL correcte pour handibasket
    String url;
    if (profileType == 'handibasket') {
      url = '$baseUrl/handibasket/profile';
    } else {
      url = '$baseUrl/profiles/$profileType/profile';
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(mappedData),
    );

    print('Réponse du serveur: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur lors de la mise à jour du profil: ${response.body}');
    }
  }

  // Mapper les données Flutter vers les champs API handibasket
  Map<String, dynamic> _mapHandibasketData(Map<String, dynamic> flutterData) {
    // Calculer birth_date à partir de l'âge si fourni
    String birthDate = '1990-01-01'; // Valeur par défaut
    if (flutterData['age'] != null) {
      try {
        final age = int.parse(flutterData['age'].toString());
        final currentYear = DateTime.now().year;
        final birthYear = currentYear - age;
        birthDate = '$birthYear-01-01';
      } catch (e) {
        print('Erreur conversion age: $e');
      }
    }

    return {
      'birth_date': birthDate,
      'handicap_type': flutterData['handicap_type']?.toString() ?? 'moteur',
      'cat': flutterData['classification']?.toString() ?? 'a_definir',
      'residence': flutterData['nationality']?.toString() ?? 'a_definir',
      'profession': flutterData['profession']?.toString() ?? 'a_definir',
      'club': flutterData['club']?.toString(),
      'coach': flutterData['coach']?.toString(),
      'position': flutterData['position']?.toString() ?? 'polyvalent',
      'championship_level':
          flutterData['championship_level']?.toString() ?? 'non_specifie',
      'passport_type': flutterData['passport_type']?.toString(),
      'height': flutterData['height'] != null
          ? int.tryParse(flutterData['height'].toString())
          : null,
      'weight': flutterData['weight'] != null
          ? int.tryParse(flutterData['weight'].toString())
          : null,
      'experience_years': flutterData['experience_years'] != null
          ? int.tryParse(flutterData['experience_years'].toString())
          : null,
      'level': flutterData['level']?.toString(),
      'achievements': flutterData['achievements']?.toString(),
      'video_url': flutterData['video_url']?.toString(),
      'bio': flutterData['bio']?.toString(),
    };
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
                  'name': 'gender',
                  'label': 'Genre',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'masculin',
                    'feminin',
                  ],
                },
                {
                  'name': 'nationality',
                  'label': 'Nationalité',
                  'type': 'text',
                  'required': false,
                  'default': 'France',
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
              ],
            },
            {
              'title': 'Informations sportives',
              'fields': [
                {
                  'name': 'position',
                  'label': 'Poste',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'meneur',
                    'arriere',
                    'ailier',
                    'ailier_fort',
                    'pivot',
                    'polyvalent'
                  ],
                },
                {
                  'name': 'championship_level',
                  'label': 'Niveau de championnat',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'nationale',
                    'regional',
                    'departemental',
                  ],
                },
                {
                  'name': 'passport_type',
                  'label': 'Type de passeport',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'france',
                    'europe_ue',
                    'europe_hors_ue',
                    'afrique',
                    'amerique',
                    'canada',
                    'autres'
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

      case 'handibasket':
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
                  'name': 'gender',
                  'label': 'Genre',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'masculin',
                    'feminin',
                  ],
                },
                {
                  'name': 'nationality',
                  'label': 'Nationalité',
                  'type': 'text',
                  'required': false,
                  'default': 'France',
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
                  'name': 'handicap_type',
                  'label': 'Type de handicap',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'moteur',
                    'visuel',
                    'auditif',
                    'cognitif',
                    'non_specifie',
                  ],
                },
              ],
            },
            {
              'title': 'Informations sportives',
              'fields': [
                {
                  'name': 'club',
                  'label': 'Club actuel',
                  'type': 'text',
                  'required': false,
                },
                {
                  'name': 'coach',
                  'label': 'Entraîneur',
                  'type': 'text',
                  'required': false,
                },
                {
                  'name': 'profession',
                  'label': 'Profession',
                  'type': 'text',
                  'required': false,
                },
                {
                  'name': 'position',
                  'label': 'Poste',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'meneur',
                    'arriere',
                    'ailier',
                    'ailier_fort',
                    'pivot',
                    'polyvalent'
                  ],
                },
                {
                  'name': 'championship_level',
                  'label': 'Niveau de championnat',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'nationale',
                    'regional',
                    'departemental',
                  ],
                },
                {
                  'name': 'passport_type',
                  'label': 'Type de passeport',
                  'type': 'text',
                  'required': true,
                  'options': [
                    'france',
                    'europe_ue',
                    'europe_hors_ue',
                    'afrique',
                    'amerique',
                    'canada',
                    'autres'
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
                {
                  'name': 'classification',
                  'label': 'Classification handibasket',
                  'type': 'text',
                  'required': false,
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
    return getPlayersWithFilters();
  }

  // Récupérer la liste des joueurs avec filtres
  Future<List<Map<String, dynamic>>> getPlayersWithFilters({
    String? championshipLevel,
    String? gender,
    String? position,
    String? passportType,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Non authentifié');
    }

    // Construire l'URL avec les paramètres de filtre
    String url = '$baseUrl/players';
    List<String> queryParams = [];

    if (championshipLevel != null && championshipLevel != 'all') {
      queryParams.add('championship_level=$championshipLevel');
    }
    if (gender != null && gender != 'all') {
      queryParams.add('gender=$gender');
    }
    if (position != null && position != 'all') {
      queryParams.add('position=$position');
    }
    if (passportType != null && passportType != 'all') {
      queryParams.add('passport_type=$passportType');
    }

    if (queryParams.isNotEmpty) {
      url += '?' + queryParams.join('&');
    }

    print('Récupération de la liste des joueurs avec filtres: $url');
    print('Token: $token');

    final response = await http.get(
      Uri.parse(url),
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

  // Récupérer les diététiciennes
  Future<List<Map<String, dynamic>>> getDietitians() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/dietitians'),
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
          'Erreur lors de la récupération des diététiciennes: ${response.body}');
    }
  }

  // Récupérer les avocats/juristes
  Future<List<Map<String, dynamic>>> getLawyers() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/lawyers'),
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
          'Erreur lors de la récupération des avocats: ${response.body}');
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

  // Récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>> getUsers() async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception(
          'Erreur lors de la récupération des utilisateurs: ${response.body}');
    }
  }
}
