from fastapi import APIRouter, HTTPException, Depends
from typing import Optional
from uuid import UUID
from database import get_supabase
from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["Auth & Roles"])

class OperatorRequest(BaseModel):
    user_id: UUID
    nom_entreprise: str
    siret: str
    message: Optional[str] = None

@router.post("/request-operator")
async def request_operator_role(request: OperatorRequest):
    """Soumettre une demande pour devenir opérateur"""
    supabase = get_supabase()
    
    # 1. Vérifier si le profil existe
    profile = supabase.table("profiles").select("*").eq("user_id", str(request.user_id)).execute()
    if not profile.data:
        raise HTTPException(status_code=404, detail="Profil non trouvé")
    
    # 2. Vérifier si une demande est déjà en cours ou si déjà opérateur
    if profile.data[0]["role"] == "operateur":
        return {"message": "Vous êtes déjà un opérateur"}
    
    # 3. Créer la demande (on utilise une table dédiée ou le champ metadata du profil)
    # Pour l'instant, on va simuler en mettant à jour le statut du profil
    # mais une table 'demandes_roles' serait mieux.
    # Créons une insertion dans une table 'demandes_operateurs' (on suppose qu'elle existe)
    try:
        demande_data = {
            "user_id": str(request.user_id),
            "nom_entreprise": request.nom_entreprise,
            "siret": request.siret,
            "message": request.message,
            "statut": "en_attente"
        }
        res = supabase.table("demandes_operateurs").insert(demande_data).execute()
        return {"status": "success", "message": "Votre demande a été soumise avec succès et sera validée par un admin."}
    except Exception as e:
        # Si la table n'existe pas, on renvoie une erreur explicite pour que je la crée en SQL
        print(f"Erreur demande opérateur: {e}")
        raise HTTPException(status_code=500, detail="Erreur lors de la soumission. Demandez à l'admin de vérifier la table demandes_operateurs.")
