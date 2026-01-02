from fastapi import APIRouter, HTTPException
from typing import List
from uuid import UUID
from database import get_supabase
from schemas import AvisCreate, AvisResponse
from datetime import datetime

router = APIRouter(prefix="/avis", tags=["Avis"])


@router.get("/", response_model=List[AvisResponse])
async def get_avis(
    activite_id: UUID = None,
    client_id: UUID = None,
    statut_moderation: str = None,
    limit: int = 20,
    offset: int = 0
):
    """Récupère la liste des avis avec filtres"""
    supabase = get_supabase()
    
    query = supabase.table("avis").select("*")
    
    if activite_id:
        query = query.eq("activite_id", str(activite_id))
    if client_id:
        query = query.eq("client_id", str(client_id))
    if statut_moderation:
        query = query.eq("statut_moderation", statut_moderation)
    
    query = query.range(offset, offset + limit - 1).order("created_at", desc=True)
    
    response = query.execute()
    return response.data


@router.post("/", response_model=AvisResponse, status_code=201)
async def create_avis(avis: AvisCreate):
    """Crée un nouvel avis"""
    supabase = get_supabase()
    
    # Vérifier que la réservation existe et est terminée
    reservation_response = supabase.table("reservations").select("*").eq("id", str(avis.reservation_id)).execute()
    if not reservation_response.data:
        raise HTTPException(status_code=404, detail="Réservation non trouvée")
    
    reservation = reservation_response.data[0]
    if reservation["statut"] != "terminee":
        raise HTTPException(status_code=400, detail="Vous ne pouvez laisser un avis que pour une activité terminée")
    
    # Vérifier qu'un avis n'existe pas déjà pour cette réservation
    existing_avis = supabase.table("avis").select("id").eq("reservation_id", str(avis.reservation_id)).execute()
    if existing_avis.data:
        raise HTTPException(status_code=400, detail="Un avis existe déjà pour cette réservation")
    
    # Créer l'avis
    avis_data = avis.model_dump()
    avis_data.update({
        "client_id": str(avis.client_id),
        "activite_id": str(avis.activite_id),
        "reservation_id": str(avis.reservation_id),
        "statut_moderation": "en_attente"
    })
    
    response = supabase.table("avis").insert(avis_data).execute()
    
    if not response.data:
        raise HTTPException(status_code=400, detail="Erreur lors de la création de l'avis")
    
    # Mettre à jour la moyenne des avis de l'activité
    await update_activity_rating(avis.activite_id)
    
    return response.data[0]


@router.get("/{avis_id}", response_model=AvisResponse)
async def get_avis_by_id(avis_id: UUID):
    """Récupère un avis par son ID"""
    supabase = get_supabase()
    
    response = supabase.table("avis").select("*").eq("id", str(avis_id)).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Avis non trouvé")
    
    return response.data[0]


@router.post("/{avis_id}/moderate")
async def moderate_avis(avis_id: UUID, statut: str, raison: str = None):
    """Modère un avis (admin uniquement)"""
    supabase = get_supabase()
    
    if statut not in ["approuve", "rejete", "en_attente"]:
        raise HTTPException(status_code=400, detail="Statut invalide")
    
    response = supabase.table("avis").update({
        "statut_moderation": statut,
        "updated_at": datetime.now().isoformat()
    }).eq("id", str(avis_id)).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Avis non trouvé")
    
    return {"status": "success", "avis": response.data[0]}


@router.post("/{avis_id}/respond")
async def respond_to_avis(avis_id: UUID, reponse: str):
    """Permet à un opérateur de répondre à un avis"""
    supabase = get_supabase()
    
    response = supabase.table("avis").update({
        "reponse_operateur": reponse,
        "date_reponse": datetime.now().isoformat()
    }).eq("id", str(avis_id)).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Avis non trouvé")
    
    return {"status": "success", "avis": response.data[0]}


async def update_activity_rating(activite_id: UUID):
    """Met à jour la moyenne des avis d'une activité"""
    supabase = get_supabase()
    
    # Récupérer tous les avis approuvés de l'activité
    avis_response = supabase.table("avis").select("note_globale").eq("activite_id", str(activite_id)).eq("statut_moderation", "approuve").execute()
    
    if avis_response.data:
        notes = [avis["note_globale"] for avis in avis_response.data]
        moyenne = sum(notes) / len(notes)
        
        # Mettre à jour l'activité
        supabase.table("activites").update({
            "moyenne_avis": round(moyenne, 2)
        }).eq("id", str(activite_id)).execute()
