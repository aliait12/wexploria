import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activite.dart';

class ActiviteService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
    try {
      // Start with a Filter Builder
      PostgrestFilterBuilder query = _supabase.from('activites').select();

      if (typeActivite != null) {
        query = query.eq('type_activite', typeActivite);
      }
      if (niveauDifficulte != null) {
        query = query.eq('niveau_difficulte', niveauDifficulte);
      }
      if (localisation != null) {
        query = query.ilike('localisation_precise', '%$localisation%');
      }
      if (operateurId != null) {
        query = query.eq('operateur_id', operateurId);
      }
      if (prixMin != null) {
        query = query.gte('prix_base', prixMin);
      }
      if (prixMax != null) {
        query = query.lte('prix_base', prixMax);
      }

      // Apply pagination (returns a TransformBuilder, so we await it directly or assign to new var)
      final List<dynamic> response = await query.range(
        offset,
        offset + limit - 1,
      );

      return response.map((json) => Activite.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des activités: $e');
    }
  }

  /// Récupère une activité par son ID
  Future<Activite> getActiviteById(String id) async {
    try {
      final response = await _supabase
          .from('activites')
          .select()
          .eq('id', id)
          .single();

      return Activite.fromJson(response);
    } catch (e) {
      throw Exception('Activité non trouvée: $e');
    }
  }

  // Placeholder for advanced features that might require Edge Functions or more complex logic
  // For now, we return default/mock data if not implemented in DB columns yet,
  // or we can implement these via Supabase RPC if we had them.

  /// Récupère la météo et le score Wexploria pour une activité (Mock/Placeholder or from DB if stored)
  Future<Map<String, dynamic>> getActiviteWeather(String id) async {
    // Dans une future version, on pourrait appeler une Edge Function
    return {'score_meteo': 8.5, 'conditions': 'Ensoleillé'};
  }

  /// Récupère le prix dynamique pour une activité
  Future<Map<String, dynamic>> getDynamicPrice(String id) async {
    // TODO: Implement Dynamic Pricing Logic via Edge Function
    return {'current_price': 450, 'factor': 1.0};
  }

  /// Obtient des recommandations personnalisées
  Future<List<Map<String, dynamic>>> getRecommendations({
    String? userId,
    double? latitude,
    double? longitude,
  }) async {
    // Pour l'instant on retourne les activités les mieux notées
    try {
      final response = await _supabase
          .from('activites')
          .select()
          .order('moyenne_avis', ascending: false)
          .limit(5);

      // Mapper vers le format attendu si nécessaire, ou retourner directement
      // Pour l'instant le code appelant s'attend sans doute à une liste brute
      // On va adapter pour renvoyer une Liste de Map
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Crée une nouvelle activité (opérateur uniquement)
  Future<Activite> createActivite(Map<String, dynamic> activiteData) async {
    try {
      final response = await _supabase
          .from('activites')
          .insert(activiteData)
          .select()
          .single();

      return Activite.fromJson(response);
    } catch (e) {
      throw Exception('Erreur création activité: $e');
    }
  }

  /// Met à jour une activité
  Future<Activite> updateActivite(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _supabase
          .from('activites')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Activite.fromJson(response);
    } catch (e) {
      throw Exception('Erreur update activité: $e');
    }
  }

  /// Supprime une activité
  Future<void> deleteActivite(String id) async {
    try {
      await _supabase.from('activites').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erreur delete activité: $e');
    }
  }
}
