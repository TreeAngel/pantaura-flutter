import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/submit_bar.dart' as core;

/// Sticky CTA bawah untuk mengirim laporan bencana.
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
      label: 'Kirim Laporan Bencana Sekarang',
      loadingLabel: 'Mengirim Laporan...',
      isSubmitting: isSubmitting,
      onSubmit: onSubmit,
      showSafeArea: false,
    );
  }
}
