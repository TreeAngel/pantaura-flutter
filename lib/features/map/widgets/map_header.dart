import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Header tetap di atas peta sesuai desain Stitch.
class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.96),
        boxShadow: AppShadows.level2,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            AppSpacing.spaceXs,
            AppSpacing.margin,
            AppSpacing.spaceXs + 4,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.roundedMd,
                ),
                child: const Icon(Icons.shield_rounded,
                    color: AppColors.onPrimary, size: 24),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pantaura • Tanggap Sipil',
                      style: AppTypography.caption,
                    ),
                    Text(
                      'Beranda',
                      style: AppTypography.headlineMd
                          .copyWith(color: AppColors.textHeader),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.onPrimary, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
