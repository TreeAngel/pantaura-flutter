import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/submit_bar.dart' as core;

/// Sticky bottom CTA untuk mengirim laporan tambahan.
class SubmitReportBar extends StatelessWidget {
  const SubmitReportBar({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return core.SubmitBar(
      label: 'Kirim Laporan Tambahan',
      loadingLabel: 'Mengirim Laporan...',
      isSubmitting: isSubmitting,
      onSubmit: onSubmit,
      caption: 'Laporan langsung diverifikasi dan diteruskan ke posko darurat terdekat.',
    );
  }
}
