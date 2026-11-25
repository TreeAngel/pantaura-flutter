import 'package:material_ui/material_ui.dart';
import '../../../core/theme/theme.dart';
import '../home_state.dart';

/// Strip ringkasan status bencana wilayah (Aktif, Proses, Pulih).
class HomeStatusSummaryStrip extends StatelessWidget {
  const HomeStatusSummaryStrip({
    super.key,
    required this.counts,
    required this.lastUpdated,
  });

  final IncidentStatusCounts counts;
  final DateTime lastUpdated;

  String _formatUpdatedTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Baru saja diperbarui';
    if (diff.inMinutes < 60) return 'Pembaruan ${diff.inMinutes} mnt lalu';
    return 'Pembaruan ${diff.inHours} jam lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Bencana Wilayah Ini',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.textHeader,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formatUpdatedTime(lastUpdated),
                  style: AppTypography.caption,
                ),
              ],
            ),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.statusResolved,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceXs),
        Row(
          children: [
            Expanded(
              child: _SummaryStatCard(
                label: 'Aktif',
                sublabel: 'Terverifikasi',
                count: counts.verified,
                icon: Icons.warning_amber_rounded,
                color: AppColors.statusVerified,
                backgroundColor: const Color(0xFFFEF2F2),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceXs),
            Expanded(
              child: _SummaryStatCard(
                label: 'Proses',
                sublabel: 'Pengecekan',
                count: counts.inProcess,
                icon: Icons.schedule_rounded,
                color: AppColors.statusUnverified,
                backgroundColor: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceXs),
            Expanded(
              child: _SummaryStatCard(
                label: 'Pulih',
                sublabel: 'Telah Surut',
                count: counts.resolved,
                icon: Icons.check_circle_rounded,
                color: AppColors.statusResolved,
                backgroundColor: const Color(0xFFF0FDF4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.sublabel,
    required this.count,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final String sublabel;
  final int count;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.roundedMd,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: AppTypography.displayHero.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            sublabel,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
