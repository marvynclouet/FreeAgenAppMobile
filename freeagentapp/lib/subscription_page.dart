import 'package:flutter/material.dart';
import 'dart:io';
import 'services/subscription_service.dart';
import 'services/in_app_purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final InAppPurchaseService _iapService = InAppPurchaseService();
  List<SubscriptionPlan> _plans = [];
  List<ProductDetails> _iapProducts = [];
  bool _isLoading = true;
  bool _isSubscribing = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    try {
      await _iapService.initialize();
      if (_iapService.isAvailable) {
        setState(() {
          _iapProducts = _iapService.products;
        });
      }
    } catch (e) {
      print('Erreur initialisation IAP: $e');
    }
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _subscriptionService.getPlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des plans: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _subscribe(SubscriptionPlan plan) async {
    setState(() {
      _isSubscribing = true;
    });

    try {
      // Paiement via In-App Purchases uniquement
      await _subscribeWithIAP(plan);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'abonnement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubscribing = false;
      });
    }
  }

  Future<void> _subscribeWithIAP(SubscriptionPlan plan) async {
    // Mapper le plan vers l'ID produit
    final productId = _getProductIdFromPlan(plan);
    final product = _iapProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Produit non trouvé: $productId'),
    );

    // Lancer l'achat
    final success = await _iapService.buyProduct(product);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Achat en cours...'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      throw Exception('Échec de l\'achat');
    }
  }

  String _getProductIdFromPlan(SubscriptionPlan plan) {
    if (plan.isBasic && plan.isMonthly) return 'premium_basic_monthly';
    if (plan.isBasic && plan.isYearly) return 'premium_basic_yearly';
    if (plan.isPro && plan.isMonthly) return 'premium_pro_monthly';
    if (plan.isPro && plan.isYearly) return 'premium_pro_yearly';
    throw Exception('Type de plan non reconnu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Plans Premium',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9B5CFF),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9B5CFF), Color(0xFF6B2EFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Débloque ton potentiel !',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Accède à toutes les fonctionnalités premium',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildBenefitsList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Plans
                  if (_plans.isNotEmpty) ...[
                    const Text(
                      'Choisissez votre plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      'Candidatures illimitées',
      'Messagerie complète',
      'Opportunités prioritaires',
      'Boost de profil',
      'Support prioritaire',
    ];

    return Column(
      children: benefits
          .map((benefit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      benefit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isRecommended = plan.isPro && plan.isYearly;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(20),
        border: isRecommended
            ? Border.all(color: const Color(0xFF9B5CFF), width: 2)
            : null,
      ),
      child: Stack(
        children: [
          if (isRecommended)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF9B5CFF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'RECOMMANDÉ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: plan.isPro
                            ? const Color(0xFF9B5CFF)
                            : const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        plan.isPro ? Icons.diamond : Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            plan.isYearly
                                ? 'Facturation annuelle'
                                : 'Facturation mensuelle',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Prix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${plan.price.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan.isYearly ? '/an' : '/mois',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                if (plan.isYearly)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Économisez 20% par rapport au mensuel',
                      style: TextStyle(
                        color: plan.isPro
                            ? const Color(0xFF9B5CFF)
                            : const Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Fonctionnalités
                _buildFeaturesList(plan),

                const SizedBox(height: 24),

                // Bouton d'abonnement
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubscribing ? null : () => _subscribe(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.isPro
                          ? const Color(0xFF9B5CFF)
                          : const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isSubscribing
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            'Choisir ce plan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(SubscriptionPlan plan) {
    final features = [
      'Candidatures: ${plan.isUnlimited ? 'Illimitées' : plan.maxApplications.toString()}',
      'Opportunités: ${plan.maxOpportunities == -1 ? 'Illimitées' : plan.maxOpportunities.toString()}',
      'Messages: ${plan.maxMessages == -1 ? 'Illimités' : plan.maxMessages.toString()}',
      if (plan.hasProfileBoost) 'Boost de profil',
      if (plan.hasPrioritySupport) 'Support prioritaire',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: plan.isPro
                          ? const Color(0xFF9B5CFF)
                          : const Color(0xFF4CAF50),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  @override
  void dispose() {
    _iapService.dispose();
    super.dispose();
  }
}
