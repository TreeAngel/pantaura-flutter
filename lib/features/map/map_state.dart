import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/models/api_models.dart';

/// State immutable halaman peta bencana interaktif.
class MapData {
  /// Titik awal demo ( Jakarta Timur ) agar peta langsung terisi saat dibuka.
  static final GeoPoint demoCenter = GeoPoint(
    latitude: -6.19099,
    longitude: 106.84264,
  );
  static const double demoZoom = 15.0;

  const MapData({
    this.incidents = const [],
    this.safeZones = const [],
    this.selectedIncidentId,
    this.selectedDetail,
    this.isDetailLoading = false,
    this.userPosition,
    this.activeStatusFilter,
    this.searchQuery = '',
  });

  final List<IncidentSummaryModel> incidents;

  /// Posko/titik aman — tidak ikut filter status insiden.
  final List<SafeZoneModel> safeZones;
  final String? selectedIncidentId;
  final IncidentDetailModel? selectedDetail;
  final bool isDetailLoading;
  final Position? userPosition;
  final String? activeStatusFilter;
  final String searchQuery;

  GeoPoint pointOf(IncidentSummaryModel incident) => GeoPoint(
        latitude: incident.latitude,
        longitude: incident.longitude,
      );

  GeoPoint pointOfSafeZone(SafeZoneModel zone) => GeoPoint(
        latitude: zone.latitude,
        longitude: zone.longitude,
      );

  /// Id marker posko memakai prefix agar tidak bertabrakan dengan insiden.
  String safeZoneMarkerId(SafeZoneModel zone) => 'safezone_${zone.id}';

  /// Filter status: null = Semua, 'pending' = menunggu verifikasi + sedang diproses.
  List<IncidentSummaryModel> get filteredIncidents {
    final query = searchQuery.trim().toLowerCase();
    return incidents.where((incident) {
      if (!_matchesStatus(incident.status, activeStatusFilter)) return false;
      if (query.isEmpty) return true;
      final address = incident.address ?? '';
      return incident.title.toLowerCase().contains(query) ||
          incident.disasterTypeLabel.toLowerCase().contains(query) ||
          address.toLowerCase().contains(query);
    }).toList();
  }

  /// Jumlah untuk chip filter: semua / terverifikasi / menunggu / pulih.
  Map<String, int> get statusCounts => {
        'all': incidents.length,
        'verified': incidents
            .where((incident) => incident.status == 'verified')
            .length,
        'pending': incidents
            .where((incident) =>
                incident.status == 'unverified' ||
                incident.status == 'resolution_submitted')
            .length,
        'resolved': incidents
            .where((incident) => incident.status == 'resolved')
            .length,
      };

  static bool _matchesStatus(String status, String? filter) => switch (filter) {
        null => true,
        'verified' => status == 'verified',
        'pending' =>
          status == 'unverified' || status == 'resolution_submitted',
        'resolved' => status == 'resolved',
        _ => true,
      };

  MapData copyWith({
    List<IncidentSummaryModel>? incidents,
    List<SafeZoneModel>? safeZones,
    String? selectedIncidentId,
    bool clearSelection = false,
    IncidentDetailModel? selectedDetail,
    bool clearSelectedDetail = false,
    bool? isDetailLoading,
    Position? userPosition,
    bool clearUserPosition = false,
    String? activeStatusFilter,
    bool clearStatusFilter = false,
    String? searchQuery,
  }) {
    return MapData(
      incidents: incidents ?? this.incidents,
      safeZones: safeZones ?? this.safeZones,
      selectedIncidentId:
          clearSelection ? null : (selectedIncidentId ?? this.selectedIncidentId),
      selectedDetail: clearSelectedDetail
          ? null
          : (selectedDetail ?? this.selectedDetail),
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      userPosition:
          clearUserPosition ? null : (userPosition ?? this.userPosition),
      activeStatusFilter: clearStatusFilter
          ? null
          : (activeStatusFilter ?? this.activeStatusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
