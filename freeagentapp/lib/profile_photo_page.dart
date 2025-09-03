import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/profile_photo_service.dart';

class ProfilePhotoPage extends StatefulWidget {
  const ProfilePhotoPage({Key? key}) : super(key: key);

  @override
  State<ProfilePhotoPage> createState() => _ProfilePhotoPageState();
}

class _ProfilePhotoPageState extends State<ProfilePhotoPage> {
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _hasCustomImage = false;
  final ImagePicker _picker = ImagePicker();
  final ProfilePhotoService _photoService = ProfilePhotoService();

  @override
  void initState() {
    super.initState();
    _loadCurrentImage();
  }

  Future<void> _loadCurrentImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final data = await _photoService.getCurrentProfileImage();
      if (data != null) {
        setState(() {
          _currentImageUrl = data['imageUrl'];
          _hasCustomImage = data['hasCustomImage'] ?? false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de la photo de profil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement de la photo')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image')),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      print('Erreur lors de la prise de photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la prise de photo')),
      );
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Lire les bytes du fichier
      final imageBytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;

      final result =
          await _photoService.uploadProfileImage(imageBytes, fileName);
      if (result != null) {
        setState(() {
          _currentImageUrl = result['imageUrl'];
          _hasCustomImage = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo de profil mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final success = await _photoService.deleteProfileImage();
      if (success) {
        setState(() {
          _currentImageUrl = null;
          _hasCustomImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo de profil supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Erreur lors de la suppression');
      }
    } catch (e) {
      print('Erreur lors de la suppression: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la suppression: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF18171C),
          title: const Text(
            'Choisir une source',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  'Galerie',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Caméra',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF18171C),
          title: const Text(
            'Supprimer la photo',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre photo de profil ?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteImage();
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileImage() {
    if (_currentImageUrl != null) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: ClipOval(
          child: Image.network(
            ProfilePhotoService.getFullImageUrl(_currentImageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          color: Colors.grey[300],
        ),
        child: const Icon(
          Icons.person,
          size: 80,
          color: Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        elevation: 0,
        title: const Text(
          'Photo de profil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Photo de profil actuelle
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _buildProfileImage(),
            ),

            const SizedBox(height: 40),

            // Informations
            if (_hasCustomImage)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18171C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Vous avez une photo de profil personnalisée',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Boutons d'action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _showImageSourceDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo),
                    const SizedBox(width: 8),
                    Text(
                      _hasCustomImage
                          ? 'Changer la photo'
                          : 'Ajouter une photo',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            if (_hasCustomImage) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _showDeleteConfirmDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text(
                        'Supprimer la photo',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Conseils
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18171C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conseils pour une bonne photo de profil :',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Utilisez une photo récente et claire\n'
                    '• Assurez-vous que votre visage est bien visible\n'
                    '• Évitez les photos floues ou trop sombres\n'
                    '• Taille maximum : 5MB\n'
                    '• Formats acceptés : JPG, PNG, GIF, WebP',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
