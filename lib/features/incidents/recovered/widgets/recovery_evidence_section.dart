import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/evidence_photo_section.dart' as core;
import '../../add_report/add_report_state.dart';

/// Section 1: pembungkus tipis [core.EvidencePhotoSection] kondisi pulih.
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
    return core.EvidencePhotoSection(
      mediaFiles: mediaFiles,
      onCapturePhoto: onCapturePhoto,
      onPickGallery: onPickGallery,
      onRemovePhoto: onRemovePhoto,
      stepNumber: '1',
      title: 'Bukti Visual Kondisi Terkini',
      badgeText: 'Min. 1 Foto Wajib',
      description:
          'Ambil foto langsung di lokasi yang menunjukkan bahwa air sudah surut '
          'dan akses jalan kembali aman.',
      galleryIcon: Icons.photo_library_rounded,
      galleryIconColor: AppColors.secondary,
      tonalButtons: true,
      maxMediaCount: kMaxReportMediaCount,
      thumbnailWidth: 160,
      thumbnailHeight: 124,
      thumbnailRadius: AppRadius.roundedMd,
      badgeLabelBuilder: (index) => 'Bukti Pulih ${index + 1}',
      badgeColor: AppColors.statusResolved,
      removeButtonColor: Colors.black54,
      addSlotLabel: '+ Tambah Bukti',
      addSlotCaption: '(Maks. $kMaxReportMediaCount foto)',
      addSlotIcon: Icons.add_a_photo_rounded,
      wrapInCard: true,
    );
  }
}
