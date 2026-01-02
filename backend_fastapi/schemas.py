from pydantic import BaseModel, EmailStr, UUID4, Field
from typing import Optional, List
from datetime import datetime, date


# ============= PROFILES =============
class ProfileBase(BaseModel):
    nom: str
    prenom: Optional[str] = None
    email: EmailStr
    telephone: Optional[str] = None
    type_utilisateur: str = "client"
    date_naissance: Optional[date] = None
    adresse: Optional[str] = None
    ville: Optional[str] = None
    pays: str = "France"


class ProfileCreate(ProfileBase):
    user_id: UUID4
    role: str = "client"


class ProfileUpdate(BaseModel):
    nom: Optional[str] = None
    prenom: Optional[str] = None
    telephone: Optional[str] = None
    date_naissance: Optional[date] = None
    adresse: Optional[str] = None
    ville: Optional[str] = None
    pays: Optional[str] = None


class ProfileResponse(ProfileBase):
    id: int
    user_id: UUID4
    role: str
    statut: str
    date_inscription: datetime
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ============= CLIENTS =============
class ClientBase(BaseModel):
    preferences: List[str] = []
    niveau_experience: str = "debutant"


class ClientCreate(ClientBase):
    user_id: UUID4


class ClientResponse(ClientBase):
    id: UUID4
    user_id: UUID4
    score_fidelite: int
    created_at: datetime

    class Config:
        from_attributes = True


# ============= PILOTES =============
class PiloteBase(BaseModel):
    specialite: List[str] = []
    niveau_certification: str = "initie"
    diplomes: List[str] = []
    numero_licence: Optional[str] = None
    prix_horaire: float
    zone_intervention: List[str] = []
    langues_parlees: List[str] = ["fr"]
    capacite_passagers: int = 1


class PiloteCreate(PiloteBase):
    user_id: UUID4
    operateur_id: Optional[UUID4] = None


class PiloteUpdate(BaseModel):
    specialite: Optional[List[str]] = None
    prix_horaire: Optional[float] = None
    zone_intervention: Optional[List[str]] = None
    langues_parlees: Optional[List[str]] = None


class PiloteResponse(PiloteBase):
    id: UUID4
    user_id: UUID4
    nombre_heures_vol: int
    assurance_valide: bool
    taux_satisfaction: float
    operateur_id: Optional[UUID4] = None
    revenus: float
    created_at: datetime

    class Config:
        from_attributes = True


class PilotAccountCreate(BaseModel):
    email: EmailStr
    password: str
    nom: str
    prenom: Optional[str] = None
    pilot_info: PiloteBase

class PilotAccountResponse(BaseModel):
    user_id: str
    profile_id: int
    pilot_id: str
    email: str

# ============= OPERATEURS =============
class OperateurBase(BaseModel):
    nom_entreprise: str
    siret: str
    site_web: Optional[str] = None
    date_creation: date


class OperateurCreate(OperateurBase):
    user_id: UUID4


class OperateurResponse(OperateurBase):
    id: UUID4
    user_id: UUID4
    nombre_activites: int
    chiffre_affaires_mensuel: float
    taux_occupation: float
    created_at: datetime

    class Config:
        from_attributes = True


# ============= ACTIVITES =============
class ActiviteBase(BaseModel):
    titre: str
    description: Optional[str] = None
    type_activite: str
    niveau_difficulte: str = "debutant"
    duree_estimee: int = Field(gt=0)
    prix_base: float = Field(gt=0)
    prix_enfant: Optional[float] = None
    prix_groupe: Optional[float] = None
    capacite_max: int = Field(gt=0)
    equipement_inclus: bool = True
    equipement_requis: List[str] = []
    conditions_meteo_minimales: Optional[str] = None
    localisation_precise: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    altitude_depart: Optional[int] = None
    altitude_arrivee: Optional[int] = None
    distance_parcours: Optional[float] = None
    saisonnalite: List[str] = []
    age_minimum: int = 12
    poids_minimum: int = 40
    poids_maximum: int = 120
    restrictions_medicales: List[str] = []


