# Wexploria Backend API

API FastAPI complète pour la plateforme Wexploria - Réservation d'expériences outdoor.

## 🚀 Fonctionnalités

- ✅ **Catalogue d'activités** avec filtres avancés et recherche
- ✅ **Réservations intelligentes** avec gestion des disponibilités
- ✅ **Paiements Stripe** (Checkout + Connect pour reversements)
- ✅ **Météo en temps réel** avec calcul du Wexploria Score
- ✅ **Assistant IA** conversationnel avec streaming SSE
- ✅ **Recommandations personnalisées** basées sur l'IA
- ✅ **Traduction automatique** (FR ↔ EN)
- ✅ **Pricing dynamique** basé sur météo, demande et occupation
- ✅ **Gestion des avis** avec modération
- ✅ **Upload de médias** via Cloudinary

## 📋 Prérequis

- Python 3.12+
- Compte Supabase
- Clés API pour services tiers (voir Configuration)

## 🛠️ Installation

### 1. Créer un environnement virtuel

```bash
python -m venv venv
```

### 2. Activer l'environnement virtuel

**Windows:**
```bash
venv\Scripts\activate
```

**macOS/Linux:**
```bash
source venv/bin/activate
```

### 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 4. Configuration

Copier `.env.example` vers `.env` et remplir les variables:

```bash
cp .env.example .env
```

**Variables obligatoires:**
- `SUPABASE_URL` et `SUPABASE_KEY` ✅ (déjà configuré)
- `STRIPE_SECRET_KEY` - Clé Stripe (test ou production)
- `OPENWEATHER_API_KEY` - API OpenWeather
- `OPENAI_API_KEY` - API OpenAI pour l'IA

**Variables optionnelles:**
- `CLOUDINARY_*` - Pour upload de médias
- `ONESIGNAL_*` - Pour notifications push
- `SENDGRID_API_KEY` - Pour emails

## 🚀 Lancement

### Mode développement

```bash
python main.py
```

ou

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Mode production

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## 📚 Documentation API

Une fois l'API lancée, accédez à:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🗂️ Structure du projet

```
backend_fastapi/
├── main.py                 # Point d'entrée de l'application
├── config.py               # Configuration et settings
├── database.py             # Connexion Supabase
├── schemas.py              # Modèles Pydantic
├── requirements.txt        # Dépendances Python
├── .env                    # Variables d'environnement
├── routers/                # Endpoints API
│   ├── activites_router.py
│   ├── reservations_router.py
│   ├── payments_router.py
│   ├── avis_router.py
│   ├── weather_router.py
│   └── ai_router.py
└── services/               # Logique métier
    ├── stripe_service.py
    ├── weather_service.py
    ├── ai_service.py
    └── cloudinary_service.py
```

## 🔑 Endpoints principaux

### Activités
- `GET /activites/` - Liste des activités avec filtres
- `GET /activites/{id}` - Détail d'une activité
- `POST /activites/` - Créer une activité
- `GET /activites/{id}/weather` - Météo + Wexploria Score
- `GET /activites/{id}/dynamic-price` - Prix dynamique
- `GET /activites/search/recommendations` - Recommandations IA

### Réservations
- `GET /reservations/` - Liste des réservations
- `POST /reservations/` - Créer une réservation
- `POST /reservations/{id}/cancel` - Annuler une réservation
- `GET /reservations/client/{id}/upcoming` - Réservations à venir

### Paiements
- `POST /payments/checkout` - Créer session Stripe Checkout
- `POST /payments/connect/onboarding` - Onboarding Stripe Connect
- `POST /payments/webhook` - Webhook Stripe
- `POST /payments/{id}/refund` - Rembourser un paiement

### Météo
- `GET /weather/current` - Météo actuelle
- `GET /weather/forecast` - Prévisions
- `GET /weather/score` - Wexploria Score
- `GET /weather/best-spots` - Meilleurs spots du jour

### IA
- `POST /ai/chat` - Chat avec l'assistant IA
- `POST /ai/translate` - Traduction automatique
- `GET /ai/dynamic-pricing` - Calcul de prix dynamique

### Avis
- `GET /avis/` - Liste des avis
- `POST /avis/` - Créer un avis
- `POST /avis/{id}/moderate` - Modérer un avis
- `POST /avis/{id}/respond` - Répondre à un avis

## 🔐 Sécurité

- HTTPS obligatoire en production
- CORS configuré
- Validation des données avec Pydantic
- Row Level Security (RLS) sur Supabase
- Webhooks Stripe signés

## 🌍 Multi-devises supportées

- EUR (Euro)
- USD (Dollar US)
- CAD (Dollar Canadien)
- MAD (Dirham Marocain)

## 📊 Monitoring

L'API expose un endpoint `/health` pour les health checks:

```bash
curl http://localhost:8000/health
```

## 🤝 Contribution

1. Créer une branche feature
2. Commit les changements
3. Push et créer une Pull Request

## 📝 License

Propriétaire - Wexploria 2025

---

**Développé avec ❤️ pour Wexploria**
