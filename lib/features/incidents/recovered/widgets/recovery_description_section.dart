import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/description_section.dart' as core;
import '../../add_report/add_report_state.dart';
import '../recovered_state.dart';

/// Section 2: pembungkus tipis [core.DescriptionSection] kondisi pulih.
class RecoveryDescriptionSection extends StatelessWidget {
  const RecoveryDescriptionSection({
    super.key,
    required this.controller,
    required this.currentDescription,
    required this.onChanged,
    required this.onQuickTextToggle,
  });

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
      quickTexts: quickRecoveryTexts,
      stepNumber: '2',
      title: 'Deskripsi',
      badgeText: 'Wajib',
      instruction:
          'Tuliskan ringkasan situasi untuk mempermudah proses verifikasi:',
      hintText: 'Deskripsikan kondisi lapangan saat ini...',
      maxLength: kMaxReportDescriptionLength,
      minLines: 4,
      maxLines: 4,
      fieldHasBorder: true,
      textFieldInCard: false,
      wrapInCard: true,
      counterStyle: AppTypography.caption,
      chipSpacing: 6,
    );
  }
}