class ActiviteCreate(ActiviteBase):
    operateur_id: UUID4


class ActiviteUpdate(BaseModel):
    titre: Optional[str] = None
    description: Optional[str] = None
    prix_base: Optional[float] = None
    capacite_max: Optional[int] = None
    statut: Optional[str] = None


class ActiviteResponse(ActiviteBase):
    id: UUID4
    operateur_id: UUID4
    score_meteo: float
    moyenne_avis: float
    score_securite: float
    taux_remplissage: float
    statut: str
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ============= RESERVATIONS =============
class ReservationBase(BaseModel):
    date_activite: datetime
    duree_reservation: int
    nombre_participants: int = Field(gt=0)
    options_supplementaires: List[str] = []
    notes_particulieres: Optional[str] = None


class ReservationCreate(ReservationBase):
    client_id: UUID4
    activite_id: UUID4
    pilote_id: UUID4
    prix_total: float


class ReservationUpdate(BaseModel):
    statut: Optional[str] = None
    motif_annulation: Optional[str] = None


class ReservationResponse(ReservationBase):
    id: UUID4
    date_reservation: datetime
    client_id: UUID4
    activite_id: UUID4
    pilote_id: UUID4
    statut: str
    prix_total: float
    acompte_verse: bool
    code_confirmation: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# ============= PAIEMENTS =============
class PaiementBase(BaseModel):
    montant_total: float = Field(ge=0)
    montant_acompte: float = 0
    methode: str
    assurance_annulation: bool = False


class PaiementCreate(PaiementBase):
    reservation_id: UUID4
    client_id: UUID4
    numero_transaction: str


class PaiementResponse(PaiementBase):
    id: UUID4
    reservation_id: UUID4
    client_id: UUID4
    date_paiement: datetime
    statut: str
    numero_transaction: str
    frais_service: float
    taxe_sejour: float
    date_remboursement: Optional[datetime] = None
    motif_remboursement: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# ============= AVIS =============
class AvisBase(BaseModel):
    note_globale: int = Field(ge=1, le=5)
    note_securite: int = Field(ge=1, le=5)
    note_accueil: int = Field(ge=1, le=5)
    note_materiel: int = Field(ge=1, le=5)
    note_pilote: int = Field(ge=1, le=5)
    commentaire: Optional[str] = None
    photos_jointes: List[str] = []
    recommandation: bool = True
    date_experience: date


class AvisCreate(AvisBase):
    client_id: UUID4
    activite_id: UUID4
    reservation_id: UUID4


class AvisResponse(AvisBase):
    id: UUID4
    client_id: UUID4
    activite_id: UUID4
    reservation_id: UUID4
    statut_moderation: str
    reponse_operateur: Optional[str] = None
    date_reponse: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True


# ============= METEO =============
class MeteoResponse(BaseModel):
    id: UUID4
    localisation: str
    temperature: Optional[float] = None
    vitesse_vent: Optional[float] = None
    direction_vent: Optional[str] = None
    precipitation: Optional[float] = None
    humidite: Optional[float] = None
    pression_atmospherique: Optional[float] = None
    visibilite: Optional[float] = None
    indice_uv: Optional[int] = None
    conditions_ciel: Optional[str] = None
    alertes_meteo: List[str] = []
    fiabilite_prevision: Optional[float] = None
    heure_releve: datetime
    source_donnees: str
    created_at: datetime

    class Config:
        from_attributes = True


# ============= STRIPE =============
class StripeCheckoutRequest(BaseModel):
    reservation_id: UUID4
    success_url: str
    cancel_url: str
    code_promo: Optional[str] = None


class StripeCheckoutResponse(BaseModel):
    session_id: str
    url: str


class StripeConnectOnboardingRequest(BaseModel):
    operateur_id: UUID4
    refresh_url: str
    return_url: str


class StripeConnectOnboardingResponse(BaseModel):
    account_id: str
    onboarding_url: str
