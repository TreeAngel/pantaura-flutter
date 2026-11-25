import '../../core/models/api_models.dart';

/// Filter kategori bencana untuk halaman Beranda sesuai API.md.
enum DisasterCategoryFilter {
  all(null, 'Semua'),
  flood('flood', 'Banjir'),
  earthquake('earthquake', 'Gempa Bumi'),
  landslide('landslide', 'Tanah Longsor'),
  fire('fire', 'Kebakaran');

  const DisasterCategoryFilter(this.apiValue, this.label);

  final String? apiValue;
  final String label;
}

/// Ringkasan jumlah insiden berdasarkan status siklus hidupnya.
class IncidentStatusCounts {
  const IncidentStatusCounts({
    this.verified = 0,
    this.inProcess = 0,
    this.resolved = 0,
  });

  final int verified;
  final int inProcess;
  final int resolved;

  int get total => verified + inProcess + resolved;
}

/// State immutable untuk halaman Beranda Warga.
class HomeData {
  const HomeData({
    required this.incidents,
    required this.allIncidentsForSummary,
    required this.safeZones,
    required this.watchAreas,
    this.currentUser,
    this.activeWatchArea,
    this.selectedCategory = DisasterCategoryFilter.all,
    this.unreadAlertsCount = 0,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.isFiltering = false,
    required this.lastUpdated,
  });

  final List<IncidentSummaryModel> incidents;
  final List<IncidentSummaryModel> allIncidentsForSummary;
  final List<SafeZoneModel> safeZones;
  final List<WatchAreaModel> watchAreas;
  final UserModel? currentUser;
  final WatchAreaModel? activeWatchArea;
  final DisasterCategoryFilter selectedCategory;
  final int unreadAlertsCount;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool isFiltering;
  final DateTime lastUpdated;

  bool get hasMore => currentPage < lastPage;

  IncidentStatusCounts get statusCounts {
    var verified = 0;
    var inProcess = 0;
    var resolved = 0;

    for (final item in allIncidentsForSummary) {
      switch (item.status) {
        case 'verified':
          verified++;
        case 'unverified' || 'resolution_submitted':
          inProcess++;
        case 'resolved':
          resolved++;
      }
    }

    return IncidentStatusCounts(
      verified: verified,
      inProcess: inProcess,
      resolved: resolved,
    );
  }

  Map<DisasterCategoryFilter, int> get categoryCounts {
    final counts = <DisasterCategoryFilter, int>{
      DisasterCategoryFilter.all: allIncidentsForSummary.length,
      DisasterCategoryFilter.flood: 0,
      DisasterCategoryFilter.earthquake: 0,
      DisasterCategoryFilter.landslide: 0,
      DisasterCategoryFilter.fire: 0,
    };

    for (final item in allIncidentsForSummary) {
      switch (item.disasterType) {
        case 'flood':
          counts[DisasterCategoryFilter.flood] =
              (counts[DisasterCategoryFilter.flood] ?? 0) + 1;
        case 'earthquake':
          counts[DisasterCategoryFilter.earthquake] =
              (counts[DisasterCategoryFilter.earthquake] ?? 0) + 1;
        case 'landslide':
          counts[DisasterCategoryFilter.landslide] =
              (counts[DisasterCategoryFilter.landslide] ?? 0) + 1;
        case 'fire':
          counts[DisasterCategoryFilter.fire] =
              (counts[DisasterCategoryFilter.fire] ?? 0) + 1;
      }
    }
    return counts;
  }

  HomeData copyWith({
    List<IncidentSummaryModel>? incidents,
    List<IncidentSummaryModel>? allIncidentsForSummary,
    List<SafeZoneModel>? safeZones,
    List<WatchAreaModel>? watchAreas,
    UserModel? currentUser,
    WatchAreaModel? activeWatchArea,
    bool clearActiveWatchArea = false,
    DisasterCategoryFilter? selectedCategory,
    int? unreadAlertsCount,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? isFiltering,
    DateTime? lastUpdated,
  }) {
    return HomeData(
      incidents: incidents ?? this.incidents,
      allIncidentsForSummary:
          allIncidentsForSummary ?? this.allIncidentsForSummary,
      safeZones: safeZones ?? this.safeZones,
      watchAreas: watchAreas ?? this.watchAreas,
      currentUser: currentUser ?? this.currentUser,
      activeWatchArea: clearActiveWatchArea
          ? null
          : (activeWatchArea ?? this.activeWatchArea),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      unreadAlertsCount: unreadAlertsCount ?? this.unreadAlertsCount,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFiltering: isFiltering ?? this.isFiltering,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
