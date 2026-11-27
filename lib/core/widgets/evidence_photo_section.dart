import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';
import 'empty_media_card.dart';
import 'media_thumbnail.dart';
import 'section_step_header.dart';

/// Section bukti foto generik untuk ketiga form laporan.
///
/// Judul, badge, instruksi, label tombol, ikon, ukuran thumbnail, dan slot
/// kosong dapat disesuaikan lewat parameter tanpa menyalin logika picker.
class EvidencePhotoSection extends StatelessWidget {
  const EvidencePhotoSection({
    super.key,
    required this.mediaFiles,
    required this.onCapturePhoto,
    required this.onPickGallery,
    required this.onRemovePhoto,
    this.stepNumber = '2',
    this.title = 'Bukti Kondisi Terbaru',
    this.badgeText = 'Wajib (Min. 1 Foto)',
    this.description,
    this.captureLabel = 'Ambil Foto',
    this.galleryLabel = 'Pilih Galeri',
    this.captureIcon = Icons.photo_camera_rounded,
    this.galleryIcon = Icons.add_photo_alternate_rounded,
    this.galleryIconColor,
    this.tonalButtons = false,
    this.maxMediaCount = 5,
    this.thumbnailWidth = 112,
    this.thumbnailHeight = 112,
    this.thumbnailRadius = AppRadius.roundedStandard,
    this.badgeLabelBuilder,
    this.badgeColor = AppColors.primary,
    this.badgeTextColor = AppColors.onPrimary,
    this.badgeAtTop = true,
    this.removeButtonColor = AppColors.statusVerified,
    this.addSlotLabel = 'Tambah Foto',
    this.addSlotCaption,
    this.addSlotIcon = Icons.add_circle_outline_rounded,
    this.emptySlotLabel,
    this.wrapInCard = false,
  });

  final List<XFile> mediaFiles;
  final VoidCallback onCapturePhoto;
  final VoidCallback onPickGallery;
  final ValueChanged<int> onRemovePhoto;
  final String stepNumber;
  final String title;
  final String badgeText;
  final String? description;
  final String captureLabel;
  final String galleryLabel;
  final IconData captureIcon;
  final IconData galleryIcon;
  final Color? galleryIconColor;
  final bool tonalButtons;
  final int maxMediaCount;
  final double thumbnailWidth;
  final double thumbnailHeight;
  final BorderRadius thumbnailRadius;
  final String Function(int index)? badgeLabelBuilder;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool badgeAtTop;
  final Color removeButtonColor;
  final String addSlotLabel;
  final String? addSlotCaption;
  final IconData addSlotIcon;
  final String? emptySlotLabel;
  final bool wrapInCard;

  @override
  Widget build(BuildContext context) {
    final canAddMore = mediaFiles.length < maxMediaCount;
    final body = _buildBody(context, canAddMore);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: wrapInCard
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: AppRadius.roundedLg,
                boxShadow: AppShadows.level1,
              ),
              child: body,
            )
          : body,
    );
  }

  Widget _buildBody(BuildContext context, bool canAddMore) {
    final descriptionText = description;
    final badgeBuilder = badgeLabelBuilder;
    final emptyLabel = emptySlotLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionStepHeader(
          stepNumber: stepNumber,
          title: title,
          badgeText: badgeText,
        ),
        if (descriptionText != null) ...[
          const SizedBox(height: AppSpacing.spaceXs),
          Text(descriptionText, style: AppTypography.bodySm),
        ],
        const SizedBox(height: AppSpacing.spaceSm),
        Row(
          children: [
            Expanded(
              child: _MediaSourceButton(
                icon: captureIcon,
                label: captureLabel,
                onTap: canAddMore ? onCapturePhoto : null,
                tonal: tonalButtons,
              ),
            ),
            SizedBox(
              width: tonalButtons ? AppSpacing.spaceXs : AppSpacing.spaceSm,
            ),
            Expanded(
              child: _MediaSourceButton(
                icon: galleryIcon,
                label: galleryLabel,
                onTap: canAddMore ? onPickGallery : null,
                tonal: tonalButtons,
                iconColor: galleryIconColor,
                background: tonalButtons ? AppColors.surfaceContainerLow : null,
                foreground: tonalButtons ? AppColors.textHeader : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(AppSpacing.spaceSm),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.roundedLg,
            boxShadow: AppShadows.level1,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < mediaFiles.length; i++) ...[
                  MediaThumbnail(
                    file: mediaFiles[i],
                    onRemove: () => onRemovePhoto(i),
                    badgeLabel: badgeBuilder?.call(i),
                    badgeColor: badgeColor,
                    badgeTextColor: badgeTextColor,
                    badgeAtTop: badgeAtTop,
                    width: thumbnailWidth,
                    height: thumbnailHeight,
                    borderRadius: thumbnailRadius,
                    removeButtonColor: removeButtonColor,
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                ],
                if (canAddMore) ...[
                  EmptyMediaCard(
                    label: addSlotLabel,
                    caption: addSlotCaption ?? '(Maks. $maxMediaCount)',
                    icon: addSlotIcon,
                    onTap: onPickGallery,
                    borderRadius: thumbnailRadius,
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                ],
                if (emptyLabel != null &&
                    mediaFiles.length + (canAddMore ? 1 : 0) < 3)
                  EmptyMediaCard(
                    label: emptyLabel,
                    borderRadius: thumbnailRadius,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaSourceButton extends StatelessWidget {
  const _MediaSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tonal,
    this.iconColor,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool tonal;
  final Color? iconColor;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    if (tonal) {
      return SizedBox(
        height: AppSpacing.inputMinHeight,
        child: FilledButton.tonalIcon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: background ?? AppColors.surfaceTintIce,
            foregroundColor: foreground ?? AppColors.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
            ),
          ),
          icon: Icon(icon, size: 22, color: iconColor),
          label: Text(label),
        ),
      );
    }

    final enabledColor = onTap == null ? AppColors.outline : AppColors.primary;
    return Material(
      color: AppColors.surfaceTintIce.withValues(alpha: 0.55),
      borderRadius: AppRadius.roundedLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedLg,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.inputMinHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceSm,
            vertical: AppSpacing.spaceSm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: enabledColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: onTap == null
                      ? AppColors.outline
                      : AppColors.textHeader,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
