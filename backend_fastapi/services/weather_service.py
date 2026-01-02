import httpx
from typing import Dict, Any, Optional
from datetime import datetime
from decimal import Decimal
from config import settings


class WeatherService:
    """Service pour récupérer et analyser les données météo"""
    
    def __init__(self):
        self.openweather_api_key = settings.openweather_api_key
        self.windy_api_key = settings.windy_api_key
        self.openweather_base_url = "https://api.openweathermap.org/data/2.5"
    
    async def get_current_weather(
        self,
        latitude: float,
        longitude: float
    ) -> Dict[str, Any]:
        """
        Récupère la météo actuelle pour une localisation
        
        Args:
            latitude: Latitude du lieu
            longitude: Longitude du lieu
        
        Returns:
            Données météo actuelles
        """
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.openweather_base_url}/weather",
                params={
                    "lat": latitude,
                    "lon": longitude,
                    "appid": self.openweather_api_key,
                    "units": "metric",
                    "lang": "fr"
                }
            )
            response.raise_for_status()
            data = response.json()
        
        return {
            "temperature": data["main"]["temp"],
            "feels_like": data["main"]["feels_like"],
            "humidity": data["main"]["humidity"],
            "pressure": data["main"]["pressure"],
            "wind_speed": data["wind"]["speed"],
            "wind_direction": data["wind"].get("deg"),
            "clouds": data["clouds"]["all"],
            "visibility": data.get("visibility", 10000) / 1000,  # en km
            "weather_condition": data["weather"][0]["main"],
            "weather_description": data["weather"][0]["description"],
            "timestamp": datetime.fromtimestamp(data["dt"])
        }
    
    async def get_forecast(
        self,
        latitude: float,
        longitude: float,
        days: int = 5
    ) -> Dict[str, Any]:
        """
        Récupère les prévisions météo
        
        Args:
            latitude: Latitude du lieu
            longitude: Longitude du lieu
            days: Nombre de jours de prévisions
        
        Returns:
            Prévisions météo
        """
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.openweather_base_url}/forecast",
                params={
                    "lat": latitude,
                    "lon": longitude,
                    "appid": self.openweather_api_key,
                    "units": "metric",
                    "lang": "fr",
                    "cnt": days * 8  # 8 prévisions par jour (toutes les 3h)
                }
            )
            response.raise_for_status()
            data = response.json()
        
        forecasts = []
        for item in data["list"]:
            forecasts.append({
                "datetime": datetime.fromtimestamp(item["dt"]),
                "temperature": item["main"]["temp"],
                "wind_speed": item["wind"]["speed"],
                "wind_direction": item["wind"].get("deg"),
                "humidity": item["main"]["humidity"],
                "precipitation": item.get("rain", {}).get("3h", 0),
                "weather_condition": item["weather"][0]["main"],
                "weather_description": item["weather"][0]["description"]
            })
        
        return {
            "location": data["city"]["name"],
            "forecasts": forecasts
        }
    
    def calculate_wexploria_score(
        self,
        weather_data: Dict[str, Any],
        activity_type: str
    ) -> Decimal:
        """
        Calcule le Wexploria Score (0-1) pour une activité
        
        Args:
            weather_data: Données météo actuelles
            activity_type: Type d'activité (parapente, surf, kitesurf, etc.)
        
        Returns:
            Score entre 0 et 1
        """
        score = Decimal("0.5")  # Score de base
        
        wind_speed = weather_data.get("wind_speed", 0)
        temperature = weather_data.get("temperature", 15)
        visibility = weather_data.get("visibility", 10)
        clouds = weather_data.get("clouds", 50)
        weather_condition = weather_data.get("weather_condition", "Clear")
        
        # Règles spécifiques par type d'activité
        if activity_type == "parapente":
            # Vent idéal : 10-25 km/h
            if 10 <= wind_speed <= 25:
                score += Decimal("0.3")
            elif wind_speed < 10 or wind_speed > 30:
                score -= Decimal("0.2")
            
            # Visibilité importante
            if visibility >= 10:
                score += Decimal("0.1")
            
            # Pas de pluie
            if weather_condition in ["Clear", "Clouds"]:
                score += Decimal("0.1")
            elif weather_condition in ["Rain", "Thunderstorm"]:
                score -= Decimal("0.4")
        
        elif activity_type == "surf":
            # Vent modéré
            if 15 <= wind_speed <= 30:
                score += Decimal("0.2")
            
            # Température agréable
            if 18 <= temperature <= 28:
                score += Decimal("0.2")
            
            # Conditions météo
            if weather_condition in ["Clear", "Clouds"]:
                score += Decimal("0.1")
        
        elif activity_type == "kitesurf":
            # Vent fort nécessaire : 15-35 km/h
            if 15 <= wind_speed <= 35:
                score += Decimal("0.4")
            elif wind_speed < 10:
                score -= Decimal("0.3")
            
            # Pas de pluie
            if weather_condition in ["Clear", "Clouds"]:
                score += Decimal("0.1")
        
        elif activity_type in ["quad", "trekking"]:
            # Pas de pluie
            if weather_condition in ["Clear", "Clouds"]:
                score += Decimal("0.3")
            elif weather_condition == "Rain":
                score -= Decimal("0.3")
            
            # Température confortable
            if 15 <= temperature <= 30:
                score += Decimal("0.2")
        
        elif activity_type == "hot_air_balloon":
            # Vent très faible : < 10 km/h
            if wind_speed < 10:
                score += Decimal("0.3")
            elif wind_speed > 15:
                score -= Decimal("0.4")
            
            # Ciel dégagé
            if clouds < 30:
                score += Decimal("0.2")
            
            # Visibilité excellente
            if visibility >= 10:
                score += Decimal("0.1")
        
        # Limiter le score entre 0 et 1
        score = max(Decimal("0"), min(Decimal("1"), score))
        
        return score.quantize(Decimal("0.01"))
    
    async def get_weather_with_score(
        self,
        latitude: float,
        longitude: float,
        activity_type: str
    ) -> Dict[str, Any]:
        """
        Récupère la météo et calcule le score Wexploria
        
        Args:
            latitude: Latitude du lieu
            longitude: Longitude du lieu
            activity_type: Type d'activité
        
        Returns:
            Données météo + score Wexploria
        """
        weather_data = await self.get_current_weather(latitude, longitude)
        score = self.calculate_wexploria_score(weather_data, activity_type)
        
        return {
            **weather_data,
            "wexploria_score": float(score),
            "activity_type": activity_type,
            "recommendation": self._get_recommendation(score)
        }
    
    def _get_recommendation(self, score: Decimal) -> str:
        """Génère une recommandation basée sur le score"""
        if score >= Decimal("0.8"):
            return "Conditions optimales ! C'est le moment idéal."
        elif score >= Decimal("0.6"):
            return "Bonnes conditions, activité recommandée."
        elif score >= Decimal("0.4"):
            return "Conditions acceptables."
        elif score >= Decimal("0.2"):
            return "Conditions moyennes, prudence recommandée."
        else:
            return "Conditions défavorables, activité déconseillée."


# Instance globale du service
weather_service = WeatherService()
