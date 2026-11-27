import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Opsi aksesibilitas — pajangan, tap memunculkan snackbar "masih dikembangkan".
class AccessibilitySection extends StatelessWidget {
  const AccessibilitySection({super.key, required this.onComingSoon});

  final ValueChanged<String> onComingSoon;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      icon: Icons.accessibility_new_rounded,
      title: 'Aksesibilitas & Ramah Lansia',
      subtitle: 'Kenyamanan membaca di ruang terbuka dan kondisi darurat',
      children: [
        _ToggleRow(
          icon: Icons.text_fields_rounded,
          title: 'Mode Teks Besar (+20%)',
          subtitle: 'Memperbesar tulisan laporan dan petunjuk evakuasi',
          onChanged: () => onComingSoon('Mode Teks Besar'),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        _ToggleRow(
          icon: Icons.contrast_rounded,
          title: 'Kontras Tinggi (Outdoor)',
          subtitle: 'Memaksimalkan keterbacaan di bawah sinar terik matahari',
          onChanged: () => onComingSoon('Kontras Tinggi'),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        _ToggleRow(
          icon: Icons.record_voice_over_rounded,
          title: 'Panduan Suara / Narasi Cepat',
          subtitle: 'Membacakan alert bencana via audio otomatis',
          onChanged: () => onComingSoon('Panduan Suara'),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
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
          Icon(icon, size: 24, color: AppColors.primary),
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
          Switch(
            value: false,
            onChanged: (_) => onChanged(),
            activeThumbColor: AppColors.statusResolution,
          ),
        ],
      ),
    );
  }
}

/// Kartu umum untuk section profil.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    required this.children,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (icon != null) ...[
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTintIce,
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.textHeader,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.space2xs),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(subtitle!, style: AppTypography.caption),
              ),
            ],
            const SizedBox(height: AppSpacing.spaceSm),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
              child: Text(
                title,
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.textHeader,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

