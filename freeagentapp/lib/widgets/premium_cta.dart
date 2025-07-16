import 'package:flutter/material.dart';

class PremiumCTA extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final bool isCompact;

  const PremiumCTA({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    this.icon = Icons.star,
    this.backgroundColor,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(isCompact ? 8.0 : 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: backgroundColor != null
              ? [backgroundColor!, backgroundColor!.withOpacity(0.8)]
              : [Colors.deepOrange, Colors.orange],
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: isCompact ? 24 : 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isCompact ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: isCompact ? 16 : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumBanner extends StatelessWidget {
  final String message;
  final VoidCallback onTap;
  final bool isDismissible;

  const PremiumBanner({
    Key? key,
    required this.message,
    required this.onTap,
    this.isDismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade600, Colors.orange.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isDismissible)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isLocked;
  final VoidCallback? onTap;

  const PremiumFeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.isLocked = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(
              icon,
              color: isLocked ? Colors.grey : Colors.orange,
              size: 32,
            ),
            if (isLocked)
              const Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  Icons.lock,
                  color: Colors.red,
                  size: 16,
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLocked ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isLocked ? Colors.grey : Colors.black54,
          ),
        ),
        trailing: isLocked
            ? const Icon(Icons.lock, color: Colors.red)
            : const Icon(Icons.check_circle, color: Colors.green),
        onTap: isLocked ? onTap : null,
      ),
    );
  }
}

class PremiumUpgradeDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<String> features;
  final VoidCallback onUpgrade;

  const PremiumUpgradeDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.features,
    required this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.diamond, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Avec Premium, vous débloquez :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Plus tard'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onUpgrade();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Passer Premium'),
        ),
      ],
    );
  }
}
