import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

IconData safeZoneIcon(String type) {
  final value = type.toLowerCase();
  return value.contains('hospital') ||
          value.contains('medis') ||
          value.contains('medical')
      ? Icons.local_hospital_rounded
      : Icons.health_and_safety_rounded;
}

/// Pin posko/titik aman: hijau dan sengaja tanpa badge jumlah laporan.
class SafeZonePin extends StatelessWidget {
  const SafeZonePin({
    super.key,
    this.type = '',
    this.isSelected = false,
  });

  final String type;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 56.0 : 48.0;

    return Transform.rotate(
      angle: -math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.statusResolved,
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
              safeZoneIcon(type),
              color: AppColors.onPrimary,
              size: isSelected ? 30 : 24,
            ),
          ),
        ),
      ),
    );
  }
}
