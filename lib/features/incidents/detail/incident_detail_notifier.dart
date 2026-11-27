import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/api_models.dart';
import '../../../core/providers.dart';
import 'incident_detail_state.dart';

/// Notifier untuk memuat dan memanipulasi data halaman detail insiden.
///
/// Riverpod 3 tidak lagi memiliki `FamilyAsyncNotifier`; argumen family
/// diterima langsung melalui konstruktor notifier.
class IncidentDetailNotifier extends AsyncNotifier<IncidentDetailData> {
  IncidentDetailNotifier(this.incidentId);

  final String incidentId;

  @override
  Future<IncidentDetailData> build() => _load(incidentId);

  Future<IncidentDetailData> _load(String incidentId) async {
    final incidentService = ref.read(incidentServiceProvider);
    final safeZoneService = ref.read(safeZoneServiceProvider);

    // Fetch paralel: detail insiden + daftar posko.
    final (incident, safeZones) = await (
      incidentService.getIncidentDetail(incidentId),
      safeZoneService.getSafeZones().catchError((_) => <SafeZoneModel>[]),
    ).wait;

    final nearest = _findNearestSafeZone(
      safeZones.where((zone) => zone.isActive).toList(),
      incident.latitude,
      incident.longitude,
    );

    return IncidentDetailData(
      incident: incident,
      timeline: _buildTimeline(incident, ascending: true),
      allMedia: _buildMediaList(incident),
      nearestSafeZone: nearest.zone,
      nearestSafeZoneDistanceKm: nearest.distanceKm,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<TimelineEntry> _buildTimeline(
    IncidentDetailModel incident, {
    required bool ascending,
  }) {
    final entries = <TimelineEntry>[
      ...incident.reports.map(TimelineEntry.fromReport),
      ...incident.resolutions.map(TimelineEntry.fromResolution),
    ];
    entries.sort((a, b) {
      final timeA = a.createdAt ?? DateTime(0);
      final timeB = b.createdAt ?? DateTime(0);
      return ascending ? timeA.compareTo(timeB) : timeB.compareTo(timeA);
    });
    return entries;
  }

  /// Media digabung dari report + resolution, diurutkan dari yang pertama diunggah.
  List<MediaItem> _buildMediaList(IncidentDetailModel incident) {
    final items = <MediaItem>[];
    for (final report in incident.reports) {
      for (final media in report.media) {
        items.add(
          MediaItem(media: media, parentDescription: report.description),
        );
      }
    }
    for (final resolution in incident.resolutions) {
      for (final media in resolution.media) {
        items.add(
          MediaItem(media: media, parentDescription: resolution.description),
        );
      }
    }
    items.sort((a, b) {
      final timeA = a.media.createdAt ?? DateTime(0);
      final timeB = b.media.createdAt ?? DateTime(0);
      return timeA.compareTo(timeB);
    });
    return items;
  }

  /// Jarak Euclidean (approx. 1 derajat ≈ 111 km) dari titik insiden.
  ({SafeZoneModel? zone, double? distanceKm}) _findNearestSafeZone(
    List<SafeZoneModel> zones,
    double latitude,
    double longitude,
  ) {
    if (zones.isEmpty) return (zone: null, distanceKm: null);

    SafeZoneModel? nearest;
    var minDistance = double.infinity;
    for (final zone in zones) {
      final dLat = zone.latitude - latitude;
      final dLng = zone.longitude - longitude;
      final distance = math.sqrt(dLat * dLat + dLng * dLng);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = zone;
      }
    }
    return (zone: nearest, distanceKm: minDistance * 111.0);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Balik urutan kronologi (asc ↔ desc).
  void toggleSort() {
    final current = state.value;
    if (current == null) return;
    final ascending = !current.isSortAscending;
    state = AsyncData(
      current.copyWith(
        timeline: _buildTimeline(current.incident, ascending: ascending),
        isSortAscending: ascending,
      ),
    );
  }

  /// Tampilkan 10 media berikutnya di grid thumbnail.
  void showMoreMedia() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(visibleMediaCount: current.visibleMediaCount + 10),
    );
  }

  /// Konfirmasi kerumunan, lalu muat ulang data terbaru.
  Future<void> toggleConfirm(String incidentId) async {
    final current = state.value;
    if (current == null || current.isConfirmLoading) return;

    state = AsyncData(current.copyWith(isConfirmLoading: true));
    try {
      await ref.read(incidentServiceProvider).toggleConfirm(incidentId);
      final refreshed = await _load(incidentId);
      state = AsyncData(refreshed.copyWith(isConfirmLoading: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isConfirmLoading: false));
    }
  }
}

final incidentDetailProvider =
    AsyncNotifierProvider.family<IncidentDetailNotifier, IncidentDetailData, String>(
  IncidentDetailNotifier.new,
);
