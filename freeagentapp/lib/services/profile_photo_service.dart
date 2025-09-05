import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'auth_service.dart';
import 'config.dart';

class ProfilePhotoService {
  static String get baseUrl => ApiConfig.uploadUrl;
  final AuthService _authService = AuthService();

  // Récupérer la photo de profil actuelle
  Future<Map<String, dynamic>?> getCurrentProfileImage() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/profile-image'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la photo de profil: $e');
      return null;
    }
  }

  // Uploader une nouvelle photo de profil (compatible web)
  Future<Map<String, dynamic>?> uploadProfileImage(
      Uint8List imageBytes, String fileName) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      print('Upload de la photo: $fileName');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Déterminer le type MIME à partir du nom de fichier
      String mimeType = 'image/jpeg'; // Par défaut
      final extension = fileName.toLowerCase();
      if (extension.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (extension.endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (extension.endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      // Créer le MultipartFile à partir des bytes
      var multipartFile = http.MultipartFile.fromBytes(
        'profileImage',
        imageBytes,
        filename: fileName,
        contentType: http_parser.MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

      print('Envoi de la requête...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Réponse serveur: ${response.statusCode}');
      print('Corps de la réponse: $responseBody');

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        try {
          final error = json.decode(responseBody);
          throw Exception(error['message'] ?? 'Erreur lors de l\'upload');
        } catch (e) {
          throw Exception('Erreur serveur: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Erreur lors de l\'upload de la photo: $e');
      rethrow;
    }
  }

  // Supprimer la photo de profil
  Future<bool> deleteProfileImage() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/profile-image'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la suppression de la photo: $e');
      return false;
    }
  }

  // Obtenir l'URL complète de l'image
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    return 'https://freeagenappmobile-production.up.railway.app$imageUrl';
  }

  // Vérifier si l'utilisateur a une photo personnalisée
  Future<bool> hasCustomProfileImage() async {
    try {
      final data = await getCurrentProfileImage();
      return data?['hasCustomImage'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
