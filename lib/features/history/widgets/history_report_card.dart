import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/api_models.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/incident_status_chip.dart';

/// Kartu riwayat laporan — saturu status, termasuk card rejected (jaga-jaga).
class HistoryReportCard extends StatelessWidget {
  const HistoryReportCard({super.key, required this.report});

  final ReportModel report;

  static IncidentStatus _statusOf(String raw) => switch (raw.toLowerCase()) {
        'pending' || 'unverified' => IncidentStatus.unverified,
        'approved' || 'verified' => IncidentStatus.verified,
        'resolution_submitted' => IncidentStatus.resolutionSubmitted,
        'resolved' => IncidentStatus.resolved,
        'rejected' => IncidentStatus.rejected,
        _ => IncidentStatus.unverified,
      };

  static String _relativeTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays == 1) return 'Kemarin';
    return '${difference.inDays} hari lalu';
  }

  Future<void> _showRejectionInfo(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Mengapa laporan ditolak?',
          style: AppTypography.headlineSm.copyWith(color: AppColors.textHeader),
        ),
        content: Text(
          'Laporan ditolak bila foto atau keterangan tidak menunjukkan kondisi bencana yang sebenarnya, duplikat laporan, atau berada di luar area verifikasi petugas. '
          'Perbaiki bukti lapangan lalu ajukan laporan baru, atau hubungi posko BPBD terdekat untuk bantuan verifikasi.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppealInfo(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Ajukan Banding',
          style: AppTypography.headlineSm.copyWith(color: AppColors.textHeader),
        ),
        content: const Text(
          'Fitur sedang dalam pengembangan, silahkan hubungi admin atau pihak terkait untuk informasi lebih lanjut atau untuk mengajukan banding',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = report.moderationStatus.toLowerCase();
    final isRejected = status == 'rejected';
    final isPending = status == 'pending' || status == 'unverified';
    final isResolved = status == 'resolved';
    final incident = report.incident;
    final incidentTitle = incident?.title ?? '';
    final incidentAddress = incident?.address ?? '';
    final title =
        incidentTitle.isNotEmpty ? incidentTitle : report.description;
    final address = incidentAddress.isNotEmpty
        ? incidentAddress
        : 'Lat: ${report.latitude.toStringAsFixed(5)}, '
            'Lng: ${report.longitude.toStringAsFixed(5)}';
    final media = report.media.isEmpty ? null : report.media.first;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.roundedLg,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: incident == null
                      ? AppColors.surfaceContainerHigh
                      : AppColors.surfaceTintIce,
                  borderRadius: AppRadius.roundedStandard,
                ),
                child: Text(
                  incident == null ? 'Laporan Tambahan' : 'Laporan Utama',
                  style: AppTypography.labelSm.copyWith(
                    color: incident == null
                        ? AppColors.textHeader
                        : AppColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              IncidentStatusChip(status: _statusOf(report.moderationStatus)),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (incident != null &&
                        incident.disasterTypeLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          incident.disasterTypeLabel,
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.space2xs),
                        Text(
                          _relativeTime(report.submittedAt),
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 16, color: AppColors.statusVerified),
                        const SizedBox(width: AppSpacing.space2xs),
                        Expanded(
                          child: Text(
                            address,
                            style: AppTypography.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              ClipRRect(
                borderRadius: AppRadius.roundedMd,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: media == null
                      ? Image.asset(
                          'assets/images/data-not-found.png',
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          media.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset(
                            'assets/images/data-not-found.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (incident != null) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceXs + 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceTintIce,
                borderRadius: AppRadius.roundedMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.hub_rounded,
                      size: 18, color: AppColors.primaryContainer),
                  const SizedBox(width: AppSpacing.space2xs),
                  Expanded(
                    child: Text(
                      'Laporan Utama • Tergabung ${incident.reportsCount} laporan warga',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            _InfoBox(
              color: AppColors.statusUnverifiedBg,
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.statusUnverified,
              title: 'Menunggu Verifikasi',
              body: 'Laporan foto & keterangan sedang ditinjau relawan posko BPBD. Estimasi verifikasi ± 15 menit.',
            ),
          ],
          if (isResolved) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            _InfoBox(
              color: AppColors.statusResolvedBg,
              icon: Icons.verified_rounded,
              iconColor: AppColors.statusResolved,
              title: 'Dikonfirmasi Selesai',
              body: 'Kondisi lapangan dinyatakan pulih dan pembersihan selesai oleh tim gabungan.',
            ),
          ],
          if (isRejected) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.statusRejectedBg,
                borderRadius: AppRadius.roundedMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: AppSpacing.space2xs),
                      Text(
                        'Catatan Verifikator Administrator',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.statusRejected,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2xs),
                  Text(
                    report.rejectionReason ??
                        'Laporan tidak memenuhi kriteria verifikasi lapangan.',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectionInfo(context),
                      icon: const Icon(Icons.help_outline_rounded, size: 18),
                      label: const Text('Pelajari Alasan'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => _showAppealInfo(context),
                      icon: const Icon(Icons.gavel_rounded, size: 18),
                      label: const Text('Ajukan Banding'),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (report.incidentId.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadius.roundedMd,
                child: InkWell(
                  onTap: () => context
                      .push(AppRoutes.incidentDetail(report.incidentId)),
                  borderRadius: AppRadius.roundedMd,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceMd,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Lihat Detail Insiden & Pemantauan',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 20, color: AppColors.primaryContainer),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSm.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: AppTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
