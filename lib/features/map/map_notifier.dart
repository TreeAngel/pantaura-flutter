import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/providers.dart';
import 'map_state.dart';

/// Memuat marker insiden dan detail insiden yang dipilih dari peta.
class MapNotifier extends AsyncNotifier<MapData> {
  static const double _pointTolerance = 0.00001;

  @override
  Future<MapData> build() async {
    final incidents = await ref.read(incidentServiceProvider).getIncidentsMap();
    return MapData(incidents: incidents);
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

  /// `onGeoPointClicked` hanya mengembalikan koordinat, bukan id marker.
  String? findIncidentIdByPoint(GeoPoint point) {
    final incidents = state.value?.incidents ?? [];
    for (final incident in incidents) {
      if ((incident.latitude - point.latitude).abs() < _pointTolerance &&
          (incident.longitude - point.longitude).abs() < _pointTolerance) {
        return incident.id;
      }
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
