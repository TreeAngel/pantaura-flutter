import 'package:material_ui/material_ui.dart';
import '../theme/theme.dart';

enum IncidentStatus {
  unverified,
  verified,
  resolutionSubmitted,
  resolved,
  rejected,
}

/// Incident Status Chip adhering to DESIGN.md specs:
/// - Always pairs an icon with uppercase/title text
/// - Min height: 28px, horizontal padding: 10px, radius: 8px
class IncidentStatusChip extends StatelessWidget {
  const IncidentStatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  final IncidentStatus status;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final statusTheme = context.statusTheme;

    final (Color bgColor, Color textColor, IconData iconData, String defaultLabel) =
        switch (status) {
      IncidentStatus.unverified => (
          statusTheme.statusUnverifiedBg,
          statusTheme.statusUnverified,
          Icons.access_time_filled_rounded,
          'MENUNGGU VERIFIKASI',
        ),
      IncidentStatus.verified => (
          statusTheme.statusVerifiedBg,
          statusTheme.statusVerified,
          Icons.warning_amber_rounded,
          'TERVERIFIKASI',
        ),
      IncidentStatus.resolutionSubmitted => (
          statusTheme.statusResolutionBg,
          statusTheme.statusResolution,
          Icons.sync_rounded,
          'PROSES PENYELESAIAN',
        ),
      IncidentStatus.resolved => (
          statusTheme.statusResolvedBg,
          statusTheme.statusResolved,
          Icons.check_circle_rounded,
          'SELESAI',
        ),
      IncidentStatus.rejected => (
          statusTheme.statusRejectedBg,
          statusTheme.statusRejected,
          Icons.cancel_rounded,
          'DITOLAK',
        ),
    };

    return Container(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.statusChipMinHeight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.roundedStandard,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: textColor),
          const SizedBox(width: AppSpacing.space2xs),
          Text(
            customLabel ?? defaultLabel,
            style: AppTypography.labelSm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
