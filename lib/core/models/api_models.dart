class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'citizen',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };
}

class AuthResponseModel {
  final String token;
  final String tokenType;
  final UserModel user;

  const AuthResponseModel({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class MediaModel {
  final String id;
  final String url;
  final String fileType;
  final String originalFilename;
  final int fileSize;
  final DateTime? createdAt;

  const MediaModel({
    required this.id,
    required this.url,
    required this.fileType,
    required this.originalFilename,
    required this.fileSize,
    this.createdAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      fileType: json['file_type'] as String? ?? 'image',
      originalFilename: json['original_filename'] as String? ?? '',
      fileSize: json['file_size'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class IncidentSummaryModel {
  final String id;
  final String title;
  final String disasterType;
  final String disasterTypeLabel;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String status;
  final String statusLabel;
  final int reportsCount;
  final DateTime? verifiedAt;
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  const IncidentSummaryModel({
    required this.id,
    required this.title,
    required this.disasterType,
    required this.disasterTypeLabel,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.status,
    required this.statusLabel,
    this.reportsCount = 0,
    this.verifiedAt,
    this.resolvedAt,
    this.createdAt,
  });

  factory IncidentSummaryModel.fromJson(Map<String, dynamic> json) {
    return IncidentSummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      disasterType: json['disaster_type'] as String? ?? '',
      disasterTypeLabel: json['disaster_type_label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'unverified',
      statusLabel: json['status_label'] as String? ?? '',
      reportsCount: json['reports_count'] as int? ?? 0,
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at'].toString()) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class ReportModel {
  final String id;
  final String incidentId;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime? submittedAt;
  final String moderationStatus;
  final String? rejectionReason;
  final UserModel? reporter;
  final List<MediaModel> media;
  final IncidentSummaryModel? incident;

  const ReportModel({
    required this.id,
    required this.incidentId,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.submittedAt,
    required this.moderationStatus,
    this.rejectionReason,
    this.reporter,
    this.media = const [],
    this.incident,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      incidentId: json['incident_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      submittedAt: json['submitted_at'] != null ? DateTime.tryParse(json['submitted_at'].toString()) : null,
      moderationStatus: json['moderation_status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      reporter: json['reporter'] != null ? UserModel.fromJson(json['reporter'] as Map<String, dynamic>) : null,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      incident: json['incident'] != null
          ? IncidentSummaryModel.fromJson(json['incident'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ResolutionSubmissionModel {
  final String id;
  final String incidentId;
  final String description;
  final String status;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final UserModel? submitter;
  final List<MediaModel> media;

  const ResolutionSubmissionModel({
    required this.id,
    required this.incidentId,
    required this.description,
    required this.status,
    this.rejectionReason,
    this.reviewedAt,
    this.createdAt,
    this.submitter,
    this.media = const [],
  });

  factory ResolutionSubmissionModel.fromJson(Map<String, dynamic> json) {
    return ResolutionSubmissionModel(
      id: json['id'] as String? ?? '',
      incidentId: json['incident_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      reviewedAt: json['reviewed_at'] != null ? DateTime.tryParse(json['reviewed_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      submitter: json['submitter'] != null ? UserModel.fromJson(json['submitter'] as Map<String, dynamic>) : null,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class IncidentStatusHistoryModel {
  final String id;
  final String? previousStatus;
  final String newStatus;
  final String? reason;
  final UserModel? changedBy;
  final DateTime? createdAt;

  const IncidentStatusHistoryModel({
    required this.id,
    this.previousStatus,
    required this.newStatus,
    this.reason,
    this.changedBy,
    this.createdAt,
  });

  factory IncidentStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return IncidentStatusHistoryModel(
      id: json['id'] as String? ?? '',
      previousStatus: json['previous_status'] as String?,
      newStatus: json['new_status'] as String? ?? '',
      reason: json['reason'] as String?,
      changedBy: json['changed_by'] != null ? UserModel.fromJson(json['changed_by'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class IncidentDetailModel extends IncidentSummaryModel {
  final List<ReportModel> reports;
  final List<ResolutionSubmissionModel> resolutions;
  final List<IncidentStatusHistoryModel> statusHistories;

  const IncidentDetailModel({
    required super.id,
    required super.title,
    required super.disasterType,
    required super.disasterTypeLabel,
    required super.description,
    required super.latitude,
    required super.longitude,
    super.address,
    required super.status,
    required super.statusLabel,
    super.reportsCount,
    super.verifiedAt,
    super.resolvedAt,
    super.createdAt,
    this.reports = const [],
    this.resolutions = const [],
    this.statusHistories = const [],
  });

  factory IncidentDetailModel.fromJson(Map<String, dynamic> json) {
    final base = IncidentSummaryModel.fromJson(json);
    return IncidentDetailModel(
      id: base.id,
      title: base.title,
      disasterType: base.disasterType,
      disasterTypeLabel: base.disasterTypeLabel,
      description: base.description,
      latitude: base.latitude,
      longitude: base.longitude,
      address: base.address,
      status: base.status,
      statusLabel: base.statusLabel,
      reportsCount: base.reportsCount,
      verifiedAt: base.verifiedAt,
      resolvedAt: base.resolvedAt,
      createdAt: base.createdAt,
      reports: (json['reports'] as List<dynamic>?)
              ?.map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      resolutions: (json['resolutions'] as List<dynamic>?)
              ?.map((e) => ResolutionSubmissionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusHistories: (json['status_histories'] as List<dynamic>?)
              ?.map((e) => IncidentStatusHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SafeZoneModel {
  final String id;
  final String name;
  final String type;
  final String? address;
  final double latitude;
  final double longitude;
  final String? description;
  final int? capacity;
  final bool isActive;

  const SafeZoneModel({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.capacity,
    this.isActive = true,
  });

  factory SafeZoneModel.fromJson(Map<String, dynamic> json) {
    return SafeZoneModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      capacity: json['capacity'] as int?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class WatchAreaModel {
  final String id;
  final String label;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final DateTime? createdAt;

  const WatchAreaModel({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.createdAt,
  });

  factory WatchAreaModel.fromJson(Map<String, dynamic> json) {
    return WatchAreaModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: json['radius_meters'] as int? ?? 1000,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class AlertModel {
  final String id;
  final String title;
  final String message;
  final String? incidentId;
  final bool isRead;
  final DateTime? createdAt;

  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    this.incidentId,
    this.isRead = false,
    this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      incidentId: json['incident_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class PaginatedList<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedList({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final list = (json['data'] as List<dynamic>?)
            ?.map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList() ??
        [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedList<T>(
      data: list,
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? list.length,
    );
  }
}
