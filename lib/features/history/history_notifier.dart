import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/api_models.dart';
import '../../core/providers.dart';
import 'history_state.dart';

/// Memuat riwayat laporan milik warga (GET /reports/my).
class HistoryNotifier extends AsyncNotifier<HistoryData> {
  @override
  Future<HistoryData> build() async {
    final page = await ref.read(reportServiceProvider).getMyReports(page: 1);
    return HistoryData(
      reports: page.data,
      currentPage: page.currentPage,
      lastPage: page.lastPage,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        current.isLoadingMore ||
        current.currentPage >= current.lastPage) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(reportServiceProvider)
          .getMyReports(page: current.currentPage + 1);
      final latest = state.value;
      if (latest == null) return;
      final existingIds = latest.reports.map((report) => report.id).toSet();
      final merged = <ReportModel>[...latest.reports];
      for (final report in page.data) {
        if (!existingIds.contains(report.id)) merged.add(report);
      }
      state = AsyncData(
        latest.copyWith(
          reports: merged,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null || current.isRefreshing) return;
    state = AsyncData(current.copyWith(isRefreshing: true));
    try {
      final page = await ref.read(reportServiceProvider).getMyReports(page: 1);
      state = AsyncData(
        current.copyWith(
          reports: page.data,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          isRefreshing: false,
        ),
      );
    } catch (_) {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(isRefreshing: false));
      }
    }
  }

  void setTab(HistoryTab tab) {
    final current = state.value;
    if (current == null || current.activeTab == tab) return;
    state = AsyncData(current.copyWith(activeTab: tab));
  }

  void setStatusFilter(String? filter) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        statusFilter: filter,
        clearStatusFilter: filter == null,
      ),
    );
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, HistoryData>(HistoryNotifier.new);
