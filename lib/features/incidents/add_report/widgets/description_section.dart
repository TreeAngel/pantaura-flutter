import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../add_report_state.dart';
import 'section_step_header.dart';

/// Section 3: Pilihan cepat bergaya lapor kondisi pulih + textarea deskripsi.
class DescriptionSection extends StatelessWidget {
  const DescriptionSection({
    super.key,
    required this.disasterType,
    required this.controller,
    required this.currentDescription,
    required this.onChanged,
    required this.onQuickTextTap,
  });

  final String disasterType;
  final TextEditingController controller;
  final String currentDescription;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onQuickTextTap;

  @override
  Widget build(BuildContext context) {
    final quickTexts = getQuickTextsForDisaster(disasterType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionStepHeader(
            stepNumber: '3',
            title: 'Deskripsi Perkembangan',
            badgeText: 'Wajib',
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            children: [
              const Icon(
                Icons.touch_app_rounded,
                size: 16,
                color: AppColors.statusResolution,
              ),
              const SizedBox(width: AppSpacing.space2xs),
              Expanded(
                child: Text(
                  'Pilihan Cepat (Ketuk untuk menyisipkan ke deskripsi):',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textHeader,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Wrap(
            spacing: AppSpacing.space2xs,
            runSpacing: AppSpacing.space2xs,
            children: [
              for (final text in quickTexts)
                _QuickTextChip(
                  label: text,
                  isSelected: currentDescription
                      .toLowerCase()
                      .contains(text.toLowerCase()),
                  onTap: () => onQuickTextTap(text),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.roundedLg,
              boxShadow: AppShadows.level1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Kondisi Nyata di Lapangan',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textHeader,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                TextField(
                  controller: controller,
                  minLines: 5,
                  maxLines: 5,
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
                    hintText:
                        'Tuliskan perubahan situasi terkini, kebutuhan mendesak, atau kendala akses...',
                    hintStyle: AppTypography.bodyMd.copyWith(
                      color: AppColors.outline,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceCanvas,
                    border: const OutlineInputBorder(
                      borderRadius: AppRadius.roundedStandard,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.spaceSm),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.statusResolution,
                        ),
                        const SizedBox(width: AppSpacing.space2xs),
                        Text(
                          'Laporan kronologis & faktual',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    Text(
                      '${currentDescription.length} / $kMaxReportDescriptionLength',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip cepat bergaya lapor kondisi pulih (`surfaceContainerLow`, rounded-lg, `+ ...`).
class _QuickTextChip extends StatelessWidget {
  const _QuickTextChip({
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
          color: isSelected ? AppColors.primary : AppColors.textHeader,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
