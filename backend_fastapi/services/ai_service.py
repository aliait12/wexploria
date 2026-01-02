from openai import AsyncOpenAI
from typing import List, Dict, Any, AsyncGenerator
from config import settings
import json

client = AsyncOpenAI(api_key=settings.openai_api_key)


class AIService:
    """Service pour les fonctionnalités d'Intelligence Artificielle"""
    
    def __init__(self):
        self.model = "gpt-4o-mini"
        self.embedding_model = "text-embedding-3-small"
    
    async def chat_completion(
        self,
        messages: List[Dict[str, str]],
        stream: bool = False
    ) -> AsyncGenerator[str, None] | Dict[str, Any]:
        """
        Génère une réponse de chat avec l'IA
        
        Args:
            messages: Liste des messages de conversation
            stream: Si True, retourne un stream SSE
        
        Returns:
            Réponse de l'IA ou générateur de stream
        """
        system_message = {
            "role": "system",
            "content": """Tu es l'assistant virtuel de Wexploria, une plateforme de réservation d'expériences outdoor.
            Tu aides les utilisateurs à :
            - Trouver des activités (parapente, surf, kitesurf, quad, trekking, montgolfière)
            - Comprendre les conditions météo
            - Réserver des expériences
            - Répondre aux questions sur les paiements et annulations
            
            Sois amical, professionnel et concis. Utilise des emojis quand approprié.
            Si tu ne connais pas une information, recommande de contacter le support."""
        }
        
        full_messages = [system_message] + messages
        
        if stream:
            return self._stream_chat(full_messages)
        else:
            response = await client.chat.completions.create(
                model=self.model,
                messages=full_messages,
                temperature=0.7,
                max_tokens=500
            )
            
            return {
                "message": response.choices[0].message.content,
                "usage": {
                    "prompt_tokens": response.usage.prompt_tokens,
                    "completion_tokens": response.usage.completion_tokens,
                    "total_tokens": response.usage.total_tokens
                }
            }
    
    async def _stream_chat(self, messages: List[Dict[str, str]]) -> AsyncGenerator[str, None]:
        """Stream la réponse de chat en temps réel"""
        stream = await client.chat.completions.create(
            model=self.model,
            messages=messages,
            temperature=0.7,
            max_tokens=500,
            stream=True
        )
        
        async for chunk in stream:
            if chunk.choices[0].delta.content:
                yield chunk.choices[0].delta.content
    
    async def generate_recommendations(
        self,
        user_preferences: List[str],
        user_history: List[Dict[str, Any]],
        weather_conditions: Dict[str, Any],
        available_activities: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """
        Génère des recommandations personnalisées d'activités
        
        Args:
            user_preferences: Préférences de l'utilisateur
            user_history: Historique des réservations
            weather_conditions: Conditions météo actuelles
            available_activities: Activités disponibles
        
        Returns:
            Liste d'activités recommandées avec scores
        """
        # Créer un prompt pour l'IA
        prompt = f"""Analyse les données suivantes et recommande les 5 meilleures activités :

Préférences utilisateur : {', '.join(user_preferences)}
Historique : {len(user_history)} réservations précédentes
Météo actuelle : {weather_conditions.get('weather_description', 'N/A')}, vent {weather_conditions.get('wind_speed', 0)} km/h

Activités disponibles :
{json.dumps(available_activities, indent=2, ensure_ascii=False)}

Retourne un JSON avec les IDs des activités recommandées et un score de pertinence (0-1) pour chacune.
Format : {{"recommendations": [{{"activity_id": "uuid", "score": 0.95, "reason": "raison"}}]}}"""
        
        response = await client.chat.completions.create(
            model=self.model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            response_format={"type": "json_object"}
        )
        
        result = json.loads(response.choices[0].message.content)
        return result.get("recommendations", [])
    
    async def translate_text(
        self,
        text: str,
        source_lang: str,
        target_lang: str
    ) -> str:
        """
        Traduit un texte d'une langue à une autre
        
        Args:
            text: Texte à traduire
            source_lang: Langue source (fr, en)
            target_lang: Langue cible (fr, en)
        
        Returns:
            Texte traduit
        """
        if source_lang == target_lang:
            return text
        
        prompt = f"Traduis ce texte de {source_lang} vers {target_lang}. Retourne uniquement la traduction, sans commentaire :\n\n{text}"
        
        response = await client.chat.completions.create(
            model=self.model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=1000
        )
        
        return response.choices[0].message.content.strip()
    
    async def create_embedding(self, text: str) -> List[float]:
        """
        Crée un embedding vectoriel pour du texte (RAG)
        
        Args:
            text: Texte à vectoriser
        
        Returns:
            Vecteur d'embedding
        """
        response = await client.embeddings.create(
            model=self.embedding_model,
            input=text
        )
        
        return response.data[0].embedding
    
    async def calculate_dynamic_pricing(
        self,
        base_price: float,
        weather_score: float,
        demand_level: float,
        occupancy_rate: float
    ) -> Dict[str, Any]:
        """
        Calcule un prix dynamique basé sur plusieurs facteurs
        
        Args:
            base_price: Prix de base
            weather_score: Score météo (0-1)
            demand_level: Niveau de demande (0-1)
            occupancy_rate: Taux d'occupation (0-1)
        
        Returns:
            Prix ajusté et justification
        """
        # Facteur météo : +20% si excellent, -10% si mauvais
        weather_factor = 1.0 + (weather_score - 0.5) * 0.4
        
        # Facteur demande : +30% si forte demande
        demand_factor = 1.0 + (demand_level * 0.3)
        
        # Facteur occupation : +20% si presque complet
        occupancy_factor = 1.0 + (occupancy_rate * 0.2)
        
        # Prix final
        adjusted_price = base_price * weather_factor * demand_factor * occupancy_factor
        
        # Limiter l'ajustement à +/-40%
        min_price = base_price * 0.6
        max_price = base_price * 1.4
        adjusted_price = max(min_price, min(max_price, adjusted_price))
        
        return {
            "base_price": base_price,
            "adjusted_price": round(adjusted_price, 2),
            "discount_percent": round(((adjusted_price - base_price) / base_price) * 100, 1),
            "factors": {
                "weather": round(weather_factor, 2),
                "demand": round(demand_factor, 2),
                "occupancy": round(occupancy_factor, 2)
            }
        }


# Instance globale du service
ai_service = AIService()
