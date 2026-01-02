import cloudinary
import cloudinary.uploader
from typing import Dict, Any, List
from config import settings

# Configuration Cloudinary
cloudinary.config(
    cloud_name=settings.cloudinary_cloud_name,
    api_key=settings.cloudinary_api_key,
    api_secret=settings.cloudinary_api_secret
)


class CloudinaryService:
    """Service pour gérer l'upload et la modération de médias"""
    
    async def upload_image(
        self,
        file_path: str,
        folder: str = "wexploria",
        public_id: str = None,
        tags: List[str] = None
    ) -> Dict[str, Any]:
        """
        Upload une image sur Cloudinary
        
        Args:
            file_path: Chemin du fichier ou URL
            folder: Dossier de destination
            public_id: ID public personnalisé
            tags: Tags pour l'image
        
        Returns:
            Détails de l'upload
        """
        upload_params = {
            "folder": folder,
            "resource_type": "image",
            "quality": "auto:good",
            "fetch_format": "auto"
        }
        
        if public_id:
            upload_params["public_id"] = public_id
        
        if tags:
            upload_params["tags"] = tags
        
        result = cloudinary.uploader.upload(file_path, **upload_params)
        
        return {
            "url": result["secure_url"],
            "public_id": result["public_id"],
            "width": result["width"],
            "height": result["height"],
            "format": result["format"],
            "size": result["bytes"]
        }
    
    async def upload_video(
        self,
        file_path: str,
        folder: str = "wexploria/videos",
        public_id: str = None
    ) -> Dict[str, Any]:
        """
        Upload une vidéo sur Cloudinary
        
        Args:
            file_path: Chemin du fichier
            folder: Dossier de destination
            public_id: ID public personnalisé
        
        Returns:
            Détails de l'upload
        """
        upload_params = {
            "folder": folder,
            "resource_type": "video",
            "quality": "auto"
        }
        
        if public_id:
            upload_params["public_id"] = public_id
        
        result = cloudinary.uploader.upload(file_path, **upload_params)
        
        return {
            "url": result["secure_url"],
            "public_id": result["public_id"],
            "duration": result.get("duration"),
            "format": result["format"],
            "size": result["bytes"]
        }
    
    async def delete_media(self, public_id: str, resource_type: str = "image") -> bool:
        """
        Supprime un média de Cloudinary
        
        Args:
            public_id: ID public du média
            resource_type: Type de ressource (image, video)
        
        Returns:
            True si suppression réussie
        """
        result = cloudinary.uploader.destroy(public_id, resource_type=resource_type)
        return result.get("result") == "ok"
    
    async def moderate_image(self, public_id: str) -> Dict[str, Any]:
        """
        Modère une image avec l'IA de Cloudinary
        
        Args:
            public_id: ID public de l'image
        
        Returns:
            Résultats de la modération
        """
        # Utiliser l'API de modération de Cloudinary
        result = cloudinary.api.resource(
            public_id,
            moderation="aws_rek:suggestive:explicit",
            resource_type="image"
        )
        
        moderation = result.get("moderation", [])
        
        if moderation:
            mod_result = moderation[0]
            return {
                "status": mod_result.get("status"),
                "kind": mod_result.get("kind"),
                "response": mod_result.get("response", {}),
                "is_appropriate": mod_result.get("status") == "approved"
            }
        
        return {"is_appropriate": True, "status": "pending"}
    
    def get_optimized_url(
        self,
        public_id: str,
        width: int = None,
        height: int = None,
        crop: str = "fill",
        quality: str = "auto"
    ) -> str:
        """
        Génère une URL optimisée pour une image
        
        Args:
            public_id: ID public de l'image
            width: Largeur souhaitée
            height: Hauteur souhaitée
            crop: Mode de crop
            quality: Qualité (auto, auto:good, auto:best)
        
        Returns:
            URL optimisée
        """
        transformation = {
            "quality": quality,
            "fetch_format": "auto"
        }
        
        if width:
            transformation["width"] = width
        if height:
            transformation["height"] = height
        if width or height:
            transformation["crop"] = crop
        
        return cloudinary.CloudinaryImage(public_id).build_url(**transformation)


# Instance globale du service
cloudinary_service = CloudinaryService()
