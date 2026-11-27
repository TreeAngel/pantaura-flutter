import 'dart:async';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../incidents/add_report/widgets/section_step_header.dart';

/// Peta interaktif dengan pin yang bisa digeser pengguna + input alamat manual.
class LocationPickerSection extends StatefulWidget {
  const LocationPickerSection({
    super.key,
    required this.pin,
    required this.address,
    required this.isLocating,
    required this.onPinMoved,
    required this.onRefreshGps,
    required this.onAddressChanged,
  });

  final GeoPoint? pin;
  final String address;
  final bool isLocating;
  final ValueChanged<GeoPoint?> onPinMoved;
  final Future<void> Function() onRefreshGps;
  final ValueChanged<String> onAddressChanged;

  @override
  State<LocationPickerSection> createState() => _LocationPickerSectionState();
}

class _LocationPickerSectionState extends State<LocationPickerSection> {
  static const double _moveThreshold = 0.0002;
  static const Duration _moveDebounce = Duration(milliseconds: 300);
  static const MarkerIcon _pinIcon = MarkerIcon(iconWidget: _ReportPin());

  late final MapController _controller;
  late final TextEditingController _addressController;
  Timer? _moveTimer;
  bool _mapReady = false;
  bool _showManualAddress = false;
  int _zoomLevel = 15;

  /// Marker native dibuat sekali, lalu hanya direposisi — tidak remove/add.
  GeoPoint? _placedMarker;
  GeoPoint? _lastReportedPoint;
  GeoPoint? _markerTarget;
  bool _isMovingMarker = false;

  @override
  void initState() {
    super.initState();
    _controller = MapController.withUserPosition();
    _addressController = TextEditingController(text: widget.address);
    _lastReportedPoint = widget.pin;
  }

