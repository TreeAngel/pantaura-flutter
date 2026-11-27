import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/models/api_models.dart';
import '../../../../core/theme/theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  4. LOCATION CARD + STATIC MAP
// ═══════════════════════════════════════════════════════════════════════════

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.incident, required this.onOpenMap});

  final IncidentDetailModel incident;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final address = incident.address?.trim();
    final displayAddress = (address != null && address.isNotEmpty)
        ? address
        : 'Lat: ${incident.latitude.toStringAsFixed(5)}, '
              'Lng: ${incident.longitude.toStringAsFixed(5)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spaceMd,
                AppSpacing.spaceMd,
                AppSpacing.spaceMd,
                AppSpacing.spaceXs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.statusVerified,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Expanded(
                    child: Text(
                      displayAddress,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.minTouchTarget,
                child: OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.near_me_rounded),
                  label: const Text('Buka di Peta'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Stack(
              children: [
                SizedBox(
                  height: 176,
                  width: double.infinity,
                  child: _StaticOsmPreview(
                    latitude: incident.latitude,
                    longitude: incident.longitude,
                  ),
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
                      color: AppColors.surfaceCard.withValues(alpha: 0.9),
                      borderRadius: AppRadius.roundedStandard,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.space2xs),
                        Text(
                          '${incident.latitude.toStringAsFixed(4)}, '
                          '${incident.longitude.toStringAsFixed(4)}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTintIce.withValues(alpha: 0.6),
                  borderRadius: AppRadius.roundedMd,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.statusResolution,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: AppColors.onPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Multiple Reports, One Incident',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textHeader,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Digabungkan dari ${incident.reportsCount} laporan warga & relawan untuk penanganan terpadu.',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticOsmPreview extends StatefulWidget {
  const _StaticOsmPreview({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<_StaticOsmPreview> createState() => _StaticOsmPreviewState();
}

class _StaticOsmPreviewState extends State<_StaticOsmPreview> {
  late final MapController _controller;

  @override
  void initState() {
    super.initState();
    final center = GeoPoint(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
    _controller = MapController.withPosition(
      initPosition: center,
      areaLimit: BoundingBox.fromCenter(center, 0.001),
    );
  }

  @override
  void didUpdateWidget(covariant _StaticOsmPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      final center = GeoPoint(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      _controller.moveTo(center);
      _controller.limitAreaMap(BoundingBox.fromCenter(center, 0.001));
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = GeoPoint(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );

    // AbsorbPointer + minZoom == maxZoom + areaLimit menjaga peta tetap statis.
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
              'incident_location',
              const MarkerIcon(
                icon: Icon(
                  Icons.location_pin,
                  color: AppColors.statusVerified,
                  size: 48,
                ),
              ),
              [center],
            ),
          ],
        ),
      ),
    );
  }
}
