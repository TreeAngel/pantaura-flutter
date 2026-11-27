import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';

/// AppBar halaman Tambah Laporan Insiden dengan tombol kembali ≥ 48×48dp.
class AddReportAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AddReportAppBar({super.key});

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
            'Tambah Laporan Insiden',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.textHeader,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 14,
                color: AppColors.statusResolution,
              ),
              const SizedBox(width: AppSpacing.space2xs),
              Text(
                'Pantaura Darurat',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
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
