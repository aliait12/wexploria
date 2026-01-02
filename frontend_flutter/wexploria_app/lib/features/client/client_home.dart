import 'package:flutter/material.dart';
import 'package:wexploria_app/core/constants/app_constants.dart';
import 'package:wexploria_app/features/auth/auth_service.dart';
import 'package:wexploria_app/features/auth/auth_page.dart';
import 'package:wexploria_app/features/activities/activities_list_page.dart';
import 'package:wexploria_app/core/services/activite_service.dart';
import 'package:wexploria_app/core/models/activite.dart';

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

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final activites = await _activiteService.getActivites(limit: 5);
      if (mounted) {
        setState(() {
          _activites = activites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Wexploria'),
            background: Container(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.network(
                        'https://picsum.photos/seed/wexploria/1200/400',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore. Fly. Feel free.',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: AppFontSizes.md,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Quick Actions
              _buildQuickActions(context),

              const SizedBox(height: AppSpacing.lg),

              // Recommended Activities Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommandé pour vous',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Voir tout')),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              SizedBox(
                height: 250,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _activites.isEmpty
                    ? const Center(child: Text('Aucune activité recommandée.'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _activites.length,
                        itemBuilder: (context, index) {
                          final activite = _activites[index];
                          return Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: AppSpacing.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      'https://picsum.photos/seed/${activite.id}/600/400',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.8),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activite.titre,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: AppColors.textWhite,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: AppColors.textWhite,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.xs,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  activite.localisationPrecise,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: AppColors.textWhite,
                                                    fontSize: AppFontSizes.sm,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.wb_sunny,
            title: 'Météo',
            subtitle: 'Conditions',
            gradient: AppColors.accentGradient,
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.favorite_outline,
            title: 'Favoris',
            subtitle: 'Mes activités',
            gradient: AppColors.secondaryGradient,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textWhite, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textWhite.withOpacity(0.9),
              ),
            ),
          ],
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
              if (nomController.text.isEmpty || siretController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs'),
                  ),
                );
                return;
              }

              final authService = AuthService();
              final userId = authService.currentUser?.id;

              if (userId == null) return;

              final error = await authService.requestOperatorRole(
                userId: userId,
                nomEntreprise: nomController.text,
                siret: siretController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Demande envoyée avec succès!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
