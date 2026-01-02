from fastapi import APIRouter, HTTPException, Depends, Query
from fastapi.encoders import jsonable_encoder
from typing import List, Optional
from uuid import UUID
from database import get_supabase
from schemas import (
    ActiviteCreate,
    ActiviteUpdate,
    ActiviteResponse
)
from services.weather_service import weather_service
from services.ai_service import ai_service
from decimal import Decimal

router = APIRouter(prefix="/activites", tags=["Activités"])


@router.get("/", response_model=List[ActiviteResponse])
async def get_activites(
    type_activite: Optional[str] = None,
    niveau_difficulte: Optional[str] = None,
    prix_min: Optional[float] = None,
    prix_max: Optional[float] = None,
    localisation: Optional[str] = None,
    operateur_id: Optional[UUID] = None,
    limit: int = Query(20, le=100),
    offset: int = 0
):
    """Récupère la liste des activités avec filtres"""
    supabase = get_supabase()
    
    query = supabase.table("activites").select("*")
    
    # Filtres
    if type_activite:
        query = query.eq("type_activite", type_activite)
    if niveau_difficulte:
        query = query.eq("niveau_difficulte", niveau_difficulte)
    if prix_min:
        query = query.gte("prix_base", prix_min)
    if prix_max:
        query = query.lte("prix_base", prix_max)
    if localisation:
        query = query.ilike("localisation_precise", f"%{localisation}%")
    if operateur_id:
        query = query.eq("operateur_id", str(operateur_id))
    
    # Pagination
    query = query.range(offset, offset + limit - 1)
    
    # Tri par score météo décroissant
    query = query.order("score_meteo", desc=True)
    
    response = query.execute()
    return jsonable_encoder(response.data)


@router.get("/{activite_id}", response_model=ActiviteResponse)
async def get_activite(activite_id: UUID):
    """Récupère une activité par son ID"""
    supabase = get_supabase()
    
    response = supabase.table("activites").select("*").eq("id", str(activite_id)).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    
    return jsonable_encoder(response.data[0])


