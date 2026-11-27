import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/api_models.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers.dart';
import '../auth/auth_notifier.dart';
import 'home_notifier.dart';
import 'watch_area_state.dart';

/// Notifier terpusat untuk CRUD area pantauan dan penandaan alert in-app.
///
/// Setiap perubahan berhasil disinkronkan ke [HomeNotifier] agar daftar area
/// dan jumlah notifikasi belum dibaca di Beranda selalu konsisten.
class WatchAreaNotifier extends AsyncNotifier<WatchAreaData> {
  @override
  Future<WatchAreaData> build() => _load();

  Future<WatchAreaData> _load() async {
    final isAuthenticated = ref.read(authNotifierProvider) is AuthAuthenticated;
    if (!isAuthenticated) return const WatchAreaData();

    final service = ref.read(watchAreaServiceProvider);
    final (watchAreas, alerts) = await (
      service.getWatchAreas().catchError((_) => <WatchAreaModel>[]),
      service.getAlerts().catchError((_) => <AlertModel>[]),
    ).wait;

    return WatchAreaData(watchAreas: watchAreas, alerts: alerts);
  }

  WatchAreaData get _data => state.value ?? const WatchAreaData();

  void _commit(WatchAreaData data) => state = AsyncData(data);

  void _setMutating(bool value) =>
      _commit(_data.copyWith(isMutating: value));

  void _syncHome(WatchAreaData data) {
    ref.read(homeNotifierProvider.notifier).syncWatchAreaData(
          watchAreas: data.watchAreas,
          unreadAlertsCount: data.unreadAlertsCount,
        );
  }

  /// Muat ulang daftar area pantauan & alert dari API.
  Future<void> refresh() async {
    final next = await AsyncValue.guard(_load);
    state = next;
    final data = next.value;
    if (data != null) _syncHome(data);
  }

  /// Simpan area pantauan baru (maksimal [WatchAreaData.maxAreas]).
  Future<WatchAreaModel> createWatchArea({
    required String label,
    required double latitude,
    required double longitude,
    int radiusMeters = WatchAreaData.defaultRadiusMeters,
  }) async {
    final current = _data;
    if (!current.canAddWatchArea) {
      throw ApiException(
        message:
            'Maksimal ${WatchAreaData.maxAreas} area pantauan. Hapus salah satu terlebih dahulu.',
      );
    }

    _setMutating(true);
    try {
      final created = await ref.read(watchAreaServiceProvider).createWatchArea(
            label: label,
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters,
          );
      final updated = current.copyWith(
        watchAreas: [...current.watchAreas, created],
      );
      _commit(updated.copyWith(isMutating: true));
      _syncHome(updated);
      return created;
    } finally {
      _setMutating(false);
    }
  }

  /// Hapus area pantauan berdasarkan id.
  Future<void> deleteWatchArea(String watchAreaId) async {
    final current = _data;
    _setMutating(true);
    try {
      await ref
          .read(watchAreaServiceProvider)
          .deleteWatchArea(watchAreaId);
      final updated = current.copyWith(
        watchAreas: current.watchAreas
            .where((area) => area.id != watchAreaId)
            .toList(),
      );
      _commit(updated.copyWith(isMutating: true));
      _syncHome(updated);
    } finally {
      _setMutating(false);
    }
  }

  /// Tandai alert sebagai dibaca via `POST /alerts/{id}/read`.
  Future<void> markAlertAsRead(String alertId) async {
    final current = _data;
    final index = current.alerts.indexWhere((alert) => alert.id == alertId);
    if (index < 0 || current.alerts[index].isRead) return;

    _setMutating(true);
    try {
      await ref.read(watchAreaServiceProvider).markAlertAsRead(alertId);
      final updatedAlerts = List<AlertModel>.of(current.alerts);
      final alert = updatedAlerts[index];
      updatedAlerts[index] = AlertModel(
        id: alert.id,
        title: alert.title,
        message: alert.message,
        incidentId: alert.incidentId,
        isRead: true,
        createdAt: alert.createdAt,
      );
      final updated = current.copyWith(alerts: updatedAlerts);
      _commit(updated.copyWith(isMutating: true));
      _syncHome(updated);
    } finally {
      _setMutating(false);
    }
  }
}

/// Provider untuk [WatchAreaNotifier].
final watchAreaNotifierProvider =
    AsyncNotifierProvider<WatchAreaNotifier, WatchAreaData>(() {
  return WatchAreaNotifier();
});
