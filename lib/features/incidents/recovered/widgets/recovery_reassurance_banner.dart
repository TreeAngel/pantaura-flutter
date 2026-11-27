import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';

/// Banner penenang di bagian atas halaman Lapor Kondisi Pulih.
class RecoveryReassuranceBanner extends StatelessWidget {
  const RecoveryReassuranceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceTintIce,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            decoration: BoxDecoration(
              color: AppColors.statusResolution,
              borderRadius: AppRadius.roundedMd,
              boxShadow: AppShadows.level1,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.onPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: AppRadius.roundedFull,
                    boxShadow: AppShadows.level1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.statusResolution,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ditinjau dalam estimasi ~15 menit',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textHeader,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Text(
                  'Pengajuan Penutupan & Pemulihan Insiden',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.textHeader,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2xs),
                Text(
                  'Laporan kondisi pulih Anda akan divalidasi oleh petugas piket '
                  'BPBD & Relawan sebelum status insiden resmi dinyatakan selesai ("Resolved"). '
                  'Terima kasih atas kepedulian Anda menjaga keselamatan bersama.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
