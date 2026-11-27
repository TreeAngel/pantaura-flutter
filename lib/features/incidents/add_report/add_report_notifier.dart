import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../detail/incident_detail_notifier.dart';
import 'add_report_state.dart';

/// Notifier untuk mengelola form Tambah Laporan Insiden dengan Riverpod 3.5.
class AddReportNotifier extends AsyncNotifier<AddReportData> {
  AddReportNotifier(this.incidentId);

  final String incidentId;

  @override
  Future<AddReportData> build() async {
    final detailData = await ref.read(
      incidentDetailProvider(incidentId).future,
    );
    return AddReportData(incident: detailData.incident);
  }

  /// Meminta izin lokasi, mengambil posisi GPS terkini, dan menghitung jarak
  /// Haversine terhadap titik utama insiden.
  Future<PermissionStatus?> refreshLocation() async {
    final current = state.value;
    if (current == null || current.isRefreshingLocation) return null;

    state = AsyncData(
      current.copyWith(isRefreshingLocation: true, clearErrorMessage: true),
    );

    try {
      final permissionService = ref.read(permissionServiceProvider);
      final status = await permissionService.requestLocationPermission();

      if (!status.isGranted) {
        state = AsyncData(
          current.copyWith(
            isRefreshingLocation: false,
            isLocationValid: false,
            errorMessage:
                'Izin lokasi diperlukan untuk memverifikasi radius laporan.',
          ),
        );
        return status;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        current.incident.latitude,
        current.incident.longitude,
      );

      state = AsyncData(
        current.copyWith(
          userPosition: position,
          distanceMeters: distance,
          isLocationValid: distance <= kMaxReportRadiusMeters,
          isRefreshingLocation: false,
          clearErrorMessage: true,
        ),
      );
      return status;
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isRefreshingLocation: false,
          errorMessage:
              'Gagal mengambil lokasi GPS. Pastikan GPS aktif dan coba lagi.',
        ),
      );
      return null;
    }
  }

  /// Menambahkan foto bukti maksimal hingga [kMaxReportMediaCount] file.
  void addMedia(List<XFile> files) {
    final current = state.value;
    if (current == null || files.isEmpty) return;

    final remaining = kMaxReportMediaCount - current.mediaFiles.length;
    if (remaining <= 0) return;

    final updated = [...current.mediaFiles, ...files.take(remaining)];
    state = AsyncData(
      current.copyWith(mediaFiles: updated, clearErrorMessage: true),
    );
  }

  /// Menghapus foto pada [index].
  void removeMedia(int index) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.mediaFiles.length) {
      return;
    }
    final updated = [...current.mediaFiles]..removeAt(index);
    state = AsyncData(current.copyWith(mediaFiles: updated));
  }

  /// Memperbarui teks deskripsi secara langsung.
  void updateDescription(String text) {
    final current = state.value;
    if (current == null) return;
    final trimmed = text.length > kMaxReportDescriptionLength
        ? text.substring(0, kMaxReportDescriptionLength)
        : text;
    state = AsyncData(
      current.copyWith(description: trimmed, clearErrorMessage: true),
    );
  }

  /// Menambahkan [quickText] bila belum ada, atau menghapusnya bila sudah ada.
  String? toggleQuickText(String quickText) {
    final current = state.value;
    if (current == null) return null;

    final nextText = toggleQuickTextInDescription(
      current.description,
      quickText,
    );
    if (nextText == current.description) return nextText;

    state = AsyncData(
      current.copyWith(description: nextText, clearErrorMessage: true),
    );
    return nextText;
  }

  /// Mengirim laporan tambahan ke backend.
  Future<bool> submit() async {
    final current = state.value;
    if (current == null || current.isSubmitting) return false;

    final position = current.userPosition;
    if (position == null || !current.isLocationValid) {
      state = AsyncData(
        current.copyWith(
          errorMessage:
              'Posisi Anda harus berada dalam radius ${kMaxReportRadiusMeters.toInt()} meter dari titik insiden.',
        ),
      );
      return false;
    }

    if (current.mediaFiles.isEmpty) {
      state = AsyncData(
        current.copyWith(
          errorMessage: 'Lampirkan minimal 1 foto bukti kondisi terbaru.',
        ),
      );
      return false;
    }

    final cleanDescription = current.description.trim();
    if (cleanDescription.isEmpty) {
      state = AsyncData(
        current.copyWith(
          errorMessage: 'Deskripsi perkembangan kondisi wajib diisi.',
        ),
      );
      return false;
    }

    state = AsyncData(
      current.copyWith(isSubmitting: true, clearErrorMessage: true),
    );

    try {
      final multipartFiles = await Future.wait(
        current.mediaFiles.map(
          (file) => MultipartFile.fromFile(file.path, filename: file.name),
        ),
      );

      await ref
          .read(incidentServiceProvider)
          .addIncidentReport(
            incidentId: incidentId,
            latitude: position.latitude,
            longitude: position.longitude,
            description: cleanDescription,
            mediaFiles: multipartFiles,
          );

      ref.invalidate(incidentDetailProvider(incidentId));
      return true;
    } on ApiException catch (e) {
      state = AsyncData(
        current.copyWith(isSubmitting: false, errorMessage: e.message),
      );
      return false;
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isSubmitting: false,
          errorMessage:
              'Gagal mengirim laporan. Periksa koneksi internet Anda.',
        ),
      );
      return false;
    }
  }
}

final addReportProvider =
    AsyncNotifierProvider.family<AddReportNotifier, AddReportData, String>(
      AddReportNotifier.new,
    );
