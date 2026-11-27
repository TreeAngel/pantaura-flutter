import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/api_models.dart';

/// Daftar 5 opsi teks cepat umum untuk pengajuan kondisi pulih.
const List<String> quickRecoveryTexts = [
  'Air sudah surut total / area kering kembali',
  'Akses jalan sudah dapat dilalui',
  'Tidak ada korban tertinggal',
  'Tim lapangan sedang tahap pembersihan',
  'Kondisi kembali aman untuk warga',
];

/// State immutable untuk halaman Lapor Kondisi Pulih.
class RecoveredData {
  const RecoveredData({
    required this.incident,
    this.userPosition,
    this.distanceMeters,
    this.isLocationValid = false,
    this.isRefreshingLocation = false,
    this.mediaFiles = const [],
    this.description = '',
    this.isDeclarationChecked = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final IncidentDetailModel incident;
  final Position? userPosition;
  final double? distanceMeters;
  final bool isLocationValid;
  final bool isRefreshingLocation;
  final List<XFile> mediaFiles;
  final String description;
  final bool isDeclarationChecked;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canSubmit =>
      isLocationValid &&
      isDeclarationChecked &&
      mediaFiles.isNotEmpty &&
      description.trim().isNotEmpty &&
      !isSubmitting;

  RecoveredData copyWith({
    IncidentDetailModel? incident,
    Position? userPosition,
    double? distanceMeters,
    bool? isLocationValid,
    bool? isRefreshingLocation,
    List<XFile>? mediaFiles,
    String? description,
    bool? isDeclarationChecked,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return RecoveredData(
      incident: incident ?? this.incident,
      userPosition: userPosition ?? this.userPosition,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isLocationValid: isLocationValid ?? this.isLocationValid,
      isRefreshingLocation: isRefreshingLocation ?? this.isRefreshingLocation,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      description: description ?? this.description,
      isDeclarationChecked: isDeclarationChecked ?? this.isDeclarationChecked,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
