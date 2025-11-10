import 'package:flutter/material.dart';
import '../../features/auth/auth_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image de fond avec logo
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/wexploria_logo3.png', // Remplacez par votre image de fond
                      width: 350,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    child: Image.asset(
                      'assets/images/wexploria_logo2.png',
                      width: 120,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Explore your world, ride your story\nWhere discovery meets emotion',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                    );
                  },
                  child: const Text('login'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Naviguer vers la page d'inscription
                  },
                  child: const Text('Sign up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}