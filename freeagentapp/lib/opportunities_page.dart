import 'package:flutter/material.dart';
import 'services/opportunity_service.dart';
import 'services/auth_service.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({Key? key}) : super(key: key);

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  final OpportunityService _opportunityService = OpportunityService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _opportunities = [];
  List<Map<String, dynamic>> _filteredOpportunities = [];
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _selectedFilter = 'all';
  bool _showMyOpportunities = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterOpportunities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userData = await _authService.getUserData();
      final opportunities = await _opportunityService.getOpportunities();
      setState(() {
        _userData = userData;
        _opportunities = opportunities;
        _isLoading = false;
      });
      _filterOpportunities();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterOpportunities() {
    List<Map<String, dynamic>> filtered = List.from(_opportunities);

    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((opp) {
        return (opp['title'] ?? '').toLowerCase().contains(query) ||
            (opp['description'] ?? '').toLowerCase().contains(query) ||
            (opp['user_name'] ?? '').toLowerCase().contains(query);
      }).toList();
    }

    // Filtrer par type
    if (_selectedFilter != 'all') {
      filtered =
          filtered.where((opp) => opp['type'] == _selectedFilter).toList();
    }

    // Filtrer mes annonces
    if (_showMyOpportunities && _userData != null) {
      filtered =
          filtered.where((opp) => opp['user_id'] == _userData!['id']).toList();
    }

    setState(() {
      _filteredOpportunities = filtered;
    });
  }

  void _showCreateOpportunityDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOpportunityPage(
          onOpportunityCreated: () {
            _loadData();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF9B5CFF),
          backgroundColor: const Color(0xFF18171C),
          onRefresh: _loadData,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec titre et bouton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Annonces',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B5CFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 24),
                        onPressed: _showCreateOpportunityDialog,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Barre de recherche
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18171C),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Rechercher une annonce...',
                            hintStyle:
                                TextStyle(color: Colors.white38, fontSize: 16),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: const Icon(Icons.clear, color: Colors.white38),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Filtres
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(
                          'Toutes', 'all', _selectedFilter == 'all'),
                      _buildFilterChip(
                          'Équipe → Joueur',
                          'equipe_recherche_joueur',
                          _selectedFilter == 'equipe_recherche_joueur'),
                      _buildFilterChip(
                          'Joueur → Équipe',
                          'joueur_recherche_equipe',
                          _selectedFilter == 'joueur_recherche_equipe'),
                      _buildFilterChip(
                          'Coach → Équipe',
                          'coach_recherche_equipe',
                          _selectedFilter == 'coach_recherche_equipe'),
                      _buildFilterChip(
                          'Équipe → Coach',
                          'equipe_recherche_coach',
                          _selectedFilter == 'equipe_recherche_coach'),
                      _buildFilterChip('Services Pro', 'service_professionnel',
                          _selectedFilter == 'service_professionnel'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle mes annonces
                Row(
                  children: [
                    Switch(
                      value: _showMyOpportunities,
                      onChanged: (value) {
                        setState(() {
                          _showMyOpportunities = value;
                        });
                        _filterOpportunities();
                      },
                      activeColor: const Color(0xFF9B5CFF),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mes annonces uniquement',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Liste des annonces
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF9B5CFF)),
                    ),
                  )
                else if (_filteredOpportunities.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off_outlined,
                            size: 64,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty ||
                                    _selectedFilter != 'all' ||
                                    _showMyOpportunities
                                ? 'Aucune annonce trouvée'
                                : 'Aucune annonce disponible',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Soyez le premier à publier !',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredOpportunities.length,
                      itemBuilder: (context, index) {
                        final opportunity = _filteredOpportunities[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OpportunityDetailPage(
                                  opportunity: opportunity,
                                  isOwner: opportunity['user_id'] ==
                                      _userData?['id'],
                                  onUpdate: _loadData,
                                ),
                              ),
                            );
                          },
                          child: OpportunityCard(
                            title: opportunity['title'],
                            details: opportunity['description'],
                            publisher: opportunity['user_name'],
                            type: opportunity['type'],
                            requirements: opportunity['requirements'],
                            salaryRange: opportunity['salary_range'],
                            location: opportunity['location'],
                            createdAt: opportunity['created_at'],
                            onClose: opportunity['user_id'] == _userData?['id']
                                ? () async {
                                    try {
                                      await _opportunityService
                                          .closeOpportunity(opportunity['id']);
                                      _loadData();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Erreur: $e')),
                                      );
                                    }
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? value : 'all';
          });
          _filterOpportunities();
        },
        selectedColor: const Color(0xFF9B5CFF),
        backgroundColor: const Color(0xFF18171C),
        side: BorderSide(
          color: isSelected ? const Color(0xFF9B5CFF) : Colors.white24,
        ),
      ),
    );
  }
}

