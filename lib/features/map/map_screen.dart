import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import 'map_notifier.dart';
import 'map_state.dart';
import 'widgets/incident_pin.dart';
import 'widgets/incident_preview_sheet.dart';
import 'widgets/map_controls.dart';
import 'widgets/map_filter_chips.dart';
import 'widgets/map_header.dart';
import 'widgets/map_search_bar.dart';
import 'widgets/safe_zone_pin.dart';
import 'widgets/user_location_pin.dart';

/// Peta bencana interaktif: tap pin → reload detail → bottom sheet.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late final MapController _controller = MapController.withPosition(
    initPosition: MapData.demoCenter,
  );

  bool _mapReady = false;
  final List<GeoPoint> _markerPoints = <GeoPoint>[];
  Future<void> _pendingSync = Future.value();

  /// Sinkronisasi di-antre agar filter cepat tidak menumpuk/duplikat marker.
  void _syncMarkers(MapData data) {
    _pendingSync = _pendingSync.then((_) => _syncMarkersNow(data));
  }

  Future<void> _syncMarkersNow(MapData data) async {
    if (!_mapReady) return;
    final previous = List<GeoPoint>.from(_markerPoints);
    _markerPoints.clear();

    if (previous.isNotEmpty) {
      try {
        await _controller.removeMarkers(previous);
      } catch (_) {
        // Marker mungkin belum terpasang pada platform native.
      }
    }

    // Posko dipasang lebih dulu agar menang bila koordinatnya beririsan.
    for (final zone in data.safeZones) {
      await _addMarkerOnce(
        data.pointOfSafeZone(zone),
        MarkerIcon(
          key: ValueKey(data.safeZoneMarkerId(zone)),
          iconWidget: SafeZonePin(type: zone.type),
        ),
      );
    }

    for (final incident in data.filteredIncidents) {
      await _addMarkerOnce(
        data.pointOf(incident),
        MarkerIcon(
          key: ValueKey('incident_${incident.id}'),
          iconWidget: IncidentPin(
            disasterType: incident.disasterType,
            status: incident.status,
            reportsCount: incident.reportsCount,
            isSelected: data.selectedIncidentId == incident.id,
          ),
        ),
      );
    }

    final position = data.userPosition;
    final userPoint = position != null
        ? GeoPoint(
            latitude: position.latitude,
            longitude: position.longitude,
          )
        : MapData.demoCenter;
    await _addMarkerOnce(
      userPoint,
      MarkerIcon(
        key: const ValueKey('user_location'),
        iconWidget: UserLocationPin(isDemo: position == null),
      ),
    );
  }

  Future<void> _addMarkerOnce(GeoPoint point, MarkerIcon icon) async {
    if (_markerPoints.contains(point)) return;
    try {
      await _controller.addMarker(point, markerIcon: icon);
      _markerPoints.add(point);
    } catch (_) {
      // Lanjutkan ke marker berikutnya bila satu gagal dipasang.
    }
  }

  Future<void> _onPinClicked(GeoPoint point) async {
    final notifier = ref.read(mapProvider.notifier);
    final zone = notifier.findSafeZoneByPoint(point);
    if (zone != null) {
      final address = zone.address?.trim() ?? '';
      final message = address.isEmpty ? zone.name : '${zone.name} • $address';
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
      return;
    }
    final incidentId = notifier.findIncidentIdByPoint(point);
    if (incidentId == null) return;
    await notifier.selectIncident(incidentId);
  }

  Future<void> _locate() async {
    await ref.read(mapProvider.notifier).refreshLocation();
    final position = ref.read(mapProvider).value?.userPosition;
    final target = position != null
        ? GeoPoint(
            latitude: position.latitude,
            longitude: position.longitude,
          )
        : MapData.demoCenter;
    await _controller.moveTo(target, animate: true);
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod 3: ref.listen harus dipanggil di dalam build, bukan initState.
    ref.listen(mapProvider, (_, next) {
      final data = next.value;
      if (data != null) _syncMarkers(data);
    });

    final mapAsync = ref.watch(mapProvider);
    final data = mapAsync.value ?? const MapData();
    final selectedDetail = data.selectedDetail;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: OSMFlutter(
                controller: _controller,
                osmOption: const OSMOption(
                  showZoomController: false,
                  enableRotationByGesture: false,
                  zoomOption: ZoomOption(
                    initZoom: MapData.demoZoom,
                    minZoomLevel: 4,
                    maxZoomLevel: 19,
                  ),
                ),
                mapIsLoading: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                onMapIsReady: (ready) {
                  setState(() => _mapReady = ready);
                  if (ready) _syncMarkers(ref.read(mapProvider).value ?? const MapData());
                },
                onGeoPointClicked: _onPinClicked,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const MapHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.margin,
                      AppSpacing.spaceXs,
                      AppSpacing.margin,
                      0,
                    ),
                    child: MapSearchBar(
                      query: data.searchQuery,
                      onSearch: ref.read(mapProvider.notifier).setSearch,
                      onClear: ref.read(mapProvider.notifier).clearSearch,
                      onLocate: _locate,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.margin,
                      AppSpacing.spaceXs,
                      0,
                      0,
                    ),
                    child: MapFilterChips(
                      counts: data.statusCounts,
                      activeFilter: data.activeStatusFilter,
                      onSelected: ref.read(mapProvider.notifier).setStatusFilter,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: AppSpacing.margin,
              bottom: AppSpacing.spaceMd,
              child: MapControls(
                onZoomIn: () => _controller.zoomIn(),
                onZoomOut: () => _controller.zoomOut(),
                onLocate: _locate,
              ),
            ),
            if (selectedDetail != null || data.isDetailLoading)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IncidentPreviewSheet(
                  detail: selectedDetail,
                  isLoading: data.isDetailLoading,
                  userPosition: data.userPosition,
                  onClose: ref.read(mapProvider.notifier).clearSelection,
                ),
              ),
            if (mapAsync.isLoading)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            if (mapAsync.hasError)
              Positioned.fill(
                child: Container(
                  color: AppColors.surfaceCanvas.withValues(alpha: 0.92),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.marginLg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: AppSpacing.spaceSm),
                          Text(
                            'Gagal memuat peta bencana',
                            style: AppTypography.headlineSm.copyWith(
                              color: AppColors.textHeader,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceMd),
                          FilledButton.icon(
                            onPressed: () => ref.invalidate(mapProvider),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
