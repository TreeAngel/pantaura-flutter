import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Banner urgensi + akses cepat darurat 112.
class CreateReportUrgencyBanner extends StatelessWidget {
  const CreateReportUrgencyBanner({super.key, required this.onEmergencyCall});

  final VoidCallback onEmergencyCall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.roundedLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed_rounded,
                    size: 22, color: AppColors.secondary),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: Text(
                    'Laporan Cepat Siaga',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.textHeader,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceXs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded,
                          size: 16, color: AppColors.statusResolution),
                      const SizedBox(width: AppSpacing.space2xs),
                      Text(
                        '< 1 Menit',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              'Laporkan kejadian segera untuk penanganan cepat petugas gabungan, BPBD, dan relawan terdekat.',
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            InkWell(
              onTap: onEmergencyCall,
              borderRadius: AppRadius.roundedMd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: AppRadius.roundedMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.call_rounded,
                        size: 20, color: AppColors.error),
                    const SizedBox(width: AppSpacing.spaceXs),
                    Expanded(
                      child: Text(
                        'Darurat Jiwa? Hubungi 112',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(
                        'Bebas Pulsa',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
