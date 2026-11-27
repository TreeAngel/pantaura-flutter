import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  7. STICKY ACTION FOOTER
// ═══════════════════════════════════════════════════════════════════════════

class DetailActionBar extends StatelessWidget {
  const DetailActionBar({
    super.key,
    required this.isAuthenticated,
    this.resolvedAt,
    required this.onAddReport,
    required this.onConfirm,
    required this.onReportRecovered,
  });

  final bool isAuthenticated;
  final DateTime? resolvedAt;
  final VoidCallback onAddReport;
  final VoidCallback onConfirm;
  final VoidCallback onReportRecovered;

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
          if (resolvedAt == null) ...[
            Row(
              children: [
                if (isAuthenticated) ...[
                  Expanded(child: _AddReportButton(onTap: onAddReport)),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: _CrowdConfirmButton(onTap: onReportRecovered),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.minTouchTarget,
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.verified_outlined,
                        color: AppColors.error,
                        size: 18,
                      ),
                      label: Text(
                        'User belum login',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.space2xs),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: AppSpacing.minTouchTarget,
              child: TextButton.icon(
                onPressed: onReportRecovered,
                icon: const Icon(
                  Icons.verified_outlined,
                  color: AppColors.statusResolved,
                  size: 18,
                ),
                label: Text(
                  'Kondisi Pulih',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.statusResolved,
                  ),
                ),
              ),
            ),
          ],
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
  const _CrowdConfirmButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.ctaButtonHeight,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusResolution,
          foregroundColor: AppColors.onPrimary,
        ),
        icon: const Icon(Icons.check_circle_outline_outlined),
        label: Text('Lapor Pulih'),
      ),
    );
  }
}
