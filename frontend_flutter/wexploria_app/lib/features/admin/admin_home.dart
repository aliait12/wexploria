import 'package:flutter/material.dart';
import 'package:wexploria_app/core/constants/app_constants.dart';
import 'package:wexploria_app/features/auth/auth_service.dart';
import 'package:wexploria_app/features/auth/auth_page.dart';
import 'package:wexploria_app/core/services/admin_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminStatsTab(),
    const AdminUsersTab(),
    const AdminModerationTab(),
    const AdminSettingsTab(),
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
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Vue d\'ensemble',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt),
              label: 'Utilisateurs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.gavel_outlined),
              activeIcon: Icon(Icons.gavel),
              label: 'Modération',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Système',
            ),
          ],
        ),
      ),
    );
  }
}

// --- Tabs ---

class AdminStatsTab extends StatelessWidget {
  const AdminStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supervision Globele')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildKpiGrid(),
            const SizedBox(height: AppSpacing.lg),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      children: [
        _buildStatTile('Total CA', '452k €', Icons.euro, Colors.green),
        _buildStatTile('Utilisateurs', '1.2k', Icons.person, Colors.blue),
        _buildStatTile(
          'Réservations',
          '8.4k',
          Icons.book_online,
          Colors.orange,
        ),
        _buildStatTile('Alertes IA', '12', Icons.auto_awesome, Colors.purple),
      ],
    );
  }

  Widget _buildStatTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: const TextStyle(
                fontSize: AppFontSizes.xl,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppFontSizes.xs,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité récente',
          style: TextStyle(
            fontSize: AppFontSizes.lg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.notification_important_outlined),
              ),
              title: const Text('Nouvel opérateur inscrit'),
              subtitle: const Text('Il y a 10 minutes'),
              trailing: const Text('Voir'),
              onTap: () {},
            );
          },
        ),
      ],
    );
  }
}

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final AdminService _adminService = AdminService();
  late Future<List<dynamic>> _pilotsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPilots();
  }

  void _refreshPilots() {
    setState(() {
      _pilotsFuture = _adminService.listPilots();
    });
  }

  void _showPilotForm({Map<String, dynamic>? pilotProfile}) {
    final dynamic pilotDataRaw = pilotProfile?['pilotes'];
    final bool hasInfo =
        pilotDataRaw != null &&
        ((pilotDataRaw is List && pilotDataRaw.isNotEmpty) ||
            (pilotDataRaw is Map && pilotDataRaw.isNotEmpty));

    final bool isEdit = hasInfo;
    final Map<String, dynamic>? pilotInfo = isEdit
        ? (pilotDataRaw is List
              ? pilotDataRaw.first as Map<String, dynamic>
              : pilotDataRaw as Map<String, dynamic>)
        : null;

    String selectedCertif = pilotInfo?['niveau_certification'] ?? 'initie';

    final emailController = TextEditingController(
      text: pilotProfile?['email'] ?? '',
    );
    final passwordController = TextEditingController();
    final nomController = TextEditingController(
      text: pilotProfile?['nom'] ?? '',
    );
    final prenomController = TextEditingController(
      text: pilotProfile?['prenom'] ?? '',
    );
    final specialiteController = TextEditingController(
      text: (pilotInfo?['specialite'] is List
          ? (pilotInfo?['specialite'] as List).join(', ')
          : ''),
    );
    final prixController = TextEditingController(
      text: (pilotInfo?['prix_horaire'] ?? 50.0).toString(),
    );
    final diplomesController = TextEditingController(
      text: (pilotInfo?['diplomes'] is List
          ? (pilotInfo?['diplomes'] as List).join(', ')
          : ''),
    );
    final licenceController = TextEditingController(
      text: pilotInfo?['numero_licence'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Modifier Pilote' : 'Vérifier / Créer Pilote'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEdit && (pilotProfile == null)) ...[
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                ),
              ],
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              const Divider(),
              TextField(
                controller: specialiteController,
                decoration: const InputDecoration(
                  labelText: 'Spécialités (virgules)',
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedCertif,
                decoration: const InputDecoration(
                  labelText: 'Niveau Certification',
                ),
                items: const [
                  DropdownMenuItem(value: 'initie', child: Text('Initié')),
                  DropdownMenuItem(value: 'confirme', child: Text('Confirmé')),
                  DropdownMenuItem(value: 'expert', child: Text('Expert')),
                ],
                onChanged: (val) => selectedCertif = val ?? 'initie',
              ),
              TextField(
                controller: diplomesController,
                decoration: const InputDecoration(
                  labelText: 'Diplômes (virgules)',
                ),
              ),
              TextField(
                controller: licenceController,
                decoration: const InputDecoration(labelText: 'Numéro Licence'),
              ),
              TextField(
                controller: prixController,
                decoration: const InputDecoration(
                  labelText: 'Prix horaire (€)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final pilotData = {
                  'specialite': specialiteController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  'niveau_certification': selectedCertif,
                  'diplomes': diplomesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  'numero_licence': licenceController.text,
                  'prix_horaire': double.tryParse(prixController.text) ?? 50.0,
                  'zone_intervention':
                      pilotInfo?['zone_intervention'] ?? ['France'],
                  'langues_parlees': pilotInfo?['langues_parlees'] ?? ['fr'],
                  'capacite_passagers': pilotInfo?['capacite_passagers'] ?? 1,
                };

                if (isEdit ||
                    (pilotProfile != null &&
                        pilotProfile['role'] == 'pilote')) {
                  await _adminService.updatePilotAccount(
                    userId: pilotProfile!['user_id'],
                    email: emailController.text,
                    nom: nomController.text,
                    prenom: prenomController.text,
                    pilotInfo: pilotData,
                  );
                } else {
                  await _adminService.createPilotAccount(
                    email: emailController.text,
                    password: passwordController.text,
                    nom: nomController.text,
                    prenom: prenomController.text,
                    pilotInfo: pilotData,
                  );
                }

                if (mounted) {
                  Navigator.pop(context);
                  _refreshPilots();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit ? 'Pilote mis à jour !' : 'Pilote créé !',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isEdit ? 'Enregistrer' : 'Créer'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePilot(Map<String, dynamic> pilot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment retirer le rôle pilote de ${pilot['nom'] ?? 'cet utilisateur'} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _adminService.deletePilotAccount(pilot['user_id']);
                if (mounted) {
                  Navigator.pop(context);
                  _refreshPilots();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rôle pilote retiré avec succès'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion Pilotes')),
      body: FutureBuilder<List<dynamic>>(
        future: _pilotsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final pilots = snapshot.data ?? [];
          if (pilots.isEmpty) {
            return const Center(child: Text('Aucun pilote trouvé.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: pilots.length,
            itemBuilder: (context, index) {
              final profile = pilots[index] as Map<String, dynamic>?;
              if (profile == null) return const SizedBox.shrink();

              final dynamic pilotRaw = profile['pilotes'];
              final bool hasInfo =
                  pilotRaw != null &&
                  ((pilotRaw is List && pilotRaw.isNotEmpty) ||
                      (pilotRaw is Map && pilotRaw.isNotEmpty));

              final Map<String, dynamic>? pilotInfo = hasInfo
                  ? (pilotRaw is List
                        ? pilotRaw.first as Map<String, dynamic>
                        : pilotRaw as Map<String, dynamic>)
                  : null;

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.flight)),
                  title: Text(
                    '${profile['nom'] ?? 'Sans Nom'} ${profile['prenom'] ?? ''}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: hasInfo && pilotInfo != null
                      ? Text(
                          '${(pilotInfo['specialite'] is List ? (pilotInfo['specialite'] as List).join(', ') : 'Aucune spécialité')} • ${pilotInfo['prix_horaire'] ?? 0}€/h',
                          overflow: TextOverflow.ellipsis,
                        )
                      : const Text(
                          'ℹ️ Dossier technique incomplet',
                          style: TextStyle(
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          hasInfo ? Icons.edit : Icons.add_circle_outline,
                          color: Colors.blue,
                        ),
                        onPressed: () => _showPilotForm(pilotProfile: profile),
                        tooltip: hasInfo ? 'Modifier' : 'Compléter le dossier',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeletePilot(profile),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPilotForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter Pilote'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class AdminModerationTab extends StatelessWidget {
  const AdminModerationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File de Modération')),
      body: const Center(child: Text('Contenu signalé ou en attente')),
    );
  }
}

class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Système'),
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
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Paramètres de sécurité'),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Configuration notifications'),
          ),
          ListTile(
            leading: Icon(Icons.api),
            title: Text('Clés API & Webhooks'),
          ),
        ],
      ),
    );
  }
}
