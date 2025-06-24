import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DietitiansPage extends StatefulWidget {
  const DietitiansPage({Key? key}) : super(key: key);

  @override
  State<DietitiansPage> createState() => _DietitiansPageState();
}

class _DietitiansPageState extends State<DietitiansPage> {
  final ProfileService _profileService = ProfileService();
  List<Map<String, dynamic>> dietitians = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDietitians();
  }

  Future<void> _loadDietitians() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final dietitiansList =
          await _profileService.getUsersByType('dieteticienne');
      setState(() {
        dietitians = dietitiansList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les diététiciens'),
        backgroundColor: const Color(0xFF111014),
      ),
      backgroundColor: const Color(0xFF111014),
      body: RefreshIndicator(
        onRefresh: _loadDietitians,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDietitians,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (dietitians.isEmpty) {
      return const Center(
        child: Text(
          'Aucun diététicien trouvé',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: dietitians.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dietitian = dietitians[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF4CAF50),
            radius: 28,
            child: Text(
              (dietitian['name'] ?? 'D')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(
            dietitian['name'] ?? 'Diététicien',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Diététicien sportif',
            style: const TextStyle(color: Colors.white70),
          ),
          tileColor: const Color(0xFF18171C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white70,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DietitianDetailPage(dietitian: dietitian),
            ),
          ),
        );
      },
    );
  }
}

class DietitianDetailPage extends StatelessWidget {
  final Map<String, dynamic> dietitian;

  const DietitianDetailPage({
    Key? key,
    required this.dietitian,
  }) : super(key: key);

  Future<void> _sendEmail() async {
    final email = dietitian['email'] ?? '';
    if (email.isEmpty) {
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Contact depuis FreeAgent App',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        title: Text(dietitian['name'] ?? 'Diététicien'),
        backgroundColor: const Color(0xFF111014),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF4CAF50),
                child: Text(
                  (dietitian['name'] ?? 'D')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton Envoyer un email
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: dietitian['email'] != null ? _sendEmail : null,
                icon: const Icon(Icons.email, color: Colors.white),
                label: const Text(
                  'Envoyer un email',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInfoSection('Informations générales', [
              _buildInfoRow('Email', dietitian['email'] ?? 'Non spécifié'),
              _buildInfoRow('Spécialité', 'Diététicien sportif'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF18171C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
