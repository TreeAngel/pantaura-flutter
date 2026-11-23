import 'package:dio/dio.dart';

/// Custom Exception wrapper for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioException(DioException dioException) {
    int? code = dioException.response?.statusCode;
    String message = 'Terjadi kesalahan pada jaringan';
    Map<String, dynamic>? validationErrors;

    final responseData = dioException.response?.data;
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        message = responseData['message'].toString();
      }
      if (responseData['errors'] is Map<String, dynamic>) {
        validationErrors = responseData['errors'] as Map<String, dynamic>;
      }
    } else if (dioException.type == DioExceptionType.connectionTimeout) {
      message = 'Koneksi ke server timeout';
    } else if (dioException.type == DioExceptionType.receiveTimeout) {
      message = 'Server membutuhkan waktu terlalu lama untuk merespons';
    } else if (dioException.type == DioExceptionType.connectionError) {
      message = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda';
    }

    return ApiException(
      message: message,
      statusCode: code,
      errors: validationErrors,
    );
  }

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
