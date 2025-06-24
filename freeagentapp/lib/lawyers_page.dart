import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LawyersPage extends StatefulWidget {
  const LawyersPage({Key? key}) : super(key: key);

  @override
  State<LawyersPage> createState() => _LawyersPageState();
}

class _LawyersPageState extends State<LawyersPage> {
  final ProfileService _profileService = ProfileService();
  List<Map<String, dynamic>> lawyers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadLawyers();
  }

  Future<void> _loadLawyers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final lawyersList = await _profileService.getUsersByType('juriste');
      setState(() {
        lawyers = lawyersList;
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
        title: const Text('Tous les juristes'),
        backgroundColor: const Color(0xFF111014),
      ),
      backgroundColor: const Color(0xFF111014),
      body: RefreshIndicator(
        onRefresh: _loadLawyers,
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
              onPressed: _loadLawyers,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (lawyers.isEmpty) {
      return const Center(
        child: Text(
          'Aucun juriste trouvé',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lawyers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lawyer = lawyers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFFF9800),
            radius: 28,
            child: Text(
              (lawyer['name'] ?? 'J')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(
            lawyer['name'] ?? 'Juriste',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Juriste en droit du sport',
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
              builder: (context) => LawyerDetailPage(lawyer: lawyer),
            ),
          ),
        );
      },
    );
  }
}

class LawyerDetailPage extends StatelessWidget {
  final Map<String, dynamic> lawyer;

  const LawyerDetailPage({
    Key? key,
    required this.lawyer,
  }) : super(key: key);

  Future<void> _sendEmail() async {
    final email = lawyer['email'] ?? '';
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
        title: Text(lawyer['name'] ?? 'Juriste'),
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
                backgroundColor: const Color(0xFFFF9800),
                child: Text(
                  (lawyer['name'] ?? 'J')[0].toUpperCase(),
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
                onPressed: lawyer['email'] != null ? _sendEmail : null,
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
                  backgroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInfoSection('Informations générales', [
              _buildInfoRow('Email', lawyer['email'] ?? 'Non spécifié'),
              _buildInfoRow('Spécialité', 'Juriste en droit du sport'),
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
