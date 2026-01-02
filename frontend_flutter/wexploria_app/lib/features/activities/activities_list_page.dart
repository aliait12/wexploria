import 'package:flutter/material.dart';
import 'package:wexploria_app/core/constants/app_constants.dart';
import 'package:wexploria_app/core/models/activite.dart';
import 'package:wexploria_app/core/services/activite_service.dart';
import 'widgets/activity_card.dart';

class ActivitiesListPage extends StatefulWidget {
  const ActivitiesListPage({super.key});

  @override
  State<ActivitiesListPage> createState() => _ActivitiesListPageState();
}

class _ActivitiesListPageState extends State<ActivitiesListPage> {
  final ActiviteService _activiteService = ActiviteService();
  List<Activite> _activites = [];
  bool _isLoading = true;
  String? _error;
  
  // Filtres
  String? _selectedType;
  String? _selectedNiveau;
  double? _prixMin;
  double? _prixMax;

  final List<String> _activityTypes = [
    'parapente',
    'surf',
    'kitesurf',
    'quad',
    'trekking',
    'hot_air_balloon',
  ];

  final List<String> _niveaux = [
    'debutant',
    'intermediaire',
    'expert',
  ];

  @override
  void initState() {
    super.initState();
    _loadActivites();
  }

  Future<void> _loadActivites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final activites = await _activiteService.getActivites(
        typeActivite: _selectedType,
        niveauDifficulte: _selectedNiveau,
        prixMin: _prixMin,
        prixMax: _prixMax,
      );

      setState(() {
        _activites = activites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersSheet(),
    );
  }

  Widget _buildFiltersSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      _selectedNiveau = null;
                      _prixMin = null;
                      _prixMax = null;
                    });
                    Navigator.pop(context);
                    _loadActivites();
                  },
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ),
          
          // Filtres
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type d'activité
                  Text(
                    'Type d\'activité',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _activityTypes.map((type) {
                      final isSelected = _selectedType == type;
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Niveau
                  Text(
                    'Niveau',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _niveaux.map((niveau) {
                      final isSelected = _selectedNiveau == niveau;
                      return FilterChip(
                        label: Text(niveau),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedNiveau = selected ? niveau : null;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.secondary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Prix
                  Text(
                    'Budget',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Prix min',
                            suffixText: '€',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _prixMin = double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Prix max',
                            suffixText: '€',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _prixMax = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          
          // Bouton Appliquer
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadActivites();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text('Appliquer les filtres'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Erreur de chargement',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton(
                        onPressed: _loadActivites,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _activites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Aucune activité trouvée',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Essayez de modifier vos filtres',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadActivites,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _activites.length,
                        itemBuilder: (context, index) {
                          final activite = _activites[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: ActivityCard(
                              activite: activite,
                              onTap: () {
                                // TODO: Navigate to activity detail
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
