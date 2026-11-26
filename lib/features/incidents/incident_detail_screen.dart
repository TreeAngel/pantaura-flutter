import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/api_models.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/incident_status_chip.dart';
import '../auth/auth_notifier.dart';
import 'incident_detail_notifier.dart';
import 'incident_detail_state.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class IncidentDetailScreen extends ConsumerStatefulWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  ConsumerState<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends ConsumerState<IncidentDetailScreen> {
  Future<void> _showEmergency112Dialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
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

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(incidentDetailProvider(widget.incidentId));
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState is AuthAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Insiden',
          style: AppTypography.headlineSm.copyWith(color: AppColors.onPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_rounded, color: AppColors.onError),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
            ),
            tooltip: 'Panggil Darurat 112',
            onPressed: _showEmergency112Dialog,
          ),
          const SizedBox(width: AppSpacing.spaceXs),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(message: e.toString(), onRetry: () {
          ref.invalidate(incidentDetailProvider(widget.incidentId));
        }),
        data: (data) => _DetailBody(
          data: data,
          incidentId: widget.incidentId,
          isAuthenticated: isAuthenticated,
          onToggleSort: () =>
              ref.read(incidentDetailProvider(widget.incidentId).notifier).toggleSort(),
          onShowMoreMedia: () =>
              ref.read(incidentDetailProvider(widget.incidentId).notifier).showMoreMedia(),
          onToggleConfirm: () => ref
              .read(incidentDetailProvider(widget.incidentId).notifier)
              .toggleConfirm(widget.incidentId),
          onOpenMap: () => context.go(AppRoutes.map),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BODY
// ═══════════════════════════════════════════════════════════════════════════

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.spaceMd),
            Text('Gagal memuat detail insiden', style: AppTypography.headlineSm),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(message, style: AppTypography.bodySm, textAlign: TextAlign.center),
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
    required this.incidentId,
    required this.isAuthenticated,
    required this.onToggleSort,
    required this.onShowMoreMedia,
    required this.onToggleConfirm,
    required this.onOpenMap,
  });

  final IncidentDetailData data;
  final String incidentId;
  final bool isAuthenticated;
  final VoidCallback onToggleSort;
  final VoidCallback onShowMoreMedia;
  final VoidCallback onToggleConfirm;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DisasterStatusHeader(incident: data.incident),
          _IncidentSummarySection(incident: data.incident),
          const SizedBox(height: AppSpacing.spaceMd),
          _LocationCard(incident: data.incident, onOpenMap: onOpenMap),
          const SizedBox(height: AppSpacing.spaceMd),
          _MediaGalleryCard(
            allMedia: data.allMedia,
            visibleCount: data.visibleMediaCount,
            onShowMore: onShowMoreMedia,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          _TimelineSection(
            timeline: data.timeline,
            isSortAscending: data.isSortAscending,
            onToggleSort: onToggleSort,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          _NearestSafeZoneCard(
            safeZone: data.nearestSafeZone,
            incidentLat: data.incident.latitude,
            incidentLng: data.incident.longitude,
          ),
          if (isAuthenticated) ...[
            const SizedBox(height: AppSpacing.spaceMd),
            _CrowdConfirmButton(
              isLoading: data.isConfirmLoading,
              onConfirm: onToggleConfirm,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

// ── 1. Disaster Status Header ─────────────────────────────────────────────

class _DisasterStatusHeader extends StatelessWidget {
  const _DisasterStatusHeader({required this.incident});

  final IncidentDetailModel incident;

  IncidentStatus _parseStatus(String status) => switch (status) {
        'verified' => IncidentStatus.verified,
        'resolution_submitted' => IncidentStatus.resolutionSubmitted,
        'resolved' => IncidentStatus.resolved,
        'rejected' => IncidentStatus.rejected,
        _ => IncidentStatus.unverified,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceMd,
      ),
      color: AppColors.surfaceContainerLow,
      child: Wrap(
        spacing: AppSpacing.spaceXs,
        runSpacing: AppSpacing.spaceXs,
        children: [
          _DisasterTypeChip(label: incident.disasterTypeLabel),
          IncidentStatusChip(status: _parseStatus(incident.status)),
        ],
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
      constraints: const BoxConstraints(minHeight: AppSpacing.statusChipMinHeight),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.roundedStandard,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded, size: 14, color: AppColors.onPrimaryContainer),
          const SizedBox(width: AppSpacing.space2xs),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Incident Summary Section ───────────────────────────────────────────

class _IncidentSummarySection extends StatelessWidget {
  const _IncidentSummarySection({required this.incident});

  final IncidentDetailModel incident;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.spaceMd,
        AppSpacing.margin,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(incident.title, style: AppTypography.headlineLg),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            incident.description,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          _SummaryStatsRow(incident: incident),
        ],
      ),
    );
  }
}

class _SummaryStatsRow extends StatelessWidget {
  const _SummaryStatsRow({required this.incident});

  final IncidentDetailModel incident;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.article_outlined,
          label: '${incident.reportsCount} Laporan',
        ),
        const SizedBox(width: AppSpacing.spaceXs),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm, vertical: AppSpacing.space2xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
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

// ── 3. Location Card ──────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.incident, required this.onOpenMap});

  final IncidentDetailModel incident;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final address = incident.address?.isNotEmpty == true
        ? incident.address!
        : 'Lat: ${incident.latitude.toStringAsFixed(5)}, Lng: ${incident.longitude.toStringAsFixed(5)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
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
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Expanded(
                    child: Text(address, style: AppTypography.bodyMd),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.minTouchTarget,
                child: OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Buka Peta'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.lg),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
              child: SizedBox(
                height: 160,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(incident.latitude, incident.longitude),
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.paradisus.animalium.pantaura',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(incident.latitude, incident.longitude),
                          width: 32,
                          height: 32,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppColors.error,
                            size: 32,
                          ),
                        ),
                      ],
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

