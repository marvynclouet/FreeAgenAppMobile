import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'dart:io';
import 'config.dart';

class ContentService {
  static String get baseUrl => ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Récupérer le fil d'actualités (posts + opportunités)
  Future<List<Map<String, dynamic>>> getFeed() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token non disponible');

      final response = await http.get(
        Uri.parse('$baseUrl/feed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['feed'] ?? []);
      } else {
        throw Exception('Erreur lors de la récupération du fil d\'actualités');
      }
    } catch (e) {
      print('Erreur ContentService.getFeed: $e');
      // Retourner des données de test si l'API n'est pas disponible
      return _getMockFeed();
    }
  }

  // Créer un nouveau post
  Future<bool> createPost({
    required String content,
    List<String>? imageUrls,
    String? eventDate,
    String? eventLocation,
    String? eventTime,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token non disponible');

      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': content,
          'imageUrls': imageUrls ?? [],
          'eventDate': eventDate,
          'eventLocation': eventLocation,
          'eventTime': eventTime,
        }),
      );

      if (response.statusCode == 403) {
        final errorData = json.decode(response.body);
        if (errorData['requiresPremium'] == true) {
          throw Exception('Fonctionnalité réservée aux abonnés premium');
        }
      }

      return response.statusCode == 201;
    } catch (e) {
      print('Erreur ContentService.createPost: $e');
      rethrow; // Relancer l'erreur pour que l'UI puisse la gérer
    }
  }

  // Liker/unliker un post
  Future<bool> toggleLike(String postId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token non disponible');

      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur ContentService.toggleLike: $e');
      return false;
    }
  }

  // Commenter un post
  Future<bool> addComment(String postId, String comment) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token non disponible');

      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': comment}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Erreur ContentService.addComment: $e');
      return false;
    }
  }

  // Récupérer les commentaires d'un post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token non disponible');

      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['comments'] ?? []);
      } else {
        throw Exception('Erreur lors de la récupération des commentaires');
      }
    } catch (e) {
      print('Erreur ContentService.getComments: $e');
      return [];
    }
  }

  // Uploader une image de post
  Future<String?> uploadPostImage(File imageFile) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token non disponible');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/post-image'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files
          .add(await http.MultipartFile.fromPath('postImage', imageFile.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['imageUrl'] as String?;
      } else {
        throw Exception('Erreur lors de l\'upload de l\'image: $responseBody');
      }
    } catch (e) {
      print('Erreur ContentService.uploadPostImage: $e');
      rethrow;
    }
  }

  // Données de test pour le développement
  List<Map<String, dynamic>> _getMockFeed() {
    return [
      {
        'id': '1',
        'type': 'opportunity',
        'title': 'Recrutement Joueur Pro',
        'content':
            'Le club ASVEL recherche un meneur de jeu pour la saison 2024-2025. Profil recherché : joueur expérimenté avec un bon leadership.',
        'author_name': 'ASVEL Basket',
        'author_type': 'club',
        'author_avatar': 'https://via.placeholder.com/50',
        'created_at':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'likes_count': 15,
        'comments_count': 8,
        'location': 'Lyon, France',
        'salary_range': '5000-8000€/mois',
        'requirements': 'Pro A, Leadership, Expérience'
      },
      {
        'id': '2',
        'type': 'post',
        'content':
            'Super match hier soir ! 🏀 Félicitations à toute l\'équipe pour cette victoire importante. On continue sur cette lancée ! 💪 #Basketball #Victory',
        'author_name': 'Thomas Dupont',
        'author_type': 'player',
        'author_avatar': 'https://via.placeholder.com/50',
        'created_at':
            DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'likes_count': 23,
        'comments_count': 12,
        'image_urls': [
          'https://via.placeholder.com/400x300',
          'https://via.placeholder.com/400x300'
        ],
        'event_date': '2024-01-15',
        'event_location': 'Palais des Sports, Paris'
      },
      {
        'id': '3',
        'type': 'event',
        'title': 'Tournoi National U18',
        'content':
            'Inscriptions ouvertes pour le tournoi national U18 qui se déroulera du 15 au 20 février 2024. Un événement à ne pas manquer !',
        'author_name': 'FFBB',
        'author_type': 'federation',
        'author_avatar': 'https://via.placeholder.com/50',
        'created_at':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'likes_count': 45,
        'comments_count': 18,
        'image_url': 'https://via.placeholder.com/400x250',
        'event_date': '2024-02-15',
        'event_time': '14:30:00',
        'event_location': 'Paris, France'
      },
      {
        'id': '4',
        'type': 'opportunity',
        'title': 'Coach Assistant Recherché',
        'content':
            'Le club de Nanterre recherche un coach assistant pour accompagner l\'équipe première. Formation requise et expérience appréciée.',
        'author_name': 'Nanterre 92',
        'author_type': 'club',
        'author_avatar': 'https://via.placeholder.com/50',
        'created_at':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'likes_count': 8,
        'comments_count': 3,
        'location': 'Nanterre, France',
        'salary_range': '3000-4500€/mois',
        'requirements': 'Diplôme coach, Expérience, Disponibilité'
      },
      {
        'id': '5',
        'type': 'post',
        'content':
            'Entraînement ce matin avec l\'équipe ! 💪 La préparation physique est essentielle pour performer au plus haut niveau. #Training #Basketball',
        'author_name': 'Marie Laurent',
        'author_type': 'coach',
        'author_avatar': 'https://via.placeholder.com/50',
        'created_at':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'likes_count': 31,
        'comments_count': 7,
        'image_urls': ['https://via.placeholder.com/400x300']
      }
    ];
  }
}
