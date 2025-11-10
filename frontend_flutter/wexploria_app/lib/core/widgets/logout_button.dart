import 'package:flutter/material.dart';
import '../../features/auth/auth_service.dart';
import '../../features/auth/auth_page.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        // Afficher une boîte de dialogue de confirmation
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Déconnecter'),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          // Déconnecter l'utilisateur
          await AuthService().signOut();
          // Rediriger vers la page de connexion
          if (context.mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
          }
        }
      },
    );
  }
}