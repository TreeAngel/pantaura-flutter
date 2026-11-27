import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/description_section.dart' as core;
import '../../incidents/add_report/add_report_state.dart';

/// Section 4: pembungkus tipis [core.DescriptionSection] buat laporan baru.
class ReportDescriptionSection extends StatelessWidget {
  const ReportDescriptionSection({
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
      stepNumber: '4',
      title: 'Deskripsi Singkat Kejadian',
      badgeText: 'Wajib',
      instruction:
          'Sentuh kata kunci di bawah untuk melengkapi rincian secara cepat '
          'tanpa repot mengetik:',
      hintText: 'Jelaskan situasi terkini, korban terdampak, atau kebutuhan bantuan darurat...',
      fieldNote: 'Sertakan referensi lokasi/bangunan/point of interest.',
      maxLength: kMaxReportDescriptionLength,
      minLines: 4,
      maxLines: 4,
    );
  }
}
