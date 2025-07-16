import 'package:flutter/material.dart';
import '../services/profile_photo_service.dart';

class UserAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final bool hasCustomImage;
  final double radius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color borderColor;
  final bool showEditIcon;
  final String? profileType;

  const UserAvatar({
    Key? key,
    this.name,
    this.imageUrl,
    this.hasCustomImage = false,
    this.radius = 24,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.borderColor = const Color(0xFF9B5CFF),
    this.showEditIcon = false,
    this.profileType,
  }) : super(key: key);

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    // Couleurs par type de profil
    switch (profileType) {
      case 'player':
        return const Color(0xFF2196F3);
      case 'handibasket':
        return Colors.orange;
      case 'coach_pro':
      case 'coach_basket':
        return const Color(0xFF9B5CFF);
      case 'dieteticienne':
        return const Color(0xFF4CAF50);
      case 'juriste':
        return const Color(0xFFFF9800);
      case 'club':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF9B5CFF);
    }
  }

  Widget _buildAvatarContent() {
    if (hasCustomImage && imageUrl != null) {
      return ClipOval(
        child: Image.network(
          ProfilePhotoService.getFullImageUrl(imageUrl),
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultContent();
          },
        ),
      );
    }
    return _buildDefaultContent();
  }

  Widget _buildDefaultContent() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          (name?.isNotEmpty == true ? name![0] : 'U').toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: showBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            )
          : null,
      child: _buildAvatarContent(),
    );

    if (showEditIcon) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: hasCustomImage
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF9B5CFF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                hasCustomImage ? Icons.edit : Icons.add_a_photo,
                color: Colors.white,
                size: radius * 0.4,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}
