import 'package:flutter/material.dart';
import 'services/subscription_service.dart';
import 'services/payment_service.dart';
import 'premium_page.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementPage> createState() =>
      _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState
    extends State<SubscriptionManagementPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final PaymentService _paymentService = PaymentService();

  SubscriptionStatus? _subscriptionStatus;
  List<SubscriptionPlan> _availablePlans = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final status = await _subscriptionService.getSubscriptionStatus();
      final plans = await _subscriptionService.getPlans();

      setState(() {
        _subscriptionStatus = status;
        _availablePlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changePlan(SubscriptionPlan newPlan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18171C),
        title: const Text(
          'Changer d\'abonnement',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voulez-vous changer pour le plan ${newPlan.name} ?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nouveau plan: ${newPlan.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prix: ${newPlan.price.toStringAsFixed(2)}€/${newPlan.isMonthly ? 'mois' : 'an'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Applications: ${newPlan.maxApplications == -1 ? 'Illimitées' : newPlan.maxApplications.toString()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Messages: ${newPlan.maxMessages == -1 ? 'Illimités' : newPlan.maxMessages.toString()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (newPlan.hasProfileBoost)
                    const Text(
                      'Profil mis en avant',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5CFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);
      try {
        // Créer une session de paiement pour le nouveau plan
        final result = await _paymentService.createCheckoutSession(
          planId: newPlan.id,
          successUrl: 'freeagent://subscription/success',
          cancelUrl: 'freeagent://subscription/cancel',
        );

        if (result['url'] != null) {
          await _paymentService.launchStripeCheckout(
            planId: newPlan.id,
            successUrl: 'freeagent://subscription/success',
            cancelUrl: 'freeagent://subscription/cancel',
          );

          // Recharger les données après le changement
          await _loadData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abonnement modifié avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du changement d\'abonnement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18171C),
        title: const Text(
          'Résilier l\'abonnement',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Êtes-vous sûr de vouloir résilier votre abonnement ?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vous perdrez l\'accès à :',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Messages illimités',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Text(
                    '• Candidatures illimitées',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Text(
                    '• Profil mis en avant',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Text(
                    '• Support prioritaire',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  if (_subscriptionStatus?.expiry != null)
                    Text(
                      'Votre abonnement restera actif jusqu\'au ${_formatDate(_subscriptionStatus!.expiry!)}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Résilier'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);
      try {
        await _subscriptionService.cancelSubscription();

        // Recharger les données après l'annulation
        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abonnement résilié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la résiliation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildCurrentPlanCard() {
    if (_subscriptionStatus == null) return const SizedBox();

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_subscriptionStatus!.type) {
      case 'premium_basic':
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Premium Basic';
        statusIcon = Icons.star;
        break;
      case 'premium_pro':
        statusColor = const Color(0xFFFFD700);
        statusText = 'Premium Pro';
        statusIcon = Icons.star;
        break;
      default:
        statusColor = const Color(0xFF757575);
        statusText = 'Gratuit';
        statusIcon = Icons.person;
        break;
    }

    return Card(
      color: const Color(0xFF18171C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Plan actuel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_subscriptionStatus!.expiry != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Expire le ${_formatDate(_subscriptionStatus!.expiry!)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                  if (_subscriptionStatus!.isPremium) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Applications: ${_subscriptionStatus!.limits.plan.maxApplications == -1 ? 'Illimitées' : _subscriptionStatus!.limits.plan.maxApplications.toString()}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      'Messages: ${_subscriptionStatus!.limits.plan.maxMessages == -1 ? 'Illimités' : _subscriptionStatus!.limits.plan.maxMessages.toString()}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    if (_subscriptionStatus!.limits.plan.hasProfileBoost)
                      const Text(
                        'Profil mis en avant',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    if (_subscriptionStatus!.limits.plan.hasPrioritySupport)
                      const Text(
                        'Support prioritaire',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                  ],
                ],
              ),
            ),
            if (_subscriptionStatus!.isPremium) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _cancelSubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Résilier l\'abonnement'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailablePlansSection() {
    if (_availablePlans.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plans disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._availablePlans.map((plan) => _buildPlanCard(plan)).toList(),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = _subscriptionStatus?.type == plan.type;
    final isRecommended = plan.isPro && plan.isYearly;

    return Card(
      color: const Color(0xFF18171C),
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: plan.isPro
                          ? const Color(0xFF9B5CFF)
                          : const Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      plan.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrentPlan) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ACTUEL',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${plan.price.toStringAsFixed(2)}€/${plan.isMonthly ? 'mois' : 'an'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeaturesList(plan),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan || _isProcessing
                        ? null
                        : () => _changePlan(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? Colors.grey
                          : plan.isPro
                              ? const Color(0xFF9B5CFF)
                              : const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isCurrentPlan
                                ? 'Plan actuel'
                                : 'Changer pour ce plan',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
      'Applications: ${plan.maxApplications == -1 ? 'Illimitées' : plan.maxApplications.toString()}',
      'Messages: ${plan.maxMessages == -1 ? 'Illimités' : plan.maxMessages.toString()}',
      'Opportunités: ${plan.maxOpportunities == -1 ? 'Illimitées' : plan.maxOpportunities.toString()}',
      if (plan.hasProfileBoost) 'Profil mis en avant',
      if (plan.hasPrioritySupport) 'Support prioritaire',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: plan.isPro
                          ? const Color(0xFF9B5CFF)
                          : const Color(0xFF4CAF50),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        title: const Text(
          'Mon Abonnement',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumPage(),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informations Premium',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentPlanCard(),
                  const SizedBox(height: 24),
                  _buildAvailablePlansSection(),
                ],
              ),
            ),
    );
  }
}
