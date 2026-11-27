import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/section_header.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      leadingIcon: Icons.shield_rounded,
      title: 'Profil Warga',
      actions: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(Icons.settings_rounded,
                size: 24, color: AppColors.textHeader),
            tooltip: 'Pengaturan',
          ),
        ),
      ],
    );
  }
}
