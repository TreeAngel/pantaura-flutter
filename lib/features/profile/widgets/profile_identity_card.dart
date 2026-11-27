import 'package:material_ui/material_ui.dart';

import '../../../core/models/api_models.dart';
import '../../../core/theme/theme.dart';

/// Kartu identitas warga berdasarkan data auth yang sudah login.
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key, required this.user});

  final UserModel? user;

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'WP';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final rawName = user?.name ?? '';
    final rawEmail = user?.email ?? '';
    final name = rawName.trim().isEmpty ? 'Warga Pantaura' : rawName.trim();
    final email = rawEmail.trim().isEmpty ? 'Email belum tersedia' : rawEmail.trim();
    final role = (user?.role ?? '').trim();
    final roleLabel = role.isEmpty
        ? 'Warga Terverifikasi'
        : (role.toLowerCase() == 'citizen'
            ? 'Warga Terverifikasi'
            : role.replaceAll('_', ' ').toUpperCase());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.roundedLg,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceTintIce,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Row(
                      children: [
                        const Icon(Icons.mail_outline_rounded,
                            size: 16, color: AppColors.primaryContainer),
                        const SizedBox(width: AppSpacing.space2xs),
                        Expanded(
                          child: Text(
                            email,
                            style: AppTypography.bodySm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.primaryContainer),
                        const SizedBox(width: AppSpacing.space2xs),
                        Expanded(
                          child: Text(
                            'Alamat warga belum diisi',
                            style: AppTypography.bodySm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.space2xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.statusResolvedBg,
              borderRadius: AppRadius.roundedFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                    size: 14, color: AppColors.statusResolved),
                const SizedBox(width: AppSpacing.space2xs),
                Text(
                  roleLabel,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.statusResolved,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
