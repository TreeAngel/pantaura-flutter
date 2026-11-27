import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/network/api_exception.dart';
import '../../core/providers.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/emergency_112_dialog.dart';
import '../auth/auth_notifier.dart';
import 'home_notifier.dart';
import 'home_state.dart';
import 'widgets/home_alert_sheet.dart';
import 'widgets/home_category_filter.dart';
import 'widgets/home_emergency_banner.dart';
import 'widgets/home_header_section.dart';
import 'widgets/home_incident_card.dart';
import 'widgets/home_status_summary.dart';
import 'widgets/watch_area_sheet.dart';

/// Halaman Beranda Warga Pantaura sesuai desain Stitch & DESIGN.md.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(permissionServiceProvider).ensureAll();
    });
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
      ref.read(homeNotifierProvider.notifier).loadMoreIncidents();
    }
  }

  Future<void> _showWatchAreaSheet(HomeData data) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheet,
      ),
      builder: (_) => WatchAreaSheet(
        activeWatchAreaId: data.activeWatchArea?.id,
        onAreaSelected: (area) =>
            ref.read(homeNotifierProvider.notifier).selectWatchArea(area),
      ),
    );
  }

  Future<void> _showAlertsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheet,
      ),
      builder: (_) => HomeAlertSheet(
        onAlertSelected: (alert) {
          final incidentId = alert.incidentId;
          if (incidentId != null && incidentId.isNotEmpty && mounted) {
            context.push(AppRoutes.incidentDetail(incidentId));
          }
        },
      ),
    );
  }

  Future<void> _showEmergency112Dialog() => showEmergency112Dialog(context);

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous is! AuthAuthenticated && next is AuthAuthenticated) {
        ref.read(permissionServiceProvider).ensureAll();
      }
    });
    final homeAsync = ref.watch(homeNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final fetchedName = homeAsync.value?.currentUser?.name;
    final authName = switch (authState) {
      AuthAuthenticated(:final user) => user.name,
      _ => null,
    };
    final rawName = (fetchedName != null && fetchedName.trim().isNotEmpty)
        ? fetchedName
        : authName;
    final userName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : 'Warga Pantaura';

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: HomeTopBar(
        unreadAlertsCount: homeAsync.value?.unreadAlertsCount ?? 0,
        onAlertsTap: _showAlertsSheet,
        onProfileTap: () => context.go(AppRoutes.profile),
      ),
      body: homeAsync.when(
        loading: () => const _HomeLoadingView(),
        error: (error, _) {
          final message = error is ApiException
              ? error.message
              : 'Gagal memuat data beranda. Periksa koneksi internet Anda.';
          return _HomeErrorView(
            message: message,
            onRetry: () => ref.read(homeNotifierProvider.notifier).refresh(),
          );
        },
        data: (data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeGreetingHeader(
                  userName: userName,
                  activeWatchArea: data.activeWatchArea,
                  isRefreshing: data.isFiltering,
                  onRefreshTap: () =>
                      ref.read(homeNotifierProvider.notifier).refresh(),
                  onWatchAreaTap: () => _showWatchAreaSheet(data),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.spaceMd,
                  AppSpacing.margin,
                  AppSpacing.spaceMd,
                ),
                sliver: SliverList.list(
                  children: [
                    HomeEmergencyBanner(
                      onCreateReportTap: () =>
                          context.push(AppRoutes.createReport),
                      onEmergencyCallTap: _showEmergency112Dialog,
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    HomeStatusSummaryStrip(
                      counts: data.statusCounts,
                      lastUpdated: data.lastUpdated,
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: HomeCategoryFilterBar(
                  selectedCategory: data.selectedCategory,
                  categoryCounts: data.categoryCounts,
                  onCategorySelected: (category) => ref
                      .read(homeNotifierProvider.notifier)
                      .selectCategory(category),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.spaceMd,
                  AppSpacing.margin,
                  AppSpacing.spaceXs,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Insiden di Sekitar Anda',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go(AppRoutes.map),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.statusResolution,
                        ),
                        label: Text(
                          'Lihat Peta',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.statusResolution,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (data.isFiltering)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.margin,
                      vertical: AppSpacing.spaceXs,
                    ),
                    child: LinearProgressIndicator(
                      color: AppColors.statusResolution,
                      backgroundColor: AppColors.surfaceTintIce,
                    ),
                  ),
                ),
              if (data.incidents.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.margin,
                    vertical: AppSpacing.spaceSm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _EmptyIncidentsCard(
                      selectedCategory: data.selectedCategory,
                      onResetFilter: () => ref
                          .read(homeNotifierProvider.notifier)
                          .selectCategory(DisasterCategoryFilter.all),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.margin,
                  ),
                  sliver: SliverList.separated(
                    itemCount: data.incidents.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.spaceSm),
                    itemBuilder: (context, index) {
                      final incident = data.incidents[index];
                      return HomeIncidentCard(
                        incident: incident,
                        onTap: () => context.push(
                          AppRoutes.incidentDetail(incident.id),
                        ),
                      );
                    },
                  ),
                ),
              if (data.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.spaceMd),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.spaceMd,
                  AppSpacing.margin,
                  112,
                ),
                sliver: SliverToBoxAdapter(
                  child: SafeZoneReassuranceCard(safeZones: data.safeZones),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyIncidentsCard extends StatelessWidget {
  const _EmptyIncidentsCard({
    required this.selectedCategory,
    required this.onResetFilter,
  });

  final DisasterCategoryFilter selectedCategory;
  final VoidCallback onResetFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 44,
            color: AppColors.statusResolution,
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            'Belum ada insiden untuk kategori ${selectedCategory.label}',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.textHeader,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Wilayah pantauan dalam kondisi aman atau tidak ada laporan baru.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm,
          ),
          if (selectedCategory != DisasterCategoryFilter.all) ...[
            const SizedBox(height: AppSpacing.spaceMd),
            SecondaryButton(
              label: 'Tampilkan Semua Kategori',
              onPressed: onResetFilter,
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.spaceSm),
          Text('Memuat kondisi wilayah terkini...'),
        ],
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.marginLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              'Tidak Dapat Memuat Beranda',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.textHeader,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            PrimaryButton(
              label: 'Coba Lagi',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
