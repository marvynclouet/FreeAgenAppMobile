import 'package:flutter/material.dart';
import 'services/handibasket_team_service.dart';

class HandibasketTeamProfilePage extends StatefulWidget {
  const HandibasketTeamProfilePage({Key? key}) : super(key: key);

  @override
  _HandibasketTeamProfilePageState createState() =>
      _HandibasketTeamProfilePageState();
}

class _HandibasketTeamProfilePageState
    extends State<HandibasketTeamProfilePage> {
  final HandibasketTeamService _teamService = HandibasketTeamService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _teamService.getTeamProfile();
      if (profile != null) {
        setState(() {
          _profileData = profile;
          _initializeControllers(profile);
        });
      }
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
      _showErrorDialog('Erreur lors du chargement du profil');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers(Map<String, dynamic> data) {
    final fields = _teamService.getProfileFields();
    for (final field in fields) {
      final fieldName = field['name'] as String;
      _controllers[fieldName] = TextEditingController();

      // Initialiser avec les données existantes
      if (data.containsKey(fieldName) && data[fieldName] != null) {
        _controllers[fieldName]!.text = data[fieldName].toString();
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer les données du formulaire
      for (final field in _teamService.getProfileFields()) {
        final fieldName = field['name'] as String;
        final controller = _controllers[fieldName];
        if (controller != null) {
          _formData[fieldName] = controller.text;
        }
      }

      final success = await _teamService.updateTeamProfile(_formData);

      if (success) {
        setState(() {
          _isEditing = false;
        });
        _showSuccessDialog('Profil mis à jour avec succès');
        await _loadProfile(); // Recharger les données
      } else {
        _showErrorDialog('Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      _showErrorDialog('Erreur lors de la sauvegarde');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(Widget child, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String fieldName, String label,
      {bool isRequired = false}) {
    final controller = _controllers[fieldName];
    if (controller == null) return const SizedBox.shrink();

    return _buildField(
      TextFormField(
        controller: controller,
        enabled: _isEditing,
        decoration: InputDecoration(
          hintText: 'Entrez $label',
          border: const OutlineInputBorder(),
          suffixIcon: isRequired
              ? const Icon(Icons.star, color: Colors.red, size: 16)
              : null,
        ),
      ),
      label + (isRequired ? ' *' : ''),
    );
  }

  Widget _buildDropdownField(
      String fieldName, String label, List<String> options,
      {bool isRequired = false}) {
    final controller = _controllers[fieldName];
    if (controller == null) return const SizedBox.shrink();

    return _buildField(
      DropdownButtonFormField<String>(
        value: options.contains(controller.text) ? controller.text : null,
        onChanged: _isEditing
            ? (value) {
                if (value != null) {
                  controller.text = value;
                }
              }
            : null,
        decoration: InputDecoration(
          hintText: 'Sélectionnez $label',
          border: const OutlineInputBorder(),
          suffixIcon: isRequired
              ? const Icon(Icons.star, color: Colors.red, size: 16)
              : null,
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
      label + (isRequired ? ' *' : ''),
    );
  }

  Widget _buildCheckboxField(String fieldName, String label) {
    final controller = _controllers[fieldName];
    if (controller == null) return const SizedBox.shrink();

    final bool value =
        controller.text.toLowerCase() == 'true' || controller.text == '1';

    return _buildField(
      CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: _isEditing
            ? (bool? newValue) {
                controller.text = newValue == true ? 'true' : 'false';
                setState(() {});
              }
            : null,
        controlAffinity: ListTileControlAffinity.leading,
      ),
      '',
    );
  }

  Widget _buildTextAreaField(String fieldName, String label,
      {bool isRequired = false}) {
    final controller = _controllers[fieldName];
    if (controller == null) return const SizedBox.shrink();

    return _buildField(
      TextFormField(
        controller: controller,
        enabled: _isEditing,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Entrez $label',
          border: const OutlineInputBorder(),
          suffixIcon: isRequired
              ? const Icon(Icons.star, color: Colors.red, size: 16)
              : null,
        ),
      ),
      label + (isRequired ? ' *' : ''),
    );
  }

  Widget _buildFormField(Map<String, dynamic> field) {
    final fieldName = field['name'] as String;
    final label = field['label'] as String;
    final type = field['type'] as String;
    final isRequired = field['required'] as bool? ?? false;

    switch (type) {
      case 'dropdown':
        final options = (field['options'] as List<dynamic>).cast<String>();
        return _buildDropdownField(fieldName, label, options,
            isRequired: isRequired);
      case 'checkbox':
        return _buildCheckboxField(fieldName, label);
      case 'textarea':
        return _buildTextAreaField(fieldName, label, isRequired: isRequired);
      case 'number':
        return _buildField(
          TextFormField(
            controller: _controllers[fieldName],
            enabled: _isEditing,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Entrez $label',
              border: const OutlineInputBorder(),
              suffixIcon: isRequired
                  ? const Icon(Icons.star, color: Colors.red, size: 16)
                  : null,
            ),
          ),
          label + (isRequired ? ' *' : ''),
        );
      case 'email':
        return _buildField(
          TextFormField(
            controller: _controllers[fieldName],
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Entrez $label',
              border: const OutlineInputBorder(),
              suffixIcon: isRequired
                  ? const Icon(Icons.star, color: Colors.red, size: 16)
                  : null,
            ),
          ),
          label + (isRequired ? ' *' : ''),
        );
      case 'url':
        return _buildField(
          TextFormField(
            controller: _controllers[fieldName],
            enabled: _isEditing,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'Entrez $label',
              border: const OutlineInputBorder(),
              suffixIcon: isRequired
                  ? const Icon(Icons.star, color: Colors.red, size: 16)
                  : null,
            ),
          ),
          label + (isRequired ? ' *' : ''),
        );
      default:
        return _buildTextField(fieldName, label, isRequired: isRequired);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil Équipe Handibasket'),
        ),
        body: const Center(
          child: Text('Aucun profil trouvé'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Équipe Handibasket'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadProfile(); // Recharger les données originales
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom de l'équipe
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profileData?['team_name'] ?? 'Nom de l\'équipe',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_profileData?['city'] ?? 'Ville'}, ${_profileData?['region'] ?? 'Région'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Niveau: ${_profileData?['level'] ?? 'Non spécifié'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Formulaire
            ..._teamService
                .getProfileFields()
                .map((field) => _buildFormField(field))
                .toList(),

            const SizedBox(height: 32),

            // Boutons d'action
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Sauvegarder'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                        _loadProfile();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

