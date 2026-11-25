import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';

/// Banner Aksi Tanggap Cepat & Panggilan Darurat 112 sesuai Stitch & DESIGN.md.
class HomeEmergencyBanner extends StatelessWidget {
  const HomeEmergencyBanner({
    super.key,
    required this.onCreateReportTap,
    required this.onEmergencyCallTap,
  });

  final VoidCallback onCreateReportTap;
  final VoidCallback onEmergencyCallTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.statusResolutionBg,
        borderRadius: AppRadius.roundedLg,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(24, 145, 172, 0.18),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.textHeader,
                  borderRadius: AppRadius.roundedMd,
                  boxShadow: AppShadows.level1,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.onPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AKSI TANGGAP CEPAT',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Melihat kejadian bencana di sekitar Anda?',
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Laporkan segera untuk respons tanggap cepat petugas BPBD & tim relawan wilayah.',
                      style: AppTypography.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          SizedBox(
            height: AppSpacing.ctaButtonHeight,
            child: ElevatedButton(
              onPressed: onCreateReportTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textHeader,
                foregroundColor: AppColors.onPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedMd,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign_rounded, size: 24),
                      const SizedBox(width: AppSpacing.spaceXs),
                      Text(
                        'Buat Laporan Cepat',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          SizedBox(
            height: AppSpacing.minTouchTarget,
            child: ElevatedButton.icon(
              onPressed: onEmergencyCallTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceCard,
                foregroundColor: AppColors.error,
                elevation: 1,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedMd,
                ),
              ),
              icon: const Icon(Icons.call_rounded, size: 20),
              label: Text(
                'Hubungi Panggilan Darurat 112 (Bebas Pulsa)',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
