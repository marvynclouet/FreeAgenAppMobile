import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum OpportunityType {
  equipe_recherche_joueur, // Une équipe cherche un joueur
  joueur_recherche_equipe, // Un joueur cherche une équipe
  coach_recherche_equipe, // Un coach cherche une équipe
  coach_recherche_joueur, // Un coach cherche un joueur
  equipe_recherche_coach, // Une équipe cherche un coach
  service_professionnel, // Offre de service (juriste, médecin, etc.)
  autre // Autres types d'annonces
}

class OpportunityService {
  static const String _baseUrl = 'http://192.168.1.43:3000/api';
  static const String _tokenKey = 'auth_token';

  String _mapTypeForBackend(OpportunityType type) {
    switch (type) {
      case OpportunityType.equipe_recherche_joueur:
      case OpportunityType.joueur_recherche_equipe:
        return 'recrutement';
      case OpportunityType.coach_recherche_equipe:
      case OpportunityType.equipe_recherche_coach:
      case OpportunityType.coach_recherche_joueur:
        return 'coaching';
      case OpportunityType.service_professionnel:
        return 'consultation';
      case OpportunityType.autre:
        return 'recrutement'; // Par défaut
    }
  }

  String _mapTypeFromBackend(String backendType) {
    // Pour l'affichage, on utilise le type le plus générique
    switch (backendType) {
      case 'recrutement':
        return 'equipe_recherche_joueur'; // Type par défaut pour recrutement
      case 'coaching':
        return 'coach_recherche_equipe'; // Type par défaut pour coaching
      case 'consultation':
        return 'service_professionnel';
      default:
        return 'autre';
    }
  }

  String _handleErrorResponse(http.Response response) {
    try {
      final errorBody = json.decode(response.body);
      return errorBody['message'] ?? 'Erreur serveur (${response.statusCode})';
    } catch (e) {
      return 'Erreur serveur (${response.statusCode}): ${response.body}';
    }
  }

  Future<List<Map<String, dynamic>>> getOpportunities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/annonces'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Mapper les types du backend vers les types de l'app
        final List<Map<String, dynamic>> mappedData = data.map((item) {
          final Map<String, dynamic> opportunity = Map.from(item);
          if (opportunity['type'] != null) {
            opportunity['type'] = _mapTypeFromBackend(opportunity['type']);
          }
          return opportunity;
        }).toList();
        return mappedData;
      } else {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Erreur dans getOpportunities: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOpportunity(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/annonces/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> opportunity = json.decode(response.body);
        // Mapper le type du backend vers le type de l'app
        if (opportunity['type'] != null) {
          opportunity['type'] = _mapTypeFromBackend(opportunity['type']);
        }
        return opportunity;
      } else {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Erreur dans getOpportunity: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOpportunity({
    required String title,
    required String description,
    required OpportunityType type,
    required String requirements,
    required String salaryRange,
    required String location,
  }) async {
    try {
      print('Début de createOpportunity');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null || token.isEmpty) {
        print('Token non trouvé ou vide');
        throw Exception('Non authentifié - Veuillez vous reconnecter');
      }

      print('Token trouvé: ${token.substring(0, 10)}...');

      // Validation des données selon la structure de la base de données
      if (title.length > 100) {
        throw Exception('Le titre ne doit pas dépasser 100 caractères');
      }

      if (salaryRange.length > 100) {
        throw Exception('Le salaire ne doit pas dépasser 100 caractères');
      }

      if (location.length > 100) {
        throw Exception('La localisation ne doit pas dépasser 100 caractères');
      }

      final body = {
        'title': title,
        'description': description,
        'type': _mapTypeForBackend(type),
        'requirements': requirements,
        'salary_range': salaryRange,
        'location': location,
        'status': 'open', // Ajout du statut par défaut
      };

      print('Préparation de la requête:');
      print('URL: $_baseUrl/annonces');
      print(
          'Headers: {Authorization: Bearer ***, Content-Type: application/json}');
      print('Body: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/annonces'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('Réponse reçue:');
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        print('Création réussie');
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print('Token invalide ou expiré');
        throw Exception('Session expirée - Veuillez vous reconnecter');
      } else {
        print('Erreur serveur détectée');
        final errorMessage = _handleErrorResponse(response);
        print('Message d\'erreur: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      print('Erreur détaillée dans createOpportunity:');
      print('Type d\'erreur: ${e.runtimeType}');
      print('Message: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> closeOpportunity(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/annonces/$id/close'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Erreur dans closeOpportunity: $e');
      rethrow;
    }
  }

  Future<void> applyToOpportunity(int id, String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/annonces/$id/apply'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message': message}),
      );

      if (response.statusCode != 201) {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Erreur dans applyToOpportunity: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getApplications(int opportunityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/annonces/$opportunityId/applications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(_handleErrorResponse(response));
      }
    } catch (e) {
      print('Erreur dans getApplications: $e');
      rethrow;
    }
  }

  Future<bool> hasApplied(int opportunityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/annonces/$opportunityId/hasApplied'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasApplied'] ?? false;
      } else {
        return false; // En cas d'erreur, considérer qu'on n'a pas postulé
      }
    } catch (e) {
      print('Erreur dans hasApplied: $e');
      return false;
    }
  }
}
