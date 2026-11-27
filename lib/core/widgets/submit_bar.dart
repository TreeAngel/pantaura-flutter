import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Sticky action bar generik untuk form laporan/pengajuan.
class SubmitBar extends StatelessWidget {
  const SubmitBar({
    super.key,
    required this.onSubmit,
    this.label = 'Kirim Laporan',
    this.loadingLabel = 'Mengirim...',
    this.icon = Icons.send_rounded,
    this.isSubmitting = false,
    this.isEnabled = true,
    this.backgroundColor = AppColors.primary,
    this.disabledBackgroundColor = AppColors.outlineVariant,
    this.caption,
    this.captionIcon = Icons.verified_user_rounded,
    this.showSafeArea = true,
    this.height = AppSpacing.ctaButtonHeight,
  });

  final VoidCallback onSubmit;
  final String label;
  final String loadingLabel;
  final IconData icon;
  final bool isSubmitting;
  final bool isEnabled;
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final String? caption;
  final IconData? captionIcon;
  final bool showSafeArea;
  final double height;

  @override
  Widget build(BuildContext context) {
    final captionText = caption;
    final captionGlyph = captionIcon;
    final button = SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton.icon(
        onPressed: isEnabled && !isSubmitting ? onSubmit : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          foregroundColor: AppColors.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
          ),
        ),
        icon: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.onPrimary,
                ),
              )
            : Icon(icon),
        label: Text(
          isSubmitting ? loadingLabel : label,
          style: AppTypography.labelLg.copyWith(
            color: isEnabled ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        if (captionText != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (captionGlyph != null) ...[
                Icon(captionGlyph, size: 14, color: AppColors.statusResolution),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  captionText,
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    return Container(
      width: double.infinity,
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
      child: showSafeArea ? SafeArea(top: false, child: content) : content,
    );
  }
}
