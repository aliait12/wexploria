import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wexploria_app/core/constants/app_constants.dart';

class WeatherService {
  // TODO: Move this to a secure config or environment variable
  final String _apiKey = 'e1f109c1fa6e2e50550c66657c72f102'; // Using a demo key or placeholder. Ideally provided by user.
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=fr',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  String getRecommendation(String condition, double temp) {
    // Simple logic for recommendation based on weather
    // This can be expanded significantly
    if (condition.toLowerCase().contains('rain') ||
        condition.toLowerCase().contains('pluie')) {
      return 'Idéal pour des activités en intérieur ou aquatiques (si équipé)';
    } else if (condition.toLowerCase().contains('clear') ||
        condition.toLowerCase().contains('ciel dégagé') ||
        condition.toLowerCase().contains('sunny')) {
      if (temp > 25) {
        return 'Parfait pour les activités aquatiques';
      } else {
        return 'Parfait pour les activités aériennes et randonnées';
      }
    } else if (condition.toLowerCase().contains('wind') ||
        condition.toLowerCase().contains('vent')) {
      return 'Bonnes conditions pour le Kitesurf';
    }
    return 'Conditions correctes pour explorer';
  }
}
