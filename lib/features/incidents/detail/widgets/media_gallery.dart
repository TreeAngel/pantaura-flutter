import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../incident_detail_state.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  1. MEDIA GALLERY
// ═══════════════════════════════════════════════════════════════════════════

const String _mediaPlaceholder = 'assets/images/data-not-found.png';

String _formatDate(DateTime? dateTime) {
  if (dateTime == null) return '-';
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
}

class MediaGalleryCard extends StatefulWidget {
  const MediaGalleryCard({super.key, 
    required this.allMedia,
    required this.visibleCount,
    required this.onShowMore,
  });

  final List<MediaItem> allMedia;
  final int visibleCount;
  final VoidCallback onShowMore;

  @override
  State<MediaGalleryCard> createState() => _MediaGalleryCardState();
}

class _MediaGalleryCardState extends State<MediaGalleryCard> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(covariant MediaGalleryCard oldWidget) {
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
