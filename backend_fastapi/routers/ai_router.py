from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from typing import List, Dict, Any
from pydantic import BaseModel
from services.ai_service import ai_service

router = APIRouter(prefix="/ai", tags=["Intelligence Artificielle"])


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    messages: List[ChatMessage]
    stream: bool = False


class TranslationRequest(BaseModel):
    text: str
    source_lang: str = "fr"
    target_lang: str = "en"


@router.post("/chat")
async def chat_with_ai(request: ChatRequest):
    """Chat avec l'assistant IA Wexploria"""
    messages = [msg.model_dump() for msg in request.messages]
    
    if request.stream:
        # Retourner un stream SSE
        async def event_generator():
            async for chunk in await ai_service.chat_completion(messages, stream=True):
                yield f"data: {chunk}\n\n"
            yield "data: [DONE]\n\n"
        
        return StreamingResponse(
            event_generator(),
            media_type="text/event-stream"
        )
    else:
        # Retourner une réponse complète
        response = await ai_service.chat_completion(messages, stream=False)
        return response


@router.post("/translate")
async def translate_text(request: TranslationRequest):
    """Traduit un texte d'une langue à une autre"""
    if request.source_lang not in ["fr", "en"] or request.target_lang not in ["fr", "en"]:
        raise HTTPException(status_code=400, detail="Langues supportées: fr, en")
    
    translation = await ai_service.translate_text(
        text=request.text,
        source_lang=request.source_lang,
        target_lang=request.target_lang
    )
    
    return {
        "original": request.text,
        "translated": translation,
        "source_lang": request.source_lang,
        "target_lang": request.target_lang
    }


@router.post("/embedding")
async def create_text_embedding(text: str):
    """Crée un embedding vectoriel pour du texte (RAG)"""
    embedding = await ai_service.create_embedding(text)
    
    return {
        "text": text,
        "embedding": embedding,
        "dimensions": len(embedding)
    }


@router.get("/dynamic-pricing")
async def calculate_dynamic_price(
    base_price: float,
    weather_score: float = 0.5,
    demand_level: float = 0.5,
    occupancy_rate: float = 0.5
):
    """Calcule un prix dynamique basé sur plusieurs facteurs"""
    if not (0 <= weather_score <= 1):
        raise HTTPException(status_code=400, detail="weather_score doit être entre 0 et 1")
    if not (0 <= demand_level <= 1):
        raise HTTPException(status_code=400, detail="demand_level doit être entre 0 et 1")
    if not (0 <= occupancy_rate <= 1):
        raise HTTPException(status_code=400, detail="occupancy_rate doit être entre 0 et 1")
    
    pricing = await ai_service.calculate_dynamic_pricing(
        base_price=base_price,
        weather_score=weather_score,
        demand_level=demand_level,
        occupancy_rate=occupancy_rate
    )
    
    return pricing
