import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../add_report/add_report_state.dart';
import '../detail/incident_detail_notifier.dart';
import 'recovered_state.dart';

/// Notifier untuk mengelola pengajuan Lapor Kondisi Pulih dengan Riverpod 3.5.
class RecoveredNotifier extends AsyncNotifier<RecoveredData> {
  RecoveredNotifier(this.incidentId);

  final String incidentId;

  @override
  Future<RecoveredData> build() async {
    final detailData = await ref.read(
      incidentDetailProvider(incidentId).future,
    );
    return RecoveredData(incident: detailData.incident);
  }

  /// Meminta izin lokasi, mengambil posisi GPS terkini, dan memvalidasi jarak ≤ 500 m.
  Future<({PermissionStatus? status, bool isValid, double? distanceMeters})>
  refreshLocation() async {
    final current = state.value;
    if (current == null || current.isRefreshingLocation) {
      return (
        status: null,
        isValid: current?.isLocationValid ?? false,
        distanceMeters: current?.distanceMeters,
      );
    }

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
            errorMessage: 'Izin lokasi diperlukan untuk memverifikasi posisi di area insiden.',
          ),
        );
        return (
          status: status,
          isValid: false,
          distanceMeters: current.distanceMeters,
        );
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

      final isValid = distance <= kMaxReportRadiusMeters;

      state = AsyncData(
        current.copyWith(
          userPosition: position,
          distanceMeters: distance,
          isLocationValid: isValid,
          isRefreshingLocation: false,
          clearErrorMessage: true,
        ),
      );
      return (status: status, isValid: isValid, distanceMeters: distance);
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isRefreshingLocation: false,
          isLocationValid: false,
          errorMessage: 'Gagal mengambil koordinat GPS. Pastikan GPS aktif dan coba lagi.',
        ),
      );
      return (
        status: null,
        isValid: false,
        distanceMeters: current.distanceMeters,
      );
    }
  }

  /// Menambahkan foto bukti maksimal 5 file.
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

  /// Memperbarui deskripsi kondisi pulih.
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

  /// Mengubah status centang pernyataan kebenaran lapangan.
  void setDeclaration(bool checked) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(isDeclarationChecked: checked, clearErrorMessage: true),
    );
  }

  /// Mengirim pengajuan status pulih ke endpoint `submitResolution`.
  Future<bool> submit() async {
    final current = state.value;
    if (current == null || current.isSubmitting) return false;

    if (!current.isLocationValid) {
      state = AsyncData(
        current.copyWith(
          errorMessage:
              'Verifikasi posisi hanya berlaku dalam radius maksimal ${kMaxReportRadiusMeters.toInt()} meter.',
        ),
      );
      return false;
    }

    if (!current.isDeclarationChecked) {
      state = AsyncData(
        current.copyWith(
          errorMessage:
              'Centang Pernyataan Kebenaran Lapangan sebelum mengajukan.',
        ),
      );
      return false;
    }

    if (current.mediaFiles.isEmpty) {
      state = AsyncData(
        current.copyWith(
          errorMessage: 'Lampirkan minimal 1 foto bukti kondisi pulih.',
        ),
      );
      return false;
    }

    final cleanDescription = current.description.trim();
    if (cleanDescription.isEmpty) {
      state = AsyncData(
        current.copyWith(
          errorMessage: 'Deskripsi kondisi lapangan saat ini wajib diisi.',
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
          .submitResolution(
            incidentId: incidentId,
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
          errorMessage: 'Gagal mengirim pengajuan status pulih. Periksa koneksi internet Anda.',
        ),
      );
      return false;
    }
  }
}

final recoveredProvider =
    AsyncNotifierProvider.family<RecoveredNotifier, RecoveredData, String>(
      RecoveredNotifier.new,
    );
