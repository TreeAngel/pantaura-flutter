import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';
import 'quick_text_chip.dart';
import 'section_step_header.dart';

/// Shell generik deskripsi + chip cepat untuk ketiga form laporan.
class DescriptionSection extends StatelessWidget {
  const DescriptionSection({
    super.key,
    required this.controller,
    required this.currentDescription,
    required this.onChanged,
    required this.onQuickTextToggle,
    required this.quickTexts,
    this.stepNumber = '3',
    this.title = 'Deskripsi',
    this.badgeText = 'Wajib',
    this.instruction,
    this.instructionIcon,
    this.fieldLabel,
    this.fieldNote,
    this.fieldNoteIcon,
    this.hintText = 'Deskripsikan kondisi lapangan saat ini...',
    this.maxLength = 500,
    this.minLines = 4,
    this.maxLines = 4,
    this.fieldHasBorder = false,
    this.textFieldInCard = true,
    this.wrapInCard = false,
    this.counterStyle,
    this.chipSpacing = AppSpacing.space2xs,
  });

  final TextEditingController controller;
  final String currentDescription;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onQuickTextToggle;
  final List<String> quickTexts;
  final String stepNumber;
  final String title;
  final String badgeText;
  final String? instruction;
  final IconData? instructionIcon;
  final String? fieldLabel;
  final String? fieldNote;
  final IconData? fieldNoteIcon;
  final String hintText;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final bool fieldHasBorder;
  final bool textFieldInCard;
  final bool wrapInCard;
  final TextStyle? counterStyle;
  final double chipSpacing;

  @override
  Widget build(BuildContext context) {
    final instructionText = instruction;
    final label = fieldLabel;
    final note = fieldNote;
    final noteIcon = fieldNoteIcon;
    final counter =
        counterStyle ??
        AppTypography.labelSm.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        );

    final fieldBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          buildCounter: (
            _, {
            required currentLength,
            required isFocused,
            required maxLength,
          }) => null,
          style: AppTypography.bodyMd,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceCanvas,
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedStandard,
              borderSide: fieldHasBorder
                  ? const BorderSide(color: AppColors.borderSubtle)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedStandard,
              borderSide: fieldHasBorder
                  ? const BorderSide(color: AppColors.borderSubtle)
                  : BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.spaceSm),
          ),
        ),
        const SizedBox(height: AppSpacing.space2xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: note == null
                  ? const SizedBox.shrink()
                  : noteIcon == null
                  ? Text(note, style: AppTypography.caption)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          noteIcon,
                          size: 14,
                          color: AppColors.statusResolution,
                        ),
                        const SizedBox(width: AppSpacing.space2xs),
                        Flexible(
                          child: Text(note, style: AppTypography.caption),
                        ),
                      ],
                    ),
            ),
            Text(
              '${currentDescription.length} / $maxLength karakter',
              style: counter,
            ),
          ],
        ),
      ],
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionStepHeader(
          stepNumber: stepNumber,
          title: title,
          badgeText: badgeText,
        ),
        if (instructionText != null) ...[
          const SizedBox(height: AppSpacing.spaceXs),
          if (instructionIcon == null)
            Text(instructionText, style: AppTypography.bodySm)
          else
            Row(
              children: [
                Icon(
                  instructionIcon,
                  size: 16,
                  color: AppColors.statusResolution,
                ),
                const SizedBox(width: AppSpacing.space2xs),
                Expanded(
                  child: Text(
                    instructionText,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textHeader,
                    ),
                  ),
                ),
              ],
            ),
        ],
        SizedBox(
          height: instructionText == null
              ? AppSpacing.spaceSm
              : AppSpacing.spaceXs,
        ),
        Wrap(
          spacing: chipSpacing,
          runSpacing: chipSpacing,
          children: [
            for (final text in quickTexts)
              QuickTextChip(
                label: text,
                isSelected: currentDescription.toLowerCase().contains(
                  text.toLowerCase(),
                ),
                onTap: () => onQuickTextToggle(text),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        if (label != null) ...[
          Text(
            label,
            style: AppTypography.labelMd.copyWith(color: AppColors.textHeader),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
        ],
        if (textFieldInCard)
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.roundedLg,
              boxShadow: AppShadows.level1,
            ),
            child: fieldBlock,
          )
        else
          fieldBlock,
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: wrapInCard
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: AppRadius.roundedLg,
                boxShadow: AppShadows.level1,
              ),
              child: body,
            )
          : body,
    );
  }
}
