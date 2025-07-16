import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MatchProfile {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String type;
  final double compatibilityScore;
  final int compatibilityPercentage;
  final String matchLevel;
  final List<String> matchReasons;
  final String? position;
  final String? level;
  final String? location;
  final int? age;
  final int? experienceYears;
  final bool isNew;

  MatchProfile({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.type,
    required this.compatibilityScore,
    required this.compatibilityPercentage,
    required this.matchLevel,
    required this.matchReasons,
    this.position,
    this.level,
    this.location,
    this.age,
    this.experienceYears,
    this.isNew = false,
  });

  factory MatchProfile.fromJson(Map<String, dynamic> json) {
    return MatchProfile(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      type: json['candidate_type'] ?? json['type'] ?? '',
      compatibilityScore: (json['compatibilityScore'] ?? 0.0).toDouble(),
      compatibilityPercentage: json['compatibilityPercentage'] ?? 0,
      matchLevel: json['matchLevel'] ?? 'potentiel',
      matchReasons: List<String>.from(json['matchReasons'] ?? []),
      position: json['position'],
      level: json['level'] ?? json['championship_level'],
      location: json['location'],
      age: json['age'],
      experienceYears: json['experience_years'],
      isNew: json['isNew'] ?? false,
    );
  }

  String get compatibilityText {
    switch (matchLevel) {
      case 'excellent':
        return 'Match parfait';
      case 'très bon':
        return 'Très compatible';
      case 'bon':
        return 'Compatible';
      default:
        return 'Potentiel';
    }
  }

  Color get matchColor {
    switch (matchLevel) {
      case 'excellent':
        return const Color(0xFF4CAF50); // Vert
      case 'très bon':
        return const Color(0xFF2196F3); // Bleu
      case 'bon':
        return const Color(0xFF9C27B0); // Violet
      default:
        return const Color(0xFF757575); // Gris
    }
  }
}

class MatchingStats {
  final int totalMatches;
  final int excellentMatches;
  final int goodMatches;
  final double averageScore;
  final double topMatchScore;
  final Map<String, int> matchTypes;

  MatchingStats({
    required this.totalMatches,
    required this.excellentMatches,
    required this.goodMatches,
    required this.averageScore,
    required this.topMatchScore,
    required this.matchTypes,
  });

