import 'package:flutter/material.dart';
import 'package:wexploria_app/core/constants/app_constants.dart';
import 'package:wexploria_app/features/auth/auth_service.dart';
import 'package:wexploria_app/features/auth/auth_page.dart';
import 'package:wexploria_app/core/models/activite.dart';
import 'package:wexploria_app/core/services/activite_service.dart';
import 'package:wexploria_app/core/services/reservation_service.dart';
import 'package:wexploria_app/core/models/reservation.dart';
import 'widgets/activite_form.dart';

class OperateurHomePage extends StatefulWidget {
  const OperateurHomePage({super.key});

  @override
  State<OperateurHomePage> createState() => _OperateurHomePageState();
}

class _OperateurHomePageState extends State<OperateurHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OperateurActivitiesTab(),
    const OperateurBookingsTab(),
    const OperateurTeamTab(),
    const OperateurStatsTab(),
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
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Activités',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'Résas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.badge_outlined),
              activeIcon: Icon(Icons.badge),
              label: 'Équipe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActiviteForm(onSaved: () => setState(() {})),
                ),
              ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.textWhite),
            )
          : null,
    );
  }
}

// --- Tabs ---

class OperateurActivitiesTab extends StatefulWidget {
  const OperateurActivitiesTab({super.key});

  @override
  State<OperateurActivitiesTab> createState() => _OperateurActivitiesTabState();
}

class _OperateurActivitiesTabState extends State<OperateurActivitiesTab> {
  final _service = ActiviteService();
  final _authService = AuthService();
  List<Activite> _activites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final data = await _service.getActivites(operateurId: user.id);
        setState(() => _activites = data);
      }
    } catch (e) {
      debugPrint('Error loading activities: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteActivity(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'activité ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'SUPPRIMER',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteActivite(id);
        _loadActivities();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Activités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activites.isEmpty
          ? const Center(child: Text('Aucune activité publiée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _activites.length,
              itemBuilder: (context, index) {
                final activite = _activites[index];
                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        ActivityIcons.getIcon(activite.typeActivite),
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(activite.titre),
                    subtitle: Text(
                      '${activite.prixBase} € • ${activite.statut}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActiviteForm(
                                activite: activite,
                                onSaved: _loadActivities,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () => _deleteActivity(activite.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OperateurBookingsTab extends StatefulWidget {
  const OperateurBookingsTab({super.key});

  @override
  State<OperateurBookingsTab> createState() => _OperateurBookingsTabState();
}

class _OperateurBookingsTabState extends State<OperateurBookingsTab> {
  final _service = ReservationService();
  final _authService = AuthService();
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final data = await _service.getOperateurReservations(user.id);
        setState(() => _reservations = data);
      }
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStatusUpdate(String id, String action) async {
    try {
      if (action == 'confirm') {
        await _service.confirmReservation(id);
      } else if (action == 'cancel') {
        await _service.cancelReservation(id, motif: 'Annulé par l\'opérateur');
      }
      _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Réservation ${action == 'confirm' ? 'confirmée' : 'annulée'} avec succès',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'confirmee':
        return AppColors.success;
      case 'annulee':
        return AppColors.error;
      case 'en_attente':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Réservations'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
          ? const Center(child: Text('Aucune réservation enregistrée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final res = _reservations[index];
                final dateStr =
                    res.dateActivite.day.toString().padLeft(2, '0') +
                    '/' +
                    res.dateActivite.month.toString().padLeft(2, '0') +
                    '/' +
                    res.dateActivite.year.toString();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          res.statut,
                        ).withOpacity(0.1),
                        child: Icon(
                          Icons.calendar_month,
                          color: _getStatusColor(res.statut),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Résa #${res.id.substring(0, 8)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                res.statut,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              res.statut.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(res.statut),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Date: $dateStr • ${res.nombreParticipants} pers.',
                          ),
                          Text('Total: ${res.prixTotal} €'),
                        ],
                      ),
                      trailing: res.statut == 'en_attente'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.success,
                                  ),
                                  onPressed: () =>
                                      _handleStatusUpdate(res.id, 'confirm'),
                                  tooltip: 'Confirmer',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      _handleStatusUpdate(res.id, 'cancel'),
                                  tooltip: 'Annuler',
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OperateurTeamTab extends StatelessWidget {
  const OperateurTeamTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Équipe')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 4,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Pilote Nom ${index + 1}'),
            subtitle: const Text('Actif • Certifié'),
            trailing: const Icon(Icons.chat_bubble_outline),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class OperateurStatsTab extends StatelessWidget {
  const OperateurStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildStatCard(
              'Chiffre d\'affaires',
              '15,400 €',
              Icons.trending_up,
              Colors.green,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatCard(
              'Réservations ce mois',
              '42',
              Icons.calendar_today,
              Colors.blue,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatCard(
              'Note moyenne école',
              '4.8/5',
              Icons.star,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: AppSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppFontSizes.xl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
