import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/evidence_photo_section.dart' as core;
import '../add_report_state.dart';

/// Section 2: pembungkus tipis [EvidencePhotoSection] untuk tambah laporan.
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
    return core.EvidencePhotoSection(
      mediaFiles: mediaFiles,
      onCapturePhoto: onCapturePhoto,
      onPickGallery: onPickGallery,
      onRemovePhoto: onRemovePhoto,
      stepNumber: '2',
      title: 'Bukti Kondisi Terbaru',
      badgeText: 'Wajib (Min. 1 Foto)',
      maxMediaCount: kMaxReportMediaCount,
      badgeLabelBuilder: (_) => 'Baru',
      badgeAtTop: false,
      badgeColor: AppColors.surfaceTintIce,
      badgeTextColor: AppColors.primary,
      emptySlotLabel: 'Slot ${mediaFiles.length + (canAddMore ? 2 : 1)}',
    );
  }
}
