import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../add_report/add_report_state.dart';
import '../../add_report/widgets/section_step_header.dart';

/// Section 1: Bukti visual kondisi pulih terkini (tanpa banner Kompresi Cerdas Aktif).
class RecoveryEvidenceSection extends StatelessWidget {
  const RecoveryEvidenceSection({
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
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionStepHeader(
              stepNumber: '1',
              title: 'Bukti Visual Kondisi Terkini',
              badgeText: 'Min. 1 Foto Wajib',
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              'Ambil foto langsung di lokasi yang menunjukkan bahwa air sudah '
              'surut dan akses jalan kembali aman.',
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSpacing.inputMinHeight,
                    child: FilledButton.tonalIcon(
                      onPressed: canAddMore ? onCapturePhoto : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surfaceTintIce,
                        foregroundColor: AppColors.primary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedMd,
                        ),
                      ),
                      icon: const Icon(Icons.photo_camera_rounded, size: 22),
                      label: const Text('Ambil Foto'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: SizedBox(
                    height: AppSpacing.inputMinHeight,
                    child: FilledButton.tonalIcon(
                      onPressed: canAddMore ? onPickGallery : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerLow,
                        foregroundColor: AppColors.textHeader,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedMd,
                        ),
                      ),
                      icon: const Icon(
                        Icons.photo_library_rounded,
                        size: 22,
                        color: AppColors.secondary,
                      ),
                      label: const Text('Pilih Galeri'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            ClipRRect(
              borderRadius: AppRadius.roundedMd,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < mediaFiles.length; i++) ...[
                      _RecoveredThumbnailCard(
                        index: i,
                        file: mediaFiles[i],
                        onRemove: () => onRemovePhoto(i),
                      ),
                      const SizedBox(width: AppSpacing.spaceSm),
                    ],
                    if (canAddMore)
                      _AddEvidenceSlot(
                        onTap: onPickGallery,
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

class _RecoveredThumbnailCard extends StatelessWidget {
  const _RecoveredThumbnailCard({
    required this.index,
    required this.file,
    required this.onRemove,
  });

  final int index;
  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 124,
      child: ClipRRect(
        borderRadius: AppRadius.roundedMd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(file.path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.surfaceContainer,
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
                  colors: [Color(0x99000000), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusResolved,
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Text(
                  'Bukti Pulih ${index + 1}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: SizedBox(
                width: 28,
                height: 28,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemove,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.onPrimary,
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

class _AddEvidenceSlot extends StatelessWidget {
  const _AddEvidenceSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: AppRadius.roundedMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: SizedBox(
          width: 140,
          height: 124,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceCard,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.level1,
                ),
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '+ Tambah Bukti',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textHeader,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '(Maks. $kMaxReportMediaCount foto)',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
