import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../incident_detail_state.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  5. TIMELINE
// ═══════════════════════════════════════════════════════════════════════════

String _formatDate(DateTime? dateTime) {
  if (dateTime == null) return '-';
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
}

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key, 
    required this.timeline,
    required this.isSortAscending,
    required this.onToggleSort,
  });

  final List<TimelineEntry> timeline;
  final bool isSortAscending;
  final VoidCallback onToggleSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: Text(
                    'Kronologi Laporan Lapangan',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.textHeader,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onToggleSort,
                  borderRadius: AppRadius.roundedFull,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: AppSpacing.statusChipMinHeight,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTintIce,
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${timeline.length} Laporan',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space2xs),
                          Icon(
                            isSortAscending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            if (timeline.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceMd),
                child: Text('Belum ada laporan.', style: AppTypography.caption),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                    top: AppSpacing.space2xs,
                    right: AppSpacing.space2xs,
                  ),
                  itemCount: timeline.length,
                  separatorBuilder: (_, _) => Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: SizedBox(height: AppSpacing.spaceSm),
                  ),
                  itemBuilder: (context, index) =>
                      _TimelineEntryTile(entry: timeline[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntryTile extends StatelessWidget {
  const _TimelineEntryTile({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final isReport = entry.type == TimelineEntryType.report;
    final badgeColor = isReport
        ? AppColors.primaryContainer
        : AppColors.statusResolvedBg;
    final badgeText = isReport ? 'Laporan' : 'Resolusi';
    final badgeTextColor = isReport
        ? AppColors.onPrimaryContainer
        : AppColors.statusResolved;
    final firstMediaUrl = entry.media.isEmpty ? null : entry.media.first.url;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 18, right: 11),
          decoration: BoxDecoration(
            color: isReport
                ? AppColors.statusVerified
                : AppColors.statusResolved,
            shape: BoxShape.circle,
          ),
        ),
        ClipRRect(
          borderRadius: AppRadius.roundedMd,
          child: SizedBox(
            width: 48,
            height: 48,
            child: firstMediaUrl == null
                ? _TimelineAvatarPlaceholder(isReport: isReport)
                : Image.network(
                    firstMediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _TimelineAvatarPlaceholder(isReport: isReport),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceSm),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.roundedMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.authorName ?? 'Anonim',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textHeader,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    Text(
                      _formatDate(entry.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Text(
                    badgeText,
                    style: AppTypography.labelSm.copyWith(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space2xs),
                Text(
                  entry.description,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineAvatarPlaceholder extends StatelessWidget {
  const _TimelineAvatarPlaceholder({required this.isReport});

  final bool isReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isReport ? AppColors.statusVerifiedBg : AppColors.statusResolvedBg,
      child: Icon(
        isReport ? Icons.article_rounded : Icons.task_alt_rounded,
        color: isReport ? AppColors.statusVerified : AppColors.statusResolved,
        size: 24,
      ),
    );
  }
}
