import '../../../core/models/api_models.dart';

/// Jenis entri kronologi: berasal dari laporan warga atau resolusi petugas.
enum TimelineEntryType { report, resolution }

/// Entri kronologi gabungan dari [ReportModel] dan [ResolutionSubmissionModel].
class TimelineEntry {
  final String id;
  final String description;
  final DateTime? createdAt;
  final List<MediaModel> media;
  final TimelineEntryType type;
  final String? authorName;

  const TimelineEntry({
    required this.id,
    required this.description,
    this.createdAt,
    required this.media,
    required this.type,
    this.authorName,
  });

  factory TimelineEntry.fromReport(ReportModel report) => TimelineEntry(
        id: report.id,
        description: report.description,
        createdAt: report.submittedAt,
        media: report.media,
        type: TimelineEntryType.report,
        authorName: report.reporter?.name,
      );

  factory TimelineEntry.fromResolution(ResolutionSubmissionModel resolution) =>
      TimelineEntry(
        id: resolution.id,
        description: resolution.description,
        createdAt: resolution.createdAt,
        media: resolution.media,
        type: TimelineEntryType.resolution,
        authorName: resolution.submitter?.name,
      );
}

/// Satu media beserta deskripsi laporan/resolusi induknya (untuk judul gambar).
class MediaItem {
  final MediaModel media;
  final String parentDescription;

  const MediaItem({
    required this.media,
    required this.parentDescription,
  });
}

/// State immutable halaman detail insiden.
class IncidentDetailData {
  final IncidentDetailModel incident;
  final List<TimelineEntry> timeline;
  final List<MediaItem> allMedia;
  final SafeZoneModel? nearestSafeZone;
  final double? nearestSafeZoneDistanceKm;
  final bool isSortAscending;
  final int visibleMediaCount;
  final bool isConfirmLoading;

  const IncidentDetailData({
    required this.incident,
    required this.timeline,
    required this.allMedia,
    this.nearestSafeZone,
    this.nearestSafeZoneDistanceKm,
    this.isSortAscending = true,
    this.visibleMediaCount = 10,
    this.isConfirmLoading = false,
  });

  IncidentDetailData copyWith({
    IncidentDetailModel? incident,
    List<TimelineEntry>? timeline,
    List<MediaItem>? allMedia,
    SafeZoneModel? nearestSafeZone,
    bool clearNearestSafeZone = false,
    double? nearestSafeZoneDistanceKm,
    bool clearDistance = false,
    bool? isSortAscending,
    int? visibleMediaCount,
    bool? isConfirmLoading,
  }) {
    return IncidentDetailData(
      incident: incident ?? this.incident,
      timeline: timeline ?? this.timeline,
      allMedia: allMedia ?? this.allMedia,
      nearestSafeZone:
          clearNearestSafeZone ? null : (nearestSafeZone ?? this.nearestSafeZone),
      nearestSafeZoneDistanceKm: clearDistance
          ? null
          : (nearestSafeZoneDistanceKm ?? this.nearestSafeZoneDistanceKm),
      isSortAscending: isSortAscending ?? this.isSortAscending,
      visibleMediaCount: visibleMediaCount ?? this.visibleMediaCount,
      isConfirmLoading: isConfirmLoading ?? this.isConfirmLoading,
    );
  }
}
