import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/reservation.dart';

class ReservationService {
  final String baseUrl =
      ApiConstants.baseUrl + ApiConstants.reservationsEndpoint;

  /// Récupère la liste des réservations avec filtres
  Future<List<Reservation>> getReservations({
    String? clientId,
    String? piloteId,
    String? activiteId,
    String? statut,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (clientId != null) queryParams['client_id'] = clientId;
    if (piloteId != null) queryParams['pilote_id'] = piloteId;
    if (activiteId != null) queryParams['activite_id'] = activiteId;
    if (statut != null) queryParams['statut'] = statut;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des réservations');
    }
  }

  /// Récupère une réservation par son ID
  Future<Reservation> getReservationById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Reservation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Réservation non trouvée');
    }
  }

  /// Crée une nouvelle réservation
  Future<Reservation> createReservation(
    Map<String, dynamic> reservationData,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservationData),
    );

    if (response.statusCode == 201) {
      return Reservation.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(
        error['detail'] ?? 'Erreur lors de la création de la réservation',
      );
    }
  }

  /// Met à jour une réservation
  Future<Reservation> updateReservation(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      return Reservation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de la réservation');
    }
  }

  /// Annule une réservation
  Future<Map<String, dynamic>> cancelReservation(
    String id, {
    String? motif,
  }) async {
    final queryParams = motif != null ? {'motif': motif} : <String, String>{};
    final uri = Uri.parse(
      '$baseUrl/$id/cancel',
    ).replace(queryParameters: queryParams);

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de l\'annulation de la réservation');
    }
  }

  /// Confirme une réservation
  Future<Map<String, dynamic>> confirmReservation(String id) async {
    final response = await http.post(Uri.parse('$baseUrl/$id/confirm'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la confirmation de la réservation');
    }
  }

  /// Récupère les réservations à venir d'un client
  Future<List<Reservation>> getClientUpcomingReservations(
    String clientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/client/$clientId/upcoming'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> reservations = data['reservations'];
      return reservations.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur lors de la récupération des réservations à venir',
      );
    }
  }

  /// Récupère les réservations d'un opérateur
  Future<List<Reservation>> getOperateurReservations(String operateurId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/operateur/$operateurId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur lors de la récupération des réservations de l\'opérateur',
      );
    }
  }

  /// Récupère le calendrier d'un pilote
  Future<List<Reservation>> getPiloteCalendar(
    String piloteId, {
    int? month,
    int? year,
  }) async {
    final queryParams = <String, String>{};
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();

    final uri = Uri.parse(
      '$baseUrl/pilote/$piloteId/calendar',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> reservations = data['reservations'];
      return reservations.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération du calendrier');
    }
  }
}
