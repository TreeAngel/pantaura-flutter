import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/section_header.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key, required this.onFilterTap});

  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      leadingIcon: Icons.history_edu_rounded,
      eyebrow: 'Pantaura • Tanggap Warga',
      title: 'Riwayat Laporan Warga',
      actions: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: onFilterTap,
            icon: const Icon(Icons.tune_rounded,
                size: 24, color: AppColors.textHeader),
            tooltip: 'Filter laporan',
          ),
        ),
      ],
    );
  }
}
