import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:image_picker/image_picker.dart';

/// State immutable halaman Buat Laporan Bencana.
/// Posisi awal tidak memakai titik demo — diisi dari GPS akurasi tinggi.

class CreateReportData {
  const CreateReportData({
    this.pin,
    this.disasterType = 'flood',
    this.address = '',
    this.mediaFiles = const [],
    this.description = '',
    this.isLocating = false,
    this.isSubmitting = false,
  });

  factory CreateReportData.initial() => const CreateReportData();

  final String disasterType;
  final GeoPoint? pin;
  final String address;
  final List<XFile> mediaFiles;
  final String description;
  final bool isLocating;
  final bool isSubmitting;

  CreateReportData copyWith({
    String? disasterType,
    GeoPoint? pin,
    bool clearPin = false,
    String? address,
    List<XFile>? mediaFiles,
    String? description,
    bool? isLocating,
    bool? isSubmitting,
  }) {
    return CreateReportData(
      disasterType: disasterType ?? this.disasterType,
      pin: clearPin ? null : (pin ?? this.pin),
      address: address ?? this.address,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      description: description ?? this.description,
      isLocating: isLocating ?? this.isLocating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
