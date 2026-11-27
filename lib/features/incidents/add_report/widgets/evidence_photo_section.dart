import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../add_report_state.dart';
import 'section_step_header.dart';

/// Section 2: Ambil foto / pilih galeri dengan preview horizontal max 5 foto.
class EvidencePhotoSection extends StatelessWidget {
  const EvidencePhotoSection({
    super.key,
    required this.mediaFiles,
    required this.onCapturePhoto,
    required this.onPickGallery,
    required this.onRemovePhoto,
  });

  final List<XFile> mediaFiles;
  final VoidCallback onCapturePhoto;
  final VoidCallback onPickGallery;
  final ValueChanged<int> onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final canAddMore = mediaFiles.length < kMaxReportMediaCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionStepHeader(
            stepNumber: '2',
            title: 'Bukti Kondisi Terbaru',
            badgeText: 'Wajib (Min. 1 Foto)',
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            children: [
              Expanded(
                child: _MediaSourceButton(
                  icon: Icons.photo_camera_rounded,
                  label: 'Ambil Foto',
                  onTap: canAddMore ? onCapturePhoto : null,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: _MediaSourceButton(
                  icon: Icons.add_photo_alternate_rounded,
                  label: 'Pilih Galeri',
                  onTap: canAddMore ? onPickGallery : null,
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
                    _MediaThumbnailCard(
                      file: mediaFiles[i],
                      onRemove: () => onRemovePhoto(i),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                  ],
                  if (canAddMore)
                    _AddPhotoSlotCard(
                      onTap: onPickGallery,
                    ),
                  if (mediaFiles.length + (canAddMore ? 1 : 0) < 3) ...[
                    const SizedBox(width: AppSpacing.spaceSm),
                    _EmptySlotPlaceholder(
                      slotNumber: mediaFiles.length + (canAddMore ? 2 : 1),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaSourceButton extends StatelessWidget {
  const _MediaSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
              Icon(
                icon,
                size: 26,
                color: onTap == null ? AppColors.outline : AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color:
                      onTap == null ? AppColors.outline : AppColors.textHeader,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaThumbnailCard extends StatelessWidget {
  const _MediaThumbnailCard({
    required this.file,
    required this.onRemove,
  });

  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: ClipRRect(
        borderRadius: AppRadius.roundedStandard,
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
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x8800476E), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTintIce,
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Text(
                  'Baru',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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
                  color: AppColors.statusVerified,
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

class _AddPhotoSlotCard extends StatelessWidget {
  const _AddPhotoSlotCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCanvas,
      borderRadius: AppRadius.roundedStandard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedStandard,
        child: SizedBox(
          width: 112,
          height: 112,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 24,
                color: AppColors.statusResolution,
              ),
              const SizedBox(height: 4),
              Text(
                'Tambah Foto',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '(Maks. $kMaxReportMediaCount)',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySlotPlaceholder extends StatelessWidget {
  const _EmptySlotPlaceholder({required this.slotNumber});

  final int slotNumber;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.roundedStandard,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, size: 22, color: AppColors.outline),
            const SizedBox(height: 4),
            Text(
              'Slot $slotNumber',
              style: AppTypography.caption.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}
