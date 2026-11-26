import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../core/network/api_exception.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_button.dart';
import '../auth/auth_notifier.dart';
import 'home_notifier.dart';
import 'home_state.dart';
import 'widgets/home_category_filter.dart';
import 'widgets/home_emergency_banner.dart';
import 'widgets/home_header_section.dart';
import 'widgets/home_incident_card.dart';
import 'widgets/home_status_summary.dart';

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
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.margin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Lokasi Pantauan Aktif',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.textHeader,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tampilkan insiden di sekitar area pantauan tersimpan atau seluruh wilayah.',
                  style: AppTypography.bodySm,
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                _WatchAreaOptionTile(
                  title: 'Semua Wilayah Pantauan',
                  subtitle: 'Menampilkan seluruh laporan insiden publik terkini',
                  isSelected: data.activeWatchArea == null,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref.read(homeNotifierProvider.notifier).selectWatchArea(null);
                  },
                ),
                for (final area in data.watchAreas) ...[
                  const SizedBox(height: AppSpacing.spaceXs),
                  _WatchAreaOptionTile(
                    title: area.label,
                    subtitle:
                        'Radius ${(area.radiusMeters / 1000).toStringAsFixed(1)} km dari titik pantau',
                    isSelected: data.activeWatchArea?.id == area.id,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      ref
                          .read(homeNotifierProvider.notifier)
                          .selectWatchArea(area);
                    },
                  ),
                ],
                if (data.watchAreas.isEmpty) ...[
                  const SizedBox(height: AppSpacing.spaceSm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.spaceSm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: Text(
                      'Belum ada area pantauan pribadi. Anda dapat menambahkannya melalui halaman Profil.',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEmergency112Dialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedLg,
          ),
          title: Row(
            children: [
              const Icon(Icons.call_rounded, color: AppColors.error),
              const SizedBox(width: AppSpacing.spaceXs),
              Text(
                'Panggilan Darurat 112',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.textHeader,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            '(Fitur belum terhubung dengan sistem 112 nyata dan hanya berupa tampilan)\nLayanan darurat nasional 112 aktif 24 jam dan bebas pulsa. Gunakan hanya untuk kondisi darurat yang mengancam keselamatan jiwa.',
            style: AppTypography.bodyMd,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menghubungi layanan darurat 112...'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
              ),
              child: const Text('Hubungi 112'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

class _WatchAreaOptionTile extends StatelessWidget {
  const _WatchAreaOptionTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.surfaceTintIce : AppColors.surfaceCanvas,
      borderRadius: AppRadius.roundedMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          padding: const EdgeInsets.all(AppSpacing.spaceSm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(subtitle, style: AppTypography.caption),
                  ],
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
