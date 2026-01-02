import 'package:flutter/material.dart';
import 'package:wexploria_app/core/constants/app_constants.dart';
import 'package:wexploria_app/features/auth/auth_service.dart';
import 'package:wexploria_app/features/auth/auth_page.dart';

class PiloteHomePage extends StatefulWidget {
  const PiloteHomePage({super.key});

  @override
  State<PiloteHomePage> createState() => _PiloteHomePageState();
}

class _PiloteHomePageState extends State<PiloteHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PilotePlanningTab(),
    const PiloteAvailabilityTab(),
    const PiloteEarningsTab(),
    const PiloteProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
          selectedItemColor: AppColors.secondary, // Emerald for Pilot/Eco vibe
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Planning',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available_outlined),
              activeIcon: Icon(Icons.event_available),
              label: 'Dispo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              activeIcon: Icon(Icons.payments),
              label: 'Revenus',
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

// --- Tabs ---

class PilotePlanningTab extends StatelessWidget {
  const PilotePlanningTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Planning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.air, color: AppColors.secondary),
              ),
              title: Text('Vol Duo Parapente #${800 + index}'),
              subtitle: Text('Demain - 10:30 • 2 participants'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class PiloteAvailabilityTab extends StatelessWidget {
  const PiloteAvailabilityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Disponibilités'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 64, color: AppColors.textLight),
            const SizedBox(height: AppSpacing.md),
            const Text('Gérez vos créneaux ici'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Ajouter une disponibilité'),
            ),
          ],
        ),
      ),
    );
  }
}

class PiloteEarningsTab extends StatelessWidget {
  const PiloteEarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Revenus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Column(
                children: [
                  Text(
                    'Solde disponible',
                    style: TextStyle(color: AppColors.textWhite, fontSize: AppFontSizes.md),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '1,245.50 €',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: AppFontSizes.huge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Derniers paiements',
                style: TextStyle(fontSize: AppFontSizes.lg, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.arrow_downward, color: AppColors.secondary),
                    title: Text('Virement Stripe #${5432 - index}'),
                    subtitle: const Text('24 Déc 2025'),
                    trailing: const Text(
                      '+ 350.00 €',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PiloteProfileTab extends StatelessWidget {
  const PiloteProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pilote'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, size: 60, color: AppColors.textWhite),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(
            child: Text(
              'Marc L. (Pilote Certifié)',
              style: TextStyle(fontSize: AppFontSizes.xl, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Mes Certifications'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Paramètres'),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnexion', style: TextStyle(color: AppColors.textWhite)),
          ),
        ],
      ),
    );
  }
}
