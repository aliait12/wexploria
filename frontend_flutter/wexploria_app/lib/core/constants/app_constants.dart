import 'package:flutter/material.dart';

/// Couleurs de la palette Wexploria (Gamma)
class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF00BCD4); // Cyan turquoise
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color primaryLight = Color(0xFF26C6DA);

  // Couleurs secondaires
  static const Color secondary = Color(0xFF10B981); // Vert émeraude (gardé)
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFF34D399);

  // Couleurs d'accent
  static const Color accent = Color(0xFFF59E0B); // Orange doré (gardé)
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFFBBF24);

  // Couleurs de fond
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2937);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Couleurs de statut
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Couleurs de gradient
  static final LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism
  static const Color glassBackground = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
}

/// Espacements constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Rayons de bordure
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

/// Tailles de police
class AppFontSizes {
  static const double xs = 12.0;
  static const double sm = 14.0;
  static const double md = 16.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
}

/// Icônes d'activités
class ActivityIcons {
  static const Map<String, IconData> icons = {
    'parapente': Icons.paragliding,
    'surf': Icons.surfing,
    'kitesurf': Icons.kitesurfing,
    'quad': Icons.directions_bike,
    'trekking': Icons.hiking,
    'hot_air_balloon': Icons.air,
  };

  static IconData getIcon(String activityType) {
    return icons[activityType.toLowerCase()] ?? Icons.explore;
  }
}

/// URLs de l'API
class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String activitesEndpoint = '/activites/';
  static const String reservationsEndpoint = '/reservations/';
  static const String paymentsEndpoint = '/payments/';
  static const String weatherEndpoint = '/weather/';
  static const String aiEndpoint = '/ai/';
  static const String avisEndpoint = '/avis/';
}
