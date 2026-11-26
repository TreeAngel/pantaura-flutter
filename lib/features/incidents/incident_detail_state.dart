import '../../core/models/api_models.dart';

/// Type of timeline entry — from a report or a resolution submission.
enum TimelineEntryType { report, resolution }

/// A unified timeline entry merging [ReportModel] and [ResolutionSubmissionModel].
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

  factory TimelineEntry.fromReport(ReportModel r) => TimelineEntry(
        id: r.id,
        description: r.description,
        createdAt: r.submittedAt,
        media: r.media,
        type: TimelineEntryType.report,
        authorName: r.reporter?.name,
      );

  factory TimelineEntry.fromResolution(ResolutionSubmissionModel r) => TimelineEntry(
        id: r.id,
        description: r.description,
        createdAt: r.createdAt,
        media: r.media,
        type: TimelineEntryType.resolution,
        authorName: r.submitter?.name,
      );
}

/// Wraps a [MediaModel] together with its parent description for display.
class MediaItem {
  final MediaModel media;
  final String parentDescription;

  const MediaItem({
    required this.media,
    required this.parentDescription,
  });
}

/// Immutable state for the Incident Detail screen.
class IncidentDetailData {
  final IncidentDetailModel incident;
  final List<TimelineEntry> timeline;
  final List<MediaItem> allMedia;
  final SafeZoneModel? nearestSafeZone;
  final bool isSortAscending;
  final int visibleMediaCount;
  final bool isConfirmLoading;

  const IncidentDetailData({
    required this.incident,
    required this.timeline,
    required this.allMedia,
    this.nearestSafeZone,
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
    bool? isSortAscending,
    int? visibleMediaCount,
    bool? isConfirmLoading,
  }) {
    return IncidentDetailData(
      incident: incident ?? this.incident,
      timeline: timeline ?? this.timeline,
      allMedia: allMedia ?? this.allMedia,
      nearestSafeZone: clearNearestSafeZone ? null : (nearestSafeZone ?? this.nearestSafeZone),
      isSortAscending: isSortAscending ?? this.isSortAscending,
      visibleMediaCount: visibleMediaCount ?? this.visibleMediaCount,
      isConfirmLoading: isConfirmLoading ?? this.isConfirmLoading,
    );
  }
}
