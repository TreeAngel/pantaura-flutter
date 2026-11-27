import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/evidence_photo_section.dart' as core;
import '../../incidents/add_report/add_report_state.dart';

/// Section 3: pembungkus tipis [core.EvidencePhotoSection] buat laporan baru.
class ReportEvidenceSection extends StatelessWidget {
  const ReportEvidenceSection({
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
      stepNumber: '3',
      title: 'Bukti Foto / Video',
      badgeText: 'Min. 1 Foto',
      description:
          'Ambil foto jelas yang memperlihatkan ketinggian air, kerusakan, '
          'atau objek terdampak.',
      captureLabel: 'Buka Kamera',
      maxMediaCount: kMaxReportMediaCount,
      badgeLabelBuilder: (index) =>
          index == 0 ? 'Foto Utama' : 'Foto ${index + 1}',
      thumbnailRadius: AppRadius.roundedMd,
      addSlotLabel: '+ Tambah',
      addSlotCaption: '(Maks. $kMaxReportMediaCount)',
      emptySlotLabel: 'Kosong',
    );
  }
}
