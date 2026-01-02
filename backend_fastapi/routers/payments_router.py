from fastapi import APIRouter, HTTPException, Request, Header
from fastapi.encoders import jsonable_encoder
from typing import Optional
from uuid import UUID
from database import get_supabase
from schemas import (
    StripeCheckoutRequest,
    StripeCheckoutResponse,
    StripeConnectOnboardingRequest,
    StripeConnectOnboardingResponse,
    PaiementCreate,
    PaiementResponse
)
from services.stripe_service import stripe_service
from datetime import datetime

router = APIRouter(prefix="/payments", tags=["Paiements"])


@router.post("/checkout", response_model=StripeCheckoutResponse)
async def create_checkout_session(request: StripeCheckoutRequest):
    """Crée une session Stripe Checkout pour payer une réservation"""
    supabase = get_supabase()
    
    # Récupérer la réservation
    reservation_response = supabase.table("reservations").select("*, activites(operateur_id)").eq("id", str(request.reservation_id)).execute()
    
    if not reservation_response.data:
        raise HTTPException(status_code=404, detail="Réservation non trouvée")
    
    reservation = reservation_response.data[0]
    
    # Récupérer l'opérateur pour obtenir son compte Stripe Connect
    operateur_id = reservation["activites"]["operateur_id"]
    operateur_response = supabase.table("operateurs").select("*, profiles(email)").eq("id", operateur_id).execute()
    
    if not operateur_response.data:
        raise HTTPException(status_code=404, detail="Opérateur non trouvé")
    
    operateur = operateur_response.data[0]
    
    # Récupérer le client
    client_response = supabase.table("clients").select("*, profiles(email)").eq("id", reservation["client_id"]).execute()
    
    if not client_response.data:
        raise HTTPException(status_code=404, detail="Client non trouvé")
    
    client = client_response.data[0]
    client_email = client["profiles"]["email"]
    
    # TODO: Récupérer le compte Stripe Connect de l'opérateur depuis la base
    # Pour l'instant, on utilise None (paiement direct sans Connect)
    connected_account_id = None
    
    # Créer la session Stripe
    session = await stripe_service.create_checkout_session(
        amount=reservation["prix_total"],
        currency="eur",  # TODO: Gérer multi-devises
        reservation_id=request.reservation_id,
        client_email=client_email,
        success_url=request.success_url,
        cancel_url=request.cancel_url,
        promo_code=request.code_promo,
        connected_account_id=connected_account_id
    )
    
    return StripeCheckoutResponse(
        session_id=session["session_id"],
        url=session["url"]
    )


@router.post("/connect/onboarding", response_model=StripeConnectOnboardingResponse)
async def create_connect_onboarding(request: StripeConnectOnboardingRequest):
    """Crée un lien d'onboarding Stripe Connect pour un opérateur"""
    supabase = get_supabase()
    
    # Récupérer l'opérateur
    operateur_response = supabase.table("operateurs").select("*, profiles(email)").eq("id", str(request.operateur_id)).execute()
    
    if not operateur_response.data:
        raise HTTPException(status_code=404, detail="Opérateur non trouvé")
    
    operateur = operateur_response.data[0]
    email = operateur["profiles"]["email"]
    
    # Créer le compte Connect (ou récupérer s'il existe déjà)
    # TODO: Stocker l'account_id dans la table operateurs
    account_id = await stripe_service.create_connect_account(email=email, country="FR")
    
    # Créer le lien d'onboarding
    onboarding_url = await stripe_service.create_account_link(
        account_id=account_id,
        refresh_url=request.refresh_url,
        return_url=request.return_url
    )
    
    # Sauvegarder l'account_id dans la base
    # TODO: Ajouter une colonne stripe_account_id dans la table operateurs
    
    return StripeConnectOnboardingResponse(
        account_id=account_id,
        onboarding_url=onboarding_url
    )


@router.post("/webhook")
async def stripe_webhook(request: Request, stripe_signature: str = Header(None)):
    """Webhook pour recevoir les événements Stripe"""
    supabase = get_supabase()
    
    # Lire le corps de la requête
    payload = await request.body()
    
    # Vérifier la signature
    try:
        event = await stripe_service.verify_webhook_signature(payload, stripe_signature)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    # Traiter l'événement
    event_type = event["type"]
    
    if event_type == "checkout.session.completed":
        # Paiement réussi
        session = event["data"]["object"]
        reservation_id = session["metadata"]["reservation_id"]
        
        # Créer l'enregistrement de paiement
        paiement_data = {
            "reservation_id": reservation_id,
            "client_id": session["metadata"].get("client_id"),
            "montant_total": session["amount_total"] / 100,
            "methode": "carte",
            "statut": "reussi",
            "numero_transaction": session["payment_intent"],
            "date_paiement": datetime.now().isoformat()
        }
        
        supabase.table("paiements").insert(paiement_data).execute()
        
        # Mettre à jour la réservation
        supabase.table("reservations").update({
            "statut": "confirmee",
            "acompte_verse": True
        }).eq("id", reservation_id).execute()
    
    elif event_type == "payment_intent.payment_failed":
        # Paiement échoué
        payment_intent = event["data"]["object"]
        reservation_id = payment_intent["metadata"]["reservation_id"]
        
        # Mettre à jour la réservation
        supabase.table("reservations").update({
            "statut": "paiement_echoue"
        }).eq("id", reservation_id).execute()
    
    elif event_type == "payout.paid":
        # Reversement effectué
        payout = event["data"]["object"]
        # TODO: Mettre à jour les revenus du pilote/opérateur
    
    return {"status": "success"}


@router.post("/{paiement_id}/refund")
async def refund_payment(paiement_id: UUID, reason: Optional[str] = None):
    """Rembourse un paiement"""
    supabase = get_supabase()
    
    # Récupérer le paiement
    paiement_response = supabase.table("paiements").select("*").eq("id", str(paiement_id)).execute()
    
    if not paiement_response.data:
        raise HTTPException(status_code=404, detail="Paiement non trouvé")
    
    paiement = paiement_response.data[0]
    
    if paiement["statut"] != "reussi":
        raise HTTPException(status_code=400, detail="Ce paiement ne peut pas être remboursé")
    
    # Créer le remboursement Stripe
    refund = await stripe_service.create_refund(
        payment_intent_id=paiement["numero_transaction"],
        reason=reason or "requested_by_customer"
    )
    
    # Mettre à jour le paiement
    supabase.table("paiements").update({
        "statut": "rembourse",
        "date_remboursement": datetime.now().isoformat(),
        "motif_remboursement": reason
    }).eq("id", str(paiement_id)).execute()
    
    # Mettre à jour la réservation
    supabase.table("reservations").update({
        "statut": "annulee",
        "motif_annulation": reason
    }).eq("id", paiement["reservation_id"]).execute()
    
    return {
        "status": "success",
        "refund": refund
    }


@router.get("/client/{client_id}")
async def get_client_payments(client_id: UUID):
    """Récupère l'historique des paiements d'un client"""
    supabase = get_supabase()
    
    response = supabase.table("paiements").select("*, reservations(*, activites(titre))").eq("client_id", str(client_id)).order("date_paiement", desc=True).execute()
    
    return jsonable_encoder({
        "payments": response.data,
        "total": len(response.data)
    })
