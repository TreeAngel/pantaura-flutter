import 'package:material_ui/material_ui.dart';

import '../../../../core/models/api_models.dart';
import '../../../../core/theme/theme.dart';
import '../../add_report/add_report_state.dart';

/// Card ringkasan insiden dengan tepat dua chip: jumlah laporan & verifikasi posisi.
class IncidentSummaryCard extends StatelessWidget {
  const IncidentSummaryCard({
    super.key,
    required this.incident,
    required this.distanceMeters,
    required this.isLocationValid,
  });

  final IncidentDetailModel incident;
  final double? distanceMeters;
  final bool isLocationValid;

  @override
  Widget build(BuildContext context) {
    final address = incident.address?.trim();
    final displayAddress = (address != null && address.isNotEmpty)
        ? address
        : 'Lat: ${incident.latitude.toStringAsFixed(5)}, '
            'Lng: ${incident.longitude.toStringAsFixed(5)}';

    final distance = distanceMeters;
    final positionMessage = isLocationValid && distance != null
        ? 'Posisi Anda terverifikasi di area insiden (radius ${distance.round()} meter)'
        : 'Verifikasi hanya berlaku di area maksimal ${kMaxReportRadiusMeters.toInt()} meter dari titik insiden';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident.title,
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.textHeader,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    displayAddress,
                    style: AppTypography.bodySm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceTintIce,
                borderRadius: AppRadius.roundedStandard,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.group_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${incident.reportsCount} Laporan Warga Tergabung',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.spaceXs),
              decoration: BoxDecoration(
                color: isLocationValid
                    ? AppColors.statusResolvedBg
                    : AppColors.statusVerifiedBg,
                borderRadius: AppRadius.roundedStandard,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.my_location_rounded,
                    size: 18,
                    color: isLocationValid
                        ? AppColors.statusResolved
                        : AppColors.statusVerified,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Expanded(
                    child: Text(
                      positionMessage,
                      style: AppTypography.labelSm.copyWith(
                        color: isLocationValid
                            ? AppColors.statusResolved
                            : AppColors.statusVerified,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
