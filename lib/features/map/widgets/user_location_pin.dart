import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Marker lokasi pengguna (dot biru berdenyut + label).
class UserLocationPin extends StatelessWidget {
  const UserLocationPin({super.key, this.isDemo = false});

  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.statusResolution.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: AppShadows.level2,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: AppColors.onPrimary,
                size: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.textHeader.withValues(alpha: 0.9),
            borderRadius: AppRadius.roundedSm,
          ),
          child: Text(
            isDemo ? 'Lokasi Demo' : 'Lokasi Anda',
            style: AppTypography.caption.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
