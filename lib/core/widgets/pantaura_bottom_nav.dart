import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../routing/app_routes.dart';
import '../theme/theme.dart';

/// Bottom Navigation Bar dengan Center Emergency FAB sesuai Stitch & DESIGN.md.
class PantauraBottomNav extends StatelessWidget {
  const PantauraBottomNav({
    super.key,
    required this.currentIndex,
  });

  /// 0: Beranda, 1: Peta, 2: Riwayat, 3: Profil
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.96),
        boxShadow: AppShadows.level4,
        border: const Border(
          top: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavTabItem(
                    icon: Icons.home_rounded,
                    label: 'Beranda',
                    isActive: currentIndex == 0,
                    onTap: () => context.go(AppRoutes.home),
                  ),
                  _NavTabItem(
                    icon: Icons.explore_rounded,
                    label: 'Peta',
                    isActive: currentIndex == 1,
                    onTap: () => context.go(AppRoutes.map),
                  ),
                  const SizedBox(width: 76), // Ruang untuk Center FAB Lapor
                  _NavTabItem(
                    icon: Icons.history_rounded,
                    label: 'Riwayat',
                    isActive: currentIndex == 2,
                    onTap: () => context.go(AppRoutes.history),
                  ),
                  _NavTabItem(
                    icon: Icons.person_rounded,
                    label: 'Profil',
                    isActive: currentIndex == 3,
                    onTap: () => context.go(AppRoutes.profile),
                  ),
                ],
              ),
              Positioned(
                top: -22,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: AppColors.statusResolution,
                      shape: CircleBorder(
                        side: BorderSide(
                          color: AppColors.surfaceTintIce,
                          width: 4,
                        ),
                      ),
                      elevation: 6,
                      shadowColor: AppColors.shadowNavy.withValues(alpha: 0.35),
                      child: InkWell(
                        onTap: () => context.push(AppRoutes.createReport),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: AppSpacing.emergencyFabSize,
                          height: AppSpacing.emergencyFabSize,
                          child: Icon(
                            Icons.campaign_rounded,
                            color: AppColors.onPrimary,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lapor',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedMd,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 64,
          minHeight: AppSpacing.minTouchTarget,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
