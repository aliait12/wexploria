import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/weather_service.dart';

class WeatherWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherWidget({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    // Extracting data safely
    final temp = (weatherData['main']?['temp'] as num?)?.toDouble() ?? 25.0;
    final condition = (weatherData['weather'] as List?)?.isNotEmpty == true
        ? weatherData['weather'][0]['main'] as String
        : 'Clear';
    final description = (weatherData['weather'] as List?)?.isNotEmpty == true
        ? weatherData['weather'][0]['description'] as String
        : 'Ciel dégagé';
    
    final recommendation = WeatherService().getRecommendation(condition, temp);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONDITIONS TODAY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description.capitalize(), // You might need an extension for this or just raw string
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    recommendation,
                    style: const TextStyle(
                      color: AppColors.info,
                      fontSize: AppFontSizes.sm,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    _getWeatherIcon(condition),
                    size: 48,
                    color: AppColors.warning,
                  ),
                  Text(
                    '${temp.round()}°C',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('rain')) return Icons.water_drop;
    if (cond.contains('cloud')) return Icons.cloud;
    if (cond.contains('snow')) return Icons.ac_unit;
    if (cond.contains('thunder')) return Icons.flash_on;
    return Icons.wb_sunny_rounded;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
