import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/description_section.dart' as core;
import '../add_report_state.dart';

/// Section 3: pembungkus tipis [core.DescriptionSection] untuk tambah laporan.
class DescriptionSection extends StatelessWidget {
  const DescriptionSection({
    super.key,
    required this.disasterType,
    required this.controller,
    required this.currentDescription,
    required this.onChanged,
    required this.onQuickTextToggle,
  });

  final String disasterType;
  final TextEditingController controller;
  final String currentDescription;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onQuickTextToggle;

  @override
  Widget build(BuildContext context) {
    return core.DescriptionSection(
      controller: controller,
      currentDescription: currentDescription,
      onChanged: onChanged,
      onQuickTextToggle: onQuickTextToggle,
      quickTexts: getQuickTextsForDisaster(disasterType),
      stepNumber: '3',
      title: 'Deskripsi Perkembangan',
      badgeText: 'Wajib',
      instruction: 'Pilihan Cepat (Ketuk untuk menyisipkan ke deskripsi):',
      instructionIcon: Icons.touch_app_rounded,
      fieldLabel: 'Detail Kondisi Nyata di Lapangan',
      fieldNote: 'Laporan kronologis & faktual',
      fieldNoteIcon: Icons.verified_rounded,
      hintText: 'Tuliskan perubahan situasi terkini, kebutuhan mendesak, atau kendala akses...',
      maxLength: kMaxReportDescriptionLength,
      minLines: 5,
      maxLines: 5,
    );
  }
}
