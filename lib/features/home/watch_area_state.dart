import '../../core/models/api_models.dart';

/// State untuk area pantauan pribadi dan notifikasi geofence di Beranda.
class WatchAreaData {
  const WatchAreaData({
    this.watchAreas = const <WatchAreaModel>[],
    this.alerts = const <AlertModel>[],
    this.isMutating = false,
  });

  /// Batas area pantauan sesuai API.md (maksimal 5 lokasi).
  static const int maxAreas = 5;

  /// Radius bawaan saat pengguna belum memilih nilai (meter).
  static const int defaultRadiusMeters = 1000;

  /// Koordinat bawaan Jakarta (dipakai bila lokasi perangkat tidak tersedia).
  static const double defaultLatitude = -6.19099;
  static const double defaultLongitude = 106.84264;

  final List<WatchAreaModel> watchAreas;
  final List<AlertModel> alerts;
  final bool isMutating;

  int get unreadAlertsCount =>
      alerts.where((alert) => !alert.isRead).length;

  bool get canAddWatchArea => watchAreas.length < maxAreas;

  WatchAreaData copyWith({
    List<WatchAreaModel>? watchAreas,
    List<AlertModel>? alerts,
    bool? isMutating,
  }) {
    return WatchAreaData(
      watchAreas: watchAreas ?? this.watchAreas,
      alerts: alerts ?? this.alerts,
      isMutating: isMutating ?? this.isMutating,
    );
  }
}
