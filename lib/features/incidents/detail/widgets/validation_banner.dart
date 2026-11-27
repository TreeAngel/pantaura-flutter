import 'package:material_ui/material_ui.dart';

import '../../../../core/models/api_models.dart';
import '../../../../core/theme/theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  2. VALIDATION BANNER
// ═══════════════════════════════════════════════════════════════════════════

String _formatDate(DateTime? dateTime) {
  if (dateTime == null) return '-';
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
}

class ValidationBanner extends StatelessWidget {
  const ValidationBanner({super.key, required this.incident});

  final IncidentDetailModel incident;

  @override
  Widget build(BuildContext context) {
    if (incident.status != 'verified') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.statusVerifiedBg,
          borderRadius: AppRadius.roundedLg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppSpacing.minTouchTarget,
              height: AppSpacing.minTouchTarget,
              decoration: BoxDecoration(
                color: AppColors.statusVerified,
                borderRadius: AppRadius.roundedMd,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.onPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.spaceXs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusVerified,
                          borderRadius: AppRadius.roundedStandard,
                        ),
                        child: Text(
                          'VALIDASI LAPANGAN',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'Pembaruan: ${_formatDate(incident.verifiedAt)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.statusVerified,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    (incident.statusLabel.isNotEmpty
                            ? incident.statusLabel
                            : 'Terkonfirmasi aktif')
                        .toUpperCase(),
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.statusVerified,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2xs),
                  Text(
                    'Kejadian ini telah divalidasi oleh tim berwenang dan relawan lapangan.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textPrimary,
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
