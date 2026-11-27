import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';

/// Sticky bottom CTA untuk mengirim laporan tambahan.
class SubmitReportBar extends StatelessWidget {
  const SubmitReportBar({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        boxShadow: AppShadows.level4,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.spaceSm,
        AppSpacing.margin,
        AppSpacing.spaceSm,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: AppSpacing.inputMinHeight,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedMd,
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kirim Laporan Tambahan',
                            style: AppTypography.labelLg.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spaceXs),
                          const Icon(Icons.send_rounded, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 14,
                  color: AppColors.statusResolution,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Laporan langsung diverifikasi dan diteruskan ke posko darurat terdekat.',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
