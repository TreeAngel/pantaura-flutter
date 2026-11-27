import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// App bar polos untuk ketiga form laporan dengan tombol kembali ≥ 48dp.
class FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FormAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleIcon,
    this.subtitleColor,
    this.titleStyle,
    this.showAvatar = true,
    this.toolbarHeight = 64,
  });

  final String title;
  final String? subtitle;
  final IconData? subtitleIcon;
  final Color? subtitleColor;
  final TextStyle? titleStyle;
  final bool showAvatar;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    final subtitleGlyph = subtitleIcon;

    return AppBar(
      backgroundColor: AppColors.surfaceCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: toolbarHeight,
      shape: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      leadingWidth: 56,
      leading: Center(
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textHeader,
            ),
            tooltip: 'Kembali',
            onPressed: () => context.pop(),
          ),
        ),
      ),
      titleSpacing: 4,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style:
                titleStyle ??
                AppTypography.headlineSm.copyWith(color: AppColors.textHeader),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitleText != null) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitleGlyph != null) ...[
                  Icon(
                    subtitleGlyph,
                    size: 14,
                    color: subtitleColor ?? AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                ],
                Flexible(
                  child: Text(
                    subtitleText,
                    style: AppTypography.labelSm.copyWith(
                      color: subtitleColor ?? AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (showAvatar)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.margin),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.onPrimary,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }
}
