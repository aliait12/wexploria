import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../../main.dart';
import '../client/client_home.dart' as client_page;
import '../pilote/pilote_home.dart' as pilote_page;
import '../operateur/operateur_home.dart' as operateur_page;
import '../admin/admin_home.dart' as admin_page;

// class AuthPage extends StatefulWidget {
//   const AuthPage({super.key});

//   @override
//   State<AuthPage> createState() => _AuthPageState();
// }

// class _AuthPageState extends State<AuthPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _authService = AuthService();
//   bool _isLogin = true;
//   String _selectedRole = 'client';
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   final _roles = [
//     {'label': 'Client', 'value': 'client'},
//     {'label': 'Pilote', 'value': 'pilote'},
//     {'label': 'Opérateur', 'value': 'operateur'},
//     {'label': 'Administrateur', 'value': 'admin'},
//   ];
class AuthPage extends StatefulWidget {
  final bool initialIsLogin;

  const AuthPage({
    super.key,
    this.initialIsLogin = true,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  late bool _isLogin;
  String _selectedRole = 'client';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSocialLoading = false;

  final _roles = [
    {'label': 'Client', 'value': 'client'},
    {'label': 'Pilote', 'value': 'pilote'},
    {'label': 'Opérateur', 'value': 'operateur'},
    {'label': 'Administrateur', 'value': 'admin'},
  ];

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final message = await _authService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (message != null) {
      _showError(message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isLogin = true;
      });
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final message = await _authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (message != null) {
      _showError(message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion réussie'),
          backgroundColor: Colors.green,
        ),
      );

      String? role;
      for (var i = 0; i < 4; i++) {
        role = await _authService.getCurrentUserRole();
        if (role != null) break;
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!mounted) return;

      _navigateToRolePage(role);
    }
  }

  void _navigateToRolePage(String? role) {
    switch (role) {
      case 'client':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const client_page.ClientHomePage()));
        break;
      case 'pilote':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const pilote_page.PiloteHomePage()));
        break;
      case 'operateur':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const operateur_page.OperateurHomePage()));
        break;
      case 'admin':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const admin_page.AdminHomePage()));
        break;
      default:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleDecider()));
        if (role == null) {
          _showError('Profil non encore disponible. Réessayez dans quelques secondes.');
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
      body: Stack(
        children: [
          // Background with logo and opacity
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/wexploria_logo3.png'),
                fit: BoxFit.cover,
                opacity: 0.2, // 10% opacity
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo and Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/wexploria_logo2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const SizedBox(height: 8),
                        Text(
                          _isLogin ? 'Connectez-vous à votre compte' : 'Créez votre compte',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email/Username Field
                  Text(
                    'Email ou nom d\'utilisateur',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: InputBorder.none,
                        hintText: 'Entrez votre email',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mot de passe',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_isLogin)
                        GestureDetector(
                          onTap: () {
                            _showError('Fonctionnalité mot de passe oublié à implémenter');
                          },
                          child: Text(
                            'Mot de passe oublié?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: InputBorder.none,
                        hintText: 'Entrez votre mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Role Dropdown (only for signup)
                  if (!_isLogin) ...[
                    Text(
                      'Rôle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          border: InputBorder.none,
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
                    ),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 24),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: _isLogin ? _signIn : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              _isLogin ? 'Se connecter' : 'Créer un compte',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Divider with "or"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey.shade300),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.g_mobiledata, 'Google'),
                      const SizedBox(width: 16),
                      _buildSocialButton(Icons.apple, 'Apple'),
                      const SizedBox(width: 16),
                      _buildSocialButton(Icons.facebook, 'Facebook'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sign Up/Sign In Toggle
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Vous n'avez pas de compte?" : "Vous avez déjà un compte?",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? "S'inscrire" : "Se connecter",
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white.withOpacity(0.8),
        ),
        child: TextButton(
          onPressed: () {
            _showError('Connexion $label à implémenter');
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
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