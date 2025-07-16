import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_service.dart';

class PaymentService {
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

  // Créer une session de paiement Stripe
  Future<Map<String, dynamic>> createCheckoutSession({
    required int planId,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-checkout-session'),
        headers: headers,
        body: json.encode({
          'planId': planId,
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Erreur lors de la création de la session');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Lancer le paiement Stripe (WebView)
  Future<bool> launchStripeCheckout({
    required int planId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final session = await createCheckoutSession(
        planId: planId,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

      final checkoutUrl = session['url'];

      if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
        await launchUrl(
          Uri.parse(checkoutUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        throw Exception('Impossible d\'ouvrir l\'URL de paiement');
      }
    } catch (e) {
      throw Exception('Erreur lors du lancement du paiement: $e');
    }
  }

  // Initialiser Stripe (à appeler dans main.dart)
  static Future<void> initializeStripe() async {
    try {
      // Remplacez par votre clé publique Stripe
      Stripe.publishableKey = 'pk_test_votre-cle-publique-stripe';
      await Stripe.instance.applySettings();
    } catch (e) {
      print('Erreur lors de l\'initialisation de Stripe: $e');
    }
  }

  // Vérifier le statut d'une session de paiement
  Future<bool> checkPaymentStatus(String sessionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/payments/session-status/$sessionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'complete';
      }
      return false;
    } catch (e) {
      print('Erreur lors de la vérification du statut: $e');
      return false;
    }
  }
}

// Classe pour les détails d'une carte de crédit
class CreditCardDetails {
  final String number;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;

  CreditCardDetails({
    required this.number,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
  });

  bool get isValid {
    return number.isNotEmpty &&
        expiryDate.isNotEmpty &&
        cvv.isNotEmpty &&
        cardHolderName.isNotEmpty &&
        number.length >= 13 &&
        cvv.length >= 3;
  }
}

// Classe pour les résultats de paiement
class PaymentResult {
  final bool success;
  final String? message;
  final String? transactionId;

  PaymentResult({
    required this.success,
    this.message,
    this.transactionId,
  });

  factory PaymentResult.success({String? transactionId}) {
    return PaymentResult(
      success: true,
      message: 'Paiement réussi',
      transactionId: transactionId,
    );
  }

  factory PaymentResult.failure(String message) {
    return PaymentResult(
      success: false,
      message: message,
    );
  }
}
