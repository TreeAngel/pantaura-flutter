import '../network/api_client.dart';
import '../network/api_config.dart';
import '../models/api_models.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  /// POST /auth/register
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? deviceName,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (deviceName != null) ...{'device_name': deviceName},
      },
    );
    final auth = AuthResponseModel.fromJson(response.data!);
    await _client.tokenProvider.saveToken(auth.token);
    return auth;
  }

  /// POST /auth/login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.login,
      data: {
        'email': email,
        'password': password,
        if (deviceName != null) ...{'device_name': deviceName},
      },
    );
    final auth = AuthResponseModel.fromJson(response.data!);
    await _client.tokenProvider.saveToken(auth.token);
    return auth;
  }

  /// POST /auth/logout
  Future<void> logout() async {
    try {
      await _client.post<Map<String, dynamic>>(ApiConfig.logout);
    } finally {
      await _client.tokenProvider.clearToken();
    }
  }

  /// GET /auth/me
  Future<UserModel> getMe() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConfig.me);
    final data = response.data?['data'] as Map<String, dynamic>? ?? response.data!;
    return UserModel.fromJson(data);
  }
}
