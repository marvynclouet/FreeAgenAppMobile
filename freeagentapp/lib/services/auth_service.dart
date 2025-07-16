import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.43:3000/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user';

  // Méthode d'inscription
  Future<Map<String, dynamic>> register(
      Map<String, dynamic> registrationData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registrationData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Vérifier que les données essentielles sont présentes
        if (data['token'] != null && data['user'] != null) {
          // Stocker le token et les données utilisateur
          await _saveToken(data['token']);
          await _saveUserData(data['user']);
          return data;
        } else {
          throw Exception('Données d\'inscription incomplètes');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Erreur d\'inscription');
      }
    } catch (e) {
      print('Erreur dans AuthService.register: $e');
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Vérifier que les données essentielles sont présentes
        if (data['token'] != null && data['user'] != null) {
          // Stocker le token et les données utilisateur
          await _saveToken(data['token']);
          await _saveUserData(data['user']);
          return data;
        } else {
          throw Exception('Données de connexion incomplètes');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      print('Erreur dans AuthService.login: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<void> _saveToken(String? token) async {
    if (token == null || token.isEmpty) {
      throw Exception('Token invalide');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    print('Token sauvegardé avec la clé: $tokenKey');
  }

  Future<void> _saveUserData(Map<String, dynamic>? userData) async {
    if (userData == null) {
      throw Exception('Données utilisateur invalides');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(userData));
    print('Données utilisateur sauvegardées');
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);

      // Vérifier si le token existe et n'est pas vide
      if (token == null || token.isEmpty) {
        print('Token manquant ou vide');
        return null;
      }

      print('Token récupéré: ${token.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(userKey);

      if (userJson == null || userJson.isEmpty) {
        print('Données utilisateur manquantes');
        return null;
      }

      final userData = json.decode(userJson);

      // Vérifier que les données essentielles sont présentes
      if (userData is Map<String, dynamic>) {
        return userData;
      } else {
        print('Format des données utilisateur invalide');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userKey);
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userData = await getUserData();
    return token != null && userData != null;
  }

  // Nouvelle méthode pour valider le token
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Token invalide, nettoyer les données
        await logout();
        return false;
      }
    } catch (e) {
      print('Erreur lors de la validation du token: $e');
      return false;
    }
  }

  // Méthode pour vérifier et nettoyer les données corrompues
  Future<void> cleanCorruptedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Vérifier et nettoyer les anciennes clés incorrectes
      final oldToken = prefs.getString('token'); // Ancienne clé incorrecte
      if (oldToken != null) {
        print('Migration de l\'ancien token vers la nouvelle clé');
        await prefs.setString(tokenKey, oldToken);
        await prefs.remove('token'); // Supprimer l'ancienne clé
      }

      // Vérifier le token avec la bonne clé
      final token = prefs.getString(tokenKey);
      if (token == null || token.isEmpty) {
        await prefs.remove(tokenKey);
      }

      // Vérifier les données utilisateur
      final userJson = prefs.getString(userKey);
      if (userJson == null || userJson.isEmpty) {
        await prefs.remove(userKey);
      } else {
        try {
          json.decode(userJson);
        } catch (e) {
          print('Données utilisateur corrompues, suppression...');
          await prefs.remove(userKey);
        }
      }

      print('Nettoyage des données terminé');
    } catch (e) {
      print('Erreur lors du nettoyage des données: $e');
    }
  }

  // Méthode pour initialiser et vérifier l'état d'authentification
  Future<bool> initializeAuth() async {
    await cleanCorruptedData();
    return await isLoggedIn();
  }
}
