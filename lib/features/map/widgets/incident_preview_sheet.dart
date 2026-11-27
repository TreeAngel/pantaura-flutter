import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/api_models.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/incident_status_chip.dart';
import 'incident_pin.dart';

/// Bottom sheet pratinjau insiden; isi selalu berasal dari detail terbaru.
class IncidentPreviewSheet extends StatelessWidget {
  const IncidentPreviewSheet({
    super.key,
    required this.detail,
    required this.isLoading,
    required this.userPosition,
    required this.onClose,
  });

  final IncidentDetailModel? detail;
  final bool isLoading;
  final Position? userPosition;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final incident = detail;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.46,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
          boxShadow: AppShadows.level4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margin,
                AppSpacing.spaceXs,
                AppSpacing.spaceXs,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onClose,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 24,
                        alignment: Alignment.center,
                        child: Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.outlineVariant,
                            borderRadius: AppRadius.roundedFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.onSurfaceVariant,
                    tooltip: 'Tutup pratinjau',
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.space2xs,
                  AppSpacing.margin,
                  AppSpacing.spaceMd,
                ),
                child: isLoading || incident == null
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.spaceLg),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : _SheetContent(
                        incident: incident,
                        userPosition: userPosition,
                        onOpenDetail: () => context
                            .push(AppRoutes.incidentDetail(incident.id)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.incident,
    required this.userPosition,
    required this.onOpenDetail,
  });

  final IncidentDetailModel incident;
  final Position? userPosition;
  final VoidCallback onOpenDetail;

  static IncidentStatus _parseStatus(String status) => switch (status) {
        'verified' => IncidentStatus.verified,
        'resolution_submitted' => IncidentStatus.resolutionSubmitted,
        'resolved' => IncidentStatus.resolved,
        'rejected' => IncidentStatus.rejected,
        _ => IncidentStatus.unverified,
      };

  static MediaModel? _firstMedia(IncidentDetailModel incident) {
    for (final report in incident.reports) {
      if (report.media.isNotEmpty) return report.media.first;
    }
    for (final resolution in incident.resolutions) {
      if (resolution.media.isNotEmpty) return resolution.media.first;
    }
    return null;
  }

  static String _relativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'baru saja';
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mnt lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }

  String _distanceLabel() {
    final position = userPosition;
    if (position == null) return '-';
    final meters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      incident.latitude,
      incident.longitude,
    );
    if (meters < 1000) return '${meters.round()} m dari Anda';
    return '${(meters / 1000).toStringAsFixed(1)} km dari Anda';
  }

  @override
  Widget build(BuildContext context) {
    final media = _firstMedia(incident);
    final address = incident.address?.trim();
    final displayAddress = (address != null && address.isNotEmpty)
        ? address
        : 'Lat: ${incident.latitude.toStringAsFixed(5)}, '
            'Lng: ${incident.longitude.toStringAsFixed(5)}';
    final updatedAt = incident.verifiedAt ?? incident.createdAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.spaceXs,
          runSpacing: AppSpacing.spaceXs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IncidentStatusChip(
              status: _parseStatus(incident.status),
              customLabel: incident.statusLabel.isEmpty
                  ? 'TERKONFIRMASI AKTIF'
                  : incident.statusLabel.toUpperCase(),
            ),
            Container(
              constraints:
                  const BoxConstraints(minHeight: AppSpacing.statusChipMinHeight),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusResolutionBg,
                borderRadius: AppRadius.roundedStandard,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    disasterIcon(incident.disasterType),
                    size: 14,
                    color: AppColors.statusResolution,
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Text(
                    incident.disasterTypeLabel.isEmpty
                        ? 'Insiden'
                        : incident.disasterTypeLabel,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.statusResolution,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadius.roundedFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.space2xs),
                  Text(
                    _distanceLabel(),
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Text(
          incident.title,
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.textHeader,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.space2xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.space2xs),
            Expanded(
              child: Text(
                displayAddress,
                style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadius.roundedMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAMPAK TERPAU',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Text(
                      incident.description,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.spaceXs),
                    Row(
                      children: [
                        const Icon(Icons.groups_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.space2xs),
                        Flexible(
                          child: Text(
                            '${incident.reportsCount} Laporan Warga • '
                            '${_relativeTime(updatedAt)}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              ClipRRect(
                borderRadius: AppRadius.roundedSm,
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (media == null)
                        Image.asset(
                          'assets/images/data-not-found.png',
                          fit: BoxFit.cover,
                        )
                      else
                        Image.network(
                          media.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset(
                            'assets/images/data-not-found.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textHeader.withValues(alpha: 0.85),
                            borderRadius: AppRadius.roundedSm,
                          ),
                          child: Text(
                            'Valid',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onPrimary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: onOpenDetail,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Lihat Detail Insiden'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.roundedMd,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
