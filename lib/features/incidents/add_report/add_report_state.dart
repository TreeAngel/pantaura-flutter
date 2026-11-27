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

/// Menambahkan [quickText] ke [description], atau menghapusnya bila sudah ada.
///
/// Digunakan bersama oleh ketiga form (create report, tambah laporan, pulih).
/// Hasil sel dibatasi [kMaxReportDescriptionLength] karakter dan spasi/tanda
/// baca yang menggantung setelah penghapusan dibersihkan.
String toggleQuickTextInDescription(String description, String quickText) {
  if (quickText.trim().isEmpty) return description;
  final needle = quickText.toLowerCase();
  var result = description.trim();

  if (result.toLowerCase().contains(needle)) {
    while (result.toLowerCase().contains(needle)) {
      final start = result.toLowerCase().indexOf(needle);
      final end = start + quickText.length;
      final before = result.substring(0, start).trimRight();
      final after = result.substring(end).trimLeft();

      final cleanBefore = before.replaceFirst(RegExp(r'[.,;\s]+$'), '');
      final cleanAfter = after.replaceFirst(RegExp(r'^[.,;\s]+'), '');

      if (cleanBefore.isEmpty) {
        result = cleanAfter;
      } else if (cleanAfter.isEmpty) {
        result = cleanBefore;
      } else {
        result = '$cleanBefore. $cleanAfter';
      }
    }
    return result.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  }

  final separator = result.isEmpty ? '' : (result.endsWith('.') ? ' ' : '. ');
  final candidate = '$result$separator$quickText.';
  return candidate.length > kMaxReportDescriptionLength
      ? candidate.substring(0, kMaxReportDescriptionLength)
      : candidate;
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
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
