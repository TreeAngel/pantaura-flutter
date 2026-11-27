import 'package:material_ui/material_ui.dart';

import '../../../../core/models/api_models.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/incident_status_chip.dart';

/// Card ringkasan insiden induk yang sedang ditambahkan laporannya.
class IncidentSummaryCard extends StatelessWidget {
  const IncidentSummaryCard({super.key, required this.incident});

  final IncidentDetailModel incident;

  IncidentStatus _parseStatus(String status) => switch (status) {
        'verified' => IncidentStatus.verified,
        'resolution_submitted' => IncidentStatus.resolutionSubmitted,
        'resolved' => IncidentStatus.resolved,
        'rejected' => IncidentStatus.rejected,
        _ => IncidentStatus.unverified,
      };

  @override
  Widget build(BuildContext context) {
    final address = incident.address?.trim();
    final displayAddress = (address != null && address.isNotEmpty)
        ? address
        : 'Lat: ${incident.latitude.toStringAsFixed(5)}, '
            'Lng: ${incident.longitude.toStringAsFixed(5)}';
    final status = _parseStatus(incident.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -24,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surfaceTintIce.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.spaceXs,
                    runSpacing: AppSpacing.spaceXs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.link_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.space2xs),
                          Text(
                            'MENAMBAH LAPORAN PADA INSIDEN',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IncidentStatusChip(
                        status: status,
                        customLabel: status == IncidentStatus.verified
                            ? 'Terkonfirmasi Aktif'
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceSm),
                  Text(
                    incident.title,
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.textHeader,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.statusResolution,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          displayAddress,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceSm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.spaceSm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTintIce,
                      borderRadius: AppRadius.roundedStandard,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.hub_rounded,
                          size: 20,
                          color: AppColors.statusResolution,
                        ),
                        const SizedBox(width: AppSpacing.spaceXs),
                        Expanded(
                          child: Text(
                            'Laporan Anda akan digabungkan ke rantai data insiden ini '
                            'untuk mempercepat penanganan BPBD & Tim Relawan gabungan.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
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
