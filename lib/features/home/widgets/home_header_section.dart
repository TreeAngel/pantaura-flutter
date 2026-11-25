import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/models/api_models.dart';
import '../../../core/theme/theme.dart';

/// AppBar sticky di bagian atas Beranda sesuai desain Stitch.
class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({
    super.key,
    required this.unreadAlertsCount,
    required this.onProfileTap,
  });

  final int unreadAlertsCount;
  final VoidCallback onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.95),
        boxShadow: AppShadows.level2,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/pantaura-logo-svg.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceXs),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pantaura • Tanggap Sipil',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Beranda',
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.textHeader,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: AppRadius.roundedFull,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: AppSpacing.minTouchTarget,
                        height: AppSpacing.minTouchTarget,
                        alignment: Alignment.center,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      if (unreadAlertsCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.statusVerified,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surfaceCard,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bagian sapaan pengguna, tombol refresh, dan pemilih area pantauan aktif.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    super.key,
    required this.userName,
    required this.activeWatchArea,
    required this.isRefreshing,
    required this.onRefreshTap,
    required this.onWatchAreaTap,
  });

  final String userName;
  final WatchAreaModel? activeWatchArea;
  final bool isRefreshing;
  final VoidCallback onRefreshTap;
  final VoidCallback onWatchAreaTap;

  String _greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat Siang,';
    if (hour >= 15 && hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  @override
  Widget build(BuildContext context) {
    final locationLabel = activeWatchArea?.label ?? 'Semua Wilayah Pantauan';

    return Container(
      color: AppColors.surfaceCard,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.spaceXs,
        AppSpacing.margin,
        AppSpacing.spaceSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greetingByTime(),
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Halo, $userName',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Semantics(
                label: 'Perbarui Data Laporan',
                button: true,
                child: InkWell(
                  onTap: isRefreshing ? null : onRefreshTap,
                  borderRadius: AppRadius.roundedMd,
                  child: Container(
                    width: AppSpacing.minTouchTarget,
                    height: AppSpacing.minTouchTarget,
                    decoration: BoxDecoration(
                      color:
                          AppColors.statusResolutionBg.withValues(alpha: 0.45),
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: isRefreshing
                        ? const Padding(
                            padding: EdgeInsets.all(13),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.statusResolution,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.sync_rounded,
                            color: AppColors.statusResolution,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          InkWell(
            onTap: onWatchAreaTap,
            borderRadius: AppRadius.roundedMd,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              padding: const EdgeInsets.all(AppSpacing.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.surfaceCanvas,
                borderRadius: AppRadius.roundedMd,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.statusResolution.withValues(alpha: 0.12),
                      borderRadius: AppRadius.roundedStandard,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.statusResolution,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi Pantauan Aktif',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          locationLabel,
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ubah',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textHeader,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textHeader,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
