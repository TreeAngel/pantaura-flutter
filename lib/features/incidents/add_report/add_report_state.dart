import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/api_models.dart';

/// Batas radius maksimal (dalam meter) dari titik utama insiden untuk mengirim laporan.
const double kMaxReportRadiusMeters = 500.0;

/// Batas jumlah foto bukti maksimal per laporan.
const int kMaxReportMediaCount = 5;

/// Batas panjang deskripsi maksimal (karakter).
const int kMaxReportDescriptionLength = 500;

/// Daftar teks cepat berdasarkan jenis bencana (`flood`, `earthquake`, `landslide`, `fire`).
const Map<String, List<String>> quickTextsByDisaster = {
  'flood': [
    'Air bertambah naik (~15 cm)',
    'Akses perahu karet dibutuhkan',
    'Aliran listrik padam',
    'Butuh logistik / air bersih',
    'Warga lansia perlu dievakuasi',
  ],
  'earthquake': [
    'Gempa susulan masih terasa',
    'Bangunan retak / rubuh',
    'Korban terjebak di puing',
    'Butuh tenda & selimut',
    'Jalan utama tertutup puing',
  ],
  'landslide': [
    'Tanah masih bergerak',
    'Akses jalan tertutup material',
    'Rumah warga terancam',
    'Butuh alat berat',
    'Warga dievakuasi ke posko',
  ],
  'fire': [
    'Api masih menjalar',
    'Asap tebal mengganggu napas',
    'Butuh pemadam / damkar',
    'Evakuasi warga berlangsung',
    'Saluran air / hidran kering',
  ],
};

/// Mengambil daftar teks cepat berdasarkan [disasterType], dengan fallback ke `flood`.
List<String> getQuickTextsForDisaster(String disasterType) {
  return quickTextsByDisaster[disasterType.toLowerCase()] ??
      quickTextsByDisaster['flood'] ??
      const [];
}

/// State immutable untuk halaman Tambah Laporan Insiden.
class AddReportData {
  const AddReportData({
    required this.incident,
    this.userPosition,
    this.distanceMeters,
    this.isLocationValid = false,
    this.isRefreshingLocation = false,
    this.mediaFiles = const [],
    this.description = '',
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
  final bool isSubmitting;
  final String? errorMessage;

  AddReportData copyWith({
    IncidentDetailModel? incident,
    Position? userPosition,
    double? distanceMeters,
    bool? isLocationValid,
    bool? isRefreshingLocation,
    List<XFile>? mediaFiles,
    String? description,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AddReportData(
      incident: incident ?? this.incident,
      userPosition: userPosition ?? this.userPosition,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isLocationValid: isLocationValid ?? this.isLocationValid,
      isRefreshingLocation: isRefreshingLocation ?? this.isRefreshingLocation,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      description: description ?? this.description,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
