import 'package:flutter/material.dart';
import 'login_page.dart';
import 'premium_page.dart';
import 'profile_photo_page.dart';
import 'subscription_management_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/profile_photo_service.dart';
import 'widgets/user_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? profileData;
  bool isLoading = false;
  bool isEditing = false; // Mode édition
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  final _authService = AuthService();
  final _subscriptionService = SubscriptionService();
  final _profilePhotoService = ProfilePhotoService();
  final Map<String, TextEditingController> _controllers = {};

  // Variables pour le statut d'abonnement
  String _subscriptionType = 'free';
  bool _isPremium = false;
  DateTime? _subscriptionExpiry;

  // Variables pour la photo de profil
  String? _profileImageUrl;
  bool _hasCustomImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final user = await _authService.getUserData();
      if (user != null) {
        print('Données utilisateur chargées: $user');
        setState(() {
          userData = user;
        });

        // Initialiser les contrôleurs pour les champs du profil
        _initializeControllers(user['profile_type']);
        print('Type de profil: ${user['profile_type']}');

        // Charger les données du profil
        await _loadProfile();

        // Charger le statut d'abonnement
        await _loadSubscriptionStatus();

        // Charger la photo de profil
        await _loadProfilePhoto();
      } else {
        print('Aucune donnée utilisateur trouvée');
        // Rediriger vers la page de connexion si pas de données utilisateur
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final subscriptionStatus =
          await _subscriptionService.getSubscriptionStatus();
      setState(() {
        _subscriptionType = subscriptionStatus.type;
        _isPremium = subscriptionStatus.isPremium;
        _subscriptionExpiry = subscriptionStatus.expiry;
      });
    } catch (e) {
      print('Erreur lors du chargement du statut d\'abonnement: $e');
      // Valeurs par défaut en cas d'erreur
      setState(() {
        _subscriptionType = 'free';
        _isPremium = false;
        _subscriptionExpiry = null;
      });
    }
  }

  Future<void> _loadProfilePhoto() async {
    try {
      final photoData = await _profilePhotoService.getCurrentProfileImage();
      if (photoData != null) {
        setState(() {
          _profileImageUrl = photoData['imageUrl'];
          _hasCustomImage = photoData['hasCustomImage'] ?? false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de la photo de profil: $e');
      // Pas d'erreur affichée, on garde les valeurs par défaut
    }
  }

  void _initializeControllers(String profileType) {
    final fields = ProfileService.getProfileFields(profileType);
    for (var section in fields['sections'] as List<dynamic>) {
      for (var field in section['fields'] as List<dynamic>) {
        _controllers[field['name'] as String] = TextEditingController();
      }
    }
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.getProfile();
      print('Données du profil chargées: $data');
      setState(() {
        profileData = data;
      });
      
      // Debug: afficher les champs disponibles
      if (data.isNotEmpty) {
        print('Champs disponibles dans profileData:');
        data.forEach((key, value) {
          print('  $key: $value');
        });
      }

      // Remplir les contrôleurs avec les données du profil si elles existent
      for (var key in _controllers.keys) {
        if (key.contains('.')) {
          // Pour les champs imbriqués comme stats.points
          final parts = key.split('.');
          if (data[parts[0]] != null && data[parts[0]][parts[1]] != null) {
            _controllers[key]?.text = data[parts[0]][parts[1]].toString();
            print('Champ $key initialisé avec: ${data[parts[0]][parts[1]]}');
          } else {
            // Initialiser avec une valeur vide pour les nouveaux profils
            _controllers[key]?.text = '';
          }
        } else {
          // Pour les champs mappés, utiliser les données du profil
          if (key == 'age') {
            _controllers[key]?.text = data['age']?.toString() ?? '';
          } else if (key == 'classification') {
            _controllers[key]?.text = data['classification']?.toString() ?? '';
          } else if (key == 'nationality') {
            _controllers[key]?.text = data['nationality']?.toString() ?? '';
          } else if (key == 'gender') {
            _controllers[key]?.text =
                data['gender']?.toString() ?? userData?[key]?.toString() ?? '';
          } else {
            // Pour tous les autres champs, utiliser les données du profil directement
            _controllers[key]?.text = data[key]?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
      // Ne pas afficher d'erreur pour un nouveau profil
      if (!e.toString().contains('404')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du profil: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final Map<String, dynamic> data = {};
      for (var key in _controllers.keys) {
        if (key.contains('.')) {
          // Pour les champs imbriqués comme stats.points
          final parts = key.split('.');
          if (data[parts[0]] == null) data[parts[0]] = {};
          data[parts[0]][parts[1]] = _controllers[key]?.text;
        } else {
          data[key] = _controllers[key]?.text;
        }
      }

      await _profileService.updateProfile(data);

      // Recharger les données utilisateur pour récupérer les nouveaux champs gender et nationality
      await _loadUserData();

      // Sortir du mode édition
      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    }
  }

  Widget _buildProfileForm() {
    if (userData == null) {
      return const Center(
          child: Text('Chargement...', style: TextStyle(color: Colors.white)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 24),

        // Mode édition ou mode affichage
        if (isEditing) _buildEditForm() else _buildViewProfile(),
      ],
    );
  }

  Widget _buildViewProfile() {
    if (profileData == null || profileData!.isEmpty) {
      return Column(
        children: [
          const Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Profil non complété',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complétez votre profil pour être visible par les autres utilisateurs',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => isEditing = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5CFF),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Créer mon profil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }

    final fields =
        ProfileService.getProfileFields(userData!['profile_type'] as String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton Modifier
        Center(
          child: ElevatedButton.icon(
            onPressed: () => setState(() => isEditing = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5CFF),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.edit),
            label: const Text(
              'Modifier mon profil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Affichage des sections en lecture seule
        ...(fields['sections'] as List<dynamic>).map<Widget>((section) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(section['title'] as String),
              Card(
                color: const Color(0xFF18171C),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: (section['fields'] as List<dynamic>)
                        .map<Widget>((field) {
                      return _buildViewField(field as Map<String, dynamic>);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildViewField(Map<String, dynamic> field) {
    String fieldName = field['name'] as String;
    String fieldLabel = field['label'] as String;
    String value = '';
    
    print('DEBUG _buildViewField: $fieldName -> $fieldLabel');

    if (fieldName.contains('.')) {
      // Pour les champs imbriqués comme stats.points
      final parts = fieldName.split('.');
      if (profileData?[parts[0]] != null &&
          profileData![parts[0]][parts[1]] != null) {
        value = profileData![parts[0]][parts[1]].toString();
      }
    } else {
      // Pour les champs mappés, utiliser les données du profil
      if (fieldName == 'age') {
        value = profileData?['age']?.toString() ?? '';
      } else if (fieldName == 'classification') {
        value = profileData?['classification']?.toString() ?? '';
      } else if (fieldName == 'nationality') {
        value = profileData?['nationality']?.toString() ?? '';
      } else if (fieldName == 'gender') {
        value = profileData?['gender']?.toString() ??
            userData?[fieldName]?.toString() ??
            '';
      } else {
        // Pour tous les autres champs, utiliser les données du profil directement
        value = profileData?[fieldName]?.toString() ?? '';
      }
    }

    print('DEBUG valeur trouvée pour $fieldName: "$value"');

    if (value.isEmpty) {
      value = 'Non renseigné';
    } else {
      // Appliquer les libellés personnalisés si disponibles
      Map<String, String> customLabels = _getCustomLabels(fieldName);
      if (customLabels.containsKey(value)) {
        value = customLabels[value]!;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              fieldLabel,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: value == 'Non renseigné' ? Colors.white38 : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    final fields =
        ProfileService.getProfileFields(userData!['profile_type'] as String);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Boutons Annuler et Enregistrer
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => isEditing = false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B5CFF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Formulaire d'édition
          ...(fields['sections'] as List<dynamic>).map<Widget>((section) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(section['title'] as String),
                ...(section['fields'] as List<dynamic>).map<Widget>((field) {
                  return _buildField(field as Map<String, dynamic>);
                }).toList(),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final controller = _controllers[field['name']];
    if (controller == null) return const SizedBox.shrink();

    Widget fieldWidget;
    switch (field['type']) {
      case 'number':
        fieldWidget = TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _getInputDecoration(field['label']),
          validator: (value) {
            if (field['required'] && (value == null || value.isEmpty)) {
              return 'Ce champ est requis';
            }
            if (value != null && value.isNotEmpty) {
              final number = num.tryParse(value);
              if (number == null) {
                return 'Veuillez entrer un nombre valide';
              }
            }
            return null;
          },
        );
        break;

      case 'multiline':
        fieldWidget = TextFormField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: _getInputDecoration(field['label']),
          validator: (value) {
            if (field['required'] && (value == null || value.isEmpty)) {
              return 'Ce champ est requis';
            }
            return null;
          },
        );
        break;

      case 'url':
        fieldWidget = TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          style: const TextStyle(color: Colors.white),
          decoration: _getInputDecoration(field['label']),
          validator: (value) {
            if (field['required'] && (value == null || value.isEmpty)) {
              return 'Ce champ est requis';
            }
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasAbsolutePath) {
                return 'Veuillez entrer une URL valide';
              }
            }
            return null;
          },
        );
        break;

      case 'phone':
        fieldWidget = TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: _getInputDecoration(field['label']),
          validator: (value) {
            if (field['required'] && (value == null || value.isEmpty)) {
              return 'Ce champ est requis';
            }
            return null;
          },
        );
        break;

      case 'text':
        if (field['options'] != null) {
          // Créer un map pour les libellés personnalisés
          Map<String, String> customLabels = _getCustomLabels(field['name']);

          fieldWidget = DropdownButtonFormField<String>(
            value: controller.text.isEmpty ? null : controller.text,
            items: field['options'].map<DropdownMenuItem<String>>((option) {
              String displayLabel = customLabels[option] ?? option;
              return DropdownMenuItem<String>(
                value: option,
                child: Text(displayLabel,
                    style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.text = value;
              }
            },
            style: const TextStyle(color: Colors.white),
            decoration: _getInputDecoration(field['label']),
            dropdownColor: const Color(0xFF18171C),
            validator: (value) {
              if (field['required'] && (value == null || value.isEmpty)) {
                return 'Ce champ est requis';
              }
              return null;
            },
          );
        } else {
          fieldWidget = TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: _getInputDecoration(field['label']),
            validator: (value) {
              if (field['required'] && (value == null || value.isEmpty)) {
                return 'Ce champ est requis';
              }
              return null;
            },
          );
        }
        break;

      default:
        fieldWidget = TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: _getInputDecoration(field['label']),
          validator: (value) {
            if (field['required'] && (value == null || value.isEmpty)) {
              return 'Ce champ est requis';
            }
            return null;
          },
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: fieldWidget,
    );
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF18171C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9B5CFF)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        UserAvatar(
          name: userData?['name'],
          imageUrl: _profileImageUrl,
          hasCustomImage: _hasCustomImage,
          radius: 56,
          showBorder: true,
          borderColor: const Color(0xFF9B5CFF),
          showEditIcon: true,
          profileType: userData?['profile_type'],
          onTap: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => const ProfilePhotoPage(),
              ),
            )
                .then((_) {
              // Recharger la photo après retour de la page de gestion
              _loadProfilePhoto();
            });
          },
        ),
        const SizedBox(height: 16),
        Text(
          userData?['name'] ?? 'Utilisateur',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userData?['email'] ?? '',
          style: const TextStyle(
            color: Color(0xFF9B5CFF),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF18171C),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getProfileTypeLabel(userData?['profile_type'] ?? ''),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Statut d'abonnement
        _buildSubscriptionBadge(),

        // Bouton CTA pour les utilisateurs non premium
        if (!_isPremium) ...[
          const SizedBox(height: 16),
          _buildPremiumCTA(),
        ],
      ],
    );
  }

  Widget _buildSubscriptionBadge() {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (_subscriptionType) {
      case 'premium_basic':
        badgeColor = const Color(0xFF4CAF50);
        badgeText = 'Premium Basic';
        badgeIcon = Icons.star;
        break;
      case 'premium_pro':
        badgeColor = const Color(0xFFFFD700);
        badgeText = 'Premium Pro';
        badgeIcon = Icons.star;
        break;
      default:
        badgeColor = const Color(0xFF757575);
        badgeText = 'Gratuit';
        badgeIcon = Icons.person;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubscriptionManagementPage(),
          ),
        ).then((_) {
          // Recharger les données après retour de la page de gestion
          _loadSubscriptionStatus();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: badgeColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              badgeIcon,
              color: badgeColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_subscriptionExpiry != null && _isPremium) ...[
              const SizedBox(width: 4),
              Text(
                '•',
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _formatExpiryDate(_subscriptionExpiry!),
                style: TextStyle(
                  color: badgeColor.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.settings,
              color: badgeColor.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9B5CFF).withOpacity(0.1),
            const Color(0xFF9B5CFF).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9B5CFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            color: Color(0xFFFFE66D),
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Passez Premium !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Débloquez toutes les fonctionnalités et boostez votre profil',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PremiumPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Découvrir Premium',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiryDate(DateTime expiry) {
    final now = DateTime.now();
    final difference = expiry.difference(now).inDays;

    if (difference <= 0) {
      return 'Expiré';
    } else if (difference == 1) {
      return 'Expire demain';
    } else if (difference <= 7) {
      return 'Expire dans $difference jours';
    } else {
      return 'Expire le ${expiry.day}/${expiry.month}/${expiry.year}';
    }
  }

  String _getProfileTypeLabel(String profileType) {
    switch (profileType) {
      case 'player':
        return 'Joueur';
      case 'handibasket':
        return 'Joueur Handibasket';
      case 'coach_pro':
        return 'Coach Professionnel';
      case 'coach_basket':
        return 'Coach de Basket';
      case 'juriste':
        return 'Juriste';
      case 'dieteticienne':
        return 'Diététicienne';
      case 'club':
        return 'Club';
      default:
        return profileType;
    }
  }

  Map<String, String> _getCustomLabels(String fieldName) {
    switch (fieldName) {
      case 'gender':
        return {
          'masculin': 'Masculin',
          'feminin': 'Féminin',
        };
      case 'position':
        return {
          'meneur': 'Meneur',
          'arriere': 'Arrière',
          'ailier': 'Ailier',
          'ailier_fort': 'Ailier fort',
          'pivot': 'Pivot',
          'polyvalent': 'Polyvalent',
        };
      case 'championship_level':
        return {
          'nationale': 'Nationale',
          'regional': 'Régional',
          'departemental': 'Départemental',
        };
      case 'passport_type':
        return {
          'france': 'France',
          'europe_ue': 'Europe U.E',
          'europe_hors_ue': 'Europe hors U.E',
          'afrique': 'Afrique',
          'amerique': 'Amérique',
          'canada': 'Canada',
          'autres': 'Autres',
        };
      default:
        return {};
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            color: Colors.white,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileForm(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
