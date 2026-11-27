import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/section_header.dart';

class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionHeader(
      leadingIcon: Icons.map_rounded,
      eyebrow: 'Pantaura • Tanggap Sipil',
      title: 'Map Insiden & Posko',
    );
  }
}
