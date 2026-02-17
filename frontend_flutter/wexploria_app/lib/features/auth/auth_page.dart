import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../../main.dart';
import '../client/client_home.dart' as client_page;
import '../pilote/pilote_home.dart' as pilote_page;
import '../operateur/operateur_home.dart' as operateur_page;
import '../admin/admin_home.dart' as admin_page;

class AuthPage extends StatefulWidget {
  final bool initialIsLogin;

  const AuthPage({super.key, this.initialIsLogin = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  late bool _isLogin;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false; // Checkbox state

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _fullNameController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    // Validation Checkbox
    if (!_agreedToTerms) {
      _showError('Veuillez accepter les termes et conditions');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final message = await _authService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const client_page.ClientHomePage()),
        );
        break;
      case 'pilote':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const pilote_page.PiloteHomePage()),
        );
        break;
      case 'operateur':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const operateur_page.OperateurHomePage(),
          ),
        );
        break;
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const admin_page.AdminHomePage()),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleDecider()),
        );
        if (role == null) {
          _showError(
            'Profil non encore disponible. Réessayez dans quelques secondes.',
          );
        }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- Widgets UI Components ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isVisible,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: prefixIcon != null 
                  ? Icon(prefixIcon, color: Colors.grey.shade400, size: 20) 
                  : null,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: InkWell(
          onTap: () {
             _showError('Connexion $label à implémenter');
          },
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(icon, size: 20, color: Colors.black87),
               const SizedBox(width: 8),
               Text(
                 label, 
                 style: const TextStyle(
                   fontSize: 14, 
                   fontWeight: FontWeight.w500,
                   color: Colors.black87
                 )
               ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Image with Convex Curved Bottom
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: ClipPath(
              clipper: ConvexBottomClipper(),
              child: Image.asset(
                'assets/images/marhba.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. Scrollable Content - Logo MOVED HERE inside ScrollView
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO is now part of the scrolling content so it moves up when keyboard opens
                    Image.asset(
                       'assets/images/wexploria_logo2.png',
                       height: 80,
                       fit: BoxFit.contain,
                       color: Colors.white,
                    ),
                    const SizedBox(height: 24),

                    // Centered Card
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95), // White with slight transparency
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Text(
                            'Marhba!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D5D), // Match Green from design
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Updated Subtitle as requested
                          Text(
                            'join the outdoor community of Wexploria',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Sign Up Fields
                          if (!_isLogin) ...[
                            _buildTextField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              hint: 'Youssef Alami',
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                hint: '+212 6...',
                                prefixIcon: Icons.phone_android_outlined,
                            ),
                             const SizedBox(height: 16),
                          ],

                          // Common Fields
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'hello@wexploria.ma',
                            prefixIcon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '........',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            isVisible: !_obscurePassword,
                            onVisibilityToggle: () {
                              setState(() {
                                 _obscurePassword = !_obscurePassword;
                              });
                            }
                          ),

                          if (!_isLogin) ...[
                             const SizedBox(height: 16),
                             _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: '........',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              isVisible: !_obscureConfirmPassword,
                              onVisibilityToggle: () {
                                setState(() {
                                   _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              }
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Terms with Functional Checkbox
                          if (!_isLogin)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24, 
                                  child: Checkbox(
                                    value: _agreedToTerms,
                                    activeColor: const Color(0xFF2E7D5D), // Green
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _agreedToTerms = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      children: [
                                        TextSpan(
                                          text: 'Terms',
                                          style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 24),

                          // Main Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _isLogin ? _signIn : _signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00A9D4), // Cyan/Blue from design
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Start Your Adventure',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          ),

                          const SizedBox(height: 24),

                          // Socials Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade400,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                            ],
                          ),
                          
                          const SizedBox(height: 24),

                          // Social Buttons
                          Row(
                            children: [
                              _buildSocialButton('Google', Icons.g_mobiledata), // Using material icon as placeholder
                              const SizedBox(width: 16),
                              _buildSocialButton('Apple', Icons.apple),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Toggle Login/Signup
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLogin ? "Don't have an account? " : "Already have an account? ",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(
                                  _isLogin ? "Sign Up" : "Log in",
                                  style: TextStyle(
                                    color: const Color(0xFF2E7D5D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for the convex bottom edge
class ConvexBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    
    // Create a quadratic bezier curve
    var controlPoint = Offset(size.width / 2, size.height + 50);
    var endPoint = Offset(size.width, size.height - 50);
    
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
        
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
