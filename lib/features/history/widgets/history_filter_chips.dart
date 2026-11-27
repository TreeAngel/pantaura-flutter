import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Filter status laporan: Semua / Menunggu / Terkonfirmasi / Pulih / Ditolak.
class HistoryFilterChips extends StatelessWidget {
  const HistoryFilterChips({
    super.key,
    required this.activeFilter,
    required this.onChanged,
  });

  final String? activeFilter;
  final ValueChanged<String?> onChanged;

  static const List<_FilterOption> _options = [
    _FilterOption(null, 'Semua'),
    _FilterOption('unverified', 'Menunggu Verifikasi'),
    _FilterOption('verified', 'Terkonfirmasi'),
    _FilterOption('resolved', 'Telah Pulih'),
    _FilterOption('rejected', 'Ditolak'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in _options) ...[
            InkWell(
              onTap: () => onChanged(option.value),
              borderRadius: AppRadius.roundedFull,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: option.value == activeFilter
                        ? AppColors.textHeader
                        : AppColors.surfaceCard,
                    borderRadius: AppRadius.roundedFull,
                    boxShadow: AppShadows.level1,
                  ),
                  child: Center(
                    child: Text(
                      option.label,
                      style: AppTypography.labelSm.copyWith(
                        color: option.value == activeFilter
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceXs),
          ],
        ],
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption(this.value, this.label);

  final String? value;
  final String label;
}
