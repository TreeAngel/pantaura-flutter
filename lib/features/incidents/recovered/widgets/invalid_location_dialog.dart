import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../add_report/add_report_state.dart';

/// Dialog ketika posisi user berada di luar radius maksimal 500 meter.
class InvalidLocationDialog extends StatefulWidget {
  const InvalidLocationDialog({
    super.key,
    required this.initialDistanceMeters,
    required this.onClosePage,
    required this.onRefreshLocation,
  });

  final double? initialDistanceMeters;
  final VoidCallback onClosePage;
  final Future<({bool isValid, double? distanceMeters})> Function()
      onRefreshLocation;

  @override
  State<InvalidLocationDialog> createState() => _InvalidLocationDialogState();
}

class _InvalidLocationDialogState extends State<InvalidLocationDialog> {
  bool _isRefreshing = false;
  double? _distanceMeters;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _distanceMeters = widget.initialDistanceMeters;
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _statusMessage = null;
    });

    final result = await widget.onRefreshLocation();
    if (!mounted) return;

    if (result.isValid) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isRefreshing = false;
      _distanceMeters = result.distanceMeters;
      _statusMessage =
          'Posisi masih di luar area maksimal ${kMaxReportRadiusMeters.toInt()} meter.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final distance = _distanceMeters;
    final distanceInfo = distance != null
        ? 'Jarak Anda saat ini sekitar ${distance.round()} meter dari titik insiden.'
        : 'Lokasi GPS Anda belum dapat diverifikasi di sekitar titik insiden.';

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
      title: Row(
        children: [
          const Icon(Icons.location_off_rounded, color: AppColors.error),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: Text(
              'Posisi Di Luar Radius',
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.textHeader,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengajuan status pulih hanya dapat dilakukan dalam radius maksimal '
            '${kMaxReportRadiusMeters.toInt()} meter dari titik utama insiden.',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            distanceInfo,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: AppSpacing.spaceSm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceXs),
              decoration: BoxDecoration(
                color: AppColors.statusVerifiedBg,
                borderRadius: AppRadius.roundedStandard,
              ),
              child: Text(
                _statusMessage ?? '',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.statusVerified,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        SizedBox(
          height: AppSpacing.minTouchTarget,
          child: TextButton(
            onPressed: _isRefreshing
                ? null
                : () {
                    Navigator.of(context).pop(false);
                    widget.onClosePage();
                  },
            child: const Text('Tutup Halaman'),
          ),
        ),
        SizedBox(
          height: AppSpacing.minTouchTarget,
          child: ElevatedButton.icon(
            onPressed: _isRefreshing ? null : _handleRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            icon: _isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Icon(Icons.my_location_rounded, size: 18),
            label: Text(_isRefreshing ? 'Memeriksa...' : 'Segarkan Lokasi'),
          ),
        ),
      ],
    );
  }
}
