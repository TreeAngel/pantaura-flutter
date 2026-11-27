import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import 'accessibility_section.dart';

/// Menu pengaturan & keamanan — pajangan, tap memunculkan snackbar.
class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key, required this.onComingSoon});

  final ValueChanged<String> onComingSoon;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      title: 'Pengaturan & Keamanan',
      children: [
        _MenuTile(
          icon: Icons.radar_rounded,
          title: 'Radius Pantau Siaga',
          subtitle: 'Kel. Bidara Cina (Radius 3 KM)',
          onTap: () => onComingSoon('Radius Pantau Siaga'),
        ),
        const SizedBox(height: AppSpacing.space2xs),
        _MenuTile(
          icon: Icons.notifications_active_rounded,
          title: 'Peringatan Dini Bencana',
          subtitle: 'Alarm kencang & getar aktif',
          onTap: () => onComingSoon('Peringatan Dini Bencana'),
        ),
        const SizedBox(height: AppSpacing.space2xs),
        _MenuTile(
          icon: Icons.lock_outline_rounded,
          title: 'Keamanan & Kata Sandi',
          subtitle: 'Kelola akses akun',
          onTap: () => onComingSoon('Keamanan & Kata Sandi'),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceSm,
            vertical: AppSpacing.space2xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadius.roundedMd,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
