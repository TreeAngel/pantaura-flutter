import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Tombol keluar + catatan keamanan data.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.logout_rounded, size: 24),
            label: Text(
              'Keluar dari Akun',
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.statusVerified,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.statusVerified,
              side: const BorderSide(color: AppColors.borderSubtle),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.roundedMd,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_done_rounded,
                size: 16, color: AppColors.statusResolved),
            const SizedBox(width: AppSpacing.space2xs),
            Flexible(
              child: Text(
                'Seluruh data laporan & riwayat bencana Anda tersimpan aman di server BPBD.',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
