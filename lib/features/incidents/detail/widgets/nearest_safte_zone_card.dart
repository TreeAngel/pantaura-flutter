import 'package:material_ui/material_ui.dart';

import '../../../../core/models/api_models.dart';
import '../../../../core/theme/theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  6. NEAREST SAFE ZONE
// ═══════════════════════════════════════════════════════════════════════════

String _formatDistance(double? distanceKm) {
  if (distanceKm == null) return '-';
  if (distanceKm < 1) return '${(distanceKm * 1000).round()} m';
  return '${distanceKm.toStringAsFixed(1)} km';
}

class NearestSafeZoneCard extends StatelessWidget {
  const NearestSafeZoneCard({super.key, 
    required this.safeZone,
    required this.distanceKm,
  });

  final SafeZoneModel? safeZone;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final zone = safeZone;
    final zoneAddress = zone?.address;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  size: 22,
                  color: AppColors.statusVerified,
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: Text(
                    'Posko & Bantuan Terdekat',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.textHeader,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusResolvedBg,
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text(
                    'Siaga 24 Jam',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.statusResolved,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            if (zone == null)
              Text(
                'Tidak ada posko terdekat yang ditemukan.',
                style: AppTypography.caption,
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.roundedMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.textHeader,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Wrap(
                      spacing: AppSpacing.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (zone.type.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Text(
                              zone.type,
                              style: AppTypography.caption,
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.space2xs),
                            Text(
                              'Jarak ${_formatDistance(distanceKm)}',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (zone.capacity != null) ...[
                      const SizedBox(height: AppSpacing.space2xs),
                      Text(
                        'Kapasitas: ${zone.capacity} orang',
                        style: AppTypography.bodySm,
                      ),
                    ],
                    if (zoneAddress != null && zoneAddress.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space2xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.space2xs),
                          Expanded(
                            child: Text(
                              zoneAddress,
                              style: AppTypography.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
