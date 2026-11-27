import '../models/api_models.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';

class SafeZoneService {
  final ApiClient _client;

  SafeZoneService(this._client);

  /// GET /safe-zones (Daftar Posko & Titik Aman aktif)
  Future<List<SafeZoneModel>> getSafeZones() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConfig.safeZones);
    final list = response.data?['data'] as List<dynamic>? ?? [];
    return list.map((e) => SafeZoneModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
