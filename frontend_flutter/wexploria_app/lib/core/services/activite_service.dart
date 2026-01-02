import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/activite.dart';

class ActiviteService {
  final String baseUrl = ApiConstants.baseUrl + ApiConstants.activitesEndpoint;

  /// Récupère la liste des activités avec filtres
  Future<List<Activite>> getActivites({
    String? typeActivite,
    String? niveauDifficulte,
    double? prixMin,
    double? prixMax,
    String? localisation,
    String? operateurId,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (typeActivite != null) queryParams['type_activite'] = typeActivite;
    if (niveauDifficulte != null)
      queryParams['niveau_difficulte'] = niveauDifficulte;
    if (prixMin != null) queryParams['prix_min'] = prixMin.toString();
    if (prixMax != null) queryParams['prix_max'] = prixMax.toString();
    if (localisation != null) queryParams['localisation'] = localisation;
    if (operateurId != null) queryParams['operateur_id'] = operateurId;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Activite.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des activités');
    }
  }

  /// Récupère une activité par son ID
  Future<Activite> getActiviteById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Activite.fromJson(json.decode(response.body));
    } else {
      throw Exception('Activité non trouvée');
    }
  }

  /// Récupère la météo et le score Wexploria pour une activité
  Future<Map<String, dynamic>> getActiviteWeather(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id/weather'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération de la météo');
    }
  }

  /// Récupère le prix dynamique pour une activité
  Future<Map<String, dynamic>> getDynamicPrice(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id/dynamic-price'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du calcul du prix dynamique');
    }
  }

  /// Obtient des recommandations personnalisées
  Future<List<Map<String, dynamic>>> getRecommendations({
    String? userId,
    double? latitude,
    double? longitude,
  }) async {
    final queryParams = <String, String>{};

    if (userId != null) queryParams['user_id'] = userId;
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();

    final uri = Uri.parse(
      '$baseUrl/search/recommendations',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['recommendations']);
    } else {
      throw Exception('Erreur lors de la récupération des recommandations');
    }
  }

  /// Crée une nouvelle activité (opérateur uniquement)
  Future<Activite> createActivite(Map<String, dynamic> activiteData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(activiteData),
    );

    if (response.statusCode == 201) {
      return Activite.fromJson(json.decode(response.body));
    } else {
      print(
        'Erreur création activité: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }

  /// Met à jour une activité
  Future<Activite> updateActivite(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      return Activite.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de l\'activité');
    }
  }

  /// Supprime une activité
  Future<void> deleteActivite(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de l\'activité');
    }
  }
}
