import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Header bernomor (1, 2, 3, ...) dengan badge status di sebelah kanan.
///
/// Dipakai bersama oleh semua section form (laporan, tambah laporan, pulih).
class SectionStepHeader extends StatelessWidget {
  const SectionStepHeader({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.badgeText,
  });

  final String stepNumber;
  final String title;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spaceXs),
        Expanded(
          child: Text(
            title,
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.textHeader,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.statusUnverifiedBg,
            borderRadius: AppRadius.roundedFull,
          ),
          child: Text(
            badgeText,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.statusUnverified,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