  @override
  void didUpdateWidget(covariant LocationPickerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.address != oldWidget.address &&
        widget.address != _addressController.text) {
      _addressController.text = widget.address;
    }
    final pin = widget.pin;
    if (pin == null) {
      if (_placedMarker != null) {
        _moveTimer?.cancel();
        _lastReportedPoint = null;
        _markerTarget = null;
        _removePlacedMarker();
      }
      return;
    }
    if (pin == oldWidget.pin || pin == _lastReportedPoint) return;
    // Perubahan dari GPS/long-press: reposisi marker tanpa menambah marker baru.
    _moveTimer?.cancel();
    _lastReportedPoint = pin;
    _markerTarget = pin;
    _flushMarkerMove();
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _addressController.dispose();
    super.dispose();
  }

  static bool _beyondThreshold(GeoPoint a, GeoPoint b) =>
      (a.latitude - b.latitude).abs() > _moveThreshold ||
      (a.longitude - b.longitude).abs() > _moveThreshold;

  void _handleMapMoved(Region region) {
    final center = region.center;
    _moveTimer?.cancel();
    _moveTimer = Timer(_moveDebounce, () {
      final anchor = _lastReportedPoint ?? widget.pin;
      // Belum ada titik (GPS masih berjalan): jangan menaruh pin dari geseran peta.
      if (anchor == null || !_beyondThreshold(anchor, center)) return;
      _lastReportedPoint = center;
      _markerTarget = center;
      _flushMarkerMove();
      widget.onPinMoved(center);
    });
  }

  void _handleLongPress(GeoPoint point) {
    _moveTimer?.cancel();
    _lastReportedPoint = point;
    _markerTarget = point;
    _flushMarkerMove();
    widget.onPinMoved(point);
  }

  /// Tap pada marker yang sudah terpasang → hapus pin.
  void _handleMarkerTap(GeoPoint point) {
    final placed = _placedMarker;
    if (placed == null) {
      // Beberapa platform mengirim geo point saat peta diketuk (bukan marker).
      _handleLongPress(point);
      return;
    }
    if (!_isSamePoint(placed, point)) return;
    _moveTimer?.cancel();
    _markerTarget = null;
    _lastReportedPoint = null;
    _removePlacedMarker();
    widget.onPinMoved(null);
  }

  static bool _isSamePoint(GeoPoint a, GeoPoint b) =>
      !_beyondThreshold(a, b);

  Future<void> _removePlacedMarker() async {
    final marker = _placedMarker;
    if (marker == null) return;
    _placedMarker = null;
    try {
      await _controller.removeMarker(marker);
    } catch (_) {
      // Marker mungkin sudah dihapus native.
    }
  }

  Future<void> _zoomIn() async {
    if (_zoomLevel >= 19) return;
    _zoomLevel++;
    await _controller.zoomIn();
  }

  Future<void> _zoomOut() async {
    if (_zoomLevel <= 12) return;
    _zoomLevel--;
    await _controller.zoomOut();
  }

  /// Antrean kecil: satu reposition berjalan, target terbaru diproses setelahnya.
  Future<void> _flushMarkerMove() async {
    if (_isMovingMarker || !_mapReady) return;
    final target = _markerTarget;
    if (target == null) return;
    _markerTarget = null;

    final previous = _placedMarker;
    if (previous == null) {
      _isMovingMarker = true;
      try {
        await _controller.addMarker(target, markerIcon: _pinIcon);
        _placedMarker = target;
      } catch (_) {
        // Marker belum terpasang; dicoba lagi saat callback berikutnya.
      } finally {
        _isMovingMarker = false;
      }
      return;
    }
    if (previous == target) return;

    _isMovingMarker = true;
    try {
      await _controller.changeLocationMarker(
        oldLocation: previous,
        newLocation: target,
        markerIcon: _pinIcon,
      );
      _placedMarker = target;
    } catch (_) {
      // Pertahankan posisi terakhir yang berhasil dipasang.
    } finally {
      _isMovingMarker = false;
    }
    if (_markerTarget != null) _flushMarkerMove();
  }

  Future<void> _refreshGps() async {
    await widget.onRefreshGps();
    if (!mounted) return;
    final target = widget.pin ?? _lastReportedPoint;
    if (target != null) {
      await _controller.moveTo(target, animate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pin = widget.pin;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionStepHeader(
            stepNumber: '2',
            title: 'Lokasi Kejadian',
            badgeText: 'Wajib',
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          RepaintBoundary(
            child: ClipRRect(
              borderRadius: AppRadius.roundedLg,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: OSMFlutter(
                          key: const ValueKey<String>('create_report_map'),
                          controller: _controller,
                          osmOption: const OSMOption(
                            showZoomController: false,
                            enableRotationByGesture: false,
                            zoomOption: ZoomOption(
                              initZoom: 15,
                              minZoomLevel: 12,
                              maxZoomLevel: 19,
                            ),
                          ),
                          mapIsLoading: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          onMapIsReady: (ready) {
                            setState(() => _mapReady = ready);
                            if (ready && _placedMarker == null) {
                              final initial = _markerTarget ??
                                  _lastReportedPoint ??
                                  widget.pin;
                              if (initial != null) {
                                _markerTarget = initial;
                                _flushMarkerMove();
                              }
                            }
                          },
                          onMapMoved: _handleMapMoved,
                          onGeoPointLongPress: _handleLongPress,
                          onGeoPointClicked: _handleMarkerTap,
                        ),
                    ),
                    Positioned(
                      top: AppSpacing.spaceXs,
                      right: AppSpacing.spaceXs,
                      child: Material(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadius.roundedMd,
                        child: InkWell(
                          onTap: _refreshGps,
                          borderRadius: AppRadius.roundedMd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spaceSm,
                              vertical: AppSpacing.space2xs,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.isLocating)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                else
                                  const Icon(Icons.my_location_rounded,
                                      size: 18, color: AppColors.primary),
                                const SizedBox(width: AppSpacing.space2xs),
                                Text(
                                  'GPS Akurat',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 56,
                      right: AppSpacing.spaceXs,
                      child: _ZoomControls(
                        onZoomIn: _zoomIn,
                        onZoomOut: _zoomOut,
                      ),
                    ),
                    const Positioned(
                      bottom: AppSpacing.spaceXs,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _MapGuideChip(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.roundedLg,
              boxShadow: AppShadows.level1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.statusResolutionBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pin_drop_rounded,
                          size: 22, color: AppColors.statusResolution),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.address.trim().isEmpty
                                ? 'Titik lokasi kejadian'
                                : widget.address.trim(),
                            style: AppTypography.headlineSm.copyWith(
                              color: AppColors.textHeader,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space2xs),
                          Text(
                            pin == null
                                ? 'Titik belum ditentukan — ketuk peta'
                                : '${pin.latitude.toStringAsFixed(5)}, '
                                    '${pin.longitude.toStringAsFixed(5)}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Align(
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _showManualAddress = !_showManualAddress),
                    icon: const Icon(Icons.edit_location_alt_rounded,
                        size: 18),
                    label: Text(
                      _showManualAddress
                          ? 'Sembunyikan Alamat Manual'
                          : 'Ketik Alamat Patokan Manual',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (_showManualAddress) ...[
                  const SizedBox(height: AppSpacing.space2xs),
                  TextField(
                    controller: _addressController,
                    onChanged: widget.onAddressChanged,
                    maxLines: 2,
                    style: AppTypography.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Jl. Otista Raya No. 45, RT 04/RW 02',
                      hintStyle: AppTypography.bodyMd
                          .copyWith(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceCanvas,
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.roundedStandard,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.spaceSm),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kontrol zoom: 12–19 sesuai batas [ZoomOption].
class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final Future<void> Function() onZoomIn;
  final Future<void> Function() onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.roundedMd,
        boxShadow: AppShadows.level2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: onZoomIn,
              icon: const Icon(Icons.add_rounded, size: 26),
              color: AppColors.textHeader,
              tooltip: 'Perbesar (maks 19)',
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
              tooltip: 'Perkecil (maks 12)',
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportPin extends StatelessWidget {
  const _ReportPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.statusVerified,
            shape: BoxShape.circle,
            boxShadow: AppShadows.level2,
          ),
          child: const Icon(Icons.location_on_rounded,
              color: AppColors.onPrimary, size: 22),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.textHeader.withValues(alpha: 0.9),
            borderRadius: AppRadius.roundedSm,
          ),
          child: Text(
            'Pusat Titik Laporan',
            style: AppTypography.caption.copyWith(
              color: AppColors.onPrimary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapGuideChip extends StatelessWidget {
  const _MapGuideChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.spaceXs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: AppSpacing.space2xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.95),
        borderRadius: AppRadius.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: const Icon(Icons.touch_app_rounded,
                size: 15, color: AppColors.primary),
          ),
          // const SizedBox(width: AppSpacing.space2xs),
          Expanded(
            flex: 6,
            child: Text(
              'Tekan lama peta untuk titik • ketuk pin untuk hapus',
              style: AppTypography.caption.copyWith(color: AppColors.textHeader),
              
            ),
          ),
        ],
      ),
    );
  }
}
