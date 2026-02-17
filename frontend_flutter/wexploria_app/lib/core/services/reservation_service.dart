import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation.dart';

class ReservationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Créer une nouvelle réservation
  Future<Reservation> createReservation(Reservation reservation) async {
    try {
      final response = await _supabase
          .from('reservations')
          .insert(reservation.toJson())
          .select()
          .single();

      return Reservation.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  /// Récupérer les réservations d'un client
  Future<List<Reservation>> getReservationsByClient(String clientId) async {
    try {
      final response = await _supabase
          .from('reservations')
          .select()
          .eq('client_id', clientId)
          .order('date_reservation', ascending: false);

      return (response as List)
          .map((json) => Reservation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur récupération réservations: $e');
    }
  }

  /// Récupérer les détails d'une réservation
  Future<Reservation> getReservationById(String id) async {
    try {
      final response = await _supabase
          .from('reservations')
          .select()
          .eq('id', id)
          .single();

      return Reservation.fromJson(response);
    } catch (e) {
      throw Exception('Réservation non trouvée: $e');
    }
  }

  /// Mettre à jour le statut d'une réservation
  Future<void> updateReservationStatus(String id, String statut) async {
    try {
      await _supabase
          .from('reservations')
          .update({'statut': statut})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erreur mise à jour statut: $e');
    }
  }

  /// Confirme une réservation (pour l'opérateur)
  Future<void> confirmReservation(String id) async {
    await updateReservationStatus(id, 'confirmee');
  }

  /// Annule une réservation
  Future<void> cancelReservation(String id, {String? motif}) async {
    try {
      await _supabase
          .from('reservations')
          .update({'statut': 'annulee', 'motif_annulation': motif})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erreur annulation: $e');
    }
  }

  /// Récupère les réservations d'un opérateur via ses activités
  Future<List<Reservation>> getOperateurReservations(String operateurId) async {
    try {
      // Join with activites to filter by operateur_id
      final response = await _supabase
          .from('reservations')
          .select('*, activites!inner(id, operateur_id)')
          .eq('activites.operateur_id', operateurId)
          .order('date_reservation', ascending: false);

      return (response as List)
          .map((json) => Reservation.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback: fetch directly if operator is pilot
      try {
        final response = await _supabase
            .from('reservations')
            .select()
            .eq('pilote_id', operateurId);
        return (response as List)
            .map((json) => Reservation.fromJson(json))
            .toList();
      } catch (_) {
        throw Exception('Erreur récupération réservations opérateur: $e');
      }
    }
  }

  /// Récupère les réservations à venir d'un client
  Future<List<Reservation>> getClientUpcomingReservations(
    String clientId,
  ) async {
    try {
      final response = await _supabase
          .from('reservations')
          .select()
          .eq('client_id', clientId)
          .gte('date_activite', DateTime.now().toIso8601String())
          .order('date_activite', ascending: true);

      return (response as List)
          .map((json) => Reservation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur réservations à venir: $e');
    }
  }
}
