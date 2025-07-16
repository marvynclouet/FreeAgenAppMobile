import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class DebugUtils {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user';

  /// Nettoie complètement toutes les données d'authentification
  static Future<void> clearAllAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Toutes les données d\'authentification ont été supprimées');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }

  /// Affiche les informations de débogage de l'authentification
  static Future<void> debugAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      final userJson = prefs.getString(userKey);

      print('🔍 État de l\'authentification:');
      print(
          'Token présent: ${token != null ? 'Oui (${token.length} caractères)' : 'Non'}');
      print(
          'Données utilisateur présentes: ${userJson != null ? 'Oui' : 'Non'}');

      if (token != null) {
        print(
            'Token (10 premiers caractères): ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      }

      if (userJson != null) {
        try {
          final userData = userJson;
          print('Données utilisateur valides: Oui');
          print('Longueur des données: ${userData.length} caractères');
        } catch (e) {
          print('Données utilisateur corrompues: $e');
        }
      }

      // Test de validation du token
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      print('Utilisateur connecté selon AuthService: $isLoggedIn');
    } catch (e) {
      print('❌ Erreur lors du débogage: $e');
    }
  }

  /// Recrée des données d'authentification propres pour un utilisateur
  static Future<void> createCleanAuthSession({
    required String email,
    required String password,
  }) async {
    try {
      // Nettoyer d'abord
      await clearAllAuthData();

      // Reconnecter
      final authService = AuthService();
      await authService.login(email, password);

      print('✅ Session d\'authentification recréée avec succès');
    } catch (e) {
      print('❌ Erreur lors de la recréation de la session: $e');
    }
  }

  /// Valide et répare automatiquement les données corrompues
  static Future<bool> validateAndRepairAuth() async {
    try {
      final authService = AuthService();

      // Nettoyer les données corrompues
      await authService.cleanCorruptedData();

      // Vérifier si l'utilisateur est toujours connecté
      final isLoggedIn = await authService.isLoggedIn();

      if (!isLoggedIn) {
        print('⚠️ Utilisateur non connecté après nettoyage');
        return false;
      }

      // Valider le token
      final isTokenValid = await authService.validateToken();

      if (!isTokenValid) {
        print('⚠️ Token invalide, nettoyage complet nécessaire');
        await clearAllAuthData();
        return false;
      }

      print('✅ Authentification validée et réparée');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la validation/réparation: $e');
      return false;
    }
  }
}
