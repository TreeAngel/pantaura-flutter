import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/auth_validators.dart';
import '../../core/widgets/app_button.dart';
import '../../main.dart';
import 'auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Selamat bergabung di Pantaura.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ThemeShowcaseScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // surface-canvas
      appBar: AppBar(
        title: const Text('Registrasi Warga'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.margin,
              vertical: AppSpacing.spaceLg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpacing.maxFormWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Title
                    Text(
                      'Daftar Akun Warga',
                      style: AppTypography.headlineLg.copyWith(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Text(
                      'Daftarkan diri Anda untuk berpartisipasi memantau dan melaporkan bencana di sekitar.',
                      style: AppTypography.bodyMd.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.spaceXl),

                    // Full Name Field
                    Text(
                      'Nama Lengkap (Sesuai KTP)',
                      style: AppTypography.labelMd.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXs),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama lengkap Anda',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: AuthValidators.validateName,
                    ),

                    const SizedBox(height: AppSpacing.spaceMd),

                    // Email Field
                    Text(
                      'Alamat Email',
                      style: AppTypography.labelMd.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXs),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'nama@domain.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: AuthValidators.validateEmail,
                    ),

                    const SizedBox(height: AppSpacing.spaceMd),

                    // Password Field
                    Text(
                      'Kata Sandi Baru',
                      style: AppTypography.labelMd.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXs),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Minimal 8 karakter',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: AuthValidators.validatePassword,
                    ),

                    const SizedBox(height: AppSpacing.spaceMd),

                    // Confirm Password Field
                    Text(
                      'Konfirmasi Kata Sandi',
                      style: AppTypography.labelMd.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXs),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _handleRegister(),
                      decoration: InputDecoration(
                        hintText: 'Ulangi kata sandi di atas',
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) => AuthValidators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.spaceXl),

                    // Submit Button
                    PrimaryButton(
                      label: 'Daftar Sekarang',
                      icon: Icons.person_add_rounded,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleRegister,
                    ),

                    const SizedBox(height: AppSpacing.spaceLg),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah memiliki akun? ',
                          style: AppTypography.bodyMd.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading ? null : () => Navigator.of(context).pop(),
                          child: Text(
                            'Masuk di sini',
                            style: AppTypography.labelMd.copyWith(
                              color: const Color(0xFF1891AC),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
