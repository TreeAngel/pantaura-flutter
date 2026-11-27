import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      child: Column(
        children: [
          Image.asset('assets/images/data-not-found.png', height: 96),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
