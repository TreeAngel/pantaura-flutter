import 'package:dio/dio.dart';

import '../models/api_models.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';

class ReportService {
  final ApiClient _client;

  ReportService(this._client);

  /// POST /reports (Kirim laporan bencana baru)
  Future<ReportModel> createReport({
    required String disasterType,
    required double latitude,
    required double longitude,
    required String description,
    String? address,
    required List<MultipartFile> mediaFiles,
  }) async {
    final formData = FormData.fromMap({
      'disaster_type': disasterType,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      if (address != null) ...{'address': address},
      'media[]': mediaFiles,
    });

    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.reports,
      data: formData,
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? response.data!;
    return ReportModel.fromJson(data);
  }

  /// GET /reports/my (Daftar laporan milik pengguna saat ini)
  Future<PaginatedList<ReportModel>> getMyReports({int page = 1}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConfig.myReports,
      queryParameters: {'page': page},
    );
    return PaginatedList.fromJson(
      response.data!,
      (json) => ReportModel.fromJson(json),
    );
  }
}
