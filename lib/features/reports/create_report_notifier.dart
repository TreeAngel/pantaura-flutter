import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/providers.dart';
import '../home/home_notifier.dart';
import '../incidents/add_report/add_report_state.dart';
import '../map/map_notifier.dart';
import 'create_report_state.dart';

/// Notifier form laporan bencana baru.
class CreateReportNotifier extends AsyncNotifier<CreateReportData> {
  @override
  Future<CreateReportData> build() async => CreateReportData.initial();

  Future<void> refreshLocation() async {
    final current = state.value;
    if (current == null || current.isLocating) return;

    state = AsyncData(current.copyWith(isLocating: true));
    try {
      final status = await ref
          .read(permissionServiceProvider)
          .requestLocationPermission();
      if (!status.isGranted) {
        state = AsyncData(current.copyWith(isLocating: false));
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      state = AsyncData(
        current.copyWith(
          pin: GeoPoint(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          isLocating: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLocating: false));
    }
  }

  /// [point] null berarti pin dihapus pengguna (tap pin kedua kali).
  void movePin(GeoPoint? point) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        pin: point,
        clearPin: point == null,
      ),
    );
  }

  void setDisasterType(String type) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(disasterType: type));
  }

  void setAddress(String address) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(address: address));
  }

  Future<void> capturePhoto(BuildContext context) =>
      _pickMedia(ImageSource.camera, context);

  Future<void> pickGallery(BuildContext context) =>
      _pickMedia(ImageSource.gallery, context);

  Future<void> _pickMedia(ImageSource source, BuildContext context) async {
    final current = state.value;
    if (current == null || current.mediaFiles.length >= kMaxReportMediaCount) {
      return;
    }
    final file = await ref
        .read(permissionServiceProvider)
        .pickImageWithPermission(source, context: context);
    if (file == null || !context.mounted) return;
    final latest = state.value;
    if (latest == null || latest.mediaFiles.length >= kMaxReportMediaCount) {
      return;
    }
    state = AsyncData(
      latest.copyWith(mediaFiles: [...latest.mediaFiles, file]),
    );
  }

  void removeMedia(int index) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.mediaFiles.length) {
      return;
    }
    final updated = List<XFile>.from(current.mediaFiles)..removeAt(index);
    state = AsyncData(current.copyWith(mediaFiles: updated));
  }

  void setDescription(String description) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(description: description));
  }

  /// Menambahkan atau menghapus teks cepat dari deskripsi.
  String? toggleQuickText(String text) {
    final current = state.value;
    if (current == null) return null;
    final next = toggleQuickTextInDescription(current.description, text);
    if (next == current.description) return next;
    state = AsyncData(current.copyWith(description: next));
    return next;
  }

  /// Kirim laporan; sukses → invalidate provider lalu caller melakukan pop.
  Future<bool> submit() async {
    final current = state.value;
    final pin = current?.pin;
    if (current == null ||
        pin == null ||
        current.isSubmitting ||
        current.description.trim().isEmpty ||
        current.mediaFiles.isEmpty) {
      return false;
    }

    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      final files = <MultipartFile>[];
      for (final file in current.mediaFiles) {
        files.add(await MultipartFile.fromFile(file.path));
      }
      await ref
          .read(reportServiceProvider)
          .createReport(
            disasterType: current.disasterType,
            latitude: pin.latitude,
            longitude: pin.longitude,
            description: current.description.trim(),
            address: current.address.trim().isEmpty
                ? null
                : current.address.trim(),
            mediaFiles: files,
          );
      ref.invalidate(homeNotifierProvider);
      ref.invalidate(mapProvider);
      state = AsyncData(current.copyWith(isSubmitting: false));
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(isSubmitting: false));
      return false;
    }
  }
}

final createReportProvider =
    AsyncNotifierProvider<CreateReportNotifier, CreateReportData>(
      CreateReportNotifier.new,
    );
