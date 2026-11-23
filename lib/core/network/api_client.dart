import 'package:dio/dio.dart';
import 'api_config.dart';
import 'api_exception.dart';

/// Token storage abstraction interface
abstract class TokenProvider {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

/// In-memory token provider (can be replaced by FlutterSecureStorage / SharedPreferences)
class InMemoryTokenProvider implements TokenProvider {
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;
}

class ApiClient {
  late final Dio dio;
  final TokenProvider tokenProvider;

  ApiClient({TokenProvider? tokenProvider, Dio? customDio})
      : tokenProvider = tokenProvider ?? InMemoryTokenProvider() {
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
      return await dio.get<T>(path, queryParameters: queryParameters, options: options);
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
      return await dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
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
      return await dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
