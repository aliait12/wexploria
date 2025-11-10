import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../../main.dart';
import '../client/client_home.dart' as client_page;
import '../pilote/pilote_home.dart' as pilote_page;
import '../operateur/operateur_home.dart' as operateur_page;
import '../admin/admin_home.dart' as admin_page;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLogin = true;
  String _selectedRole = 'client'; // Par défaut

  final _roles = [
    {'label': 'Client', 'value': 'client'},
    {'label': 'Pilote', 'value': 'pilote'},
    {'label': 'Opérateur', 'value': 'operateur'},
    {'label': 'Administrateur', 'value': 'admin'},
  ];

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    final message = await _authService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (message != null) {
      _showError(message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès!')),
      );
      setState(() {
        _isLogin = true; // Basculer vers l'écran de connexion
      });
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    final message = await _authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (message != null) {
      _showError(message);
    } else {
      // Connexion réussie -> essayer de récupérer le rôle (avec quelques
      // tentatives si la row profiles n'est pas encore visible) puis
      // rediriger vers la page correspondante.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie')),
      );

      String? role;
      // retry to read role for short time (race condition protection)
      for (var i = 0; i < 4; i++) {
        role = await _authService.getCurrentUserRole();
        if (role != null) break;
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!mounted) return;

      if (role == 'client') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const client_page.ClientHomePage()));
      } else if (role == 'pilote') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const pilote_page.PiloteHomePage()));
      } else if (role == 'operateur') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const operateur_page.OperateurHomePage()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const admin_page.AdminHomePage()));
      } else {
        // fallback: go to RoleDecider which will try alternative logic
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleDecider()));
        if (role == null) {
          _showError('Profil non encore disponible. Réessayez dans quelques secondes.');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Wexploria',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (!_isLogin) ...[
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role['value'],
                      child: Text(role['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _isLogin ? _signIn : _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(_isLogin ? 'Se connecter' : "S'inscrire"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? "Pas encore de compte ? S'inscrire"
                    : 'Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}