class CreateOpportunityPage extends StatefulWidget {
  final VoidCallback onOpportunityCreated;

  const CreateOpportunityPage({
    Key? key,
    required this.onOpportunityCreated,
  }) : super(key: key);

  @override
  State<CreateOpportunityPage> createState() => _CreateOpportunityPageState();
}

class _CreateOpportunityPageState extends State<CreateOpportunityPage> {
  final OpportunityService _opportunityService = OpportunityService();
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final salaryRangeController = TextEditingController();
  final locationController = TextEditingController();

  OpportunityType selectedType = OpportunityType.equipe_recherche_joueur;
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    salaryRangeController.dispose();
    locationController.dispose();
    super.dispose();
  }

  String getTypeLabel(OpportunityType type) {
    switch (type) {
      case OpportunityType.equipe_recherche_joueur:
        return 'Équipe cherche joueur';
      case OpportunityType.joueur_recherche_equipe:
        return 'Joueur cherche équipe';
      case OpportunityType.coach_recherche_equipe:
        return 'Coach cherche équipe';
      case OpportunityType.coach_recherche_joueur:
        return 'Coach cherche joueur';
      case OpportunityType.equipe_recherche_coach:
        return 'Équipe cherche coach';
      case OpportunityType.service_professionnel:
        return 'Service professionnel';
      case OpportunityType.autre:
        return 'Autre';
    }
  }

  IconData getTypeIcon(OpportunityType type) {
    switch (type) {
      case OpportunityType.equipe_recherche_joueur:
        return Icons.group_add;
      case OpportunityType.joueur_recherche_equipe:
        return Icons.person_search;
      case OpportunityType.coach_recherche_equipe:
        return Icons.sports_basketball;
      case OpportunityType.coach_recherche_joueur:
        return Icons.sports;
      case OpportunityType.equipe_recherche_coach:
        return Icons.psychology;
      case OpportunityType.service_professionnel:
        return Icons.business_center;
      case OpportunityType.autre:
        return Icons.more_horiz;
    }
  }

  Future<void> _createOpportunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _opportunityService.createOpportunity(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        type: selectedType,
        requirements: requirementsController.text.trim(),
        salaryRange: salaryRangeController.text.trim(),
        location: locationController.text.trim(),
      );

      widget.onOpportunityCreated();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce créée avec succès !'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer une annonce',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Type d'annonce
              const Text(
                'Type d\'annonce',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF18171C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: OpportunityType.values.length,
                  itemBuilder: (context, index) {
                    final type = OpportunityType.values[index];
                    final isSelected = selectedType == type;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = type;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF9B5CFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF9B5CFF)
                                : Colors.white24,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              getTypeIcon(type),
                              color: isSelected ? Colors.white : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getTypeLabel(type),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Formulaire
              _buildTextField(
                controller: titleController,
                label: 'Titre de l\'annonce',
                hint: 'Ex: Recherche ailier shooteur expérimenté',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est requis';
                  }
                  if (value.trim().length < 5) {
                    return 'Le titre doit contenir au moins 5 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: descriptionController,
                label: 'Description détaillée',
                hint: 'Décrivez en détail votre recherche...',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est requise';
                  }
                  if (value.trim().length < 20) {
                    return 'La description doit contenir au moins 20 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: requirementsController,
                label: 'Prérequis et compétences',
                hint: 'Ex: 5 ans d\'expérience, licence N2...',
                icon: Icons.checklist,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Les prérequis sont requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: locationController,
                      label: 'Localisation',
                      hint: 'Paris, Lyon...',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La localisation est requise';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: salaryRangeController,
                      label: 'Rémunération',
                      hint: '2000-3000€',
                      icon: Icons.attach_money,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La rémunération est requise';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Bouton de création
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createOpportunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B5CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.publish, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Publier l\'annonce',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: Icon(icon, color: const Color(0xFF9B5CFF)),
            filled: true,
            fillColor: const Color(0xFF18171C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9B5CFF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class OpportunityCard extends StatelessWidget {
  final String title;
  final String details;
  final String publisher;
  final String type;
  final String? requirements;
  final String? salaryRange;
  final String? location;
  final String? createdAt;
  final VoidCallback? onClose;

  const OpportunityCard({
    required this.title,
    required this.details,
    required this.publisher,
    required this.type,
    this.requirements,
    this.salaryRange,
    this.location,
    this.createdAt,
    this.onClose,
    Key? key,
  }) : super(key: key);

  String getTypeLabel(String type) {
    switch (type) {
      case 'equipe_recherche_joueur':
        return 'Équipe cherche joueur';
      case 'joueur_recherche_equipe':
        return 'Joueur cherche équipe';
      case 'coach_recherche_equipe':
        return 'Coach cherche équipe';
      case 'coach_recherche_joueur':
        return 'Coach cherche joueur';
      case 'equipe_recherche_coach':
        return 'Équipe cherche coach';
      case 'service_professionnel':
        return 'Service professionnel';
      case 'autre':
        return 'Autre';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color getTypeColor(String type) {
      switch (type) {
        case 'equipe_recherche_joueur':
          return const Color(0xFF2196F3);
        case 'joueur_recherche_equipe':
          return const Color(0xFF4CAF50);
        case 'coach_recherche_equipe':
          return const Color(0xFF9B5CFF);
        case 'equipe_recherche_coach':
          return const Color(0xFFFF9800);
        case 'service_professionnel':
          return const Color(0xFFE91E63);
        case 'coach_recherche_joueur':
          return const Color(0xFF00BCD4);
        default:
          return const Color(0xFF607D8B);
      }
    }

    String formatDate(String? dateStr) {
      if (dateStr == null) return '';
      try {
        final date = DateTime.parse(dateStr);
        final now = DateTime.now();
        final difference = now.difference(date).inDays;

        if (difference == 0) return 'Aujourd\'hui';
        if (difference == 1) return 'Hier';
        if (difference < 7) return 'Il y a ${difference}j';
        if (difference < 30) return 'Il y a ${(difference / 7).floor()}sem';
        return 'Il y a ${(difference / 30).floor()}mois';
      } catch (e) {
        return '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getTypeColor(type).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec type et actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getTypeColor(type).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getTypeColor(type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getTypeLabel(type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (createdAt != null)
                      Text(
                        formatDate(createdAt),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    if (onClose != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                const SizedBox(height: 8),
                Text(
                  details,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                if (requirements != null && requirements!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111014),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.checklist,
                                color: Color(0xFF9B5CFF), size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Prérequis',
                              style: TextStyle(
                                color: Color(0xFF9B5CFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          requirements!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Informations supplémentaires
                Row(
                  children: [
                    if (location != null && location!.isNotEmpty) ...[
                      const Icon(Icons.location_on,
                          color: Colors.white54, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        location!,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (salaryRange != null && salaryRange!.isNotEmpty) ...[
                      const Icon(Icons.attach_money,
                          color: Colors.white54, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        salaryRange!,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Publisher info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: getTypeColor(type),
                      radius: 16,
                      child: Text(
                        publisher.isNotEmpty ? publisher[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Publié par $publisher',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OpportunityDetailPage extends StatefulWidget {
  final Map<String, dynamic> opportunity;
  final bool isOwner;
  final VoidCallback onUpdate;

  const OpportunityDetailPage({
    Key? key,
    required this.opportunity,
    required this.isOwner,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<OpportunityDetailPage> createState() => _OpportunityDetailPageState();
}

class _OpportunityDetailPageState extends State<OpportunityDetailPage> {
  final OpportunityService _opportunityService = OpportunityService();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    if (widget.isOwner) {
      _loadApplications();
    } else {
      _checkIfApplied();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final applications =
          await _opportunityService.getApplications(widget.opportunity['id']);
      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _checkIfApplied() async {
    try {
      final hasApplied =
          await _opportunityService.hasApplied(widget.opportunity['id']);
      setState(() {
        _hasApplied = hasApplied;
      });
    } catch (e) {
      print('Erreur lors de la vérification: $e');
    }
  }

  Future<void> _applyToOpportunity() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un message')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      await _opportunityService.applyToOpportunity(
        widget.opportunity['id'],
        _messageController.text.trim(),
      );
      setState(() {
        _hasApplied = true;
        _isLoading = false;
      });
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidature envoyée avec succès !'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color getTypeColor(String type) {
      switch (type) {
        case 'equipe_recherche_joueur':
          return const Color(0xFF2196F3);
        case 'joueur_recherche_equipe':
          return const Color(0xFF4CAF50);
        case 'coach_recherche_equipe':
          return const Color(0xFF9B5CFF);
        case 'equipe_recherche_coach':
          return const Color(0xFFFF9800);
        case 'service_professionnel':
          return const Color(0xFFE91E63);
        case 'coach_recherche_joueur':
          return const Color(0xFF00BCD4);
        default:
          return const Color(0xFF607D8B);
      }
    }

    String getTypeLabel(String type) {
      switch (type) {
        case 'equipe_recherche_joueur':
          return 'Équipe cherche joueur';
        case 'joueur_recherche_equipe':
          return 'Joueur cherche équipe';
        case 'coach_recherche_equipe':
          return 'Coach cherche équipe';
        case 'coach_recherche_joueur':
          return 'Coach cherche joueur';
        case 'equipe_recherche_coach':
          return 'Équipe cherche coach';
        case 'service_professionnel':
          return 'Service professionnel';
        case 'autre':
          return 'Autre';
        default:
          return type;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111014),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isOwner ? 'Mon annonce' : 'Détails de l\'annonce',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: widget.isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF18171C),
                        title: const Text('Fermer l\'annonce',
                            style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'Êtes-vous sûr de vouloir fermer cette annonce ?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Fermer',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await _opportunityService
                            .closeOpportunity(widget.opportunity['id']);
                        widget.onUpdate();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: getTypeColor(widget.opportunity['type']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                getTypeLabel(widget.opportunity['type']),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            Text(
              widget.opportunity['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Publié par
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: getTypeColor(widget.opportunity['type']),
                  radius: 16,
                  child: Text(
                    widget.opportunity['user_name']?.isNotEmpty == true
                        ? widget.opportunity['user_name'][0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Publié par ${widget.opportunity['user_name']}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18171C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.opportunity['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prérequis
            if (widget.opportunity['requirements']?.isNotEmpty == true)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18171C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.checklist,
                            color: Color(0xFF9B5CFF), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Prérequis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.opportunity['requirements'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Informations supplémentaires
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18171C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.opportunity['location']?.isNotEmpty == true)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white54, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.opportunity['location'],
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  if (widget.opportunity['salary_range']?.isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.attach_money,
                            color: Colors.white54, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.opportunity['salary_range'],
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section candidatures ou postuler
            if (widget.isOwner) ...[
              // Voir les candidatures
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Candidatures reçues',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B5CFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_applications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF9B5CFF)),
                )
              else if (_applications.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18171C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune candidature pour le moment',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final application = _applications[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18171C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF9B5CFF),
                                radius: 20,
                                child: Text(
                                  application['user_name']?.isNotEmpty == true
                                      ? application['user_name'][0]
                                          .toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      application['user_name'] ?? 'Utilisateur',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      application['created_at'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            application['message'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ] else ...[
              // Postuler à l'annonce
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18171C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasApplied
                          ? 'Vous avez déjà postulé'
                          : 'Postuler à cette annonce',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_hasApplied) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _messageController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Écrivez votre message de motivation...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF111014),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _applyToOpportunity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B5CFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Envoyer ma candidature',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                            SizedBox(width: 12),
                            Text(
                              'Candidature envoyée avec succès !',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
