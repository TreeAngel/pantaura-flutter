import '../../core/models/api_models.dart';

enum HistoryTab { report, recovery }

/// State immutable halaman riwayat laporan warga.
class HistoryData {
  const HistoryData({
    this.reports = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.activeTab = HistoryTab.report,
    this.statusFilter,
  });

  final List<ReportModel> reports;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool isRefreshing;
  final HistoryTab activeTab;
  final String? statusFilter;

  int get reportCount => reports
      .where((report) => report.moderationStatus.toLowerCase() != 'resolution_submitted')
      .length;

  int get recoveryCount => reports
      .where((report) => report.moderationStatus.toLowerCase() == 'resolution_submitted')
      .length;

  List<ReportModel> get filteredReports {
    return reports.where((report) {
      final status = report.moderationStatus.toLowerCase();
      final tabMatches = switch (activeTab) {
        HistoryTab.recovery => status == 'resolution_submitted',
        HistoryTab.report => status != 'resolution_submitted',
      };
      if (!tabMatches) return false;
      return _matchesStatusFilter(status, statusFilter);
    }).toList();
  }

  static bool _matchesStatusFilter(String status, String? filter) =>
      switch (filter) {
        null || 'all' => true,
        'unverified' => status == 'pending' || status == 'unverified',
        'verified' => status == 'approved' || status == 'verified',
        'resolved' => status == 'resolved',
        'rejected' => status == 'rejected',
        _ => true,
      };

  HistoryData copyWith({
    List<ReportModel>? reports,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? isRefreshing,
    HistoryTab? activeTab,
    String? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return HistoryData(
      reports: reports ?? this.reports,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      activeTab: activeTab ?? this.activeTab,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}
