import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class HandibasketTeamService {
  static const String baseUrl = Config.apiBaseUrl;

  // Headers avec authentification
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getToken() async {
    // Récupérer le token depuis le stockage local
    // Cette méthode doit être implémentée selon votre système de stockage
    return null; // À remplacer par la récupération réelle du token
  }

  // Récupérer le profil de l'équipe connectée
  Future<Map<String, dynamic>?> getTeamProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/handibasket-teams/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null; // Profil non trouvé
      } else {
        print(
            'Erreur lors de la récupération du profil équipe: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du profil équipe: $e');
      return null;
    }
  }

  // Mettre à jour le profil de l'équipe
  Future<bool> updateTeamProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/handibasket-teams/profile'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Erreur lors de la mise à jour du profil équipe: ${response.statusCode}');
        print('Réponse: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du profil équipe: $e');
      return false;
    }
  }

  // Récupérer toutes les équipes handibasket
  Future<List<Map<String, dynamic>>> getAllTeams() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/handibasket-teams/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
            'Erreur lors de la récupération des équipes: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des équipes: $e');
      return [];
    }
  }

  // Récupérer une équipe spécifique par ID
  Future<Map<String, dynamic>?> getTeamById(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/handibasket-teams/$teamId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print(
            'Erreur lors de la récupération de l\'équipe: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'équipe: $e');
      return null;
    }
  }

  // Rechercher des équipes handibasket
  Future<List<Map<String, dynamic>>> searchTeams({
    String? city,
    String? level,
    String? region,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (level != null && level.isNotEmpty) queryParams['level'] = level;
      if (region != null && region.isNotEmpty) queryParams['region'] = region;
      if (keyword != null && keyword.isNotEmpty)
        queryParams['keyword'] = keyword;

      final uri = Uri.parse('$baseUrl/handibasket-teams/search').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Erreur lors de la recherche d\'équipes: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erreur lors de la recherche d\'équipes: $e');
      return [];
    }
  }

  // Récupérer les champs de profil pour les équipes handibasket
  List<Map<String, dynamic>> getProfileFields() {
    return [
      {
        'name': 'team_name',
        'label': 'Nom de l\'équipe',
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
        'name': 'region',
        'label': 'Région',
        'type': 'text',
        'required': false,
      },
      {
        'name': 'level',
        'label': 'Niveau',
        'type': 'dropdown',
        'required': true,
        'options': [
          'Départemental',
          'Régional',
          'National',
          'International',
        ],
      },
      {
        'name': 'division',
        'label': 'Division',
        'type': 'text',
        'required': false,
      },
      {
        'name': 'founded_year',
        'label': 'Année de création',
        'type': 'number',
        'required': false,
      },
      {
        'name': 'description',
        'label': 'Description',
        'type': 'textarea',
        'required': false,
      },
      {
        'name': 'achievements',
        'label': 'Palmarès',
        'type': 'textarea',
        'required': false,
      },
      {
        'name': 'contact_person',
        'label': 'Personne de contact',
        'type': 'text',
        'required': false,
      },
      {
        'name': 'phone',
        'label': 'Téléphone',
        'type': 'text',
        'required': false,
      },
      {
        'name': 'email_contact',
        'label': 'Email de contact',
        'type': 'email',
        'required': false,
      },
      {
        'name': 'website',
        'label': 'Site web',
        'type': 'url',
        'required': false,
      },
      {
        'name': 'facilities',
        'label': 'Installations',
        'type': 'textarea',
        'required': false,
      },
      {
        'name': 'training_schedule',
        'label': 'Horaires d\'entraînement',
        'type': 'textarea',
        'required': false,
      },
      {
        'name': 'competition_schedule',
        'label': 'Calendrier des compétitions',
        'type': 'textarea',
        'required': false,
      },
      {
        'name': 'recruitment_needs',
        'label': 'Besoins de recrutement',
        'type': 'textarea',
        'required': false,
      },
      {
        'name': 'budget_range',
        'label': 'Fourchette de budget',
        'type': 'text',
        'required': false,
      },
      {
        'name': 'accommodation_offered',
        'label': 'Hébergement proposé',
        'type': 'checkbox',
        'required': false,
      },
      {
        'name': 'transport_offered',
        'label': 'Transport proposé',
        'type': 'checkbox',
        'required': false,
      },
      {
        'name': 'medical_support',
        'label': 'Support médical',
        'type': 'checkbox',
        'required': false,
      },
      {
        'name': 'player_requirements',
        'label': 'Exigences pour les joueurs',
        'type': 'textarea',
        'required': false,
      },
    ];
  }
}
