import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/emergency_112_dialog.dart';
import '../auth/auth_notifier.dart';
import 'widgets/accessibility_section.dart';
import 'widgets/help_section.dart';
import 'widgets/logout_button.dart';
import 'widgets/logout_confirmation_sheet.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_identity_card.dart';
import 'widgets/security_section.dart';

/// Halaman profil warga: identitas, menu pajangan, bantuan, dan logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label masih dikembangkan')),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = switch (authState) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.space2xl),
          child: Column(
            children: [
              ProfileHeader(
                onSettingsTap: () => _showComingSoon(context, 'Pengaturan'),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.margin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.spaceMd),
                    ProfileIdentityCard(user: user),
                    const SizedBox(height: AppSpacing.spaceMd),
                    AccessibilitySection(
                      onComingSoon: (label) =>
                          _showComingSoon(context, label),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    SecuritySection(
                      onComingSoon: (label) =>
                          _showComingSoon(context, label),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    HelpSection(
                      onComingSoon: (label) =>
                          _showComingSoon(context, label),
                      onEmergencyCall: () => showEmergency112Dialog(context),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    LogoutButton(
                      onTap: () => showLogoutConfirmationSheet(
                        context,
                        onConfirm: () => _logout(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
