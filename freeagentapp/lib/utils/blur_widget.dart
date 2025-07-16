import 'package:flutter/material.dart';
import 'dart:ui';
import 'premium_navigation.dart';

class BlurWidget extends StatelessWidget {
  final Widget child;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final double blurSigma;
  final Color overlayColor;

  const BlurWidget({
    Key? key,
    required this.child,
    required this.message,
    this.buttonText = 'Premium',
    this.onPressed,
    this.blurSigma = 5.0,
    this.overlayColor = const Color(0x99000000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenu flouté
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: child,
        ),

        // Overlay avec message
        Container(
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF18171C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF9B5CFF),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF9B5CFF),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PremiumNavigation.buildPremiumButton(
                    context: context,
                    text: buttonText,
                    onPressed: onPressed ??
                        () => PremiumNavigation.navigateToSubscription(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget pour les éléments de liste floutés
class BlurListItem extends StatelessWidget {
  final Widget child;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final double height;

  const BlurListItem({
    Key? key,
    required this.child,
    required this.message,
    this.buttonText = 'Premium',
    this.onPressed,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: height,
        maxHeight: height + 50,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: BlurWidget(
        child: SizedBox(
          height: height,
          child: child,
        ),
        message: message,
        buttonText: buttonText,
        onPressed: onPressed ??
            () => PremiumNavigation.navigateToSubscription(context),
        blurSigma: 3.0,
        overlayColor: const Color(0xCC000000),
      ),
    );
  }
}
