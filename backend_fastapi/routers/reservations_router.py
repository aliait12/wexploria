from fastapi import APIRouter, HTTPException, Query
from fastapi.encoders import jsonable_encoder
from typing import List
from uuid import UUID
from database import get_supabase
from schemas import (
    ReservationCreate,
    ReservationUpdate,
    ReservationResponse
)
from datetime import datetime
import secrets

router = APIRouter(prefix="/reservations", tags=["Réservations"])


@router.get("/", response_model=List[ReservationResponse])
async def get_reservations(
    client_id: UUID = None,
    pilote_id: UUID = None,
    activite_id: UUID = None,
    statut: str = None,
    limit: int = Query(20, le=100),
    offset: int = 0
):
    """Récupère la liste des réservations avec filtres"""
    supabase = get_supabase()
    
    query = supabase.table("reservations").select("*")
    
    # Filtres
    if client_id:
        query = query.eq("client_id", str(client_id))
    if pilote_id:
        query = query.eq("pilote_id", str(pilote_id))
    if activite_id:
        query = query.eq("activite_id", str(activite_id))
    if statut:
        query = query.eq("statut", statut)
    
    # Pagination
    query = query.range(offset, offset + limit - 1)
    
    # Tri par date de réservation décroissante
    query = query.order("date_reservation", desc=True)
    
    response = query.execute()
    return jsonable_encoder(response.data)


@router.get("/{reservation_id}", response_model=ReservationResponse)
async def get_reservation(reservation_id: UUID):
    """Récupère une réservation par son ID"""
    supabase = get_supabase()
    
    response = supabase.table("reservations").select("*, activites(*), clients(*, profiles(*)), pilotes(*, profiles(*))").eq("id", str(reservation_id)).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Réservation non trouvée")
    
    return jsonable_encoder(response.data[0])


@router.post("/", response_model=ReservationResponse, status_code=201)
async def create_reservation(reservation: ReservationCreate):
    """Crée une nouvelle réservation"""
    supabase = get_supabase()
    
    # Vérifier que l'activité existe et est disponible
    activite_response = supabase.table("activites").select("*").eq("id", str(reservation.activite_id)).execute()
    if not activite_response.data:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    
    activite = activite_response.data[0]
    
    if activite["statut"] != "actif":
        raise HTTPException(status_code=400, detail="Cette activité n'est pas disponible")
    
    # Vérifier la capacité
    if reservation.nombre_participants > activite["capacite_max"]:
        raise HTTPException(status_code=400, detail=f"Capacité maximale dépassée ({activite['capacite_max']} personnes)")
    
    # Vérifier que le pilote existe
    pilote_response = supabase.table("pilotes").select("id").eq("id", str(reservation.pilote_id)).execute()
    if not pilote_response.data:
        raise HTTPException(status_code=404, detail="Pilote non trouvé")
    
    # Vérifier que le client existe
    client_response = supabase.table("clients").select("id").eq("id", str(reservation.client_id)).execute()
    if not client_response.data:
        raise HTTPException(status_code=404, detail="Client non trouvé")
    
    # Générer un code de confirmation unique
    code_confirmation = secrets.token_urlsafe(8).upper()
    
    # Créer la réservation
    reservation_data = reservation.model_dump()
    reservation_data.update({
        "client_id": str(reservation.client_id),
        "activite_id": str(reservation.activite_id),
        "pilote_id": str(reservation.pilote_id),
        "prix_total": str(reservation.prix_total),
        "statut": "en_attente",
        "code_confirmation": code_confirmation,
        "date_reservation": datetime.now().isoformat()
    })
    
    response = supabase.table("reservations").insert(reservation_data).execute()
    
    if not response.data:
        raise HTTPException(status_code=400, detail="Erreur lors de la création de la réservation")
    
    return jsonable_encoder(response.data[0])


@router.patch("/{reservation_id}", response_model=ReservationResponse)
async def update_reservation(reservation_id: UUID, reservation: ReservationUpdate):
    """Met à jour une réservation"""
    supabase = get_supabase()
    
    # Vérifier que la réservation existe
    existing = supabase.table("reservations").select("*").eq("id", str(reservation_id)).execute()
    if not existing.data:
        raise HTTPException(status_code=404, detail="Réservation non trouvée")
    
    # Mettre à jour
    update_data = reservation.model_dump(exclude_unset=True)
    update_data["updated_at"] = datetime.now().isoformat()
    
    response = supabase.table("reservations").update(update_data).eq("id", str(reservation_id)).execute()
    
    return jsonable_encoder(response.data[0])


