import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/theme.dart';

/// Ringkasan status izin perangkat dalam satu sesi aplikasi.
class AppPermissionSnapshot {
  const AppPermissionSnapshot({
    this.locationGranted = false,
    this.cameraGranted = false,
    this.galleryGranted = false,
    this.hasChecked = false,
  });

  final bool locationGranted;
  final bool cameraGranted;
  final bool galleryGranted;
  final bool hasChecked;

  AppPermissionSnapshot copyWith({
    bool? locationGranted,
    bool? cameraGranted,
    bool? galleryGranted,
    bool? hasChecked,
  }) {
    return AppPermissionSnapshot(
      locationGranted: locationGranted ?? this.locationGranted,
      cameraGranted: cameraGranted ?? this.cameraGranted,
      galleryGranted: galleryGranted ?? this.galleryGranted,
      hasChecked: hasChecked ?? this.hasChecked,
    );
  }
}

/// Layanan terpusat untuk memeriksa dan meminta izin lokasi, kamera, dan galeri.
class PermissionService {
  AppPermissionSnapshot _cached = const AppPermissionSnapshot();

  AppPermissionSnapshot get snapshot => _cached;

  /// Memastikan seluruh izin inti diminta sekali per sesi saat masuk beranda.
  ///
  /// Tidak memblokir alur beranda jika pengguna menolak.
  Future<AppPermissionSnapshot> ensureAll({bool forceRefresh = false}) async {
    if (_cached.hasChecked && !forceRefresh) {
      return _cached;
    }

    final locationStatus = await requestLocationPermission();
    final cameraStatus = await requestCameraPermission();
    final galleryStatus = await requestGalleryPermission();

    _cached = AppPermissionSnapshot(
      locationGranted: locationStatus.isGranted,
      cameraGranted: cameraStatus.isGranted,
      galleryGranted: galleryStatus.isGranted || galleryStatus.isLimited,
      hasChecked: true,
    );
    return _cached;
  }

  /// Memeriksa layanan GPS dan meminta izin lokasi saat aplikasi digunakan.
  Future<PermissionStatus> requestLocationPermission() async {
    final serviceEnabled =
        await Permission.locationWhenInUse.serviceStatus.isEnabled;
    if (!serviceEnabled) {
      final current = await Permission.locationWhenInUse.status;
      _cached = _cached.copyWith(locationGranted: current.isGranted);
      return current;
    }

    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted && !status.isPermanentlyDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    _cached = _cached.copyWith(locationGranted: status.isGranted);
    return status;
  }

  /// Meminta izin kamera untuk pengambilan foto bukti.
  Future<PermissionStatus> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted && !status.isPermanentlyDenied) {
      status = await Permission.camera.request();
    }
    _cached = _cached.copyWith(cameraGranted: status.isGranted);
    return status;
  }

  /// Meminta izin galeri (`Permission.photos` untuk Android 13+, fallback `storage`).
  Future<PermissionStatus> requestGalleryPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted && !status.isLimited && !status.isPermanentlyDenied) {
      status = await Permission.photos.request();
    }

    if (!status.isGranted && !status.isLimited) {
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted && !storageStatus.isPermanentlyDenied) {
        storageStatus = await Permission.storage.request();
      }
      if (storageStatus.isGranted) {
        status = storageStatus;
      }
    }

    _cached = _cached.copyWith(
      galleryGranted: status.isGranted || status.isLimited,
    );
    return status;
  }

  /// Mengambil satu gambar dari kamera/galeri setelah izin diperiksa.
  ///
  /// [context] dipakai untuk snackbar/dialog penjelasan; bila null, penolakan
  /// izin hanya mengembalikan `null` tanpa UI. `isLimited` dianggap diizinkan.
  Future<XFile?> pickImageWithPermission(
    ImageSource source, {
    BuildContext? context,
    int imageQuality = 85,
  }) async {
    final allowed = await _ensureMediaPermission(source, context: context);
    if (!allowed) return null;

    try {
      return await ImagePicker().pickImage(
        source: source,
        imageQuality: imageQuality,
      );
    } catch (_) {
      // Picker dibatalkan pengguna atau kamera tidak tersedia.
      return null;
    }
  }

  /// Mengambil beberapa gambar dari galeri setelah izin galeri diperiksa.
  Future<List<XFile>> pickMultiImagesWithPermission({
    BuildContext? context,
    int imageQuality = 85,
  }) async {
    final allowed = await _ensureMediaPermission(
      ImageSource.gallery,
      context: context,
    );
    if (!allowed) return const <XFile>[];

    try {
      return await ImagePicker().pickMultiImage(imageQuality: imageQuality);
    } catch (_) {
      return const <XFile>[];
    }
  }

  /// Memeriksa izin media dan menampilkan pesan penolakan bila perlu.
  Future<bool> _ensureMediaPermission(
    ImageSource source, {
    BuildContext? context,
  }) async {
    final isCamera = source == ImageSource.camera;
    final label = isCamera ? 'Kamera' : 'Galeri';
    final status = isCamera
        ? await requestCameraPermission()
        : await requestGalleryPermission();

    if (status.isPermanentlyDenied) {
      if (context != null && context.mounted) {
        await showPermanentlyDeniedDialog(context, permissionLabel: label);
      }
      return false;
    }

    if (!status.isGranted && !status.isLimited) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCamera
                  ? 'Izin kamera diperlukan untuk mengambil foto bukti.'
                  : 'Izin galeri diperlukan untuk memilih foto bukti.',
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Menampilkan dialog penjelasan ketika izin ditolak permanen.
  Future<void> showPermanentlyDeniedDialog(
    BuildContext context, {
    required String permissionLabel,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Text(
          'Izin $permissionLabel Diperlukan',
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.textHeader,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Pantaura membutuhkan akses $permissionLabel agar fitur pelaporan darurat '
          'dapat berfungsi. Buka Pengaturan Aplikasi untuk mengaktifkannya.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }
}
