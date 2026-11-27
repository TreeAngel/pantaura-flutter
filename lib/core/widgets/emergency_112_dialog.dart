import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Dialog darurat 112 bersama — identik di home, buat laporan, dan profil.
Future<void> showEmergency112Dialog(BuildContext context) async {
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
        content: const Text(
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
              if (!context.mounted) return;
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