// ── 4. Media Gallery Card ─────────────────────────────────────────────────

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

  static const String _placeholder = 'assets/images/data-not-found.png';

  @override
  void didUpdateWidget(_MediaGalleryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex >= widget.allMedia.length && widget.allMedia.isNotEmpty) {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allMedia.isEmpty) {
      return _buildEmptyCard();
    }

    final selected = widget.allMedia[_selectedIndex];
    final showMoreNeeded = widget.allMedia.length > widget.visibleCount;
    // Visible thumbnails: show visibleCount - 1 actual thumbnails + "show more" if needed,
    // or all visibleCount thumbnails if no show-more needed.
    final thumbCount = showMoreNeeded ? widget.visibleCount - 1 : widget.visibleCount;
    final visibleMedia = widget.allMedia.take(thumbCount).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
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
              child: Text('Foto & Dokumentasi', style: AppTypography.headlineSm),
            ),
            // Main image viewer
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      selected.media.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        _placeholder,
                        fit: BoxFit.cover,
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    // Image title overlay
                    if (selected.parentDescription.isNotEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.spaceMd,
                            vertical: AppSpacing.spaceXs,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                          child: Text(
                            selected.parentDescription,
                            style: AppTypography.caption.copyWith(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Thumbnail grid (5 columns)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: visibleMedia.length + (showMoreNeeded ? 1 : 0),
                itemBuilder: (context, index) {
                  if (showMoreNeeded && index == visibleMedia.length) {
                    return _ShowMoreButton(onTap: widget.onShowMore);
                  }
                  final item = visibleMedia[index];
                  final isSelected = widget.allMedia.indexOf(item) == _selectedIndex;
                  return _ThumbnailItem(
                    item: item,
                    isSelected: isSelected,
                    placeholder: _placeholder,
                    onTap: () {
                      setState(() {
                        _selectedIndex = widget.allMedia.indexOf(item);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
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
              Image.asset('assets/images/data-not-found.png', height: 80),
              const SizedBox(height: AppSpacing.spaceXs),
              Text('Belum ada foto dokumentasi', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbnailItem extends StatelessWidget {
  const _ThumbnailItem({
    required this.item,
    required this.isSelected,
    required this.placeholder,
    required this.onTap,
  });

  final MediaItem item;
  final bool isSelected;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedSm,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.roundedSm,
          child: Opacity(
            opacity: isSelected ? 1.0 : 0.6,
            child: Image.network(
              item.media.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(placeholder, fit: BoxFit.cover),
            ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.roundedSm,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Center(
          child: Icon(Icons.add_rounded, size: 20, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

// ── 5. Timeline Section ───────────────────────────────────────────────────

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
                children: [
                  Text('Kronologi Laporan', style: AppTypography.headlineSm),
                  const Spacer(),
                  GestureDetector(
                    onTap: onToggleSort,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: AppSpacing.statusChipMinHeight),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.roundedStandard,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${timeline.length} laporan',
                            style: AppTypography.labelSm,
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
                ],
              ),
            ),
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.spaceMd,
                    0,
                    AppSpacing.spaceMd,
                    AppSpacing.spaceMd,
                  ),
                  itemCount: timeline.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(left: 24 + AppSpacing.spaceSm),
                    child: Container(height: 24, width: 2, color: AppColors.outlineVariant),
                  ),
                  itemBuilder: (context, index) => _TimelineEntryTile(
                    entry: timeline[index],
                    isLast: index == timeline.length - 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntryTile extends StatelessWidget {
  const _TimelineEntryTile({required this.entry, required this.isLast});

  final TimelineEntry entry;
  final bool isLast;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isReport = entry.type == TimelineEntryType.report;
    final badgeColor = isReport ? AppColors.statusVerifiedBg : AppColors.statusResolvedBg;
    final badgeText = isReport ? 'Laporan' : 'Resolusi';
    final badgeTextColor = isReport ? AppColors.statusVerified : AppColors.statusResolved;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar / photo
        ClipRRect(
          borderRadius: AppRadius.roundedFull,
          child: SizedBox(
            width: 48,
            height: 48,
            child: entry.media.isNotEmpty
                ? Image.network(
                    entry.media.first.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _AvatarPlaceholder(isReport: isReport),
                  )
                : _AvatarPlaceholder(isReport: isReport),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Text(
                      badgeText,
                      style: AppTypography.labelSm.copyWith(
                        color: badgeTextColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Flexible(
                    child: Text(
                      entry.authorName ?? 'Anonim',
                      style: AppTypography.labelSm,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2xs),
              Text(
                entry.description,
                style: AppTypography.bodySm,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.space2xs),
              Text(_formatDate(entry.createdAt), style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.isReport});

  final bool isReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isReport ? AppColors.statusVerifiedBg : AppColors.statusResolvedBg,
      child: Icon(
        isReport ? Icons.article_rounded : Icons.check_circle_rounded,
        color: isReport ? AppColors.statusVerified : AppColors.statusResolved,
        size: 24,
      ),
    );
  }
}

// ── 6. Nearest Safe Zone Card ─────────────────────────────────────────────

class _NearestSafeZoneCard extends StatelessWidget {
  const _NearestSafeZoneCard({
    required this.safeZone,
    required this.incidentLat,
    required this.incidentLng,
  });

  final SafeZoneModel? safeZone;
  final double incidentLat;
  final double incidentLng;

  String _distanceLabel(SafeZoneModel zone) {
    final dlat = zone.latitude - incidentLat;
    final dlng = zone.longitude - incidentLng;
    // 1 degree ≈ 111 km
    final km = (111.0 * (dlat * dlat + dlng * dlng));
    return km < 1 ? '< 1 km' : '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.spaceXs),
                Text('Posko Terdekat', style: AppTypography.headlineSm),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            if (safeZone == null)
              Text('Tidak ada posko terdekat yang ditemukan.', style: AppTypography.caption)
            else ...[
              Text(safeZone!.name, style: AppTypography.labelLg),
              const SizedBox(height: AppSpacing.space2xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Text(safeZone!.type, style: AppTypography.caption),
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Icon(Icons.near_me_rounded, size: 12, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 2),
                  Text(_distanceLabel(safeZone!), style: AppTypography.caption),
                ],
              ),
              if (safeZone!.address?.isNotEmpty == true) ...[
                const SizedBox(height: AppSpacing.space2xs),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Expanded(child: Text(safeZone!.address!, style: AppTypography.caption)),
                  ],
                ),
              ],
              if (safeZone!.capacity != null) ...[
                const SizedBox(height: AppSpacing.space2xs),
                Row(
                  children: [
                    const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text('Kapasitas: ${safeZone!.capacity}', style: AppTypography.caption),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── 7. Crowd Confirm Button ───────────────────────────────────────────────

class _CrowdConfirmButton extends StatelessWidget {
  const _CrowdConfirmButton({
    required this.isLoading,
    required this.onConfirm,
  });

  final bool isLoading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.ctaButtonHeight,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
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
      ),
    );
  }
}
