import 'package:material_ui/material_ui.dart';

import '../../../../core/models/api_models.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/incident_status_chip.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  3. SUMMARY (CHIP + TITLE)
// ═══════════════════════════════════════════════════════════════════════════

String _formatDate(DateTime? dateTime) {
  if (dateTime == null) return '-';
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
}

IncidentStatus _parseStatus(String status) => switch (status) {
  'verified' => IncidentStatus.verified,
  'resolution_submitted' => IncidentStatus.resolutionSubmitted,
  'resolved' => IncidentStatus.resolved,
  'rejected' => IncidentStatus.rejected,
  _ => IncidentStatus.unverified,
};

class IncidentSummarySection extends StatelessWidget {
  const IncidentSummarySection({super.key, required this.incident});

  final IncidentDetailModel incident;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.spaceXs,
              runSpacing: AppSpacing.spaceXs,
              children: [
                _DisasterTypeChip(label: incident.disasterTypeLabel),
                IncidentStatusChip(
                  status: _parseStatus(incident.status),
                  customLabel: incident.statusLabel.isEmpty
                      ? null
                      : incident.statusLabel.toUpperCase(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              incident.title,
              style: AppTypography.headlineLg.copyWith(
                color: AppColors.textHeader,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              incident.description,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            _SummaryStatsRow(incident: incident),
          ],
        ),
      ),
    );
  }
}

class _DisasterTypeChip extends StatelessWidget {
  const _DisasterTypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.statusChipMinHeight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceTintIce,
        borderRadius: AppRadius.roundedStandard,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flood_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.space2xs),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatsRow extends StatelessWidget {
  const _SummaryStatsRow({required this.incident});

  final IncidentDetailModel incident;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.spaceXs,
      runSpacing: AppSpacing.spaceXs,
      children: [
        _StatChip(
          icon: Icons.article_outlined,
          label: '${incident.reportsCount} Laporan',
        ),
        _StatChip(
          icon: Icons.calendar_today_outlined,
          label: _formatDate(incident.verifiedAt ?? incident.createdAt),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: AppSpacing.space2xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.roundedStandard,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.space2xs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
