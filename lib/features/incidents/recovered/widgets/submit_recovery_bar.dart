import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';

/// Sticky CTA "Ajukan Status Pulih" (tinggi 56dp, nonaktif bila invalid / belum centang).
class SubmitRecoveryBar extends StatelessWidget {
  const SubmitRecoveryBar({
    super.key,
    required this.isEnabled,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool isEnabled;
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
              height: AppSpacing.ctaButtonHeight,
              child: ElevatedButton(
                onPressed: isEnabled && !isSubmitting ? onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusResolution,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.outlineVariant,
                  disabledForegroundColor: AppColors.onSurfaceVariant,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedMd,
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.task_alt_rounded, size: 22),
                          const SizedBox(width: AppSpacing.spaceXs),
                          Text(
                            'Ajukan Status Pulih',
                            style: AppTypography.labelLg.copyWith(
                              color: isEnabled
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Status insiden akan otomatis berubah menjadi 'Sedang Ditinjau' begitu terkirim.",
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
