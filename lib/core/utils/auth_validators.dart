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

  /// Password validation (Min 12 characters)
  static String? validatePassword(String? value, {int minLength = 12}) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < minLength) {
      return 'Kata sandi minimal $minLength karakter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Kata sandi harus mengandung setidaknya satu angka';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Kata sandi harus mengandung setidaknya satu huruf kecil';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Kata sandi harus mengandung setidaknya satu huruf besar';
    }
    if (!value.contains(RegExp(r'[^a-zA-Z0-9\s]'))) {
      return 'Kata sandi harus mengandung setidaknya satu simbol khusus';
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
    return null;
  }
}
