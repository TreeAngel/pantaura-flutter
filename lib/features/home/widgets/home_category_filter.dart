import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../home_state.dart';

/// Baris chip filter kategori bencana yang bisa di-scroll horizontal.
class HomeCategoryFilterBar extends StatelessWidget {
  const HomeCategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.categoryCounts,
    required this.onCategorySelected,
  });

  final DisasterCategoryFilter selectedCategory;
  final Map<DisasterCategoryFilter, int> categoryCounts;
  final ValueChanged<DisasterCategoryFilter> onCategorySelected;

  IconData _iconForCategory(DisasterCategoryFilter category) {
    return switch (category) {
      DisasterCategoryFilter.all => Icons.apps_rounded,
      DisasterCategoryFilter.flood => Icons.flood_rounded,
      DisasterCategoryFilter.earthquake => Icons.public_rounded,
      DisasterCategoryFilter.landslide => Icons.landslide_rounded,
      DisasterCategoryFilter.fire => Icons.local_fire_department_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Kategori',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.textHeader,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Geser pilihan',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        SizedBox(
          height: AppSpacing.minTouchTarget,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
            itemCount: DisasterCategoryFilter.values.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.spaceXs),
            itemBuilder: (context, index) {
              final category = DisasterCategoryFilter.values[index];
              final isSelected = category == selectedCategory;
              final count = categoryCounts[category] ?? 0;

              return Material(
                color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                borderRadius: AppRadius.roundedFull,
                elevation: isSelected ? 2 : 1,
                child: InkWell(
                  onTap: () => onCategorySelected(category),
                  borderRadius: AppRadius.roundedFull,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: AppSpacing.minTouchTarget,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceMd,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconForCategory(category),
                          size: 18,
                          color: isSelected
                              ? AppColors.onPrimary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${category.label} ($count)',
                          style: AppTypography.labelMd.copyWith(
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.spaceXs),
      ],
    );
  }
}
