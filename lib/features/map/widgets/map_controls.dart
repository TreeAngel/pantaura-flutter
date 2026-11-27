import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Kontrol kanan bawah: zoom in, zoom out, dan pusat ke lokasi.
class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onLocate,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.roundedMd,
            boxShadow: AppShadows.level2,
          ),
          child: Column(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onZoomIn,
                  icon: const Icon(Icons.add_rounded, size: 26),
                  color: AppColors.textHeader,
                  tooltip: 'Perbesar peta',
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onZoomOut,
                  icon: const Icon(Icons.remove_rounded, size: 26),
                  color: AppColors.textHeader,
                  tooltip: 'Perkecil peta',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: onLocate,
            icon: const Icon(Icons.gps_fixed_rounded,
                size: 26, color: AppColors.onPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.roundedMd,
              ),
            ),
            tooltip: 'Pusatkan ke lokasi saya',
          ),
        ),
      ],
    );
  }
}