@router.post("/", response_model=ActiviteResponse, status_code=201)
async def create_activite(activite: ActiviteCreate):
    """Crée une nouvelle activité"""
    print(f"DEBUG: Tentative de création d'activité par l'opérateur: {activite.operateur_id}")
    supabase = get_supabase()
    
    # Vérifier que l'opérateur existe
    operateur_exists = False
    try:
        operateur_check = supabase.table("operateurs").select("id").eq("id", str(activite.operateur_id)).execute()
        if operateur_check.data:
            operateur_exists = True
        else:
            # Essayer de chercher par user_id au cas où le frontend envoie l'ID d'authentification
            print(f"DEBUG: Pas d'opérateur avec id={activite.operateur_id}, essai par user_id...")
            user_check = supabase.table("operateurs").select("id").eq("user_id", str(activite.operateur_id)).execute()
            if user_check.data:
                print(f"DEBUG: Opérateur trouvé via user_id: {user_check.data[0]['id']}")
                # On met à jour l'ID de l'opérateur pour l'insertion correcte
                activite.operateur_id = user_check.data[0]['id']
                operateur_exists = True
    except Exception as e:
        print(f"DEBUG: Erreur de base de données lors de la vérification: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur DB: {str(e)}")

    if not operateur_exists:
        print(f"DEBUG: Opérateur {activite.operateur_id} définitivement non trouvé")
        raise HTTPException(status_code=404, detail=f"Opérateur {activite.operateur_id} non trouvé. L'utilisateur doit avoir un profil 'opérateur' valide.")
    
    # Créer l'activité
    activite_data = activite.model_dump()
    activite_data["operateur_id"] = str(activite.operateur_id)
    
    print(f"DEBUG: Insertion data: {activite_data}")
    try:
        response = supabase.table("activites").insert(activite_data).execute()
        if not response.data:
            print("DEBUG: L'insertion n'a renvoyé aucune donnée")
            raise HTTPException(status_code=400, detail="Erreur lors de la création de l'activité (no data)")
        
        print(f"✅ Activité créée avec succès: {response.data[0].get('id')}")
        return jsonable_encoder(response.data[0])
    except Exception as e:
        print(f"❌ Erreur lors de l'insertion Supabase: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.patch("/{activite_id}", response_model=ActiviteResponse)
async def update_activite(activite_id: UUID, activite: ActiviteUpdate):
    """Met à jour une activité"""
    supabase = get_supabase()
    
    # Vérifier que l'activité existe
    existing = supabase.table("activites").select("*").eq("id", str(activite_id)).execute()
    if not existing.data:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    
    # Mettre à jour
    update_data = activite.model_dump(exclude_unset=True)
    response = supabase.table("activites").update(update_data).eq("id", str(activite_id)).execute()
    
    return jsonable_encoder(response.data[0])


@router.delete("/{activite_id}", status_code=204)
async def delete_activite(activite_id: UUID):
    """Supprime une activité"""
    supabase = get_supabase()
    
    response = supabase.table("activites").delete().eq("id", str(activite_id)).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    
    return None


@router.get("/{activite_id}/weather")
async def get_activite_weather(activite_id: UUID):
    """Récupère la météo et le score Wexploria pour une activité"""
    supabase = get_supabase()
    
    # Récupérer l'activité
    response = supabase.table("activites").select("*").eq("id", str(activite_id)).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    
    activite = response.data[0]
    
    if not activite.get("latitude") or not activite.get("longitude"):
        raise HTTPException(status_code=400, detail="Coordonnées GPS non disponibles pour cette activité")
    
    # Récupérer la météo avec score
    weather_data = await weather_service.get_weather_with_score(
        latitude=float(activite["latitude"]),
        longitude=float(activite["longitude"]),
        activity_type=activite["type_activite"]
    )
    
    # Mettre à jour le score météo dans la base
    supabase.table("activites").update({
        "score_meteo": weather_data["wexploria_score"]
    }).eq("id", str(activite_id)).execute()
    
    return weather_data


@router.get("/{activite_id}/dynamic-price")
async def get_dynamic_price(activite_id: UUID):
    """Calcule le prix dynamique pour une activité"""
    supabase = get_supabase()
    
    # Récupérer l'activité
    response = supabase.table("activites").select("*").eq("id", str(activite_id)).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    
    activite = response.data[0]
    
    # Calculer le prix dynamique
    pricing = await ai_service.calculate_dynamic_pricing(
        base_price=float(activite["prix_base"]),
        weather_score=float(activite.get("score_meteo", 0.5)),
        demand_level=0.7,  # TODO: Calculer la demande réelle
        occupancy_rate=float(activite.get("taux_remplissage", 0))
    )
    
    return pricing


@router.get("/search/recommendations")
async def get_recommendations(
    user_id: Optional[UUID] = None,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
):
    """Obtient des recommandations personnalisées d'activités"""
    supabase = get_supabase()
    
    # Récupérer les préférences utilisateur si fourni
    user_preferences = []
    user_history = []
    
    if user_id:
        client_response = supabase.table("clients").select("preferences").eq("user_id", str(user_id)).execute()
        if client_response.data:
            user_preferences = client_response.data[0].get("preferences", [])
        
        # Récupérer l'historique
        history_response = supabase.table("reservations").select("activite_id").eq("client_id", str(user_id)).execute()
        user_history = history_response.data or []
    
    # Récupérer les activités disponibles
    activites_response = supabase.table("activites").select("*").eq("statut", "actif").execute()
    available_activities = activites_response.data or []
    
    # Récupérer la météo si coordonnées fournies
    weather_conditions = {}
    if latitude and longitude:
        weather_conditions = await weather_service.get_current_weather(latitude, longitude)
    
    # Générer les recommandations avec l'IA
    recommendations = await ai_service.generate_recommendations(
        user_preferences=user_preferences,
        user_history=user_history,
        weather_conditions=weather_conditions,
        available_activities=available_activities
    )
    
    return {
        "recommendations": recommendations,
        "total": len(recommendations)
    }
