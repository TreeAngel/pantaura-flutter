import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/models/api_models.dart';
import '../../core/providers.dart';
import 'map_state.dart';

/// Memuat marker insiden dan detail insiden yang dipilih dari peta.
class MapNotifier extends AsyncNotifier<MapData> {
  static const double _pointTolerance = 0.00001;

  @override
  Future<MapData> build() async {
    final (incidents, safeZones) = await (
      ref.read(incidentServiceProvider).getIncidentsMap(),
      ref
          .read(safeZoneServiceProvider)
          .getSafeZones()
          .catchError((_) => <SafeZoneModel>[]),
    ).wait;
    return MapData(incidents: incidents, safeZones: safeZones);
  }

  /// Pin ditap → simpan id → ambil detail terbaru → bottom sheet reload.
  Future<void> selectIncident(String incidentId) async {
    final current = state.value;
    if (current == null || current.selectedIncidentId == incidentId) return;

    state = AsyncData(
      current.copyWith(
        selectedIncidentId: incidentId,
        clearSelectedDetail: true,
        isDetailLoading: true,
      ),
    );

    try {
      final detail = await ref
          .read(incidentServiceProvider)
          .getIncidentDetail(incidentId);
      final latest = state.value;
      if (latest == null || latest.selectedIncidentId != incidentId) return;
      state = AsyncData(
        latest.copyWith(selectedDetail: detail, isDetailLoading: false),
      );
    } catch (_) {
      final latest = state.value;
      if (latest == null || latest.selectedIncidentId != incidentId) return;
      state = AsyncData(
        latest.copyWith(
          clearSelectedDetail: true,
          isDetailLoading: false,
        ),
      );
    }
  }

  static bool _isSamePoint(GeoPoint a, GeoPoint b) =>
      (a.latitude - b.latitude).abs() < _pointTolerance &&
      (a.longitude - b.longitude).abs() < _pointTolerance;

  /// `onGeoPointClicked` hanya mengembalikan koordinat, bukan id marker.
  /// Titik posko sengaja diabaikan agar tidak membuka sheet insiden.
  String? findIncidentIdByPoint(GeoPoint point) {
    final current = state.value;
    if (current == null) return null;
    final safeZonePoints = current.safeZones.map(current.pointOfSafeZone).toList();
    for (final incident in current.incidents) {
      final incidentPoint = current.pointOf(incident);
      if (!_isSamePoint(incidentPoint, point)) continue;
      if (safeZonePoints.any((zone) => _isSamePoint(zone, incidentPoint))) {
        continue;
      }
      return incident.id;
    }
    return null;
  }

  /// Dipakai screen untuk snackbar ringkas nama + alamat posko.
  SafeZoneModel? findSafeZoneByPoint(GeoPoint point) {
    final current = state.value;
    if (current == null) return null;
    for (final zone in current.safeZones) {
      if (_isSamePoint(current.pointOfSafeZone(zone), point)) return zone;
    }
    return null;
  }

  void setStatusFilter(String? status) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        activeStatusFilter: status,
        clearStatusFilter: status == null,
      ),
    );
  }

  void setSearch(String query) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  void clearSearch() => setSearch('');

  void clearSelection() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        clearSelection: true,
        clearSelectedDetail: true,
        isDetailLoading: false,
      ),
    );
  }

  /// GPS opsional; gagal/denied tetap memakai titik demo.
  Future<void> refreshLocation() async {
    final current = state.value;
    if (current == null) return;
    try {
      final status = await ref
          .read(permissionServiceProvider)
          .requestLocationPermission();
      if (!status.isGranted) return;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      state = AsyncData(current.copyWith(userPosition: position));
    } catch (_) {
      // Biarkan posisi demo tetap dipakai.
    }
  }
}

final mapProvider = AsyncNotifierProvider<MapNotifier, MapData>(MapNotifier.new);
