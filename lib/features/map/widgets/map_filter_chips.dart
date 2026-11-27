import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Filter status insiden: Semua / Terverifikasi / Menunggu / Telah Pulih.
class MapFilterChips extends StatelessWidget {
  const MapFilterChips({
    super.key,
    required this.counts,
    required this.activeFilter,
    required this.onSelected,
  });

  final Map<String, int> counts;
  final String? activeFilter;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Semua',
            count: counts['all'] ?? 0,
            color: AppColors.primary,
            background: AppColors.surfaceCard,
            foreground: AppColors.onSurfaceVariant,
            isSelected: activeFilter == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          _FilterChip(
            label: 'Terverifikasi',
            count: counts['verified'] ?? 0,
            color: AppColors.statusVerified,
            background: AppColors.statusVerified,
            foreground: AppColors.onPrimary,
            isSelected: activeFilter == 'verified',
            onTap: () => onSelected('verified'),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          _FilterChip(
            label: 'Menunggu',
            count: counts['pending'] ?? 0,
            color: AppColors.statusUnverified,
            background: AppColors.surfaceCard,
            foreground: AppColors.statusUnverified,
            isSelected: activeFilter == 'pending',
            onTap: () => onSelected('pending'),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          _FilterChip(
            label: 'Telah Pulih',
            count: counts['resolved'] ?? 0,
            color: AppColors.statusResolved,
            background: AppColors.surfaceCard,
            foreground: AppColors.statusResolved,
            isSelected: activeFilter == 'resolved',
            onTap: () => onSelected('resolved'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.background,
    required this.foreground,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final Color background;
  final Color foreground;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedFull,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadius.roundedFull,
            boxShadow: AppShadows.level2,
            border: isSelected && background == AppColors.surfaceCard
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != 'Semua') ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isSelected && background != AppColors.surfaceCard
                        ? AppColors.onPrimary
                        : color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceXs),
              ],
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected && background != AppColors.surfaceCard
                      ? Colors.white24
                      : AppColors.surfaceContainer,
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text(
                  '$count',
                  style: AppTypography.labelSm.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
