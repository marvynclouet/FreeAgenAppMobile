import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/content_service.dart';

class CreatePostWidget extends StatefulWidget {
  final VoidCallback? onPostCreated;

  const CreatePostWidget({Key? key, this.onPostCreated}) : super(key: key);

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _contentController = TextEditingController();
  final ContentService _contentService = ContentService();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  bool _isEvent = false;
  DateTime? _eventDate;
  String _eventLocation = '';
  bool _isPosting = false;
  TimeOfDay? _eventTime;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      print('Erreur lors de la sélection d\'images: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      print('Erreur lors de la prise de photo: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectEventDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _selectEventTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _eventTime = picked;
      });
    }
  }

  Future<List<String>> _uploadSelectedImages() async {
    List<String> imageUrls = [];
    for (final file in _selectedImages) {
      try {
        final url = await _contentService.uploadPostImage(file);
        if (url != null) imageUrls.add(url);
      } catch (e) {
        print('Erreur upload image: $e');
      }
    }
    return imageUrls;
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez écrire quelque chose')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final imageUrls = await _uploadSelectedImages();

      String? eventTimeStr;
      if (_isEvent && _eventTime != null) {
        final hour = _eventTime!.hour.toString().padLeft(2, '0');
        final minute = _eventTime!.minute.toString().padLeft(2, '0');
        eventTimeStr = '$hour:$minute:00';
      }

      final success = await _contentService.createPost(
        content: _contentController.text.trim(),
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
        eventDate: _isEvent && _eventDate != null
            ? _eventDate!.toIso8601String()
            : null,
        eventLocation: _isEvent ? _eventLocation : null,
        eventTime: eventTimeStr,
      );

      if (success) {
        _contentController.clear();
        setState(() {
          _selectedImages.clear();
          _isEvent = false;
          _eventDate = null;
          _eventLocation = '';
        });

        widget.onPostCreated?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post créé avec succès !')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la création du post')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erreur lors de la création du post';

        if (e
            .toString()
            .contains('Fonctionnalité réservée aux abonnés premium')) {
          errorMessage =
              'Fonctionnalité réservée aux abonnés premium. Veuillez mettre à niveau votre abonnement.';
        } else if (e.toString().contains('Token non disponible')) {
          errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor:
                e.toString().contains('premium') ? Colors.orange : Colors.red,
            duration: const Duration(seconds: 4),
            action: e.toString().contains('premium')
                ? SnackBarAction(
                    label: 'Mettre à niveau',
                    textColor: Colors.white,
                    onPressed: () {
                      // Navigation vers la page d'abonnement
                      Navigator.of(context).pushNamed('/premium');
                    },
                  )
                : null,
          ),
        );
      }
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF9B5CFF),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Créer un post',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Zone de texte compacte
          TextField(
            controller: _contentController,
            maxLines: 3,
            minLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Exprime-toi...',
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Color(0xFF18171C),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          // Images sélectionnées
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          // Section événement
          if (_isEvent) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event, color: Color(0xFF9B5CFF)),
                      const SizedBox(width: 8),
                      const Text(
                        'Détails de l\'événement',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectEventDate,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.white54, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _eventDate != null
                                      ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'
                                      : 'Date',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectEventTime,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white54, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _eventTime != null
                                      ? _eventTime!.format(context)
                                      : 'Heure',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => _eventLocation = value,
                          decoration: const InputDecoration(
                            hintText: 'Lieu',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              // Bouton photo
              IconButton(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library,
                    color: Colors.white, size: 20),
                tooltip: 'Ajouter une photo',
              ),
              // Bouton caméra
              IconButton(
                onPressed: _takePhoto,
                icon:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                tooltip: 'Prendre une photo',
              ),
              // Bouton événement
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEvent = !_isEvent;
                    if (!_isEvent) {
                      _eventDate = null;
                      _eventLocation = '';
                    }
                  });
                },
                icon: Icon(Icons.event,
                    color: _isEvent ? const Color(0xFF9B5CFF) : Colors.white,
                    size: 20),
                tooltip: 'Ajouter un événement',
              ),
              const Spacer(),
              // Bouton poster
              ElevatedButton(
                onPressed: _isPosting ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B5CFF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Publier'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
