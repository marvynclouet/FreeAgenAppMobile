import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CoachesPage extends StatefulWidget {
  const CoachesPage({Key? key}) : super(key: key);

  @override
  State<CoachesPage> createState() => _CoachesPageState();
}

class _CoachesPageState extends State<CoachesPage> {
  final ProfileService _profileService = ProfileService();
  List<Map<String, dynamic>> coaches = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Récupérer les coachs pro et basket via l'API
      final coachsProList = await _profileService.getUsersByType('coach_pro');
      final coachsBasketList =
          await _profileService.getUsersByType('coach_basket');

      setState(() {
        coaches = [...coachsProList, ...coachsBasketList];
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
        title: const Text('Tous les coachs'),
        backgroundColor: const Color(0xFF111014),
      ),
      backgroundColor: const Color(0xFF111014),
      body: RefreshIndicator(
        onRefresh: _loadCoaches,
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
              onPressed: _loadCoaches,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (coaches.isEmpty) {
      return const Center(
        child: Text(
          'Aucun coach trouvé',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: coaches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final coach = coaches[index];
        String profileType = coach['profile_type'] ?? '';
        String specialtyLabel = '';

        if (profileType == 'coach_pro') {
          specialtyLabel = 'Coach professionnel';
        } else if (profileType == 'coach_basket') {
          specialtyLabel = 'Coach de basket';
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF9B5CFF),
            radius: 28,
            child: Text(
              (coach['name'] ?? 'C')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(
            coach['name'] ?? 'Coach',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            specialtyLabel,
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
              builder: (context) => CoachDetailPage(coach: coach),
            ),
          ),
        );
      },
    );
  }
}

class CoachDetailPage extends StatelessWidget {
  final Map<String, dynamic> coach;

  const CoachDetailPage({
    Key? key,
    required this.coach,
  }) : super(key: key);

  Future<void> _sendEmail() async {
    final email = coach['email'] ?? '';
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
    String profileType = coach['profile_type'] ?? '';
    String typeLabel = '';

    if (profileType == 'coach_pro') {
      typeLabel = 'Coach Professionnel';
    } else if (profileType == 'coach_basket') {
      typeLabel = 'Coach de Basket';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        title: Text(coach['name'] ?? 'Coach'),
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
                backgroundColor: const Color(0xFF9B5CFF),
                child: Text(
                  (coach['name'] ?? 'C')[0].toUpperCase(),
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
                onPressed: coach['email'] != null ? _sendEmail : null,
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
                  backgroundColor: const Color(0xFF9B5CFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInfoSection('Informations générales', [
              _buildInfoRow('Email', coach['email'] ?? 'Non spécifié'),
              _buildInfoRow('Type', typeLabel),
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
