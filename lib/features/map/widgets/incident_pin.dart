import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

IconData disasterIcon(String type) => switch (type.toLowerCase()) {
      'flood' => Icons.flood_rounded,
      'earthquake' => Icons.public_rounded,
      'landslide' => Icons.landslide_rounded,
      'fire' => Icons.local_fire_department_rounded,
      _ => Icons.warning_rounded,
    };

Color statusPinColor(String status) => switch (status) {
      'verified' => AppColors.statusVerified,
      'unverified' => AppColors.statusUnverified,
      'resolution_submitted' => AppColors.statusResolution,
      'resolved' => AppColors.statusResolved,
      _ => AppColors.statusRejected,
    };

/// Pin insiden berbentuk teardrop dengan badge jumlah laporan.
class IncidentPin extends StatelessWidget {
  const IncidentPin({
    super.key,
    required this.disasterType,
    required this.status,
    required this.reportsCount,
    this.isSelected = false,
  });

  final String disasterType;
  final String status;
  final int reportsCount;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 56.0 : 48.0;
    final color = statusPinColor(status);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(
          angle: -math.pi / 4,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: AppShadows.level3,
            ),
            child: Center(
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Icon(
                  disasterIcon(disasterType),
                  color: AppColors.onPrimary,
                  size: isSelected ? 30 : 24,
                ),
              ),
            ),
          ),
        ),
        if (reportsCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.textHeader,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceCard, width: 2),
              ),
              child: Center(
                child: Text(
                  '$reportsCount',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
