import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/api_models.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers.dart';

/// State representation for Auth operations
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String token;

  const AuthAuthenticated({
    required this.user,
    required this.token,
  });
}

final class AuthError extends AuthState {
  final String message;
  final Map<String, dynamic>? errors;

  const AuthError({
    required this.message,
    this.errors,
  });
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Notifier to manage Login & Registration with Riverpod
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  /// Handle User Login
  Future<bool> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    state = const AuthLoading();
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(
        email: email.trim(),
        password: password,
        deviceName: deviceName ?? 'Flutter Mobile',
      );
      state = AuthAuthenticated(
        user: response.user,
        token: response.token,
      );
      return true;
    } on ApiException catch (e) {
      state = AuthError(message: e.message, errors: e.errors);
      return false;
    } catch (e) {
      state = AuthError(message: e.toString());
      return false;
    }
  }

  /// Handle User Registration
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? deviceName,
  }) async {
    state = const AuthLoading();
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
        passwordConfirmation: passwordConfirmation,
        deviceName: deviceName ?? 'Flutter Mobile',
      );
      state = AuthAuthenticated(
        user: response.user,
        token: response.token,
      );
      return true;
    } on ApiException catch (e) {
      state = AuthError(message: e.message, errors: e.errors);
      return false;
    } catch (e) {
      state = AuthError(message: e.toString());
      return false;
    }
  }

  /// Handle Logout
  Future<void> logout() async {
    state = const AuthLoading();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  /// Pulihkan sesi dari token tersimpan (dipanggil saat splash).
  ///
  /// Splash sudah memeriksa usia token; di sini token dipakai untuk memuat
  /// profil via GET /auth/me agar state auth berisi data user yang valid.
  Future<void> restoreSession() async {
    final provider = ref.read(tokenProviderInstance);
    final stored = await provider.readStoredToken();
    if (stored == null || stored.token.isEmpty) {
      state = const AuthUnauthenticated();
      return;
    }
    try {
      final user = await ref.read(authServiceProvider).getMe();
      state = AuthAuthenticated(user: user, token: stored.token);
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  /// Reset error state
  void resetError() {
    if (state is AuthError) {
      state = const AuthInitial();
    }
  }
}

/// Provider for AuthNotifier
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
