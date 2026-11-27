import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../add_report/add_report_state.dart';
import '../../add_report/widgets/section_step_header.dart';
import '../recovered_state.dart';

/// Section 2: Maksimal 5 chip cepat kondisi pulih + textarea 4 baris.
class RecoveryDescriptionSection extends StatelessWidget {
  const RecoveryDescriptionSection({
    super.key,
    required this.controller,
    required this.currentDescription,
    required this.onChanged,
    required this.onQuickTextTap,
  });

  final TextEditingController controller;
  final String currentDescription;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onQuickTextTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.roundedLg,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionStepHeader(
              stepNumber: '2',
              title: 'Deskripsi',
              badgeText: 'Wajib',
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              'Tuliskan ringkasan situasi untuk mempermudah proses verifikasi:',
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final text in quickRecoveryTexts)
                  _RecoveryQuickChip(
                    label: text,
                    isSelected: currentDescription
                        .toLowerCase()
                        .contains(text.toLowerCase()),
                    onTap: () => onQuickTextTap(text),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            TextField(
              controller: controller,
              minLines: 4,
              maxLines: 4,
              maxLength: kMaxReportDescriptionLength,
              onChanged: onChanged,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) =>
                  null,
              style: AppTypography.bodyMd,
              decoration: InputDecoration(
                hintText: 'Deskripsikan kondisi lapangan saat ini...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.outline,
                ),
                filled: true,
                fillColor: AppColors.surfaceCanvas,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.roundedMd,
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.roundedMd,
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.spaceSm),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${currentDescription.length} / $kMaxReportDescriptionLength karakter',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryQuickChip extends StatelessWidget {
  const _RecoveryQuickChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: isSelected
          ? AppColors.surfaceTintIce
          : AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.roundedStandard,
      ),
      label: Text(
        isSelected ? '✓ $label' : '+ $label',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.primary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
