import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SubscriptionPlan {
  final int id;
  final String name;
  final String type;
  final double price;
  final int durationMonths;
  final int maxApplications;
  final int maxOpportunities;
  final int maxMessages;
  final bool canPostOpportunities;
  final bool hasProfileBoost;
  final bool hasPrioritySupport;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.durationMonths,
    required this.maxApplications,
    required this.maxOpportunities,
    required this.maxMessages,
    required this.canPostOpportunities,
    required this.hasProfileBoost,
    required this.hasPrioritySupport,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      price: double.parse(json['price'].toString()),
      durationMonths: json['duration_months'],
      maxApplications: json['max_applications'],
      maxOpportunities: json['max_opportunities'],
      maxMessages: json['max_messages'],
      canPostOpportunities: json['can_post_opportunities'] == 1,
      hasProfileBoost: json['has_profile_boost'] == 1,
      hasPrioritySupport: json['has_priority_support'] == 1,
    );
  }

  bool get isUnlimited => maxApplications == -1;
  bool get isBasic => type == 'premium_basic';
  bool get isPro => type == 'premium_pro';
  bool get isMonthly => durationMonths == 1;
  bool get isYearly => durationMonths == 12;
}

class SubscriptionStatus {
  final String type;
  final DateTime? expiry;
  final bool isPremium;
  final DateTime? createdAt;
  final UsageLimits limits;

  SubscriptionStatus({
    required this.type,
    this.expiry,
    required this.isPremium,
    this.createdAt,
    required this.limits,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      type: json['subscription']['type'],
      expiry: json['subscription']['expiry'] != null
          ? DateTime.parse(json['subscription']['expiry'])
          : null,
      isPremium: json['subscription']['is_premium'] == 1,
      createdAt: json['subscription']['created_at'] != null
          ? DateTime.parse(json['subscription']['created_at'])
          : null,
      limits: UsageLimits.fromJson(json['limits']),
    );
  }

  bool get isFree => type == 'free';
  bool get isExpired => expiry != null && expiry!.isBefore(DateTime.now());

  String get planName {
    switch (type) {
      case 'premium_basic':
        return 'Premium Basic';
      case 'premium_pro':
        return 'Premium Pro';
      default:
        return 'Gratuit';
    }
  }
}

class UsageLimits {
  final CurrentUsage current;
  final PlanLimits plan;

  UsageLimits({
    required this.current,
    required this.plan,
  });

  factory UsageLimits.fromJson(Map<String, dynamic> json) {
    return UsageLimits(
      current: CurrentUsage.fromJson(json['current']),
      plan: PlanLimits.fromJson(json['plan']),
    );
  }
}

class CurrentUsage {
  final int applicationsCount;
  final int opportunitiesPosted;
  final int messagesSent;
  final DateTime lastResetDate;

  CurrentUsage({
    required this.applicationsCount,
    required this.opportunitiesPosted,
    required this.messagesSent,
    required this.lastResetDate,
  });

  factory CurrentUsage.fromJson(Map<String, dynamic> json) {
    return CurrentUsage(
      applicationsCount: json['applications_count'] ?? 0,
      opportunitiesPosted: json['opportunities_posted'] ?? 0,
      messagesSent: json['messages_sent'] ?? 0,
      lastResetDate: json['last_reset_date'] != null
          ? DateTime.parse(json['last_reset_date'])
          : DateTime.now(),
    );
  }
}

class PlanLimits {
  final int maxApplications;
  final int maxOpportunities;
  final int maxMessages;
  final bool canPostOpportunities;
  final bool hasProfileBoost;
  final bool hasPrioritySupport;

  PlanLimits({
    required this.maxApplications,
    required this.maxOpportunities,
    required this.maxMessages,
    required this.canPostOpportunities,
    required this.hasProfileBoost,
    required this.hasPrioritySupport,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      maxApplications: json['max_applications'] ?? 0,
      maxOpportunities: json['max_opportunities'] ?? 0,
      maxMessages: json['max_messages'] ?? 0,
      canPostOpportunities: json['can_post_opportunities'] == 1,
      hasProfileBoost: json['has_profile_boost'] == 1,
      hasPrioritySupport: json['has_priority_support'] == 1,
    );
  }

  bool get hasUnlimitedApplications => maxApplications == -1;
  bool get hasUnlimitedOpportunities => maxOpportunities == -1;
  bool get hasUnlimitedMessages => maxMessages == -1;
}

