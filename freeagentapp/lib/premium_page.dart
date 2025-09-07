import 'package:flutter/material.dart';
import 'services/subscription_service.dart';
import 'services/auth_service.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({Key? key}) : super(key: key);

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final AuthService _authService = AuthService();

  List<SubscriptionPlan> _plans = [];
  SubscriptionStatus? _currentStatus;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final plans = await _subscriptionService.getPlans();
      final status = await _subscriptionService.getSubscriptionStatus();

      setState(() {
        _plans = plans;
        _currentStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _subscribe(int planId) async {
    try {
      // Afficher un dialogue de confirmation
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF18171C),
          title: const Text(
            'Confirmer l\'abonnement',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Voulez-vous vraiment vous abonner à ce plan ?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B5CFF)),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _subscriptionService.subscribe(planId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abonnement activé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData(); // Recharger les données
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelSubscription() async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF18171C),
          title: const Text(
            'Annuler l\'abonnement',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir annuler votre abonnement ? Vous perdrez l\'accès aux fonctionnalités premium.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Conserver'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Annuler l\'abonnement'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _subscriptionService.cancelSubscription();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abonnement annulé'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadData(); // Recharger les données
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: const Color(0xFF111014),
        actions: [
          if (_currentStatus?.isPremium == true)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.white),
              onPressed: _cancelSubscription,
              tooltip: 'Annuler l\'abonnement',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur: $_error',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentStatusCard(),
          const SizedBox(height: 24),
          _buildPremiumBenefits(),
          const SizedBox(height: 24),
          _buildPlansSection(),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    if (_currentStatus == null) return const SizedBox();

    final status = _currentStatus!;
    final isExpired = status.isExpired;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.isPremium ? const Color(0xFF9B5CFF) : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status.isPremium ? Icons.star : Icons.star_border,
                color: status.isPremium ? const Color(0xFF9B5CFF) : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Plan ${status.planName}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (status.isPremium) ...[
            if (status.expiry != null) ...[
              Text(
                isExpired ? 'Expiré le' : 'Expire le',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${status.expiry!.day}/${status.expiry!.month}/${status.expiry!.year}',
                style: TextStyle(
                  color: isExpired ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildUsageStats(),
          ] else ...[
            const Text(
              'Passez au premium pour débloquer toutes les fonctionnalités !',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    if (_currentStatus == null) return const SizedBox();

    final limits = _currentStatus!.limits;

    return Column(
      children: [
        _buildUsageBar(
          'Candidatures',
          limits.current.applicationsCount,
          limits.plan.maxApplications,
          const Color(0xFF9B5CFF),
        ),
        const SizedBox(height: 8),
        _buildUsageBar(
          'Opportunités',
          limits.current.opportunitiesPosted,
          limits.plan.maxOpportunities,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildUsageBar(
          'Messages',
          limits.current.messagesSent,
          limits.plan.maxMessages,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildUsageBar(String label, int current, int max, Color color) {
    final isUnlimited = max == -1;
    final percentage = isUnlimited ? 0.0 : (current / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              isUnlimited ? '$current/illimité' : '$current/$max',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildPremiumBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avantages Premium',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildBenefitCard(
          Icons.message,
          'Messagerie illimitée',
          'Contactez tous les recruteurs et joueurs sans limite',
          const Color(0xFF9B5CFF),
        ),
        _buildBenefitCard(
          Icons.work,
          'Postez vos opportunités',
          'Créez et publiez vos propres annonces de recrutement',
          Colors.blue,
        ),
        _buildBenefitCard(
          Icons.trending_up,
          'Profil mis en avant',
          'Votre profil apparaît en priorité dans les recherches',
          Colors.orange,
        ),
        _buildBenefitCard(
          Icons.support_agent,
          'Support prioritaire',
          'Assistance rapide et dédiée pour tous vos besoins',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildBenefitCard(
      IconData icon, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
    );
  }

  Widget _buildPlansSection() {
    if (_plans.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nos Plans',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = _currentStatus?.type == plan.type;
    final isBasic = plan.isBasic;
    final isPro = plan.isPro;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan
              ? const Color(0xFF9B5CFF)
              : isPro
                  ? Colors.orange
                  : Colors.grey[700]!,
          width: isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                    _subscriptionService.formatDuration(plan.durationMonths),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _subscriptionService.formatPrice(plan.price),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (plan.isYearly)
                    Text(
                      '${_subscriptionService.formatPrice(plan.price / 12)}/mois',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Fonctionnalités
          _buildFeature(
            'Candidatures',
            _subscriptionService.formatLimit(plan.maxApplications),
            plan.maxApplications > 0,
          ),
          _buildFeature(
            'Opportunités',
            _subscriptionService.formatLimit(plan.maxOpportunities),
            plan.maxOpportunities > 0,
          ),
          _buildFeature(
            'Messages',
            _subscriptionService.formatLimit(plan.maxMessages),
            plan.maxMessages != 0,
          ),
          _buildFeature(
            'Poster des annonces',
            plan.canPostOpportunities ? 'Oui' : 'Non',
            plan.canPostOpportunities,
          ),
          if (isPro) ...[
            _buildFeature(
              'Profil mis en avant',
              plan.hasProfileBoost ? 'Oui' : 'Non',
              plan.hasProfileBoost,
            ),
            _buildFeature(
              'Support prioritaire',
              plan.hasPrioritySupport ? 'Oui' : 'Non',
              plan.hasPrioritySupport,
            ),
          ],

          const SizedBox(height: 20),

          // Bouton d'action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan ? null : () => _subscribe(plan.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentPlan
                    ? Colors.grey
                    : isPro
                        ? Colors.orange
                        : const Color(0xFF9B5CFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isCurrentPlan ? 'Plan actuel' : 'Choisir ce plan',
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
    );
  }

  Widget _buildFeature(String name, String value, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