  factory MatchingStats.fromJson(Map<String, dynamic> json) {
    return MatchingStats(
      totalMatches: json['totalMatches'] ?? 0,
      excellentMatches: json['excellentMatches'] ?? 0,
      goodMatches: json['goodMatches'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      topMatchScore: (json['topMatchScore'] ?? 0.0).toDouble(),
      matchTypes: Map<String, int>.from(json['matchTypes'] ?? {}),
    );
  }
}

class MatchingService {
  static const String baseUrl = 'http://192.168.1.43:3000/api';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Non authentifié');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtenir des suggestions personnalisées
  Future<List<MatchProfile>> getPersonalizedSuggestions({
    double minScore = 0.5,
    int maxResults = 20,
    bool includeReasons = true,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
            '$baseUrl/matching/suggestions?minScore=$minScore&maxResults=$maxResults&includeReasons=$includeReasons'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> suggestions = data['data'] ?? [];
        return suggestions.map((json) => MatchProfile.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur dans getPersonalizedSuggestions: $e');
      throw Exception('Erreur lors de la récupération des suggestions: $e');
    }
  }

  // Calculer la compatibilité avec un profil spécifique
  Future<MatchProfile> calculateCompatibility({
    required String targetUserId,
    required String targetUserType,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
            '$baseUrl/matching/profile/$targetUserId?targetUserType=$targetUserType'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final matchData = data['data'];
        return MatchProfile(
          id: matchData['targetProfile']['id'].toString(),
          name: matchData['targetProfile']['name'],
          profileImageUrl: matchData['targetProfile']['profile_image_url'],
          type: matchData['targetProfile']['type'],
          compatibilityScore: matchData['compatibilityScore'].toDouble(),
          compatibilityPercentage: matchData['compatibilityPercentage'],
          matchLevel: matchData['matchLevel'],
          matchReasons: List<String>.from(matchData['matchReasons'] ?? []),
        );
      } else {
        throw Exception(
            'Erreur lors du calcul de compatibilité: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur dans calculateCompatibility: $e');
      throw Exception('Erreur lors du calcul de compatibilité: $e');
    }
  }

  // Obtenir les statistiques de matching
  Future<MatchingStats> getMatchingStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/matching/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MatchingStats.fromJson(data['data']);
      } else {
        throw Exception(
            'Erreur lors de la récupération des statistiques: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur dans getMatchingStats: $e');
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Découvrir de nouveaux profils
  Future<List<MatchProfile>> discoverProfiles({
    int limit = 10,
    bool shuffle = true,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/matching/discover?limit=$limit&shuffle=$shuffle'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> profiles = data['data'] ?? [];
        return profiles.map((json) => MatchProfile.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la découverte: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur dans discoverProfiles: $e');
      throw Exception('Erreur lors de la découverte: $e');
    }
  }

  // Obtenir les meilleurs matches
  Future<List<MatchProfile>> getTopMatches({int limit = 5}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/matching/top-matches?limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> matches = data['data'] ?? [];
        return matches.map((json) => MatchProfile.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des meilleurs matches: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur dans getTopMatches: $e');
      throw Exception(
          'Erreur lors de la récupération des meilleurs matches: $e');
    }
  }

  // Obtenir les matches récents
  Future<List<MatchProfile>> getRecentMatches({int limit = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/matching/recent?limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> matches = data['data'] ?? [];
        return matches.map((json) => MatchProfile.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des matches récents: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur dans getRecentMatches: $e');
      throw Exception('Erreur lors de la récupération des matches récents: $e');
    }
  }

  // Envoyer un feedback sur un match
  Future<bool> sendFeedback({
    required String targetUserId,
    required String feedback,
    int? rating,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/matching/feedback'),
        headers: headers,
        body: json.encode({
          'targetUserId': targetUserId,
          'feedback': feedback,
          'rating': rating,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur dans sendFeedback: $e');
      return false;
    }
  }

  // Obtenir des suggestions par catégorie
  Future<Map<String, List<MatchProfile>>> getSuggestionsByCategory() async {
    try {
      final suggestions = await getPersonalizedSuggestions(maxResults: 30);

      final Map<String, List<MatchProfile>> categorized = {
        'Excellents': [],
        'Très bons': [],
        'Bons': [],
        'Potentiels': [],
      };

      for (final profile in suggestions) {
        switch (profile.matchLevel) {
          case 'excellent':
            categorized['Excellents']!.add(profile);
            break;
          case 'très bon':
            categorized['Très bons']!.add(profile);
            break;
          case 'bon':
            categorized['Bons']!.add(profile);
            break;
          default:
            categorized['Potentiels']!.add(profile);
            break;
        }
      }

      return categorized;
    } catch (e) {
      print('Erreur dans getSuggestionsByCategory: $e');
      throw Exception(
          'Erreur lors de la récupération des suggestions par catégorie: $e');
    }
  }

  // Obtenir des suggestions basées sur la position (pour les joueurs)
  Future<List<MatchProfile>> getSuggestionsByPosition(String position) async {
    try {
      final allSuggestions = await getPersonalizedSuggestions(maxResults: 50);
      return allSuggestions
          .where((profile) =>
              profile.position == position || profile.position == 'polyvalent')
          .toList();
    } catch (e) {
      print('Erreur dans getSuggestionsByPosition: $e');
      throw Exception(
          'Erreur lors de la récupération des suggestions par position: $e');
    }
  }

  // Obtenir des suggestions basées sur le niveau
  Future<List<MatchProfile>> getSuggestionsByLevel(String level) async {
    try {
      final allSuggestions = await getPersonalizedSuggestions(maxResults: 50);
      return allSuggestions.where((profile) => profile.level == level).toList();
    } catch (e) {
      print('Erreur dans getSuggestionsByLevel: $e');
      throw Exception(
          'Erreur lors de la récupération des suggestions par niveau: $e');
    }
  }

  // Obtenir des suggestions basées sur la localisation
  Future<List<MatchProfile>> getSuggestionsByLocation(String location) async {
    try {
      final allSuggestions = await getPersonalizedSuggestions(maxResults: 50);
      return allSuggestions
          .where((profile) => profile.location?.contains(location) == true)
          .toList();
    } catch (e) {
      print('Erreur dans getSuggestionsByLocation: $e');
      throw Exception(
          'Erreur lors de la récupération des suggestions par localisation: $e');
    }
  }

  // Méthodes utilitaires
  String formatMatchLevel(String level) {
    switch (level) {
      case 'excellent':
        return 'Match parfait';
      case 'très bon':
        return 'Très compatible';
      case 'bon':
        return 'Compatible';
      default:
        return 'Potentiel';
    }
  }

  String formatCandidateType(String type) {
    switch (type) {
      case 'player':
        return 'Joueur';
      case 'coach':
        return 'Coach';
      case 'club':
        return 'Club';
      case 'handibasket':
        return 'Joueur Handibasket';
      default:
        return type;
    }
  }
}
