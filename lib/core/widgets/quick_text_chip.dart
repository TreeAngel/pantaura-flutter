import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Chip teks cepat yang menunjukkan apakah teks sudah dipilih.
class QuickTextChip extends StatelessWidget {
  const QuickTextChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.unselectedBackground,
    this.selectedBackground,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? unselectedBackground;
  final Color? selectedBackground;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: isSelected
          ? selectedBackground ?? AppColors.surfaceTintIce
          : unselectedBackground ?? AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.roundedStandard,
      ),
      label: Text(
        isSelected ? '✓ $label' : '+ $label',
        style: AppTypography.labelSm.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textHeader,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
