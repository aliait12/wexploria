from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from uuid import UUID
from database import get_supabase
from schemas import ProfileResponse, PiloteCreate, PilotAccountCreate, PilotAccountResponse
from fastapi.encoders import jsonable_encoder
from datetime import datetime

router = APIRouter(prefix="/admin", tags=["Administration"])

@router.get("/pending-operators")
async def get_pending_operators():
    """Liste des demandes d'opérateurs en attente"""
    supabase = get_supabase()
    res = supabase.table("demandes_operateurs").select("*, profiles(nom, prenom, email)").eq("statut", "en_attente").execute()
    return jsonable_encoder(res.data)

@router.post("/approve-operator/{user_id}")
async def approve_operator(user_id: UUID):
    """Approuver une demande opérateur"""
    supabase = get_supabase()
    
    # 1. Récupérer la demande
    demande = supabase.table("demandes_operateurs").select("*").eq("user_id", str(user_id)).eq("statut", "en_attente").execute()
    if not demande.data:
        raise HTTPException(status_code=404, detail="Demande en attente non trouvée")
    
    data = demande.data[0]
    
    # 2. Mettre à jour le profil vers 'operateur'
    supabase.table("profiles").update({"role": "operateur"}).eq("user_id", str(user_id)).execute()
    
    # 3. Créer l'entrée dans la table 'operateurs'
    from datetime import date
    operator_entry = {
        "user_id": str(user_id),
        "nom_entreprise": data["nom_entreprise"],
        "siret": data["siret"],
        "date_creation": str(date.today()),
        "nombre_activites": 0,
        "chiffre_affaires_mensuel": 0,
        "taux_occupation": 0
    }
    supabase.table("operateurs").insert(operator_entry).execute()
    
    # 4. Marquer la demande comme validée
    supabase.table("demandes_operateurs").update({"statut": "valide"}).eq("id", data["id"]).execute()
    
    return {"status": "success", "message": f"Utilisateur {user_id} est maintenant Opérateur"}

@router.post("/pilot-account", response_model=PilotAccountResponse)
async def create_full_pilot_account(data: PilotAccountCreate):
    """
    Création COMPLÈTE d'un compte pilote par l'Admin.
    - Si l'email n'existe pas : crée Auth + Profile + Pilote.
    - Si l'email existe : met à jour le Profile en 'pilote' + crée l'entrée Pilote.
    """
    supabase = get_supabase()
    
    try:
        # 1. Vérifier si l'utilisateur existe déjà via son profil
        user_id = None
        existing_profile = supabase.table("profiles").select("user_id, role").eq("email", data.email).execute()
        
        if existing_profile.data:
            user_id = existing_profile.data[0]["user_id"]
            print(f"Utilisateur existant trouvé (ID: {user_id}).")
        else:
            # 2. Créer l'utilisateur dans Supabase Auth
            try:
                auth_response = supabase.auth.admin.create_user({
                    "email": data.email,
                    "password": data.password,
                    "email_confirm": True,
                    "user_metadata": {"role": "pilote", "nom": data.nom}
                })
                user_id = auth_response.user.id
            except Exception as auth_err:
                if "already registered" in str(auth_err).lower():
                    # Si déjà dans Auth mais pas dans Profiles (rare), on tente de récupérer via email
                    # Pour faire simple ici, on demande à utiliser un compte existant ou on renvoie l'erreur
                    raise HTTPException(status_code=400, detail="L'email est déjà utilisé. Veuillez d'abord créer le profil si nécessaire.")
                raise auth_err
        
        # 3. Créer ou Mettre à jour le profil (upsert)
        profile_data = {
            "user_id": str(user_id),
            "email": data.email,
            "nom": data.nom,
            "prenom": data.prenom,
            "role": "pilote",
            "statut": "actif"
        }
        
        profile_res = supabase.table("profiles").upsert(profile_data, on_conflict="user_id").execute()
        profile_db_id = profile_res.data[0]["id"]
        
        # 4. Créer ou Mettre à jour l'entrée Pilote (upsert)
        pilot_data = data.pilot_info.model_dump()
        pilot_data["user_id"] = str(user_id)
        
        # On utilise upsert pour écraser/compléter les infos techniques
        pilot_res = supabase.table("pilotes").upsert(pilot_data, on_conflict="user_id").execute()
        pilot_id = pilot_res.data[0]["id"]
        
        return {
            "user_id": str(user_id),
            "profile_id": profile_db_id,
            "pilot_id": str(pilot_id),
            "email": data.email
        }
        
    except HTTPException as he:
        raise he
    except Exception as e:
        print(f"Erreur création compte pilote: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/pilots")
async def list_pilots():
    """Liste tous les utilisateurs ayant le rôle 'pilote'"""
    supabase = get_supabase()
    # On commence par profiles pour voir tous ceux qui ont le rôle, 
    # et on fait une jointure vers pilotes pour les infos techniques
    res = supabase.table("profiles").select("*, pilotes(*)").eq("role", "pilote").execute()
    return jsonable_encoder(res.data)

@router.put("/pilot-account/{user_id}")
async def update_pilot_account(user_id: UUID, data: PilotAccountCreate):
    """Mise à jour d'un compte pilote"""
    supabase = get_supabase()
    
    try:
        # 1. Update Profil
        profile_data = {
            "nom": data.nom,
            "prenom": data.prenom,
        }
        supabase.table("profiles").update(profile_data).eq("user_id", str(user_id)).execute()
        
        # 2. Update Pilote
        pilot_update_data = data.pilot_info.model_dump()
        supabase.table("pilotes").update(pilot_update_data).eq("user_id", str(user_id)).execute()
        
        return {"status": "success", "message": "Compte pilote mis à jour"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/pilot-account/{user_id}")
async def delete_pilot_account(user_id: UUID):
    """
    Supprime le rôle pilote. 
    Note: Supprime l'entrée 'pilotes' et remet le rôle en 'client' dans 'profiles'.
    Ne supprime pas le compte Auth pour éviter de couper l'accès utilisateur.
    """
    supabase = get_supabase()
    
    try:
        # 1. Supprimer l'entrée pilotes
        supabase.table("pilotes").delete().eq("user_id", str(user_id)).execute()
        
        # 2. Rétrograder le profil en client
        supabase.table("profiles").update({"role": "client"}).eq("user_id", str(user_id)).execute()
        
        return {"status": "success", "message": "L'utilisateur n'est plus un pilote"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
