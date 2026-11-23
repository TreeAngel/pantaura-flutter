import '../network/api_client.dart';
import '../network/api_config.dart';
import '../models/api_models.dart';

class WatchAreaService {
  final ApiClient _client;

  WatchAreaService(this._client);

  /// GET /watch-areas (Daftar area pantauan pribadi, maks 5)
  Future<List<WatchAreaModel>> getWatchAreas() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConfig.watchAreas);
    final list = response.data?['data'] as List<dynamic>? ?? [];
    return list.map((e) => WatchAreaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /watch-areas (Simpan area pantauan baru)
  Future<WatchAreaModel> createWatchArea({
    required String label,
    required double latitude,
    required double longitude,
    int? radiusMeters,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.watchAreas,
      data: {
        'label': label,
        'latitude': latitude,
        'longitude': longitude,
        if (radiusMeters != null) ...{'radius_meters': radiusMeters},
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? response.data!;
    return WatchAreaModel.fromJson(data);
  }

  /// DELETE /watch-areas/{watchArea} (Hapus area pantauan)
  Future<void> deleteWatchArea(String watchAreaId) async {
    await _client.delete<Map<String, dynamic>>(
      ApiConfig.watchAreaDelete(watchAreaId),
    );
  }

  /// GET /alerts (Daftar notifikasi geofence bencana di area pantauan)
  Future<List<AlertModel>> getAlerts() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConfig.alerts);
    final list = response.data?['data'] as List<dynamic>? ?? [];
    return list.map((e) => AlertModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /alerts/{alert}/read (Tandai notifikasi geofence sudah dibaca)
  Future<void> markAlertAsRead(String alertId) async {
    await _client.post<Map<String, dynamic>>(ApiConfig.alertRead(alertId));
  }
}
