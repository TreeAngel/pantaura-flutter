import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../incidents/add_report/widgets/section_step_header.dart';

/// Grid 2x2 pemilih jenis bencana.
class DisasterTypeSelector extends StatelessWidget {
  const DisasterTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final String selectedType;
  final ValueChanged<String> onSelected;

  static const List<_DisasterOption> _options = [
    _DisasterOption('flood', 'Banjir', 'Luapan air & genangan', Icons.flood_rounded),
    _DisasterOption(
        'earthquake', 'Gempa Bumi', 'Guncangan & retakan', Icons.public_rounded),
    _DisasterOption(
        'landslide', 'Tanah Longsor', 'Tebing tergerus longsor', Icons.landslide_rounded),
    _DisasterOption('fire', 'Kebakaran', 'Pemukiman atau hutan',
        Icons.local_fire_department_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionStepHeader(
            stepNumber: '1',
            title: 'Pilih Jenis Kejadian',
            badgeText: 'Wajib',
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            'Pilih salah satu kategori utama yang paling mendesak di sekitar Anda:',
            style: AppTypography.bodySm,
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.spaceSm,
              mainAxisSpacing: AppSpacing.spaceSm,
              childAspectRatio: 1.4,
            ),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
              return _DisasterTypeCard(
                option: option,
                isSelected: option.type == selectedType,
                onTap: () => onSelected(option.type),
              );
            },
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.statusResolution),
              const SizedBox(width: AppSpacing.space2xs),
              Expanded(
                child: Text(
                  'Kategori dapat disesuaikan petugas bila terdapat bencana ikutan.',
                  style: AppTypography.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DisasterOption {
  const _DisasterOption(this.type, this.label, this.subtitle, this.icon);

  final String type;
  final String label;
  final String subtitle;
  final IconData icon;
}

class _DisasterTypeCard extends StatelessWidget {
  const _DisasterTypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _DisasterOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.surfaceTintIce : AppColors.surfaceCard,
      borderRadius: AppRadius.roundedLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedLg,
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedLg,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceCard
                          : AppColors.surfaceContainer,
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Icon(option.icon,
                        size: 26, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    option.label,
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.textHeader,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 16, color: AppColors.onPrimary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
