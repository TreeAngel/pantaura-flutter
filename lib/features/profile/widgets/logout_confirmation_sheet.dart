import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Bottom sheet konfirmasi keluar akun sesuai desain Stitch.
Future<void> showLogoutConfirmationSheet(
  BuildContext context, {
  required Future<void> Function() onConfirm,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margin,
              AppSpacing.spaceSm,
              AppSpacing.margin,
              AppSpacing.spaceMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant.withValues(alpha: 0.6),
                      borderRadius: AppRadius.roundedFull,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.statusVerifiedBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded,
                          size: 28, color: AppColors.statusVerified),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusVerifiedBg,
                          borderRadius: AppRadius.roundedFull,
                        ),
                        child: Text(
                          'AUTENTIKASI AKUN',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.statusVerified,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded, size: 22),
                        color: AppColors.onSurfaceVariant,
                        tooltip: 'Tutup',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                Text(
                  'Konfirmasi Keluar Akun',
                  style: AppTypography.headlineLg
                      .copyWith(color: AppColors.textHeader),
                ),
                const SizedBox(height: AppSpacing.space2xs),
                Text(
                  'Apakah Anda yakin ingin keluar dari akun SiagaKita?',
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                _NoticeBox(
                  color: AppColors.surfaceTintIce,
                  icon: Icons.verified_user_rounded,
                  iconColor: AppColors.primary,
                  title: 'Data Anda Tetap Aman',
                  body: 'Seluruh riwayat laporan darurat, status kontributor relawan, dan kontak darurat Anda tetap tersimpan aman di server BPBD.',
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                _NoticeBox(
                  color: AppColors.statusUnverifiedBg,
                  icon: Icons.notifications_off_rounded,
                  iconColor: AppColors.statusUnverified,
                  title: 'Peringatan Kewaspadaan',
                  body: 'Anda tidak akan menerima sirene getar peringatan dini bencana otomatis pada radius siaga saat akun dalam keadaan keluar.',
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await onConfirm();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Ya, Keluar dari Akun'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.statusVerified,
                      foregroundColor: AppColors.onError,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.shield_rounded),
                    label: Text(
                      'Batal, Tetap Masuk',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textHeader,
                      side: const BorderSide(color: AppColors.borderSubtle),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Center(
                  child: Text(
                    'Butuh bantuan darurat? Hubungi 112 (bebas pulsa) kapan saja.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textHeader,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: AppTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
