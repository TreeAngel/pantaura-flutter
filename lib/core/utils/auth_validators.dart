class AuthValidators {
  AuthValidators._();

  /// Email validation (Standard RFC-compliant Regex)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Format email tidak valid (contoh: warga@domain.com)';
    }
    return null;
  }

  /// Password validation (Min 8 characters)
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < minLength) {
      return 'Kata sandi minimal $minLength karakter';
    }
    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    if (value != password) {
      return 'Konfirmasi kata sandi tidak cocok';
    }
    return null;
  }

  /// Full name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }
}
