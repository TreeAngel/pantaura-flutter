import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// Token beserta waktu penyimpanan untuk pengecekan masa berlaku.
class StoredToken {
  const StoredToken({
    required this.token,
    required this.savedAt,
  });

  final String token;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'token': token,
        'saved_at': savedAt.toIso8601String(),
      };

  factory StoredToken.fromJson(Map<String, dynamic> json) => StoredToken(
        token: json['token'] as String? ?? '',
        savedAt: DateTime.tryParse(json['saved_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

/// Abstraksi penyimpanan token.
abstract class TokenProvider {
  /// Token + waktu simpan (bisa null bila belum login).
  Future<StoredToken?> readStoredToken();

  /// Token saja, dipakai interceptor Dio.
  Future<String?> getToken();

  /// Simpan token; [savedAt] default waktu pemanggilan.
  Future<void> saveToken(String token, {DateTime? savedAt});

  Future<void> clearToken();
}

/// Penyimpanan aman memakai flutter_secure_storage.
///
/// Token dan waktu simpan disimpan pada key terpisah agar bisa dicek
/// umurnya saat splash screen.
class SecureTokenProvider implements TokenProvider {
  SecureTokenProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String tokenKey = 'auth_token';
  static const String savedAtKey = 'auth_token_saved_at';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredToken?> readStoredToken() async {
    final token = await _storage.read(key: tokenKey);
    if (token == null || token.isEmpty) return null;
    final rawDate = await _storage.read(key: savedAtKey);
    final savedAt = DateTime.tryParse(rawDate ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return StoredToken(token: token, savedAt: savedAt);
  }

  @override
  Future<String?> getToken() async {
    final stored = await readStoredToken();
    return stored?.token;
  }

  @override
  Future<void> saveToken(String token, {DateTime? savedAt}) async {
    final timestamp = (savedAt ?? DateTime.now()).toIso8601String();
    await _storage.write(key: tokenKey, value: token);
    await _storage.write(key: savedAtKey, value: timestamp);
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: savedAtKey);
  }
}

/// Provider memori untuk test / fallback.
class InMemoryTokenProvider implements TokenProvider {
  StoredToken? _stored;

  @override
  Future<StoredToken?> readStoredToken() async => _stored;

  @override
  Future<String?> getToken() async => _stored?.token;

  @override
  Future<void> saveToken(String token, {DateTime? savedAt}) async {
    _stored = StoredToken(
      token: token,
      savedAt: savedAt ?? DateTime.now(),
    );
  }

  @override
  Future<void> clearToken() async => _stored = null;
}

class ApiClient {
  late final Dio dio;
  final TokenProvider tokenProvider;

  ApiClient({TokenProvider? tokenProvider, Dio? customDio})
      : tokenProvider = tokenProvider ?? SecureTokenProvider() {
    dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            headers: {
              'Accept': 'application/json',
            },
          ),
        );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await this.tokenProvider.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
