import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/api_models.dart';
import '../../core/providers.dart';
import 'incident_detail_state.dart';

class IncidentDetailNotifier extends FamilyAsyncNotifier<IncidentDetailData, String> {
  @override
  Future<IncidentDetailData> build(String arg) async {
    return _load(arg);
  }

  Future<IncidentDetailData> _load(String incidentId) async {
    final incidentService = ref.read(incidentServiceProvider);
    final safeZoneService = ref.read(safeZoneServiceProvider);

    final (incident, safeZones) = await (
      incidentService.getIncidentDetail(incidentId),
      safeZoneService.getSafeZones().catchError((_) => <SafeZoneModel>[]),
    ).wait;

    final timeline = _buildTimeline(incident, ascending: true);
    final allMedia = _buildMediaList(incident);
    final nearestSafeZone = _findNearest(safeZones, incident.latitude, incident.longitude);

    return IncidentDetailData(
      incident: incident,
      timeline: timeline,
      allMedia: allMedia,
      nearestSafeZone: nearestSafeZone,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<TimelineEntry> _buildTimeline(IncidentDetailModel incident, {required bool ascending}) {
    final entries = [
      ...incident.reports.map(TimelineEntry.fromReport),
      ...incident.resolutions.map(TimelineEntry.fromResolution),
    ];
    entries.sort((a, b) {
      final ta = a.createdAt ?? DateTime(0);
      final tb = b.createdAt ?? DateTime(0);
      return ascending ? ta.compareTo(tb) : tb.compareTo(ta);
    });
    return entries;
  }

  List<MediaItem> _buildMediaList(IncidentDetailModel incident) {
    final items = <MediaItem>[];
    for (final report in incident.reports) {
      for (final media in report.media) {
        items.add(MediaItem(media: media, parentDescription: report.description));
      }
    }
    for (final resolution in incident.resolutions) {
      for (final media in resolution.media) {
        items.add(MediaItem(media: media, parentDescription: resolution.description));
      }
    }
    items.sort((a, b) {
      final ta = a.media.createdAt ?? DateTime(0);
      final tb = b.media.createdAt ?? DateTime(0);
      return ta.compareTo(tb);
    });
    return items;
  }

  SafeZoneModel? _findNearest(List<SafeZoneModel> zones, double lat, double lng) {
    if (zones.isEmpty) return null;
    SafeZoneModel? nearest;
    double minDist = double.infinity;
    for (final z in zones) {
      final dlat = z.latitude - lat;
      final dlng = z.longitude - lng;
      final dist = math.sqrt(dlat * dlat + dlng * dlng);
      if (dist < minDist) {
        minDist = dist;
        nearest = z;
      }
    }
    return nearest;
  }

  // ── Public actions ────────────────────────────────────────────────────────

  void toggleSort() {
    final current = state.value;
    if (current == null) return;
    final newAsc = !current.isSortAscending;
    final sorted = _buildTimeline(current.incident, ascending: newAsc);
    state = AsyncData(current.copyWith(timeline: sorted, isSortAscending: newAsc));
  }

  void showMoreMedia() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(visibleMediaCount: current.visibleMediaCount + 10));
  }

  Future<void> toggleConfirm(String incidentId) async {
    final current = state.value;
    if (current == null || current.isConfirmLoading) return;

    state = AsyncData(current.copyWith(isConfirmLoading: true));
    try {
      await ref.read(incidentServiceProvider).toggleConfirm(incidentId);
      // Reload fresh data after confirm
      state = AsyncData((await _load(incidentId)).copyWith(isConfirmLoading: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isConfirmLoading: false));
    }
  }
}

final incidentDetailProvider =
    AsyncNotifierProvider.family<IncidentDetailNotifier, IncidentDetailData, String>(
  IncidentDetailNotifier.new,
);
