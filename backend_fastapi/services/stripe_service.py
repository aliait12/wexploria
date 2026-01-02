import stripe
from typing import Optional, Dict, Any
from decimal import Decimal
from config import settings
from uuid import UUID

stripe.api_key = settings.stripe_secret_key


class StripeService:
    """Service pour gérer les paiements et reversements Stripe"""
    
    def __init__(self):
        self.connect_client_id = settings.stripe_connect_client_id
    
    async def create_checkout_session(
        self,
        amount: Decimal,
        currency: str,
        reservation_id: UUID,
        client_email: str,
        success_url: str,
        cancel_url: str,
        promo_code: Optional[str] = None,
        connected_account_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Crée une session Stripe Checkout pour le paiement client
        
        Args:
            amount: Montant en devise
            currency: Code devise (eur, usd, cad, mad)
            reservation_id: ID de la réservation
            client_email: Email du client
            success_url: URL de redirection après succès
            cancel_url: URL de redirection après annulation
            promo_code: Code promo optionnel
            connected_account_id: ID du compte Connect de l'opérateur
        """
        # Convertir le montant en centimes
        amount_cents = int(amount * 100)
        
        # Paramètres de base de la session
        session_params = {
            "payment_method_types": ["card"],
            "line_items": [{
                "price_data": {
                    "currency": currency.lower(),
                    "product_data": {
                        "name": "Réservation Wexploria",
                        "description": f"Réservation #{reservation_id}",
                    },
                    "unit_amount": amount_cents,
                },
                "quantity": 1,
            }],
            "mode": "payment",
            "success_url": success_url,
            "cancel_url": cancel_url,
            "customer_email": client_email,
            "metadata": {
                "reservation_id": str(reservation_id),
                "platform": "wexploria"
            },
            "payment_intent_data": {
                "metadata": {
                    "reservation_id": str(reservation_id)
                }
            }
        }
        
        # Si un compte Connect est fourni, ajouter les frais de plateforme
        if connected_account_id:
            # Commission de 10% pour la plateforme
            application_fee = int(amount_cents * 0.10)
            session_params["payment_intent_data"]["application_fee_amount"] = application_fee
            session_params["payment_intent_data"]["transfer_data"] = {
                "destination": connected_account_id
            }
        
        # Créer la session
        session = stripe.checkout.Session.create(**session_params)
        
        return {
            "session_id": session.id,
            "url": session.url
        }
    
    async def create_connect_account(self, email: str, country: str = "FR") -> str:
        """
        Crée un compte Stripe Connect Express pour un opérateur
        
        Args:
            email: Email de l'opérateur
            country: Code pays (FR, US, CA, MA)
        
        Returns:
            ID du compte Connect créé
        """
        account = stripe.Account.create(
            type="express",
            country=country,
            email=email,
            capabilities={
                "card_payments": {"requested": True},
                "transfers": {"requested": True},
            },
        )
        
        return account.id
    
    async def create_account_link(
        self,
        account_id: str,
        refresh_url: str,
        return_url: str
    ) -> str:
        """
        Crée un lien d'onboarding pour un compte Connect
        
        Args:
            account_id: ID du compte Connect
            refresh_url: URL si l'utilisateur quitte le flux
            return_url: URL après complétion
        
        Returns:
            URL d'onboarding
        """
        account_link = stripe.AccountLink.create(
            account=account_id,
            refresh_url=refresh_url,
            return_url=return_url,
            type="account_onboarding",
        )
        
        return account_link.url
    
    async def create_payout(
        self,
        account_id: str,
        amount: Decimal,
        currency: str = "eur"
    ) -> Dict[str, Any]:
        """
        Crée un reversement vers un compte Connect
        
        Args:
            account_id: ID du compte Connect
            amount: Montant à reverser
            currency: Devise
        
        Returns:
            Détails du payout
        """
        amount_cents = int(amount * 100)
        
        payout = stripe.Payout.create(
            amount=amount_cents,
            currency=currency.lower(),
            stripe_account=account_id,
        )
        
        return {
            "payout_id": payout.id,
            "amount": amount,
            "currency": currency,
            "status": payout.status,
            "arrival_date": payout.arrival_date
        }
    
    async def retrieve_payment_intent(self, payment_intent_id: str) -> Dict[str, Any]:
        """Récupère les détails d'un PaymentIntent"""
        payment_intent = stripe.PaymentIntent.retrieve(payment_intent_id)
        
        return {
            "id": payment_intent.id,
            "amount": payment_intent.amount / 100,
            "currency": payment_intent.currency,
            "status": payment_intent.status,
            "metadata": payment_intent.metadata
        }
    
    async def create_refund(
        self,
        payment_intent_id: str,
        amount: Optional[Decimal] = None,
        reason: str = "requested_by_customer"
    ) -> Dict[str, Any]:
        """
        Crée un remboursement
        
        Args:
            payment_intent_id: ID du PaymentIntent
            amount: Montant à rembourser (None = remboursement total)
            reason: Raison du remboursement
        
        Returns:
            Détails du remboursement
        """
        refund_params = {
            "payment_intent": payment_intent_id,
            "reason": reason
        }
        
        if amount:
            refund_params["amount"] = int(amount * 100)
        
        refund = stripe.Refund.create(**refund_params)
        
        return {
            "refund_id": refund.id,
            "amount": refund.amount / 100,
            "currency": refund.currency,
            "status": refund.status
        }
    
    async def verify_webhook_signature(
        self,
        payload: bytes,
        signature: str
    ) -> Dict[str, Any]:
        """
        Vérifie la signature d'un webhook Stripe
        
        Args:
            payload: Corps de la requête
            signature: Header Stripe-Signature
        
        Returns:
            Event Stripe vérifié
        """
        try:
            event = stripe.Webhook.construct_event(
                payload, signature, settings.stripe_webhook_secret
            )
            return event
        except ValueError:
            raise ValueError("Invalid payload")
        except stripe.error.SignatureVerificationError:
            raise ValueError("Invalid signature")


# Instance globale du service
stripe_service = StripeService()
