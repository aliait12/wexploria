import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class AdminService {
  final String baseUrl = ApiConstants.baseUrl + '/admin';

  /// Crée un compte pilote complet (Auth + Profil + Pilote)
  Future<Map<String, dynamic>> createPilotAccount({
    required String email,
    required String password,
    required String nom,
    String? prenom,
    required Map<String, dynamic> pilotInfo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pilot-account'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
        'pilot_info': pilotInfo,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la création du pilote: ${response.body}');
    }
  }

  /// Récupère la liste des demandes d'opérateurs en attente
  Future<List<dynamic>> getPendingOperators() async {
    final response = await http.get(Uri.parse('$baseUrl/pending-operators'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des demandes');
    }
  }

  /// Approuve un opérateur
  Future<void> approveOperator(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/approve-operator/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'approbation: ${response.body}');
    }
  }

  /// Liste tous les pilotes
  Future<List<dynamic>> listPilots() async {
    final response = await http.get(Uri.parse('$baseUrl/pilots'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Erreur lors de la récupération des pilotes: ${response.body}',
      );
    }
  }

  /// Met à jour un compte pilote
  Future<void> updatePilotAccount({
    required String userId,
    required String email,
    required String nom,
    String? prenom,
    required Map<String, dynamic> pilotInfo,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pilot-account/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password':
            'nopassword', // Non utilisé pour l'update mais requis par le schema PilotAccountCreate si on l'utilise tel quel (à optimiser potentiellement)
        'nom': nom,
        'prenom': prenom,
        'pilot_info': pilotInfo,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour: ${response.body}');
    }
  }

  /// Supprime un pilote (retrait du rôle)
  Future<void> deletePilotAccount(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pilot-account/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.body}');
    }
  }
}
