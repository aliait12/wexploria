import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<String?> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      // 1. Vérifier si l'email existe déjà
      final existingProfiles = await _supabase
          .from('profiles')
          .select('email')
          .eq('email', email)
          .limit(1);

      if (existingProfiles != null &&
          existingProfiles is List &&
          existingProfiles.isNotEmpty) {
        return 'Un compte existe déjà avec cet email';
      }

      // 2. Créer le compte auth avec le rôle 'client' par défaut
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': 'client',
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone_number': phone,
        },
      );

      if (authResponse.user == null) {
        return 'Erreur lors de la création du compte';
      }

      return null;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Violation de contrainte unique
        return 'Un compte existe déjà avec cet email';
      }
      return 'Erreur base de données: ${e.message}';
    } on AuthException catch (e) {
      return 'Erreur authentification: ${e.message}';
    } catch (e) {
      debugPrint('Exception during signUp: $e');
      return 'Une erreur est survenue: $e';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return 'Identifiants invalides';
      }

      debugPrint('Connexion réussie ! User ID: ${response.user!.id}');
      return null; // Succès
    } catch (e) {
      debugPrint('Exception pendant la connexion: $e');
      if (e is AuthException) {
        return 'Erreur de connexion: ${e.message}';
      }
      return 'Une erreur est survenue: $e';
    }
  }

  Future<String?> getUserRole(String userId) async {
    // Try to read the role from the profiles table first.
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('user_id', userId)
          .limit(1);

      if (response is List && response.isNotEmpty) {
        return response[0]['role'] as String?;
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du rôle depuis profiles: $e');
    }

    // Fallback: if the profiles row isn't available yet (race), read the
    // role stored in the authenticated user's metadata (set at signUp).
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final meta = user.userMetadata;
        if (meta != null && meta['role'] != null) {
          return meta['role'] as String?;
        }

        final appMeta = user.appMetadata;
        if (appMeta['role'] != null) {
          return appMeta['role'] as String?;
        }
      }
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération du rôle depuis user metadata: $e',
      );
    }

    return null;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Récupérer l'utilisateur actuellement connecté
  User? get currentUser => _supabase.auth.currentUser;

  // Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => currentUser != null;

  // Récupérer le rôle de l'utilisateur actuel
  Future<String?> getCurrentUserRole() async {
    if (!isAuthenticated) return null;
    return getUserRole(currentUser!.id);
  }

  // Vérifier si un utilisateur non connecté a déjà un compte
  Future<bool> hasExistingAccount(String email) async {
    try {
      final existingProfiles = await _supabase
          .from('profiles')
          .select('email')
          .eq('email', email)
          .limit(1);

      return existingProfiles != null &&
          existingProfiles is List &&
          existingProfiles.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du compte: $e');
      return false;
    }
  }

  Future<String?> requestOperatorRole({
    required String userId,
    required String nomEntreprise,
    required String siret,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/request-operator'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'nom_entreprise': nomEntreprise,
          'siret': siret,
        }),
      );

      if (response.statusCode == 200) {
        return null; // Succès
      } else {
        return 'Erreur: ${response.body}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}
