import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'auth_service.dart';

class ProfilePhotoService {
  static const String baseUrl =
      'https://freeagenappmobile-production.up.railway.app/api/upload';
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

  // Uploader une nouvelle photo de profil
  Future<Map<String, dynamic>?> uploadProfileImage(File imageFile) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      print('Upload de la photo: ${imageFile.path}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Ajouter le fichier avec détection de type MIME
      var multipartFile = await http.MultipartFile.fromPath(
        'profileImage',
        imageFile.path,
        // Forcer le type MIME pour les images
      );

      // Forcer le type MIME si non détecté
      if (multipartFile.contentType.mimeType == 'application/octet-stream') {
        final extension = imageFile.path.toLowerCase();
        String? mimeType;
        if (extension.endsWith('.jpg') || extension.endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        } else if (extension.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (extension.endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (extension.endsWith('.webp')) {
          mimeType = 'image/webp';
        }

        if (mimeType != null) {
          multipartFile = http.MultipartFile.fromBytes(
            'profileImage',
            await imageFile.readAsBytes(),
            filename: multipartFile.filename,
            contentType: http_parser.MediaType.parse(mimeType),
          );
        }
      }

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
