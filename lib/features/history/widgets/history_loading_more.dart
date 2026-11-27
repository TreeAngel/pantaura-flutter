import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class HistoryLoadingMore extends StatelessWidget {
  const HistoryLoadingMore({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.spaceMd),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
