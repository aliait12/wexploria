from fastapi import APIRouter, HTTPException
from typing import List, Dict, Any
from uuid import UUID
from database import get_supabase
from services.weather_service import weather_service

router = APIRouter(prefix="/weather", tags=["Météo"])


@router.get("/current")
async def get_current_weather(latitude: float, longitude: float):
    """Récupère la météo actuelle pour une localisation"""
    try:
        weather_data = await weather_service.get_current_weather(latitude, longitude)
        return weather_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors de la récupération de la météo: {str(e)}")


@router.get("/forecast")
async def get_weather_forecast(latitude: float, longitude: float, days: int = 5):
    """Récupère les prévisions météo"""
    if days < 1 or days > 7:
        raise HTTPException(status_code=400, detail="Le nombre de jours doit être entre 1 et 7")
    
    try:
        forecast_data = await weather_service.get_forecast(latitude, longitude, days)
        return forecast_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors de la récupération des prévisions: {str(e)}")


@router.get("/score")
async def get_wexploria_score(
    latitude: float,
    longitude: float,
    activity_type: str
):
    """Calcule le Wexploria Score pour une activité"""
    valid_activities = ["parapente", "surf", "kitesurf", "quad", "trekking", "hot_air_balloon"]
    
    if activity_type not in valid_activities:
        raise HTTPException(
            status_code=400,
            detail=f"Type d'activité invalide. Valeurs acceptées: {', '.join(valid_activities)}"
        )
    
    try:
        weather_with_score = await weather_service.get_weather_with_score(
            latitude, longitude, activity_type
        )
        return weather_with_score
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors du calcul du score: {str(e)}")


@router.get("/best-spots")
async def get_best_spots_today(activity_type: str):
    """Trouve les meilleurs spots pour une activité aujourd'hui"""
    supabase = get_supabase()
    
    # Récupérer toutes les activités du type demandé
    activites_response = supabase.table("activites").select("id, titre, latitude, longitude, localisation_precise").eq("type_activite", activity_type).eq("statut", "actif").execute()
    
    if not activites_response.data:
        return {"best_spots": [], "message": "Aucune activité trouvée pour ce type"}
    
    # Calculer le score pour chaque spot
    spots_with_scores = []
    
    for activite in activites_response.data:
        if activite.get("latitude") and activite.get("longitude"):
            try:
                weather_data = await weather_service.get_weather_with_score(
                    float(activite["latitude"]),
                    float(activite["longitude"]),
                    activity_type
                )
                
                spots_with_scores.append({
                    "activite_id": activite["id"],
                    "titre": activite["titre"],
                    "localisation": activite["localisation_precise"],
                    "wexploria_score": weather_data["wexploria_score"],
                    "temperature": weather_data["temperature"],
                    "wind_speed": weather_data["wind_speed"],
                    "weather_description": weather_data["weather_description"],
                    "recommendation": weather_data["recommendation"]
                })
            except Exception:
                continue
    
    # Trier par score décroissant
    spots_with_scores.sort(key=lambda x: x["wexploria_score"], reverse=True)
    
    return {
        "best_spots": spots_with_scores[:10],  # Top 10
        "total": len(spots_with_scores),
        "activity_type": activity_type
    }


@router.post("/cache/update")
async def update_weather_cache():
    """Met à jour le cache météo pour toutes les activités"""
    supabase = get_supabase()
    
    # Récupérer toutes les activités actives avec coordonnées
    activites_response = supabase.table("activites").select("id, type_activite, latitude, longitude").eq("statut", "actif").execute()
    
    updated_count = 0
    
    for activite in activites_response.data:
        if activite.get("latitude") and activite.get("longitude"):
            try:
                weather_data = await weather_service.get_weather_with_score(
                    float(activite["latitude"]),
                    float(activite["longitude"]),
                    activite["type_activite"]
                )
                
                # Mettre à jour le score météo de l'activité
                supabase.table("activites").update({
                    "score_meteo": weather_data["wexploria_score"]
                }).eq("id", activite["id"]).execute()
                
                updated_count += 1
            except Exception:
                continue
    
    return {
        "status": "success",
        "updated": updated_count,
        "total": len(activites_response.data)
    }
