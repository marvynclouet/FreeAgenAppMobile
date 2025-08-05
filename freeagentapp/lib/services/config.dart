class ApiConfig {
  // Configuration pour différents environnements
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // URLs de base selon l'environnement
  static String get baseUrl {
    if (isProduction) {
      // URL Railway en production
      return 'https://freeagenappmobile-production.up.railway.app/api';
    } else {
      // URL locale en développement
      return 'https://freeagenappmobile-production.up.railway.app/api';
    }
  }

  // URL pour les uploads
  static String get uploadUrl {
    if (isProduction) {
      return 'https://freeagenappmobile-production.up.railway.app/api/upload';
    } else {
      return 'https://freeagenappmobile-production.up.railway.app/api/upload';
    }
  }

  // Configuration pour les timeouts
  static const int connectionTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000; // 30 secondes

  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Debug info
  static void printConfig() {
    print('🔧 API Configuration:');
    print('   Environment: ${isProduction ? 'Production' : 'Development'}');
    print('   Base URL: $baseUrl');
    print('   Upload URL: $uploadUrl');
  }
}
