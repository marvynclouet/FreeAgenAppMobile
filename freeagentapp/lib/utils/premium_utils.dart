import 'package:flutter/material.dart';

class PremiumUtils {
  // Afficher un message d'alerte pour les utilisateurs gratuits
  static void showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.diamond, color: Colors.orange),
              SizedBox(width: 8),
              Text('Fonctionnalité Premium'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cette fonctionnalité est réservée aux utilisateurs premium.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Avec Premium, vous débloquez :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Candidatures illimitées aux opportunités'),
              Text('• Création d\'opportunités'),
              Text('• Messages illimités'),
              Text('• Accès aux notifications'),
              Text('• Support prioritaire'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/premium');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Passer Premium'),
            ),
          ],
        );
      },
    );
  }

  // Vérifier si l'utilisateur est gratuit
  static bool isFreeUser(Map<String, dynamic>? subscriptionStatus) {
    return subscriptionStatus == null ||
        subscriptionStatus['subscription']?['type'] == 'free';
  }

  // Bannière simple pour les utilisateurs gratuits
  static Widget buildFreeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '🚀 Compte gratuit - Passez Premium pour débloquer toutes les fonctionnalités !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/premium'),
            child: const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  // Card CTA simple
  static Widget buildUpgradeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/premium'),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            const Icon(Icons.diamond, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accès limité',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Passez Premium pour débloquer toutes les fonctionnalités',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}
