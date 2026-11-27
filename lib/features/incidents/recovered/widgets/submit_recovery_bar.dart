import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/submit_bar.dart' as core;

/// Sticky CTA "Ajukan Status Pulih" untuk pengajuan kondisi pulih.
class SubmitRecoveryBar extends StatelessWidget {
  const SubmitRecoveryBar({
    super.key,
    required this.isEnabled,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool isEnabled;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return core.SubmitBar(
      label: 'Ajukan Status Pulih',
      loadingLabel: 'Mengajukan Status Pulih...',
      icon: Icons.task_alt_rounded,
      isEnabled: isEnabled,
      isSubmitting: isSubmitting,
      onSubmit: onSubmit,
      backgroundColor: AppColors.statusResolution,
      caption: "Status insiden akan otomatis berubah menjadi 'Sedang Ditinjau' begitu terkirim.",
      captionIcon: null,
    );
  }
}
