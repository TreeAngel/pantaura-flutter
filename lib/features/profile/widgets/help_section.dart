import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme.dart';
import 'accessibility_section.dart';

const String _bnpbGuideUrl =
    'https://www.bnpb.go.id/storage/app/media/Buku%20BNPB/Buku%20Saku%20Bencana%20BNPB.pdf';

/// Informasi & pusat bantuan: panduan BNPB, call 112, dan item pajangan.
class HelpSection extends StatelessWidget {
  const HelpSection({
    super.key,
    required this.onComingSoon,
    required this.onEmergencyCall,
  });

  final ValueChanged<String> onComingSoon;
  final VoidCallback onEmergencyCall;

  Future<void> _openGuide() async {
    final uri = Uri.parse(_bnpbGuideUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Abaikan bila browser tidak tersedia.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      title: 'Informasi & Pusat Bantuan',
      children: [
        _MenuTile(
          icon: Icons.menu_book_rounded,
          title: 'Buku Panduan Tanggap Bencana BNPB',
          subtitle: 'Panduan saku mitigasi & tanggap darurat',
          highlighted: false,
          onTap: _openGuide,
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        _MenuTile(
          icon: Icons.sos_rounded,
          title: 'Call Center Siaga Darurat 112',
          subtitle: 'Bebas pulsa • BPBD Provinsi DKI Jakarta',
          highlighted: true,
          onTap: onEmergencyCall,
        ),
        // const SizedBox(height: AppSpacing.space2xs),
        // _MenuTile(
        //   icon: Icons.privacy_tip_outlined,
        //   title: 'Kebijakan Privasi',
        //   subtitle: 'Pengelolaan data pribadi warga',
        //   highlighted: false,
        //   onTap: () => onComingSoon('Kebijakan Privasi'),
        // ),
        // const SizedBox(height: AppSpacing.space2xs),
        // _MenuTile(
        //   icon: Icons.info_outline_rounded,
        //   title: 'Versi Aplikasi',
        //   subtitle: 'Pantaura 0.1.0',
        //   highlighted: false,
        //   onTap: () => onComingSoon('Versi Aplikasi'),
        // ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        highlighted ? AppColors.statusVerified : AppColors.textPrimary;
    return Material(
      color: highlighted ? AppColors.statusVerifiedBg : Colors.transparent,
      borderRadius: AppRadius.roundedMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceSm,
            vertical: AppSpacing.space2xs,
          ),
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.statusVerifiedBg
                : AppColors.surfaceContainerLow,
            borderRadius: AppRadius.roundedMd,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: highlighted
                      ? AppColors.statusVerified
                      : AppColors.surfaceCard,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 20,
                  color: highlighted ? AppColors.onPrimary : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMd.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: highlighted
                            ? AppColors.statusVerified
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20,
                  color: highlighted ? AppColors.statusVerified : AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
