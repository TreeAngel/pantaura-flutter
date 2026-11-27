import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/models/api_models.dart';
import '../../../../core/theme/theme.dart';
import '../add_report_state.dart';
import 'section_step_header.dart';

/// Section 1: Validasi posisi GPS user & peta statis titik utama vs posisi user.
class LocationSection extends StatelessWidget {
  const LocationSection({
    super.key,
    required this.incident,
    required this.userPosition,
    required this.distanceMeters,
    required this.isLocationValid,
    required this.isRefreshing,
    required this.onRefreshGps,
  });

  final IncidentDetailModel incident;
  final Position? userPosition;
  final double? distanceMeters;
  final bool isLocationValid;
  final bool isRefreshing;
  final VoidCallback onRefreshGps;

  IconData _disasterIcon(String type) => switch (type.toLowerCase()) {
        'flood' => Icons.water_rounded,
        'earthquake' => Icons.waves_rounded,
        'landslide' => Icons.landslide_rounded,
        'fire' => Icons.local_fire_department_rounded,
        _ => Icons.warning_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final incidentPoint = GeoPoint(
      latitude: incident.latitude,
      longitude: incident.longitude,
    );
    final position = userPosition;
    final userPoint = position != null
        ? GeoPoint(latitude: position.latitude, longitude: position.longitude)
        : null;
    final mapCenter = userPoint != null
        ? GeoPoint(
            latitude: (incidentPoint.latitude + userPoint.latitude) / 2,
            longitude: (incidentPoint.longitude + userPoint.longitude) / 2,
          )
        : incidentPoint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionStepHeader(
            stepNumber: '1',
            title: 'Posisi Anda Saat Ini',
            badgeText: 'Wajib',
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          _RadiusStatusBanner(
            distanceMeters: distanceMeters,
            isLocationValid: isLocationValid,
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceXs),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.roundedLg,
              boxShadow: AppShadows.level1,
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.roundedStandard,
                  child: SizedBox(
                    height: 176,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        _StaticOsmReportPreview(
                          key: ValueKey(
                            '${incidentPoint.latitude},${incidentPoint.longitude}_'
                            '${userPoint?.latitude},${userPoint?.longitude}',
                          ),
                          center: mapCenter,
                          incidentPoint: incidentPoint,
                          incidentIcon: _disasterIcon(incident.disasterType),
                          userPoint: userPoint,
                          distanceMeters: distanceMeters,
                        ),
                        Positioned(
                          left: AppSpacing.spaceXs,
                          bottom: AppSpacing.spaceXs,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spaceXs,
                              vertical: AppSpacing.space2xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard.withValues(alpha: 0.92),
                              borderRadius: AppRadius.roundedSm,
                              boxShadow: AppShadows.level1,
                            ),
                            child: Text(
                              position != null
                                  ? 'GPS: ${position.latitude.toStringAsFixed(4)}, '
                                      '${position.longitude.toStringAsFixed(4)}'
                                  : 'GPS: ${incident.latitude.toStringAsFixed(4)}, '
                                      '${incident.longitude.toStringAsFixed(4)}',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textHeader,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.minTouchTarget,
                  child: FilledButton.tonalIcon(
                    onPressed: isRefreshing ? null : onRefreshGps,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surfaceTintIce,
                      foregroundColor: AppColors.primary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedStandard,
                      ),
                    ),
                    icon: isRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.sync_rounded, size: 18),
                    label: Text(
                      isRefreshing ? 'Memperbarui GPS...' : 'Segarkan GPS',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceXs,
                  ),
                  child: Text(
                    'Otomatis mengunci koordinat GPS perangkat Anda untuk mencegah pelaporan palsu.',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadiusStatusBanner extends StatelessWidget {
  const _RadiusStatusBanner({
    required this.distanceMeters,
    required this.isLocationValid,
  });

  final double? distanceMeters;
  final bool isLocationValid;

  @override
  Widget build(BuildContext context) {
    final distance = distanceMeters;
    if (distance == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.statusUnverifiedBg,
          borderRadius: AppRadius.roundedMd,
          boxShadow: AppShadows.level1,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.gps_not_fixed_rounded,
              color: AppColors.statusUnverified,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.spaceXs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menunggu Koordinat GPS',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.statusUnverified,
                    ),
                  ),
                  Text(
                    'Ketuk Segarkan GPS untuk memverifikasi jarak (Maks. ${kMaxReportRadiusMeters.toInt()}m).',
                    style: AppTypography.bodySm,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final rounded = distance.round();
    final isWithinDisasterRadius = distance <= kMaxReportRadiusMeters;
    final bgColor =
        isLocationValid ? AppColors.statusResolvedBg : AppColors.statusVerifiedBg;
    final headerColor =
        isLocationValid ? AppColors.statusResolved : AppColors.statusVerified;
    final distanceTextColor = isWithinDisasterRadius
        ? AppColors.statusVerified
        : AppColors.statusResolved;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.roundedMd,
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        children: [
          Icon(Icons.near_me_rounded, color: headerColor, size: 24),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocationValid
                      ? 'Dalam Radius Aman Insiden'
                      : 'Di Luar Radius Laporan (Maks. ${kMaxReportRadiusMeters.toInt()}m)',
                  style: AppTypography.labelMd.copyWith(color: headerColor),
                ),
                Text(
                  'Berjarak ~$rounded meter dari titik utama (Maks. ${kMaxReportRadiusMeters.toInt()}m)',
                  style: AppTypography.bodySm.copyWith(
                    color: distanceTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainIncidentPin extends StatelessWidget {
  const _MainIncidentPin({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.statusVerified,
            borderRadius: AppRadius.roundedSm,
            boxShadow: AppShadows.level2,
          ),
          child: Text(
            'Titik Utama',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.statusVerified,
            shape: BoxShape.circle,
            boxShadow: AppShadows.level2,
          ),
          child: Icon(icon, color: AppColors.onPrimary, size: 18),
        ),
      ],
    );
  }
}

class _UserGpsPin extends StatelessWidget {
  const _UserGpsPin({required this.distanceMeters});

  final double? distanceMeters;

  @override
  Widget build(BuildContext context) {
    final distance = distanceMeters;
    final label = distance != null
        ? 'Posisi Anda (~${distance.round()}m)'
        : 'Posisi Anda';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: AppShadows.level2,
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: AppColors.onPrimary,
            size: 16,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.roundedSm,
            boxShadow: AppShadows.level2,
          ),
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StaticOsmReportPreview extends StatefulWidget {
  const _StaticOsmReportPreview({
    super.key,
    required this.center,
    required this.incidentPoint,
    required this.incidentIcon,
    required this.userPoint,
    required this.distanceMeters,
  });

  final GeoPoint center;
  final GeoPoint incidentPoint;
  final IconData incidentIcon;
  final GeoPoint? userPoint;
  final double? distanceMeters;

  @override
  State<_StaticOsmReportPreview> createState() =>
      _StaticOsmReportPreviewState();
}

class _StaticOsmReportPreviewState extends State<_StaticOsmReportPreview> {
  late final MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapController.withPosition(
      initPosition: widget.center,
      areaLimit: BoundingBox.fromCenter(widget.center, 0.005),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPoint = widget.userPoint;
    return AbsorbPointer(
      child: OSMFlutter(
        controller: _controller,
        mapIsLoading: const Center(child: CircularProgressIndicator()),
        osmOption: OSMOption(
          showZoomController: false,
          enableRotationByGesture: false,
          zoomOption: const ZoomOption(
            initZoom: 15,
            minZoomLevel: 15,
            maxZoomLevel: 15,
          ),
          staticPoints: [
            StaticPositionGeoPoint(
              'incident_main',
              MarkerIcon(
                iconWidget: _MainIncidentPin(icon: widget.incidentIcon),
              ),
              [widget.incidentPoint],
            ),
            if (userPoint != null)
              StaticPositionGeoPoint(
                'user_position',
                MarkerIcon(
                  iconWidget: _UserGpsPin(
                    distanceMeters: widget.distanceMeters,
                  ),
                ),
                [userPoint],
              ),
          ],
        ),
      ),
    );
  }
}
