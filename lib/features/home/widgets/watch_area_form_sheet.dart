import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_button.dart';
import '../watch_area_notifier.dart';
import '../watch_area_state.dart';

/// Tampilkan form tambah area pantauan; kembali `true` bila berhasil disimpan.
Future<bool> showWatchAreaFormSheet(BuildContext context) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceCard,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
    builder: (_) => const WatchAreaFormSheet(),
  );
  return saved ?? false;
}

/// Form label, koordinat, dan radius geofence untuk area pantauan baru.
class WatchAreaFormSheet extends ConsumerStatefulWidget {
  const WatchAreaFormSheet({super.key});

  @override
  ConsumerState<WatchAreaFormSheet> createState() =>
      _WatchAreaFormSheetState();
}

class _WatchAreaFormSheetState extends ConsumerState<WatchAreaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _latitudeController = TextEditingController(
    text: '${WatchAreaData.defaultLatitude}',
  );
  final _longitudeController = TextEditingController(
    text: '${WatchAreaData.defaultLongitude}',
  );
  final _radiusController = TextEditingController(
    text: '${WatchAreaData.defaultRadiusMeters}',
  );

  bool _isLocating = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final status = await ref
          .read(permissionServiceProvider)
          .requestLocationPermission();
      if (!status.isGranted) {
        _showMessage('Izin lokasi diperlukan untuk mendeteksi posisi Anda.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
    } catch (_) {
      _showMessage('Lokasi tidak tersedia. Silakan isi koordinat manual.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final data = ref.read(watchAreaNotifierProvider).value;
    if (data != null && !data.canAddWatchArea) {
      _showMessage(
        'Maksimal ${WatchAreaData.maxAreas} area pantauan. Hapus salah satu terlebih dahulu.',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(watchAreaNotifierProvider.notifier).createWatchArea(
            label: _labelController.text.trim(),
            latitude: double.parse(_latitudeController.text.trim()),
            longitude: double.parse(_longitudeController.text.trim()),
            radiusMeters: int.parse(_radiusController.text.trim()),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Area pantauan berhasil disimpan.')),
      );
    } on ApiException catch (error) {
      _showMessage(error.message);
    } on FormatException {
      _showMessage('Periksa kembali koordinat dan radius area pantauan.');
    } catch (_) {
      _showMessage('Gagal menyimpan area pantauan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.margin,
          right: AppSpacing.margin,
          top: AppSpacing.spaceMd,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.margin,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Area Pantauan',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.textHeader,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Simpan lokasi untuk menerima notifikasi insiden di sekitarnya.',
                  style: AppTypography.bodySm,
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                TextFormField(
                  controller: _labelController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Label area',
                    hintText: 'Contoh: Rumah Orang Tua',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final label = value?.trim() ?? '';
                    if (label.isEmpty) return 'Label area wajib diisi';
                    if (label.length > 60) return 'Label maksimal 60 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                OutlinedButton.icon(
                  onPressed: _isLocating ? null : _useCurrentLocation,
                  icon: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded),
                  label: const Text('Gunakan Lokasi Saya'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppSpacing.minTouchTarget,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(value?.trim() ?? '');
                          if (parsed == null || parsed < -90 || parsed > 90) {
                            return 'Latitude -90 s.d. 90';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(value?.trim() ?? '');
                          if (parsed == null || parsed < -180 || parsed > 180) {
                            return 'Longitude -180 s.d. 180';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                TextFormField(
                  controller: _radiusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Radius (meter)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed < 100 || parsed > 10000) {
                      return 'Radius 100 s.d. 10000 meter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                Text(
                  'Maksimal ${WatchAreaData.maxAreas} area pantauan per akun.',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                PrimaryButton(
                  label: 'Simpan Area Pantauan',
                  icon: Icons.add_location_alt_rounded,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
