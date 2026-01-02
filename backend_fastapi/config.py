import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    # Supabase
    supabase_url: str
    supabase_key: Optional[str] = None
    supabase_service_role_key: str
    
    # Stripe
    stripe_secret_key: Optional[str] = None
    stripe_connect_client_id: Optional[str] = None
    stripe_webhook_secret: Optional[str] = None
    
    # Cloudinary
    cloudinary_cloud_name: Optional[str] = None
    cloudinary_api_key: Optional[str] = None
    cloudinary_api_secret: Optional[str] = None
    
    # AI & Météo
    openweather_api_key: Optional[str] = None
    windy_api_key: Optional[str] = None
    openai_api_key: Optional[str] = None
    
    # Configuration Pydantic Settings
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
