class Reservation {
  final String id;
  final DateTime dateReservation;
  final DateTime dateActivite;
  final int dureeReservation;
  final int nombreParticipants;
  final String statut;
  final String? motifAnnulation;
  final String? conditionsMeteoActuelles;
  final double? niveauVent;
  final String? visibilite;
  final double prixTotal;
  final bool acompteVerse;
  final List<String> optionsSupplementaires;
  final String? notesParticulieres;
  final String? codeConfirmation;
  final String clientId;
  final String activiteId;
  final String piloteId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reservation({
    required this.id,
    required this.dateReservation,
    required this.dateActivite,
    required this.dureeReservation,
    required this.nombreParticipants,
    this.statut = 'en_attente',
    this.motifAnnulation,
    this.conditionsMeteoActuelles,
    this.niveauVent,
    this.visibilite,
    required this.prixTotal,
    this.acompteVerse = false,
    this.optionsSupplementaires = const [],
    this.notesParticulieres,
    this.codeConfirmation,
    required this.clientId,
    required this.activiteId,
    required this.piloteId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      dateReservation: DateTime.parse(json['date_reservation'] as String),
      dateActivite: DateTime.parse(json['date_activite'] as String),
      dureeReservation: json['duree_reservation'] as int,
      nombreParticipants: json['nombre_participants'] as int,
      statut: json['statut'] as String? ?? 'en_attente',
      motifAnnulation: json['motif_annulation'] as String?,
      conditionsMeteoActuelles: json['conditions_meteo_actuelles'] as String?,
      niveauVent: (json['niveau_vent'] as num?)?.toDouble(),
      visibilite: json['visibilite'] as String?,
      prixTotal: (json['prix_total'] as num).toDouble(),
      acompteVerse: json['acompte_verse'] as bool? ?? false,
      optionsSupplementaires: (json['options_supplementaires'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notesParticulieres: json['notes_particulieres'] as String?,
      codeConfirmation: json['code_confirmation'] as String?,
      clientId: json['client_id'] as String,
      activiteId: json['activite_id'] as String,
      piloteId: json['pilote_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_reservation': dateReservation.toIso8601String(),
      'date_activite': dateActivite.toIso8601String(),
      'duree_reservation': dureeReservation,
      'nombre_participants': nombreParticipants,
      'statut': statut,
      'motif_annulation': motifAnnulation,
      'conditions_meteo_actuelles': conditionsMeteoActuelles,
      'niveau_vent': niveauVent,
      'visibilite': visibilite,
      'prix_total': prixTotal,
      'acompte_verse': acompteVerse,
      'options_supplementaires': optionsSupplementaires,
      'notes_particulieres': notesParticulieres,
      'code_confirmation': codeConfirmation,
      'client_id': clientId,
      'activite_id': activiteId,
      'pilote_id': piloteId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  String get statutLabel {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'confirmee':
        return 'Confirmée';
      case 'annulee':
        return 'Annulée';
      case 'terminee':
        return 'Terminée';
      default:
        return statut;
    }
  }
}
