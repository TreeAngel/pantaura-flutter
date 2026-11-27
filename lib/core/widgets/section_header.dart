import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Header umum untuk tab/map/profile: ikon, eyebrow, judul, dan aksi kanan.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.eyebrow,
    this.leadingColor,
    this.actions = const [],
  });

  final IconData leadingIcon;
  final String title;
  final String? eyebrow;
  final Color? leadingColor;
  final List<Widget> actions;

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
                  color: AppColors.surfaceTintIce,
                  borderRadius: AppRadius.roundedMd,
                ),
                child: Icon(
                  leadingIcon,
                  size: 24,
                  color: leadingColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eyebrow != null) Text(eyebrow!, style: AppTypography.caption),
                    Text(
                      title,
                      style: AppTypography.headlineMd
                          .copyWith(color: AppColors.textHeader),
                    ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