@router.post("/{reservation_id}/cancel")
async def cancel_reservation(reservation_id: UUID, motif: str = None):
    """Annule une réservation"""
    supabase = get_supabase()
    
    # Vérifier que la réservation existe
    existing = supabase.table("reservations").select("*").eq("id", str(reservation_id)).execute()
    if not existing.data:
        raise HTTPException(status_code=404, detail="Réservation non trouvée")
    
    reservation = existing.data[0]
    
    if reservation["statut"] in ["annulee", "terminee"]:
        raise HTTPException(status_code=400, detail="Cette réservation ne peut pas être annulée")
    
    # Mettre à jour le statut
    response = supabase.table("reservations").update({
        "statut": "annulee",
        "motif_annulation": motif,
        "updated_at": datetime.now().isoformat()
    }).eq("id", str(reservation_id)).execute()
    
    return {
        "status": "success",
        "message": "Réservation annulée avec succès",
        "reservation": response.data[0]
    }


@router.post("/{reservation_id}/confirm")
async def confirm_reservation(reservation_id: UUID):
    """Confirme une réservation (après paiement)"""
    supabase = get_supabase()
    
    # Vérifier que la réservation existe
    existing = supabase.table("reservations").select("*").eq("id", str(reservation_id)).execute()
    if not existing.data:
        raise HTTPException(status_code=404, detail="Réservation non trouvée")
    
    reservation = existing.data[0]
    
    if reservation["statut"] != "en_attente":
        raise HTTPException(status_code=400, detail="Cette réservation ne peut pas être confirmée")
    
    # Mettre à jour le statut
    response = supabase.table("reservations").update({
        "statut": "confirmee",
        "updated_at": datetime.now().isoformat()
    }).eq("id", str(reservation_id)).execute()
    
    return {
        "status": "success",
        "message": "Réservation confirmée avec succès",
        "reservation": response.data[0]
    }


@router.get("/client/{client_id}/upcoming")
async def get_client_upcoming_reservations(client_id: UUID):
    """Récupère les réservations à venir d'un client"""
    supabase = get_supabase()
    
    response = supabase.table("reservations").select("*, activites(*), pilotes(*, profiles(*))").eq("client_id", str(client_id)).gte("date_activite", datetime.now().isoformat()).order("date_activite", desc=False).execute()
    
    return {
        "reservations": response.data,
        "total": len(response.data)
    }


@router.get("/operateur/{operateur_id}")
async def get_operateur_reservations(operateur_id: UUID):
    """Récupère toutes les réservations pour les activités d'un opérateur"""
    supabase = get_supabase()
    
    # On fait une jointure avec activites pour filtrer par operateur_id
    # On récupère aussi les infos de l'activité, du client et du pilote
    response = supabase.table("reservations") \
        .select("*, activites!inner(*), clients(*, profiles(*)), pilotes(*, profiles(*))") \
        .eq("activites.operateur_id", str(operateur_id)) \
        .order("date_reservation", desc=True) \
        .execute()
    
    return jsonable_encoder(response.data)


@router.get("/pilote/{pilote_id}/calendar")
async def get_pilote_calendar(pilote_id: UUID, month: int = None, year: int = None):
    """Récupère le calendrier des réservations d'un pilote"""
    supabase = get_supabase()
    
    query = supabase.table("reservations").select("*, activites(*), clients(*, profiles(*))").eq("pilote_id", str(pilote_id))
    
    # Filtrer par mois/année si fourni
    if month and year:
        start_date = datetime(year, month, 1).isoformat()
        if month == 12:
            end_date = datetime(year + 1, 1, 1).isoformat()
        else:
            end_date = datetime(year, month + 1, 1).isoformat()
        
        query = query.gte("date_activite", start_date).lt("date_activite", end_date)
    
    response = query.order("date_activite", desc=False).execute()
    
    return {
        "reservations": response.data,
        "total": len(response.data)
    }
