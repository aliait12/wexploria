import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../auth/auth_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Administrateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bienvenue dans votre espace administrateur'),
      ),
    );
  }
}