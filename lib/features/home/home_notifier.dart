import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/api_models.dart';
import '../../core/providers.dart';
import '../auth/auth_notifier.dart';
import 'home_state.dart';

/// Notifier untuk mengelola data Beranda Warga secara reaktif.
class HomeNotifier extends AsyncNotifier<HomeData> {
  @override
  Future<HomeData> build() async {
    return _fetchInitialData();
  }

  Future<HomeData> _fetchInitialData({
    DisasterCategoryFilter category = DisasterCategoryFilter.all,
    WatchAreaModel? activeWatchArea,
  }) async {
    final incidentService = ref.read(incidentServiceProvider);
    final safeZoneService = ref.read(safeZoneServiceProvider);
    final watchAreaService = ref.read(watchAreaServiceProvider);
    final authService = ref.read(authServiceProvider);
    final isAuthenticated = ref.read(authNotifierProvider) is AuthAuthenticated;

    // Jalankan request secara konkuren sesuai best practice Dart 3
    final incidentsFuture = activeWatchArea != null
        ? incidentService
            .getNearbyIncidents(
              latitude: activeWatchArea.latitude,
              longitude: activeWatchArea.longitude,
              type: category.apiValue,
              radiusMeters: activeWatchArea.radiusMeters,
            )
            .then(
              (list) => PaginatedList<IncidentSummaryModel>(
                data: list,
                currentPage: 1,
                lastPage: 1,
                total: list.length,
              ),
            )
        : incidentService.getIncidents(
            type: category.apiValue,
            page: 1,
          );

    final safeZonesFuture = safeZoneService
        .getSafeZones()
        .catchError((_) => <SafeZoneModel>[]);

    final watchAreasFuture = isAuthenticated
        ? watchAreaService
            .getWatchAreas()
            .catchError((_) => <WatchAreaModel>[])
        : Future.value(<WatchAreaModel>[]);

    final alertsFuture = isAuthenticated
        ? watchAreaService
            .getAlerts()
            .catchError((_) => <AlertModel>[])
        : Future.value(<AlertModel>[]);

    final currentUserFuture = authService
        .getMe()
        .then<UserModel?>((user) => user)
        .catchError((_) => null);

    final (paginatedIncidents, safeZones, watchAreas, alerts, currentUser) =
        await (
      incidentsFuture,
      safeZonesFuture,
      watchAreasFuture,
      alertsFuture,
      currentUserFuture,
    ).wait;

    final unreadCount = alerts.where((alert) => !alert.isRead).length;

    return HomeData(
      incidents: paginatedIncidents.data,
      allIncidentsForSummary: paginatedIncidents.data,
      safeZones: safeZones.where((z) => z.isActive).toList(),
      watchAreas: watchAreas,
      currentUser: currentUser,
      activeWatchArea: activeWatchArea,
      selectedCategory: category,
      unreadAlertsCount: unreadCount,
      currentPage: paginatedIncidents.currentPage,
      lastPage: paginatedIncidents.lastPage,
      lastUpdated: DateTime.now(),
    );
  }

  /// Sinkronkan area pantauan & jumlah alert yang belum dibaca dari
  /// `watchAreaNotifierProvider` tanpa memuat ulang seluruh Beranda.
  void syncWatchAreaData({
    required List<WatchAreaModel> watchAreas,
    required int unreadAlertsCount,
  }) {
    final current = state.value;
    if (current == null) return;

    final active = current.activeWatchArea;
    final activeStillExists =
        active == null || watchAreas.any((area) => area.id == active.id);

    state = AsyncData(
      current.copyWith(
        watchAreas: watchAreas,
        unreadAlertsCount: unreadAlertsCount,
        clearActiveWatchArea: !activeStillExists,
      ),
    );

    // Area aktif dihapus → kembalikan daftar insiden ke semua wilayah.
    if (!activeStillExists) {
      unawaited(selectWatchArea(null));
    }
  }

