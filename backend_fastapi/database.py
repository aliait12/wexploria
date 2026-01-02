from supabase import create_client, Client
from config import settings

def get_supabase() -> Client:
    """Initialise et retourne le client Supabase"""
    return create_client(settings.supabase_url, settings.supabase_service_role_key)
