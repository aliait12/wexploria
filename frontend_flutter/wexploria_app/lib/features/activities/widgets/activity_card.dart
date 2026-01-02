import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wexploria_app/core/constants/app_constants.dart';
import 'package:wexploria_app/core/models/activite.dart';

class ActivityCard extends StatelessWidget {
  final Activite activite;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge de score météo
            Stack(
              children: [
                // Image de l'activité
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: 'https://picsum.photos/seed/${activite.id}/800/450',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.textLight.withOpacity(0.1),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.textLight.withOpacity(0.1),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                
                // Badge Wexploria Score
                if (activite.scoreMeteo > 0)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: _buildWeatherScoreBadge(),
                  ),
                
                // Badge type d'activité
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: _buildActivityTypeBadge(),
                ),
              ],
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    activite.titre,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Localisation
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          activite.localisationPrecise,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Informations supplémentaires
                  Row(
                    children: [
                      // Durée
                      _buildInfoChip(
                        icon: Icons.access_time,
                        label: '${activite.dureeEstimee}min',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      
                      // Niveau
                      _buildInfoChip(
                        icon: Icons.signal_cellular_alt,
                        label: activite.niveauDifficulte,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      
                      // Capacité
                      _buildInfoChip(
                        icon: Icons.people,
                        label: '${activite.capaciteMax}',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Prix et note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Prix
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          '${activite.prixBase.toStringAsFixed(0)}€',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Note
                      if (activite.moyenneAvis > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              activite.moyenneAvis.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherScoreBadge() {
    final score = activite.scoreMeteo;
    Color backgroundColor;
    Color textColor = AppColors.textWhite;
    IconData icon;

    if (score >= 0.8) {
      backgroundColor = AppColors.success;
      icon = Icons.wb_sunny;
    } else if (score >= 0.6) {
      backgroundColor = AppColors.secondary;
      icon = Icons.wb_cloudy;
    } else if (score >= 0.4) {
      backgroundColor = AppColors.warning;
      icon = Icons.cloud;
    } else {
      backgroundColor = AppColors.error;
      icon = Icons.cloud_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${(score * 100).toInt()}%',
            style: TextStyle(
              color: textColor,
              fontSize: AppFontSizes.sm,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ActivityIcons.getIcon(activite.typeActivite),
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            activite.typeActivite.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppFontSizes.xs,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppFontSizes.xs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
