import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

/// Search bar mengambang di atas peta (clear + GPS).
class MapSearchBar extends StatefulWidget {
  const MapSearchBar({
    super.key,
    required this.query,
    required this.onSearch,
    required this.onClear,
    required this.onLocate,
  });

  final String query;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final VoidCallback onLocate;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant MapSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.roundedMd,
        boxShadow: AppShadows.level2,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.roundedSm,
            ),
            child: const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearch,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMd,
              decoration: InputDecoration(
                hintText: 'Cari jalan, kelurahan, atau kecamatan...',
                hintStyle: AppTypography.bodyMd
                    .copyWith(color: AppColors.statusRejected),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _controller.clear();
              widget.onClear();
            },
            icon: const Icon(Icons.cancel_rounded, size: 20),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Bersihkan pencarian',
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceTintIce,
              borderRadius: AppRadius.roundedSm,
            ),
            child: IconButton(
              onPressed: widget.onLocate,
              icon: const Icon(Icons.my_location_rounded,
                  size: 22, color: AppColors.primary),
              tooltip: 'Deteksi posisi GPS saat ini',
            ),
          ),
        ],
      ),
    );
  }
}
