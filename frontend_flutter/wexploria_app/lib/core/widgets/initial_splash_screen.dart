import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/auth/auth_page.dart';
import 'welcome_screen.dart';

class InitialSplashScreen extends StatefulWidget {
  const InitialSplashScreen({super.key});

  @override
  State<InitialSplashScreen> createState() => _InitialSplashScreenState();
}

class _InitialSplashScreenState extends State<InitialSplashScreen> with SingleTickerProviderStateMixin {
  final String assetPath = 'assets/images/wexploria_logo.png';
  bool isLoading = true;
  String? _loadError;
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialisation de l'animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5), // Monte vers le haut
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0, // Disparaît progressivement
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0), // Commence à disparaître à mi-chemin
    ));

    _initSplash();
  }

  Future<void> _initSplash() async {
    try {
      await rootBundle.load(assetPath);
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _loadError = null;
      });

      // 🕐 Attendre 2 secondes avant de lancer l'animation
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 🎬 Lancer l'animation
      _controller.forward();

      // 🚀 Navigation vers WelcomeScreen après l'animation
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: isLoading
              ? const CircularProgressIndicator()
              : _loadError != null
                  ? const Icon(Icons.error_outline, color: Colors.red, size: 48)
                  : AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _positionAnimation.value * 100, // Multiplier pour plus de mouvement
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: Image.asset(
                              assetPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}