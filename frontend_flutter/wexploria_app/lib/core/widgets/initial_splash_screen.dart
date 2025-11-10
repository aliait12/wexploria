import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/auth/auth_page.dart';
import 'welcome_screen.dart'; // N'oublie pas d'importer WelcomeScreen

class InitialSplashScreen extends StatefulWidget {
  const InitialSplashScreen({super.key});

  @override
  State<InitialSplashScreen> createState() => _InitialSplashScreenState();
}

class _InitialSplashScreenState extends State<InitialSplashScreen> {
  final String assetPath = 'assets/images/wexploria_logo.png';
  bool isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
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

      // 🕐 Attendre 5 secondes avant de naviguer
      await Future.delayed(const Duration(seconds: 5));

      if (!mounted) return;

      // 🚀 Navigation vers WelcomeScreen
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
                  : Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                    ),
        ),
      ),
    );
  }
}
