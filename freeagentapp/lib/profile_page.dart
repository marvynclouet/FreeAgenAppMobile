import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';

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
  final Map<String, TextEditingController> _controllers = {};

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
          // Initialiser avec les données existantes ou une valeur vide
          _controllers[key]?.text = data[key]?.toString() ?? '';
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

      // Recharger les données du profil
      await _loadProfile();

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

    if (fieldName.contains('.')) {
      // Pour les champs imbriqués comme stats.points
      final parts = fieldName.split('.');
      if (profileData?[parts[0]] != null &&
          profileData![parts[0]][parts[1]] != null) {
        value = profileData![parts[0]][parts[1]].toString();
      }
    } else {
      value = profileData?[fieldName]?.toString() ?? '';
    }

    if (value.isEmpty) {
      value = 'Non renseigné';
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
          fieldWidget = DropdownButtonFormField<String>(
            value: controller.text.isEmpty ? null : controller.text,
            items: field['options'].map<DropdownMenuItem<String>>((option) {
              return DropdownMenuItem<String>(
                value: option,
                child:
                    Text(option, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.text = value;
              }
            },
            style: const TextStyle(color: Colors.white),
            decoration: _getInputDecoration(field['label']),
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
        CircleAvatar(
          radius: 56,
          backgroundColor: const Color(0xFF9B5CFF),
          child: Text(
            (userData?['name'] ?? 'U')[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
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
      ],
    );
  }

  String _getProfileTypeLabel(String profileType) {
    switch (profileType) {
      case 'player':
        return 'Joueur';
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
