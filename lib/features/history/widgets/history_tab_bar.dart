import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../history_state.dart';

/// Segmen Laporan Bencana / Pengajuan Pemulihan.
class HistoryTabBar extends StatelessWidget {
  const HistoryTabBar({
    super.key,
    required this.activeTab,
    required this.reportCount,
    required this.recoveryCount,
    required this.onChanged,
  });

  final HistoryTab activeTab;
  final int reportCount;
  final int recoveryCount;
  final ValueChanged<HistoryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Laporan Bencana ($reportCount)',
            icon: Icons.campaign_rounded,
            isActive: activeTab == HistoryTab.report,
            onTap: () => onChanged(HistoryTab.report),
          ),
          const SizedBox(width: AppSpacing.space2xs),
          _TabItem(
            label: 'Pengajuan Pemulihan ($recoveryCount)',
            icon: Icons.published_with_changes_rounded,
            isActive: activeTab == HistoryTab.recovery,
            onTap: () => onChanged(HistoryTab.recovery),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isActive ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: AppRadius.roundedSm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedSm,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppColors.onPrimary
                      : AppColors.textHeader,
                ),
                const SizedBox(width: AppSpacing.space2xs),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.labelSm.copyWith(
                      color: isActive
                          ? AppColors.onPrimary
                          : AppColors.textHeader,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