  /// Muat ulang seluruh data Beranda.
  Future<void> refresh() async {
    final current = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchInitialData(
        category: current?.selectedCategory ?? DisasterCategoryFilter.all,
        activeWatchArea: current?.activeWatchArea,
      ),
    );
  }

  /// Ubah filter kategori bencana dan ambil data relevan dari API.
  Future<void> selectCategory(DisasterCategoryFilter category) async {
    final current = state.value;
    if (current == null || current.selectedCategory == category) return;

    state = AsyncData(
      current.copyWith(
        selectedCategory: category,
        isFiltering: true,
      ),
    );

    try {
      final incidentService = ref.read(incidentServiceProvider);
      final watchArea = current.activeWatchArea;

      if (watchArea != null) {
        final nearby = await incidentService.getNearbyIncidents(
          latitude: watchArea.latitude,
          longitude: watchArea.longitude,
          type: category.apiValue,
          radiusMeters: watchArea.radiusMeters,
        );
        state = AsyncData(
          current.copyWith(
            incidents: nearby,
            selectedCategory: category,
            currentPage: 1,
            lastPage: 1,
            isFiltering: false,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        final paginated = await incidentService.getIncidents(
          type: category.apiValue,
          page: 1,
        );
        state = AsyncData(
          current.copyWith(
            incidents: paginated.data,
            allIncidentsForSummary: category == DisasterCategoryFilter.all
                ? paginated.data
                : current.allIncidentsForSummary,
            selectedCategory: category,
            currentPage: paginated.currentPage,
            lastPage: paginated.lastPage,
            isFiltering: false,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (_) {
      state = AsyncData(current.copyWith(isFiltering: false));
    }
  }

  /// Ubah area pantauan aktif (null = Semua Wilayah).
  Future<void> selectWatchArea(WatchAreaModel? watchArea) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        activeWatchArea: watchArea,
        clearActiveWatchArea: watchArea == null,
        isFiltering: true,
      ),
    );

    try {
      final incidentService = ref.read(incidentServiceProvider);
      final category = current.selectedCategory;

      if (watchArea != null) {
        final nearby = await incidentService.getNearbyIncidents(
          latitude: watchArea.latitude,
          longitude: watchArea.longitude,
          type: category.apiValue,
          radiusMeters: watchArea.radiusMeters,
        );
        state = AsyncData(
          current.copyWith(
            incidents: nearby,
            allIncidentsForSummary:
                category == DisasterCategoryFilter.all ? nearby : current.allIncidentsForSummary,
            activeWatchArea: watchArea,
            currentPage: 1,
            lastPage: 1,
            isFiltering: false,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        final paginated = await incidentService.getIncidents(
          type: category.apiValue,
          page: 1,
        );
        state = AsyncData(
          current.copyWith(
            incidents: paginated.data,
            allIncidentsForSummary: category == DisasterCategoryFilter.all
                ? paginated.data
                : current.allIncidentsForSummary,
            clearActiveWatchArea: true,
            currentPage: paginated.currentPage,
            lastPage: paginated.lastPage,
            isFiltering: false,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (_) {
      state = AsyncData(current.copyWith(isFiltering: false));
    }
  }

  /// Muat halaman insiden berikutnya (pagination).
  Future<void> loadMoreIncidents() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.activeWatchArea != null) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final incidentService = ref.read(incidentServiceProvider);
      final nextPage = current.currentPage + 1;
      final paginated = await incidentService.getIncidents(
        type: current.selectedCategory.apiValue,
        page: nextPage,
      );

      final updatedList = [...current.incidents, ...paginated.data];
      state = AsyncData(
        current.copyWith(
          incidents: updatedList,
          allIncidentsForSummary:
              current.selectedCategory == DisasterCategoryFilter.all
                  ? updatedList
                  : current.allIncidentsForSummary,
          currentPage: paginated.currentPage,
          lastPage: paginated.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

/// Provider untuk HomeNotifier.
final homeNotifierProvider =
    AsyncNotifierProvider<HomeNotifier, HomeData>(() {
  return HomeNotifier();
});
