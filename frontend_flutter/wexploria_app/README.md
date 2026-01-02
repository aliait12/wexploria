# Wexploria Flutter App

Application mobile Flutter pour la plateforme Wexploria - Réservation d'expériences outdoor.

## 🎨 Design

- **Material 3** avec thème personnalisé
- **Google Fonts** (Inter)
- **Palette Gamma** - Indigo, Émeraude, Orange doré
- **Gradients** et **Glassmorphism**
- **Animations** fluides avec Lottie

## 📦 Dépendances principales

```yaml
# UI & Design
google_fonts, flutter_svg, lottie, shimmer, cached_network_image

# Backend
supabase_flutter, http, dio

# State Management
provider, flutter_riverpod

# Paiements
flutter_stripe

# Maps
mapbox_maps_flutter, geolocator, geocoding

# Notifications
onesignal_flutter

# UI Components
flutter_rating_bar, carousel_slider, smooth_page_indicator

# Navigation
go_router
```

## 🚀 Installation

### 1. Installer les dépendances

```bash
flutter pub get
```

### 2. Configuration

L'app est déjà configurée pour se connecter au backend Wexploria:
- **API Backend**: `http://localhost:8000`
- **Supabase**: Configuré dans `main.dart`

### 3. Lancer l'application

```bash
# Android/iOS
flutter run

# Web
flutter run -d chrome

# Choisir un appareil spécifique
flutter devices
flutter run -d <device_id>
```

## 📁 Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart       # Couleurs, espacements, API URLs
│   ├── theme/
│   │   └── app_theme.dart           # Thème Material 3
│   ├── models/
│   │   ├── activite.dart            # Modèle Activité
│   │   └── reservation.dart         # Modèle Réservation
│   ├── services/
│   │   ├── activite_service.dart    # API activités
│   │   ├── reservation_service.dart # API réservations
│   │   └── payment_service.dart     # Stripe
│   └── widgets/
│       ├── initial_splash_screen.dart
│       ├── logout_button.dart
│       └── welcome_screen.dart
│
├── features/
│   ├── auth/                        # Authentification
│   │   ├── auth_page.dart
│   │   └── auth_service.dart
│   │
│   ├── activities/                  # Catalogue d'activités
│   │   ├── activities_list_page.dart
│   │   └── widgets/
│   │       └── activity_card.dart
│   │
│   ├── client/                      # Dashboard client
│   │   └── client_home.dart
│   │
│   ├── pilote/                      # Dashboard pilote
│   │   └── pilote_home.dart
│   │
│   ├── operateur/                   # Dashboard opérateur
│   │   └── operateur_home.dart
│   │
│   └── admin/                       # Dashboard admin
│       └── admin_home.dart
│
└── main.dart                        # Point d'entrée
```

## 🎯 Fonctionnalités implémentées

### ✅ Authentification
- Login/Signup avec Supabase
- Gestion des rôles (Client, Pilote, Opérateur, Admin)
- Navigation automatique selon le rôle

### ✅ Dashboard Client
- **Accueil** - Vue d'ensemble avec recommandations
- **Activités** - Catalogue complet avec filtres
- **Réservations** - Liste des réservations
- **Profil** - Informations personnelles et paramètres

### ✅ Catalogue d'activités
- Liste d'activités avec cartes modernes
- Badge Wexploria Score (météo)
- Filtres par type, niveau, prix
- Recherche et pagination
- Images avec cache

### 🚧 En développement
- Page détail d'activité
- Formulaire de réservation
- Intégration Stripe Payment Sheet
- Carte Mapbox interactive
- Chat IA
- Widget météo

## 🎨 Composants UI

### ActivityCard
Carte d'activité avec:
- Image en cache
- Badge Wexploria Score (météo)
- Badge type d'activité
- Informations (durée, niveau, capacité)
- Prix et note

### Filtres
Bottom sheet avec:
- Sélection type d'activité
- Sélection niveau
- Fourchette de prix
- Bouton Appliquer/Réinitialiser

## 🔌 Services API

### ActiviteService
```dart
// Récupérer les activités
final activites = await activiteService.getActivites(
  typeActivite: 'parapente',
  niveauDifficulte: 'debutant',
  prixMin: 50,
  prixMax: 200,
);

// Météo + Score
final weather = await activiteService.getActiviteWeather(activiteId);

// Prix dynamique
final pricing = await activiteService.getDynamicPrice(activiteId);

// Recommandations IA
final recommendations = await activiteService.getRecommendations(
  userId: userId,
  latitude: 31.5,
  longitude: -9.7,
);
```

### ReservationService
```dart
// Créer une réservation
final reservation = await reservationService.createReservation({
  'client_id': clientId,
  'activite_id': activiteId,
  'pilote_id': piloteId,
  'date_activite': DateTime.now().toIso8601String(),
  'nombre_participants': 2,
  'prix_total': 150.0,
});

// Annuler
await reservationService.cancelReservation(
  reservationId,
  motif: 'Conditions météo',
);
```

### PaymentService
```dart
// Initialiser Stripe
await PaymentService.initializeStripe(publishableKey);

// Payer
final success = await paymentService.processPayment(
  reservationId: reservationId,
  codePromo: 'WELCOME10',
);
```

## 🎨 Thème

### Couleurs
```dart
Primary: #6366F1 (Indigo)
Secondary: #10B981 (Émeraude)
Accent: #F59E0B (Orange)
Success: #10B981
Warning: #F59E0B
Error: #EF4444
```

### Espacements
```dart
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
xxl: 48px
```

### Rayons
```dart
sm: 8px
md: 12px
lg: 16px
xl: 24px
full: 9999px
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

## 📱 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔧 Configuration avancée

### Stripe
Ajouter la clé publique dans le code:
```dart
await PaymentService.initializeStripe('pk_test_...');
```

### Mapbox
Ajouter le token dans `AndroidManifest.xml` et `Info.plist`

### OneSignal
Configurer l'App ID dans le code

## 📝 Notes

- L'API backend doit être lancée sur `localhost:8000`
- Les images utilisent Picsum pour le développement
- Le cache réseau est activé pour les performances

## 🤝 Contribution

1. Créer une branche feature
2. Commit les changements
3. Push et créer une Pull Request

---

**Développé avec ❤️ pour Wexploria 2025**
