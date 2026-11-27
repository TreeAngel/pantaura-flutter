import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import 'history_notifier.dart';
import 'history_state.dart';
import 'widgets/history_empty_state.dart';
import 'widgets/history_filter_chips.dart';
import 'widgets/history_header.dart';
import 'widgets/history_loading_more.dart';
import 'widgets/history_report_card.dart';
import 'widgets/history_tab_bar.dart';

/// Riwayat laporan warga dengan tab, filter, pagination, dan pull-to-refresh.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  void _scrollToFilter() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(historyProvider);
    final data = async.value ?? const HistoryData();
    final reports = data.filteredReports;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: Column(
        children: [
          HistoryHeader(onFilterTap: _scrollToFilter),
          Expanded(
            child: async.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        'Gagal memuat riwayat laporan',
                        style: AppTypography.headlineSm
                            .copyWith(color: AppColors.textHeader),
                      ),
                      const SizedBox(height: AppSpacing.spaceMd),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(historyProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (_) => RefreshIndicator(
                color: AppColors.primary,
                onRefresh: ref.read(historyProvider.notifier).refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.margin,
                        AppSpacing.spaceMd,
                        AppSpacing.margin,
                        AppSpacing.spaceXs,
                      ),
                      sliver: SliverList.list(
                        children: [
                          HistoryTabBar(
                            activeTab: data.activeTab,
                            reportCount: data.reportCount,
                            recoveryCount: data.recoveryCount,
                            onChanged: ref.read(historyProvider.notifier).setTab,
                          ),
                          const SizedBox(height: AppSpacing.spaceSm),
                          HistoryFilterChips(
                            activeFilter: data.statusFilter,
                            onChanged:
                                ref.read(historyProvider.notifier).setStatusFilter,
                          ),
                        ],
                      ),
                    ),
                    if (reports.isEmpty)
                      SliverToBoxAdapter(
                        child: HistoryEmptyState(
                          message: data.statusFilter == 'rejected'
                              ? 'Belum ada laporan yang ditolak.'
                              : data.activeTab == HistoryTab.recovery
                                  ? 'Belum ada pengajuan pemulihan.'
                                  : 'Belum ada laporan pada filter ini.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.margin,
                        ),
                        sliver: SliverList.separated(
                          itemCount: reports.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.spaceSm),
                          itemBuilder: (context, index) =>
                              HistoryReportCard(report: reports[index]),
                        ),
                      ),
                    if (data.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: HistoryLoadingMore(),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 112),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
