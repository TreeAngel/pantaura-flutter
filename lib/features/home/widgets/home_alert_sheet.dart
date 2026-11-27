import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/api_models.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/theme.dart';
import '../watch_area_notifier.dart';

/// Sheet daftar notifikasi in-app. Tap alert menandainya sebagai dibaca.
class HomeAlertSheet extends ConsumerWidget {
  const HomeAlertSheet({
    super.key,
    required this.onAlertSelected,
  });

  final ValueChanged<AlertModel> onAlertSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(watchAreaNotifierProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.margin,
          AppSpacing.spaceMd,
          AppSpacing.margin,
          AppSpacing.margin,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi Area Pantauan',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.textHeader,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Notifikasi tersedia di dalam aplikasi. Push notification eksternal belum tersedia.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            alertsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.spaceMd),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, _) => _AlertMessage(
                message: error is ApiException
                    ? error.message
                    : 'Gagal memuat notifikasi. Coba lagi nanti.',
              ),
              data: (data) {
                if (data.alerts.isEmpty) {
                  return const _AlertMessage(
                    message: 'Belum ada notifikasi untuk area pantauan Anda.',
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final alert in data.alerts) ...[
                      HomeAlertTile(
                        alert: alert,
                        onTap: () => _handleTap(context, ref, alert),
                      ),
                      const SizedBox(height: AppSpacing.spaceXs),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    AlertModel alert,
  ) async {
    try {
      await ref
          .read(watchAreaNotifierProvider.notifier)
          .markAlertAsRead(alert.id);
    } on ApiException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      return;
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menandai notifikasi sebagai dibaca.')),
      );
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();
    onAlertSelected(alert);
  }
}

/// Satu baris notifikasi dengan target sentuh minimal 48dp.
class HomeAlertTile extends StatelessWidget {
  const HomeAlertTile({
    super.key,
    required this.alert,
    required this.onTap,
  });

  final AlertModel alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: alert.isRead
          ? AppColors.surfaceCanvas
          : AppColors.statusResolutionBg.withValues(alpha: 0.4),
      borderRadius: AppRadius.roundedMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          padding: const EdgeInsets.all(AppSpacing.spaceSm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                alert.isRead
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_active_rounded,
                color: alert.isRead
                    ? AppColors.onSurfaceVariant
                    : AppColors.statusResolution,
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(alert.message, style: AppTypography.bodySm),
                  ],
                ),
              ),
              if (!alert.isRead)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.spaceXs),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: AppColors.statusVerified,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertMessage extends StatelessWidget {
  const _AlertMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Text(message, style: AppTypography.bodySm),
    );
  }
}
