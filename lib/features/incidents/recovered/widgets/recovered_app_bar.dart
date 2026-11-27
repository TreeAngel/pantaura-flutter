import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';

/// AppBar halaman Lapor Kondisi Pulih dengan tombol kembali ≥ 48×48dp.
class RecoveredAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RecoveredAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
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
            'Lapor Kondisi Pulih',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.textHeader,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Pantaura Tanggap Bencana',
            style: AppTypography.caption.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
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
