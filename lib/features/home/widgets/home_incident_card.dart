import 'package:material_ui/material_ui.dart';
import '../../../core/models/api_models.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/incident_status_chip.dart';

/// Kartu insiden bencana pada feed Beranda Warga.
class HomeIncidentCard extends StatelessWidget {
  const HomeIncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  final IncidentSummaryModel incident;
  final VoidCallback onTap;

  IncidentStatus _mapStatus(String status) {
    return switch (status) {
      'verified' => IncidentStatus.verified,
      'resolution_submitted' => IncidentStatus.resolutionSubmitted,
      'resolved' => IncidentStatus.resolved,
      'rejected' => IncidentStatus.rejected,
      _ => IncidentStatus.unverified,
    };
  }

  IconData _disasterIcon(String type) {
    return switch (type) {
      'flood' => Icons.tsunami_rounded,
      'earthquake' => Icons.public_rounded,
      'landslide' => Icons.landslide_rounded,
      'fire' => Icons.local_fire_department_rounded,
      _ => Icons.warning_amber_rounded,
    };
  }

  String _relativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Baru saja';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final mappedStatus = _mapStatus(incident.status);
    final isResolved = mappedStatus == IncidentStatus.resolved;
    final locationText = (incident.address != null &&
            incident.address!.trim().isNotEmpty)
        ? incident.address!
        : '${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}';

    return Material(
      color: AppColors.surfaceCard,
      borderRadius: AppRadius.roundedLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedLg,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.level1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Category chip + Status chip
              Wrap(
                spacing: AppSpacing.spaceXs,
                runSpacing: AppSpacing.spaceXs,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: AppSpacing.statusChipMinHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.roundedStandard,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _disasterIcon(incident.disasterType),
                          size: 15,
                          color: AppColors.textHeader,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          incident.disasterTypeLabel.isNotEmpty
                              ? incident.disasterTypeLabel
                              : incident.disasterType,
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textHeader,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IncidentStatusChip(
                    status: mappedStatus,
                    customLabel: incident.statusLabel.isNotEmpty
                        ? incident.statusLabel.toUpperCase()
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceSm),

              // Title
              Text(
                incident.title,
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.textHeader,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),

              // Location line
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.pin_drop_rounded,
                    size: 18,
                    color: isResolved
                        ? AppColors.statusResolved
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      locationText,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceSm),

              // Description highlight box
              if (incident.description.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.spaceXs),
                  decoration: BoxDecoration(
                    color: isResolved
                        ? AppColors.statusResolvedBg.withValues(alpha: 0.45)
                        : AppColors.surfaceContainerLow,
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isResolved
                            ? Icons.verified_rounded
                            : Icons.info_outline_rounded,
                        size: 18,
                        color: isResolved
                            ? AppColors.statusResolved
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          incident.description,
                          style: AppTypography.bodySm.copyWith(
                            color: isResolved
                                ? const Color(0xFF15803D)
                                : AppColors.textHeader,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.spaceSm),

              // Footer meta: reports count & relative time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.statusResolutionBg,
                      borderRadius: AppRadius.roundedFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.campaign_rounded,
                          size: 15,
                          color: AppColors.textHeader,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${incident.reportsCount > 0 ? incident.reportsCount : 1} Laporan Warga Tergabung',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textHeader,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _relativeTime(incident.createdAt),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu penenang ramah lansia yang menampilkan info Posko Siaga / Safe Zone.
class SafeZoneReassuranceCard extends StatelessWidget {
  const SafeZoneReassuranceCard({
    super.key,
    required this.safeZones,
  });

  final List<SafeZoneModel> safeZones;

  @override
  Widget build(BuildContext context) {
    final firstZone = safeZones.isNotEmpty ? safeZones.first : null;
    final subtitle = firstZone != null
        ? 'Posko siaga terdekat (${firstZone.name}) siap siaga 24 jam${firstZone.address != null ? ' di ${firstZone.address}' : ''}.'
        : 'Posko siaga terdekat siap siaga 24 jam untuk membantu warga sekitar.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.statusResolutionBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.statusResolution,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kondisi Wilayah Terpantau Stabil',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textHeader,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
