import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/auth_validators.dart';
import '../../core/widgets/app_button.dart';
import 'auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil! Selamat datang di Pantaura.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      context.go(AppRoutes.home);
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
                    // Brand Logo & Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF253B6E), Color(0xFF1F5F8B)],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1F5F8B).withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shield_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceSm),
                          Text(
                            'Pantaura',
                            style: AppTypography.headlineLg.copyWith(
                              color: const Color(0xFF253B6E),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.spaceXl),

                    // Greeting
                    Text(
                      'Masuk ke Akun Anda',
                      style: AppTypography.headlineLg.copyWith(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Text(
                      'Silakan masukkan email terdaftar untuk akses cepat pelaporan bencana.',
                      style: AppTypography.bodyMd.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.spaceXl),

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
                      'Kata Sandi',
                      style: AppTypography.labelMd.copyWith(
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXs),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _handleLogin(),
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

                    const SizedBox(height: AppSpacing.spaceXl),

                    // Submit Button (54px Elder Friendly)
                    PrimaryButton(
                      label: 'Masuk Sekarang',
                      icon: Icons.login_rounded,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleLogin,
                    ),

                    const SizedBox(height: AppSpacing.spaceLg),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: AppTypography.bodyMd.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => context.push(AppRoutes.register),
                          child: Text(
                            'Daftar Warga Baru',
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
