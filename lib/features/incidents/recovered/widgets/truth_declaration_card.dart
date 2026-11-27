import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';

/// Card pernyataan kebenaran lapangan dengan target sentuh checkbox ≥ 48dp.
class TruthDeclarationCard extends StatelessWidget {
  const TruthDeclarationCard({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  final bool isChecked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.roundedLg,
        elevation: 0,
        child: InkWell(
          onTap: () => onChanged(!isChecked),
          borderRadius: AppRadius.roundedLg,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            decoration: BoxDecoration(
              borderRadius: AppRadius.roundedLg,
              boxShadow: AppShadows.level1,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppSpacing.minTouchTarget,
                  height: AppSpacing.minTouchTarget,
                  child: Center(
                    child: Transform.scale(
                      scale: 1.25,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (value) => onChanged(value ?? false),
                        activeColor: AppColors.primary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedSm,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pernyataan Kebenaran Lapangan',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textHeader,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saya menyatakan dengan sadar dan penuh tanggung jawab bahwa '
                        'data serta foto kondisi pulih ini sesuai dengan fakta nyata '
                        'di lokasi saat ini.',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
