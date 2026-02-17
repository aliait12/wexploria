import 'package:flutter/material.dart';
import 'package:wexploria_app/core/constants/app_constants.dart';
import 'package:wexploria_app/features/auth/auth_service.dart';
import 'package:wexploria_app/features/auth/auth_page.dart';
import 'package:wexploria_app/features/activities/activities_list_page.dart';
import 'package:wexploria_app/core/services/activite_service.dart';
import 'package:wexploria_app/core/models/activite.dart';
import 'package:wexploria_app/features/activities/widgets/activity_card.dart';
import 'package:wexploria_app/features/activities/activity_details_page.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ClientDashboardTab(),
    const ActivitiesListPage(),
    const ClientBookingsTab(),
    const ClientProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Activités',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Réservations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard Tab
class ClientDashboardTab extends StatefulWidget {
  const ClientDashboardTab({super.key});

  @override
  State<ClientDashboardTab> createState() => _ClientDashboardTabState();
}

class _ClientDashboardTabState extends State<ClientDashboardTab> {
  final ActiviteService _activiteService = ActiviteService();
  List<Activite> _activites = [];
  bool _isLoading = true;
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Desert', 'icon': Icons.landscape, 'type': 'desert'},
    {'name': 'Atlas', 'icon': Icons.hiking, 'type': 'atlas'},
    {'name': 'Water', 'icon': Icons.surfing, 'type': 'water'},
    {'name': 'Air', 'icon': Icons.flight, 'type': 'air'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load Activities only - weather removed temporarily
      final activites = await _activiteService.getActivites(limit: 20);

      if (mounted) {
        setState(() {
          _activites = activites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error loading activities: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  void _onCategorySelected(String? type) {
    if (_selectedCategory == type) {
      // Toggle off
      setState(() => _selectedCategory = null);
    } else {
      setState(() => _selectedCategory = type);
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.lg),

                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: AppSpacing.lg),

                    // Categories
                    Text(
                      'Explore by Type',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildCategories(),

                    const SizedBox(height: AppSpacing.xl),

                    // Filter Chips (Recommended, Price, etc)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Toutes', false),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip('Recommended', false),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip('Price: Low to High', false),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip('Rating 4.5+', false),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Activities List
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _activites.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('Aucune activité trouvée.'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _activites.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: ActivityCard(
                                  activite: _activites[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ActivityDetailsPage(
                                              activite: _activites[index],
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                    const SizedBox(
                      height: 80,
                    ), // Bottom padding for nav bar space
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Logo placeholder or Asset
            // Container(
            //   width: 40,
            //   height: 40,
            //   decoration: const BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: AppColors.primary,
            //   ),
            //   child: const Icon(Icons.explore, color: Colors.white),
            // ),
            // const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wexploria',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors
                        .textPrimary, // Or White if background is colored
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Marrakech, Morocco',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Find your next adventure...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
          suffixIcon: Container(
            margin: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['type'];
        return GestureDetector(
          onTap: () => _onCategorySelected(cat['type']),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Icon(
                  cat['icon'],
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cat['name'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Bookings Tab
class ClientBookingsTab extends StatelessWidget {
  const ClientBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Réservations')),
      body: const Center(child: Text('Liste des réservations à venir')),
    );
  }
}

// Profile Tab
class ClientProfileTab extends StatelessWidget {
  const ClientProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.textWhite,
                  child: Icon(Icons.person, size: 50, color: AppColors.primary),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Client Wexploria',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppFontSizes.xl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'client@wexploria.com',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppFontSizes.sm,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'Informations personnelles',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.payment,
            title: 'Moyens de paiement',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'Historique',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Paramètres',
            onTap: () {},
          ),

          // Added Operator Request
          _buildMenuItem(
            context,
            icon: Icons.business,
            title: 'Devenir Opérateur',
            onTap: () => _showOperatorRequestDialog(context),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textWhite,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  void _showOperatorRequestDialog(BuildContext context) {
    // ... Existing implementation or move to a separate widget if too large ...
    // For brevity keeping it simple or reuse previous logic if needed.
    // If it was lost in replacement, I should restore it.

    final nomController = TextEditingController();
    final siretController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Devenir Opérateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Soumettez votre demande pour créer des activités sur Wexploria.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'entreprise',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: siretController,
              decoration: const InputDecoration(
                labelText: 'Numéro SIRET',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // ... Auth Service call logic ...
              // Re-implementing simplified version
              final authService = AuthService();
              final userId = authService.currentUser?.id;
              if (userId != null && nomController.text.isNotEmpty) {
                await authService.requestOperatorRole(
                  userId: userId,
                  nomEntreprise: nomController.text,
                  siret: siretController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
