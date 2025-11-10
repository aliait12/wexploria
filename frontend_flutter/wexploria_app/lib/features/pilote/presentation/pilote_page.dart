import 'package:flutter/material.dart';
import '../../../core/widgets/logout_button.dart';
import '../../auth/auth_service.dart';
import '../../auth/auth_page.dart';

class PilotePage extends StatefulWidget {
  const PilotePage({super.key});

  @override
  State<PilotePage> createState() => _PilotePageState();
}

class _PilotePageState extends State<PilotePage> {
  final _authService = AuthService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _verifyAccess();
  }

  Future<void> _verifyAccess() async {
    try {
      setState(() => _isLoading = true);

      // 1. Vérifier si l'utilisateur est connecté
      if (!_authService.isAuthenticated) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
        }
        return;
      }

      // 2. Vérifier le rôle
      final role = await _authService.getCurrentUserRole();
      if (role != 'pilote') {
        setState(() => _error = 'Accès non autorisé');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
        }
        return;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _error = 'Une erreur est survenue');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Pilote'),
        actions: const [
          LogoutButton(), // Notre bouton de déconnexion
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenue ${_authService.currentUser?.email ?? ""}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}