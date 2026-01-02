import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/initial_splash_screen.dart';
import 'features/auth/auth_page.dart';
import 'features/client/client_home.dart' as client_page;
import 'features/pilote/pilote_home.dart' as pilote_page;
import 'features/operateur/operateur_home.dart' as operateur_page;
import 'features/admin/admin_home.dart' as admin_page;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dkfldqtsfhleuiqfuifq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrZmxkcXRzZmhsZXVpcWZ1aWZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMDIyMDYsImV4cCI6MjA3NzU3ODIwNn0.2QZe2RzsCTal1Y2BIFN1QAxj3LNMiLV9va1XMxAXX00',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wexploria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const InitialSplashScreen(),
    );
  }
}

/// Widget qui vérifie l'utilisateur courant et redirige selon le rôle
class RoleDecider extends StatefulWidget {
  const RoleDecider({super.key});

  @override
  State<RoleDecider> createState() => _RoleDeciderState();
}

class _RoleDeciderState extends State<RoleDecider> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  Future<void> _checkAndNavigate() async {
    final supabase = Supabase.instance.client;

    final user = supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
      return;
    }

    // Récupère le rôle depuis la table profiles
    try {
      final res = await supabase
          .from('profiles')
          .select('role, type_utilisateur')
          .eq('user_id', user.id)
          .limit(1);

      String? role;
      if (res is List && res.isNotEmpty) {
        final row = res[0];
        if (row is Map && row.containsKey('type_utilisateur')) {
          role = row['type_utilisateur'] as String?;
        } else if (row is Map && row.containsKey('role')) {
          role = row['role'] as String?;
        }
      }

      if (!mounted) return;

      if (role == 'client') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const client_page.ClientHomePage()),
        );
      } else if (role == 'pilote') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const pilote_page.PiloteHomePage()),
        );
      } else if (role == 'operateur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const operateur_page.OperateurHomePage()),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const admin_page.AdminHomePage()),
        );
      } else {
        // rôle inconnu -> renvoyer à l'authent
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du rôle: $e');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