class SubscriptionService {
  static const String baseUrl = 'https://freeagenappmobile-production.up.railway.app/api';
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

  // Valider un achat store
  Future<Map<String, dynamic>> validateStorePurchase({
    required String productId,
    required String purchaseToken,
    required String platform,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/store/validate-${platform}-purchase'),
        headers: headers,
        body: json.encode({
          'productId': productId,
          platform == 'ios' ? 'receipt' : 'purchaseToken': purchaseToken,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erreur validation achat: $e');
    }
  }

  // Obtenir le statut d'abonnement store
  Future<Map<String, dynamic>> getStoreSubscriptionStatus() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/store/subscription-status'),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Erreur récupération statut: $e');
    }
  }

  // Obtenir tous les plans d'abonnement
  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/plans'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des plans');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir le statut d'abonnement de l'utilisateur
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SubscriptionStatus.fromJson(data);
      } else {
        throw Exception('Erreur lors de la récupération du statut');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // S'abonner à un plan
  Future<Map<String, dynamic>> subscribe(int planId,
      {String paymentMethod = 'manual'}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/subscribe'),
        headers: headers,
        body: json.encode({
          'planId': planId,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de l\'abonnement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Annuler l'abonnement
  Future<void> cancelSubscription() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/cancel'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de l\'annulation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les limites d'utilisation
  Future<Map<String, dynamic>> getUsageLimits() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/limits'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des limites');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Vérifier si l'utilisateur peut effectuer une action
  Future<bool> canPerformAction(String action) async {
    try {
      final status = await getSubscriptionStatus();

      switch (action) {
        case 'post_opportunities':
          return status.limits.plan.canPostOpportunities;
        case 'messaging':
          return !status.isFree;
        case 'profile_boost':
          return status.limits.plan.hasProfileBoost;
        case 'priority_support':
          return status.limits.plan.hasPrioritySupport;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Vérifier si l'utilisateur a atteint sa limite pour une action
  Future<bool> hasReachedLimit(String limitType) async {
    try {
      final limits = await getUsageLimits();
      final current = limits['current'];
      final plan = limits['plan'];

      switch (limitType) {
        case 'applications':
          final maxApplications = plan['max_applications'];
          if (maxApplications == -1) return false;
          return current['applications_count'] >= maxApplications;
        case 'opportunities':
          final maxOpportunities = plan['max_opportunities'];
          if (maxOpportunities == -1) return false;
          return current['opportunities_posted'] >= maxOpportunities;
        case 'messages':
          final maxMessages = plan['max_messages'];
          if (maxMessages == -1) return false;
          return current['messages_sent'] >= maxMessages;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Obtenir le nombre d'actions restantes
  Future<int> getRemainingActions(String limitType) async {
    try {
      final limits = await getUsageLimits();
      final remaining = limits['remaining'];

      switch (limitType) {
        case 'applications':
          return remaining['applications'];
        case 'opportunities':
          return remaining['opportunities'];
        case 'messages':
          return remaining['messages'];
        default:
          return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // Méthodes utilitaires pour l'interface utilisateur
  String formatPrice(double price) {
    return '${price.toStringAsFixed(2)}€';
  }

  String formatDuration(int months) {
    if (months == 1) {
      return 'Mensuel';
    } else if (months == 12) {
      return 'Annuel';
    } else {
      return '$months mois';
    }
  }

  String formatLimit(int limit) {
    if (limit == -1) {
      return 'Illimité';
    } else if (limit == 0) {
      return 'Aucun';
    } else {
      return limit.toString();
    }
  }

  // Calculer les économies pour les plans annuels
  double calculateYearlySavings(List<SubscriptionPlan> plans) {
    final monthlyPlans = plans.where((p) => p.isMonthly).toList();
    final yearlyPlans = plans.where((p) => p.isYearly).toList();

    if (monthlyPlans.isEmpty || yearlyPlans.isEmpty) return 0.0;

    // Comparer les plans de même type
    for (final monthlyPlan in monthlyPlans) {
      for (final yearlyPlan in yearlyPlans) {
        if (monthlyPlan.type == yearlyPlan.type) {
          final monthlyTotal = monthlyPlan.price * 12;
          final savings = monthlyTotal - yearlyPlan.price;
          return savings;
        }
      }
    }

    return 0.0;
  }
}
