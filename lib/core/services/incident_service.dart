import 'package:dio/dio.dart';

import '../models/api_models.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';

class IncidentService {
  final ApiClient _client;

  IncidentService(this._client);

  /// GET /incidents (terpaginasi)
  Future<PaginatedList<IncidentSummaryModel>> getIncidents({
    String? status,
    String? type,
    int page = 1,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConfig.incidents,
      queryParameters: {
        if (status != null) ...{'status': status},
        if (type != null) ...{'type': type},
        'page': page,
      },
    );
    return PaginatedList.fromJson(
      response.data!,
      (json) => IncidentSummaryModel.fromJson(json),
    );
  }

  /// GET /incidents/map
  Future<List<IncidentSummaryModel>> getIncidentsMap({
    String? status,
    String? type,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConfig.incidentMap,
      queryParameters: {
        if (status != null) ...{'status': status},
        if (type != null) ...{'type': type},
      },
    );
    final list = response.data?['data'] as List<dynamic>? ?? [];
    return list.map((e) => IncidentSummaryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /{incident}
  Future<IncidentDetailModel> getIncidentDetail(String incidentId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConfig.incidentDetail(incidentId),
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? response.data!;
    return IncidentDetailModel.fromJson(data);
  }

  /// GET /incidents/nearby
  Future<List<IncidentSummaryModel>> getNearbyIncidents({
    required double latitude,
    required double longitude,
    String? type,
    int? radiusMeters,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConfig.incidentNearby,
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
        if (type != null) ...{'type': type},
        if (radiusMeters != null) ...{'radius': radiusMeters},
      },
    );
    final list = response.data?['data'] as List<dynamic>? ?? [];
    return list.map((e) => IncidentSummaryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /incidents/{incident}/confirm
  Future<Map<String, dynamic>> toggleConfirm(String incidentId) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.incidentConfirm(incidentId),
    );
    return response.data ?? {};
  }

  /// POST /incidents/{incident}/reports (Tambah laporan pada insiden yang ada)
  Future<ReportModel> addIncidentReport({
    required String incidentId,
    required double latitude,
    required double longitude,
    required String description,
    required List<MultipartFile> mediaFiles,
  }) async {
    final formData = FormData.fromMap({
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'media[]': mediaFiles,
    });

    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.incidentReports(incidentId),
      data: formData,
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? response.data!;
    return ReportModel.fromJson(data);
  }

  /// POST /incidents/{incident}/resolutions (Ajukan bukti penyelesaian insiden)
  Future<ResolutionSubmissionModel> submitResolution({
    required String incidentId,
    required String description,
    required List<MultipartFile> mediaFiles,
  }) async {
    final formData = FormData.fromMap({
      'description': description,
      'media[]': mediaFiles,
    });

    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.incidentResolutions(incidentId),
      data: formData,
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? response.data!;
    return ResolutionSubmissionModel.fromJson(data);
  }
}
