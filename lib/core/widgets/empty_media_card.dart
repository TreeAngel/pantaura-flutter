import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Slot media kosong; dapat bersifat pasif atau menjadi tombol tambah foto.
class EmptyMediaCard extends StatelessWidget {
  const EmptyMediaCard({
    super.key,
    this.label = 'Kosong',
    this.caption,
    this.icon = Icons.image_outlined,
    this.onTap,
    this.width = 112,
    this.height = 112,
    this.opacity = 0.55,
    this.borderRadius = AppRadius.roundedStandard,
    this.activeBackground = AppColors.surfaceCanvas,
  });

  final String label;
  final String? caption;
  final IconData icon;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double opacity;
  final BorderRadius borderRadius;
  final Color activeBackground;

  @override
  Widget build(BuildContext context) {
    final action = onTap;
    final captionText = caption;
    final content = SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.statusResolution),
          const SizedBox(height: AppSpacing.space2xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (captionText != null)
            Text(captionText, style: AppTypography.caption),
        ],
      ),
    );

    if (action == null) {
      return Opacity(
        opacity: opacity,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: borderRadius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.outline),
              const SizedBox(height: AppSpacing.space2xs),
              Text(
                label,
                style: AppTypography.caption.copyWith(color: AppColors.outline),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: activeBackground,
      borderRadius: borderRadius,
      child: InkWell(onTap: action, borderRadius: borderRadius, child: content),
    );
  }
}
