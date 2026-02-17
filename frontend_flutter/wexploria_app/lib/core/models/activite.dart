class Activite {
  final String id;
  final String titre;
  final String? description;
  final String typeActivite;
  final String niveauDifficulte;
  final int dureeEstimee;
  final double prixBase;
  final double? prixEnfant;
  final double? prixGroupe;
  final int capaciteMax;
  final bool equipementInclus;
  final List<String> equipementRequis;
  final String? conditionsMeteoMinimales;
  final String localisationPrecise;
  final double? latitude;
  final double? longitude;
  final int? altitudeDepart;
  final int? altitudeArrivee;
  final double? distanceParcours;
  final List<String> saisonnalite;
  final int ageMinimum;
  final int poidsMinimum;
  final int poidsMaximum;
  final List<String> restrictionsMedicales;
  final String? imageUrl;
  final String operateurId;
  final double scoreMeteo;
  final double moyenneAvis;
  final double scoreSecurite;
  final double tauxRemplissage;
  final String statut;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Activite({
    required this.id,
    required this.titre,
    this.description,
    required this.typeActivite,
    this.niveauDifficulte = 'debutant',
    required this.dureeEstimee,
    required this.prixBase,
    this.prixEnfant,
    this.prixGroupe,
    required this.capaciteMax,
    this.equipementInclus = true,
    this.equipementRequis = const [],
    this.conditionsMeteoMinimales,
    required this.localisationPrecise,
    this.latitude,
    this.longitude,
    this.altitudeDepart,
    this.altitudeArrivee,
    this.distanceParcours,
    this.saisonnalite = const [],
    this.ageMinimum = 12,
    this.poidsMinimum = 40,
    this.poidsMaximum = 120,
    this.restrictionsMedicales = const [],
    this.imageUrl,
    required this.operateurId,
    this.scoreMeteo = 0,
    this.moyenneAvis = 0,
    this.scoreSecurite = 0,
    this.tauxRemplissage = 0,
    this.statut = 'actif',
    required this.createdAt,
    this.updatedAt,
  });

  factory Activite.fromJson(Map<String, dynamic> json) {
    return Activite(
      id: json['id'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String?,
      typeActivite: json['type_activite'] as String,
      niveauDifficulte: json['niveau_difficulte'] as String? ?? 'debutant',
      dureeEstimee: json['duree_estimee'] as int,
      prixBase: (json['prix_base'] as num).toDouble(),
      prixEnfant: (json['prix_enfant'] as num?)?.toDouble(),
      prixGroupe: (json['prix_groupe'] as num?)?.toDouble(),
      capaciteMax: json['capacite_max'] as int,
      equipementInclus: json['equipement_inclus'] as bool? ?? true,
      equipementRequis:
          (json['equipement_requis'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      conditionsMeteoMinimales: json['conditions_meteo_minimales'] as String?,
      localisationPrecise: json['localisation_precise'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitudeDepart: json['altitude_depart'] as int?,
      altitudeArrivee: json['altitude_arrivee'] as int?,
      distanceParcours: (json['distance_parcours'] as num?)?.toDouble(),
      saisonnalite:
          (json['saisonnalite'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ageMinimum: json['age_minimum'] as int? ?? 12,
      poidsMinimum: json['poids_minimum'] as int? ?? 40,
      poidsMaximum: json['poids_maximum'] as int? ?? 120,
      restrictionsMedicales:
          (json['restrictions_medicales'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['image_url'] as String?,
      operateurId: json['operateur_id'] as String,
      scoreMeteo: (json['score_meteo'] as num?)?.toDouble() ?? 0,
      moyenneAvis: (json['moyenne_avis'] as num?)?.toDouble() ?? 0,
      scoreSecurite: (json['score_securite'] as num?)?.toDouble() ?? 0,
      tauxRemplissage: (json['taux_remplissage'] as num?)?.toDouble() ?? 0,
      statut: json['statut'] as String? ?? 'actif',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'type_activite': typeActivite,
      'niveau_difficulte': niveauDifficulte,
      'duree_estimee': dureeEstimee,
      'prix_base': prixBase,
      'prix_enfant': prixEnfant,
      'prix_groupe': prixGroupe,
      'capacite_max': capaciteMax,
      'equipement_inclus': equipementInclus,
      'equipement_requis': equipementRequis,
      'conditions_meteo_minimales': conditionsMeteoMinimales,
      'localisation_precise': localisationPrecise,
      'latitude': latitude,
      'longitude': longitude,
      'altitude_depart': altitudeDepart,
      'altitude_arrivee': altitudeArrivee,
      'distance_parcours': distanceParcours,
      'saisonnalite': saisonnalite,
      'age_minimum': ageMinimum,
      'poids_minimum': poidsMinimum,
      'poids_maximum': poidsMaximum,
      'restrictions_medicales': restrictionsMedicales,
      'image_url': imageUrl,
      'operateur_id': operateurId,
      'score_meteo': scoreMeteo,
      'moyenne_avis': moyenneAvis,
      'score_securite': scoreSecurite,
      'taux_remplissage': tauxRemplissage,
      'statut': statut,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
