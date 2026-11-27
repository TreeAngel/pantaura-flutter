import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/models/api_models.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/theme.dart';
import '../watch_area_notifier.dart';
import '../watch_area_state.dart';
import 'watch_area_form_sheet.dart';

/// Sheet pemilih area pantauan aktif, tambah area, dan hapus area.
class WatchAreaSheet extends ConsumerWidget {
  const WatchAreaSheet({
    super.key,
    required this.activeWatchAreaId,
    required this.onAreaSelected,
  });

  final String? activeWatchAreaId;
  final ValueChanged<WatchAreaModel?> onAreaSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchAsync = ref.watch(watchAreaNotifierProvider);

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
              'Pilih Lokasi Pantauan Aktif',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.textHeader,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tampilkan insiden di sekitar area pantauan tersimpan atau seluruh wilayah.',
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            watchAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.spaceMd),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, _) => _WatchAreaMessage(
                message: error is ApiException
                    ? error.message
                    : 'Gagal memuat area pantauan. Tarik untuk memuat ulang.',
              ),
              data: (data) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WatchAreaOptionTile(
                    title: 'Semua Wilayah Pantauan',
                    subtitle: 'Menampilkan seluruh laporan insiden publik terkini',
                    isSelected: activeWatchAreaId == null,
                    onTap: () {
                      Navigator.of(context).pop();
                      onAreaSelected(null);
                    },
                  ),
                  for (final area in data.watchAreas) ...[
                    const SizedBox(height: AppSpacing.spaceXs),
                    WatchAreaOptionTile(
                      title: area.label,
                      subtitle:
                          'Radius ${(area.radiusMeters / 1000).toStringAsFixed(1)} km dari titik pantau',
                      isSelected: activeWatchAreaId == area.id,
                      onTap: () {
                        Navigator.of(context).pop();
                        onAreaSelected(area);
                      },
                      onDelete: () => _confirmDelete(context, ref, area),
                    ),
                  ],
                  if (data.watchAreas.isEmpty) ...[
                    const SizedBox(height: AppSpacing.spaceSm),
                    const _WatchAreaMessage(
                      message: 'Belum ada area pantauan pribadi. Tambahkan lokasi favorit Anda.',
                    ),
                  ],
                  const SizedBox(height: AppSpacing.spaceSm),
                  OutlinedButton.icon(
                    onPressed: data.canAddWatchArea
                        ? () async {
                            await showWatchAreaFormSheet(context);
                          }
                        : null,
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text('Tambah Area Pantauan'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        AppSpacing.minTouchTarget,
                      ),
                    ),
                  ),
                  if (!data.canAddWatchArea)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.spaceXs),
                      child: Text(
                        'Batas ${WatchAreaData.maxAreas} area tercapai. Hapus salah satu untuk menambah baru.',
                        style: AppTypography.caption,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  WatchAreaModel area,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
      title: Text(
        'Hapus Area Pantauan?',
        style: AppTypography.headlineSm.copyWith(
          color: AppColors.textHeader,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Area "${area.label}" akan dihapus dari daftar pantauan Anda.',
        style: AppTypography.bodyMd,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text(
            'Hapus',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;
  try {
    await ref
        .read(watchAreaNotifierProvider.notifier)
        .deleteWatchArea(area.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Area pantauan dihapus.')),
    );
  } on ApiException catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message)),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal menghapus area pantauan.')),
    );
  }
}

/// Baris opsi area pantauan: tap untuk memilih, tombol hapus di kanan.
class WatchAreaOptionTile extends StatelessWidget {
  const WatchAreaOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.surfaceTintIce : AppColors.surfaceCanvas,
      borderRadius: AppRadius.roundedMd,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        padding: const EdgeInsets.all(AppSpacing.spaceXs),
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.roundedMd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.spaceXs,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.spaceSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.textHeader,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(subtitle, style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                tooltip: 'Hapus area pantauan',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WatchAreaMessage extends StatelessWidget {
  const _WatchAreaMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Text(message, style: AppTypography.caption),
    );
  }
}
