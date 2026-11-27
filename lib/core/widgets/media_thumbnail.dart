import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Pratinilai foto bukti dengan badge opsional dan tombol hapus.
class MediaThumbnail extends StatelessWidget {
  const MediaThumbnail({
    super.key,
    required this.file,
    required this.onRemove,
    this.badgeLabel,
    this.badgeColor = AppColors.primary,
    this.badgeTextColor = AppColors.onPrimary,
    this.badgeAtTop = true,
    this.width = 112,
    this.height = 112,
    this.borderRadius = AppRadius.roundedStandard,
    this.removeButtonColor = AppColors.statusVerified,
    this.showGradient = true,
  });

  final XFile file;
  final VoidCallback onRemove;
  final String? badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool badgeAtTop;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color removeButtonColor;
  final bool showGradient;

  @override
  Widget build(BuildContext context) {
    final label = badgeLabel;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(file.path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.surfaceContainerLow,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.outline,
                ),
              ),
            ),
            if (showGradient)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0x8800476E), Colors.transparent],
                  ),
                ),
              ),
            if (label != null)
              Positioned(
                left: 6,
                top: badgeAtTop ? 6 : null,
                bottom: badgeAtTop ? null : 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: badgeTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: SizedBox(
                width: 28,
                height: 28,
                child: Material(
                  color: removeButtonColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemove,
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.onPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
