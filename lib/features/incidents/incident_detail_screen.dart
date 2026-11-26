import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/api_models.dart';
import '../../core/network/api_exception.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/incident_status_chip.dart';
import '../auth/auth_notifier.dart';
import 'incident_detail_notifier.dart';
import 'incident_detail_state.dart';

const String _mediaPlaceholder = 'assets/images/data-not-found.png';

String _formatDate(DateTime? dateTime) {
  if (dateTime == null) return '-';
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
}

String _formatDistance(double? distanceKm) {
  if (distanceKm == null) return '-';
  if (distanceKm < 1) return '${(distanceKm * 1000).round()} m';
  return '${distanceKm.toStringAsFixed(1)} km';
}

IncidentStatus _parseStatus(String status) => switch (status) {
  'verified' => IncidentStatus.verified,
  'resolution_submitted' => IncidentStatus.resolutionSubmitted,
  'resolved' => IncidentStatus.resolved,
  'rejected' => IncidentStatus.rejected,
  _ => IncidentStatus.unverified,
};

// ═══════════════════════════════════════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════════════════════════════════════

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
          onAddReport: () => context.push(AppRoutes.createReport),
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
  });

  final IncidentDetailData data;
  final bool isAuthenticated;
  final VoidCallback onToggleSort;
  final VoidCallback onShowMoreMedia;
  final VoidCallback onToggleConfirm;
  final VoidCallback onOpenMap;
  final VoidCallback onAddReport;

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
                  _MediaGalleryCard(
                    allMedia: data.allMedia,
                    visibleCount: data.visibleMediaCount,
                    onShowMore: onShowMoreMedia,
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),
                  _ValidationBanner(incident: data.incident),
                  _IncidentSummarySection(incident: data.incident),
                  const SizedBox(height: AppSpacing.spaceMd),
                  _LocationCard(incident: data.incident, onOpenMap: onOpenMap),
                  const SizedBox(height: AppSpacing.spaceMd),
                  _TimelineSection(
                    timeline: data.timeline,
                    isSortAscending: data.isSortAscending,
                    onToggleSort: onToggleSort,
                  ),
                  const SizedBox(height: AppSpacing.spaceMd),
                  _NearestSafeZoneCard(
                    safeZone: data.nearestSafeZone,
                    distanceKm: data.nearestSafeZoneDistanceKm,
                  ),
                ],
              ),
            ),
          ),
          _DetailActionBar(
            isAuthenticated: isAuthenticated,
            isConfirmLoading: data.isConfirmLoading,
            onAddReport: onAddReport,
            onConfirm: onToggleConfirm,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  1. MEDIA GALLERY
// ═══════════════════════════════════════════════════════════════════════════

class _MediaGalleryCard extends StatefulWidget {
  const _MediaGalleryCard({
    required this.allMedia,
    required this.visibleCount,
    required this.onShowMore,
  });

  final List<MediaItem> allMedia;
  final int visibleCount;
  final VoidCallback onShowMore;

  @override
  State<_MediaGalleryCard> createState() => _MediaGalleryCardState();
}

class _MediaGalleryCardState extends State<_MediaGalleryCard> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(covariant _MediaGalleryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allMedia.isNotEmpty &&
        _selectedIndex >= widget.allMedia.length) {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.allMedia;
    if (media.isEmpty) return const _EmptyMediaCard();

    final selected = media[_selectedIndex];
    final showMoreNeeded = media.length > widget.visibleCount;
    // Tombol "tampilkan lebih banyak" menempati slot ke-10 (baris 2, kolom 5).
    final thumbnailCount = showMoreNeeded
        ? widget.visibleCount - 1
        : widget.visibleCount;
    final visibleMedia = media.take(thumbnailCount).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    selected.media.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Image.asset(_mediaPlaceholder, fit: BoxFit.cover),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.onPrimary,
                        ),
                      );
                    },
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x6600476E),
                            Colors.transparent,
                            Color(0xCC00476E),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.spaceSm,
                    right: AppSpacing.spaceSm,
                    child: _MediaCounterBadge(
                      current: _selectedIndex + 1,
                      total: media.length,
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.spaceSm,
                    right: AppSpacing.spaceSm,
                    bottom: AppSpacing.spaceSm,
                    child: _HeroCaption(item: selected),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceXs + 4),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1.25,
                ),
                itemCount: visibleMedia.length + (showMoreNeeded ? 1 : 0),
                itemBuilder: (context, index) {
                  if (showMoreNeeded && index == visibleMedia.length) {
                    return _ShowMoreButton(onTap: widget.onShowMore);
                  }
                  final item = visibleMedia[index];
                  return _ThumbnailItem(
                    item: item,
                    isSelected: media.indexOf(item) == _selectedIndex,
                    onTap: () =>
                        setState(() => _selectedIndex = media.indexOf(item)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaCounterBadge extends StatelessWidget {
  const _MediaCounterBadge({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.inverseSurface.withValues(alpha: 0.85),
        borderRadius: AppRadius.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_camera_outlined,
            size: 16,
            color: AppColors.inverseOnSurface,
          ),
          const SizedBox(width: AppSpacing.space2xs),
          Text(
            '$current/$total Media Lapangan',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.inverseOnSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCaption extends StatelessWidget {
  const _HeroCaption({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.parentDescription,
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 14,
              color: AppColors.surfaceTintIce,
            ),
            const SizedBox(width: AppSpacing.space2xs),
            Text(
              'Diunggah ${_formatDate(item.media.createdAt)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.surfaceTintIce,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThumbnailItem extends StatelessWidget {
  const _ThumbnailItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final MediaItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedSm,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.6,
          child: Image.network(
            item.media.url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Image.asset(_mediaPlaceholder, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _ShowMoreButton extends StatelessWidget {
  const _ShowMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedSm,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.roundedSm,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Center(
          child: Text(
            '+ Lainnya',
            textAlign: TextAlign.center,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMediaCard extends StatelessWidget {
  const _EmptyMediaCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(_mediaPlaceholder, height: 80),
              const SizedBox(height: AppSpacing.spaceXs),
              Text('Belum ada foto dokumentasi', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  2. VALIDATION BANNER
// ═══════════════════════════════════════════════════════════════════════════

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.incident});

  final IncidentDetailModel incident;

  @override
  Widget build(BuildContext context) {
    if (incident.status != 'verified') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.statusVerifiedBg,
          borderRadius: AppRadius.roundedLg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppSpacing.minTouchTarget,
              height: AppSpacing.minTouchTarget,
              decoration: BoxDecoration(
                color: AppColors.statusVerified,
                borderRadius: AppRadius.roundedMd,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.onPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.spaceXs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusVerified,
                          borderRadius: AppRadius.roundedStandard,
                        ),
                        child: Text(
                          'VALIDASI LAPANGAN',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'Pembaruan: ${_formatDate(incident.verifiedAt)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.statusVerified,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    (incident.statusLabel.isNotEmpty
                            ? incident.statusLabel
                            : 'Terkonfirmasi aktif')
                        .toUpperCase(),
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.statusVerified,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2xs),
                  Text(
                    'Kejadian ini telah divalidasi oleh tim berwenang dan relawan lapangan.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  3. SUMMARY (CHIP + TITLE)
// ═══════════════════════════════════════════════════════════════════════════

class _IncidentSummarySection extends StatelessWidget {
  const _IncidentSummarySection({required this.incident});

  final IncidentDetailModel incident;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.spaceXs,
              runSpacing: AppSpacing.spaceXs,
              children: [
                _DisasterTypeChip(label: incident.disasterTypeLabel),
                IncidentStatusChip(
                  status: _parseStatus(incident.status),
                  customLabel: incident.statusLabel.isEmpty
                      ? null
                      : incident.statusLabel.toUpperCase(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              incident.title,
              style: AppTypography.headlineLg.copyWith(
                color: AppColors.textHeader,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              incident.description,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            _SummaryStatsRow(incident: incident),
          ],
        ),
      ),
    );
  }
}

class _DisasterTypeChip extends StatelessWidget {
  const _DisasterTypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.statusChipMinHeight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceTintIce,
        borderRadius: AppRadius.roundedStandard,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flood_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.space2xs),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatsRow extends StatelessWidget {
  const _SummaryStatsRow({required this.incident});

  final IncidentDetailModel incident;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.spaceXs,
      runSpacing: AppSpacing.spaceXs,
      children: [
        _StatChip(
          icon: Icons.article_outlined,
          label: '${incident.reportsCount} Laporan',
        ),
        _StatChip(
          icon: Icons.calendar_today_outlined,
          label: _formatDate(incident.verifiedAt ?? incident.createdAt),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: AppSpacing.space2xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.roundedStandard,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.space2xs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  4. LOCATION CARD + STATIC MAP
// ═══════════════════════════════════════════════════════════════════════════

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.incident, required this.onOpenMap});

  final IncidentDetailModel incident;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final address = incident.address?.trim();
    final displayAddress = (address != null && address.isNotEmpty)
        ? address
        : 'Lat: ${incident.latitude.toStringAsFixed(5)}, '
              'Lng: ${incident.longitude.toStringAsFixed(5)}';
    final center = LatLng(incident.latitude, incident.longitude);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spaceMd,
                AppSpacing.spaceMd,
                AppSpacing.spaceMd,
                AppSpacing.spaceXs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.statusVerified,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Expanded(
                    child: Text(
                      displayAddress,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.minTouchTarget,
                child: OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.near_me_rounded),
                  label: const Text('Buka di Peta'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Stack(
              children: [
                SizedBox(
                  height: 176,
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 15,
                      // Peta preview tidak bisa digeser / di-zoom.
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.paradisus.animalium.pantaura',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 32,
                            height: 32,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppColors.statusVerified,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: AppSpacing.spaceXs,
                  bottom: AppSpacing.spaceXs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceXs,
                      vertical: AppSpacing.space2xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard.withValues(alpha: 0.9),
                      borderRadius: AppRadius.roundedStandard,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.space2xs),
                        Text(
                          '${incident.latitude.toStringAsFixed(4)}, '
                          '${incident.longitude.toStringAsFixed(4)}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTintIce.withValues(alpha: 0.6),
                  borderRadius: AppRadius.roundedMd,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.statusResolution,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: AppColors.onPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Multiple Reports, One Incident',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textHeader,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Digabungkan dari ${incident.reportsCount} laporan warga & relawan untuk penanganan terpadu.',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  5. TIMELINE
// ═══════════════════════════════════════════════════════════════════════════

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.timeline,
    required this.isSortAscending,
    required this.onToggleSort,
  });

  final List<TimelineEntry> timeline;
  final bool isSortAscending;
  final VoidCallback onToggleSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: Text(
                    'Kronologi Laporan Lapangan',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.textHeader,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onToggleSort,
                  borderRadius: AppRadius.roundedFull,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: AppSpacing.statusChipMinHeight,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTintIce,
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${timeline.length} Laporan',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space2xs),
                          Icon(
                            isSortAscending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            if (timeline.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceMd),
                child: Text('Belum ada laporan.', style: AppTypography.caption),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                    top: AppSpacing.space2xs,
                    right: AppSpacing.space2xs,
                  ),
                  itemCount: timeline.length,
                  separatorBuilder: (_, _) => Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: Container(
                      height: 20,
                      width: 2,
                      color: AppColors.surfaceContainerHighest,
                    ),
                  ),
                  itemBuilder: (context, index) =>
                      _TimelineEntryTile(entry: timeline[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntryTile extends StatelessWidget {
  const _TimelineEntryTile({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final isReport = entry.type == TimelineEntryType.report;
    final badgeColor = isReport
        ? AppColors.primaryContainer
        : AppColors.statusResolvedBg;
    final badgeText = isReport ? 'Laporan' : 'Resolusi';
    final badgeTextColor = isReport
        ? AppColors.onPrimaryContainer
        : AppColors.statusResolved;
    final firstMediaUrl = entry.media.isEmpty ? null : entry.media.first.url;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 18, right: 11),
          decoration: BoxDecoration(
            color: isReport
                ? AppColors.statusVerified
                : AppColors.statusResolved,
            shape: BoxShape.circle,
          ),
        ),
        ClipRRect(
          borderRadius: AppRadius.roundedMd,
          child: SizedBox(
            width: 48,
            height: 48,
            child: firstMediaUrl == null
                ? _TimelineAvatarPlaceholder(isReport: isReport)
                : Image.network(
                    firstMediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _TimelineAvatarPlaceholder(isReport: isReport),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceSm),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.roundedMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.authorName ?? 'Anonim',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textHeader,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    Text(
                      _formatDate(entry.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Text(
                    badgeText,
                    style: AppTypography.labelSm.copyWith(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space2xs),
                Text(
                  entry.description,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineAvatarPlaceholder extends StatelessWidget {
  const _TimelineAvatarPlaceholder({required this.isReport});

  final bool isReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isReport ? AppColors.statusVerifiedBg : AppColors.statusResolvedBg,
      child: Icon(
        isReport ? Icons.article_rounded : Icons.task_alt_rounded,
        color: isReport ? AppColors.statusVerified : AppColors.statusResolved,
        size: 24,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  6. NEAREST SAFE ZONE
// ═══════════════════════════════════════════════════════════════════════════

class _NearestSafeZoneCard extends StatelessWidget {
  const _NearestSafeZoneCard({
    required this.safeZone,
    required this.distanceKm,
  });

  final SafeZoneModel? safeZone;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final zone = safeZone;
    final zoneAddress = zone?.address;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  size: 22,
                  color: AppColors.statusVerified,
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: Text(
                    'Posko & Bantuan Terdekat',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.textHeader,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusResolvedBg,
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text(
                    'Siaga 24 Jam',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.statusResolved,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            if (zone == null)
              Text(
                'Tidak ada posko terdekat yang ditemukan.',
                style: AppTypography.caption,
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.roundedMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.textHeader,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Wrap(
                      spacing: AppSpacing.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (zone.type.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Text(
                              zone.type,
                              style: AppTypography.caption,
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.space2xs),
                            Text(
                              'Jarak ${_formatDistance(distanceKm)}',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (zone.capacity != null) ...[
                      const SizedBox(height: AppSpacing.space2xs),
                      Text(
                        'Kapasitas: ${zone.capacity} orang',
                        style: AppTypography.bodySm,
                      ),
                    ],
                    if (zoneAddress != null && zoneAddress.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space2xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.space2xs),
                          Expanded(
                            child: Text(
                              zoneAddress,
                              style: AppTypography.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  7. STICKY ACTION FOOTER
// ═══════════════════════════════════════════════════════════════════════════

class _DetailActionBar extends StatelessWidget {
  const _DetailActionBar({
    required this.isAuthenticated,
    required this.isConfirmLoading,
    required this.onAddReport,
    required this.onConfirm,
  });

  final bool isAuthenticated;
  final bool isConfirmLoading;
  final VoidCallback onAddReport;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.spaceXs + 4,
        AppSpacing.margin,
        AppSpacing.spaceXs + 4,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCanvas,
        boxShadow: AppShadows.level4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _AddReportButton(onTap: onAddReport)),
              if (isAuthenticated) ...[
                const SizedBox(width: AppSpacing.spaceSm),
                Expanded(
                  child: _CrowdConfirmButton(
                    isLoading: isConfirmLoading,
                    onConfirm: onConfirm,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.space2xs),
          Text(
            'Laporan tambahan diverifikasi otomatis oleh tim posko & relawan.',
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _AddReportButton extends StatelessWidget {
  const _AddReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.ctaButtonHeight,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Tambah Laporan'),
      ),
    );
  }
}

class _CrowdConfirmButton extends StatelessWidget {
  const _CrowdConfirmButton({required this.isLoading, required this.onConfirm});

  final bool isLoading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.ctaButtonHeight,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusResolution,
          foregroundColor: AppColors.onPrimary,
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : const Icon(Icons.thumb_up_alt_outlined),
        label: Text(isLoading ? 'Memproses...' : 'Konfirmasi Kejadian'),
      ),
    );
  }
}
