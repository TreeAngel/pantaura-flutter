import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/api_models.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../auth/auth_notifier.dart';
import 'incident_detail_notifier.dart';
import 'incident_detail_state.dart';

import 'widgets/location_section.dart';
import 'widgets/media_gallery.dart';
import 'widgets/nearest_safte_zone_card.dart';
import 'widgets/sticky_action_footer.dart';
import 'widgets/summary_section.dart';
import 'widgets/timeline_section.dart';
import 'widgets/validation_banner.dart';

// Halaman detail insiden (bencana)

class IncidentDetailScreen extends ConsumerStatefulWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  ConsumerState<IncidentDetailScreen> createState() =>
      _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends ConsumerState<IncidentDetailScreen> {
  /// Dialog darurat 112 — identik dengan home_screen.dart.
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
            '(Fitur belum terhubung dengan sistem 112 nyata dan hanya berupa tampilan)\n'
            'Layanan darurat nasional 112 aktif 24 jam dan bebas pulsa. '
            'Gunakan hanya untuk kondisi darurat yang mengancam keselamatan jiwa.',
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

  /// Buka halaman peta dengan mengoper koordinat insiden lewat query params.
  void _openMap(IncidentDetailModel incident) {
    final location = Uri(
      path: AppRoutes.map,
      queryParameters: {
        'lat': incident.latitude.toString(),
        'lng': incident.longitude.toString(),
      },
    ).toString();
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(incidentDetailProvider(widget.incidentId));
    final isAuthenticated =
        ref.watch(authNotifierProvider) is AuthAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: _IncidentDetailAppBar(onEmergencyTap: _showEmergency112Dialog),
      body: detailAsync.when(
        loading: () => const _LoadingBody(),
        error: (error, _) => _ErrorBody(
          message: error is ApiException
              ? error.message
              : 'Gagal memuat detail insiden. Periksa koneksi internet Anda.',
          onRetry: () =>
              ref.invalidate(incidentDetailProvider(widget.incidentId)),
        ),
        data: (data) => _DetailBody(
          data: data,
          isAuthenticated: isAuthenticated,
          onToggleSort: () => ref
              .read(incidentDetailProvider(widget.incidentId).notifier)
              .toggleSort(),
          onShowMoreMedia: () => ref
              .read(incidentDetailProvider(widget.incidentId).notifier)
              .showMoreMedia(),
          onToggleConfirm: () => ref
              .read(incidentDetailProvider(widget.incidentId).notifier)
              .toggleConfirm(widget.incidentId),
          onOpenMap: () => _openMap(data.incident),
          onAddReport: () => context.push(
            AppRoutes.incidentAddReport(data.incident.id),
            extra: data.incident,
          ),
          onReportRecovered: () => context.push(
            AppRoutes.incidentRecovered(data.incident.id),
            extra: data.incident,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  APP BAR
// ═══════════════════════════════════════════════════════════════════════════

class _IncidentDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _IncidentDetailAppBar({required this.onEmergencyTap});

  final VoidCallback onEmergencyTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceCanvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textHeader),
        tooltip: 'Kembali',
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Detail Insiden Bencana',
        style: AppTypography.headlineMd.copyWith(color: AppColors.textHeader),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.spaceXs),
          child: IconButton(
            icon: const Icon(Icons.call_rounded, color: AppColors.onError),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.statusVerified,
              minimumSize: const Size(44, 44),
              shape: const CircleBorder(),
            ),
            tooltip: 'Panggilan Darurat 112',
            onPressed: onEmergencyTap,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  LOADING / ERROR / BODY
// ═══════════════════════════════════════════════════════════════════════════

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

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
              'Gagal Memuat Detail Insiden',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.textHeader,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              message,
              style: AppTypography.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.data,
    required this.isAuthenticated,
    required this.onToggleSort,
    required this.onShowMoreMedia,
    required this.onToggleConfirm,
    required this.onOpenMap,
    required this.onAddReport,
    required this.onReportRecovered,
  });

  final IncidentDetailData data;
  final bool isAuthenticated;
  final VoidCallback onToggleSort;
  final VoidCallback onShowMoreMedia;
  final VoidCallback onToggleConfirm;
  final VoidCallback onOpenMap;
  final VoidCallback onAddReport;
  final VoidCallback onReportRecovered;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.spaceMd),
                  MediaGalleryCard(
                    allMedia: data.allMedia,
                    visibleCount: data.visibleMediaCount,
                    onShowMore: onShowMoreMedia,
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),
                  ValidationBanner(incident: data.incident),
                  IncidentSummarySection(incident: data.incident),
                  const SizedBox(height: AppSpacing.spaceMd),
                  LocationCard(incident: data.incident, onOpenMap: onOpenMap),
                  const SizedBox(height: AppSpacing.spaceMd),
                  TimelineSection(
                    timeline: data.timeline,
                    isSortAscending: data.isSortAscending,
                    onToggleSort: onToggleSort,
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),
                  NearestSafeZoneCard(
                    safeZone: data.nearestSafeZone,
                    distanceKm: data.nearestSafeZoneDistanceKm,
                  ),
                ],
              ),
            ),
          ),
          DetailActionBar(
            isAuthenticated: isAuthenticated,
            resolvedAt: data.incident.resolvedAt,
            onAddReport: onAddReport,
            onConfirm: onToggleConfirm,
            onReportRecovered: onReportRecovered,
          ),
        ],
      ),
    );
  }
}
