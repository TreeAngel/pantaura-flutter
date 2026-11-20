import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';

/// Theme extension for custom incident status and semantic branding tokens
/// that go beyond standard Material 3 ColorScheme.
@immutable
class AppStatusTheme extends ThemeExtension<AppStatusTheme> {
  const AppStatusTheme({
    required this.statusUnverified,
    required this.statusUnverifiedBg,
    required this.statusVerified,
    required this.statusVerifiedBg,
    required this.statusResolution,
    required this.statusResolutionBg,
    required this.statusResolved,
    required this.statusResolvedBg,
    required this.statusRejected,
    required this.statusRejectedBg,
    required this.surfaceCanvas,
    required this.surfaceCard,
    required this.surfaceTintIce,
    required this.borderSubtle,
    required this.textHeader,
    required this.primaryBrand,
    required this.secondaryAccent,
  });

  final Color statusUnverified;
  final Color statusUnverifiedBg;
  final Color statusVerified;
  final Color statusVerifiedBg;
  final Color statusResolution;
  final Color statusResolutionBg;
  final Color statusResolved;
  final Color statusResolvedBg;
  final Color statusRejected;
  final Color statusRejectedBg;

  final Color surfaceCanvas;
  final Color surfaceCard;
  final Color surfaceTintIce;
  final Color borderSubtle;
  final Color textHeader;
  final Color primaryBrand;
  final Color secondaryAccent;

  static const standard = AppStatusTheme(
    statusUnverified: AppColors.statusUnverified,
    statusUnverifiedBg: AppColors.statusUnverifiedBg,
    statusVerified: AppColors.statusVerified,
    statusVerifiedBg: AppColors.statusVerifiedBg,
    statusResolution: AppColors.statusResolution,
    statusResolutionBg: AppColors.statusResolutionBg,
    statusResolved: AppColors.statusResolved,
    statusResolvedBg: AppColors.statusResolvedBg,
    statusRejected: AppColors.statusRejected,
    statusRejectedBg: AppColors.statusRejectedBg,
    surfaceCanvas: AppColors.surfaceCanvas,
    surfaceCard: AppColors.surfaceCard,
    surfaceTintIce: AppColors.surfaceTintIce,
    borderSubtle: AppColors.borderSubtle,
    textHeader: AppColors.textHeader,
    primaryBrand: AppColors.primaryBrand,
    secondaryAccent: AppColors.secondaryAccent,
  );

  @override
  AppStatusTheme copyWith({
    Color? statusUnverified,
    Color? statusUnverifiedBg,
    Color? statusVerified,
    Color? statusVerifiedBg,
    Color? statusResolution,
    Color? statusResolutionBg,
    Color? statusResolved,
    Color? statusResolvedBg,
    Color? statusRejected,
    Color? statusRejectedBg,
    Color? surfaceCanvas,
    Color? surfaceCard,
    Color? surfaceTintIce,
    Color? borderSubtle,
    Color? textHeader,
    Color? primaryBrand,
    Color? secondaryAccent,
  }) {
    return AppStatusTheme(
      statusUnverified: statusUnverified ?? this.statusUnverified,
      statusUnverifiedBg: statusUnverifiedBg ?? this.statusUnverifiedBg,
      statusVerified: statusVerified ?? this.statusVerified,
      statusVerifiedBg: statusVerifiedBg ?? this.statusVerifiedBg,
      statusResolution: statusResolution ?? this.statusResolution,
      statusResolutionBg: statusResolutionBg ?? this.statusResolutionBg,
      statusResolved: statusResolved ?? this.statusResolved,
      statusResolvedBg: statusResolvedBg ?? this.statusResolvedBg,
      statusRejected: statusRejected ?? this.statusRejected,
      statusRejectedBg: statusRejectedBg ?? this.statusRejectedBg,
      surfaceCanvas: surfaceCanvas ?? this.surfaceCanvas,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceTintIce: surfaceTintIce ?? this.surfaceTintIce,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textHeader: textHeader ?? this.textHeader,
      primaryBrand: primaryBrand ?? this.primaryBrand,
      secondaryAccent: secondaryAccent ?? this.secondaryAccent,
    );
  }

  @override
  AppStatusTheme lerp(ThemeExtension<AppStatusTheme>? other, double t) {
    if (other is! AppStatusTheme) return this;
    return AppStatusTheme(
      statusUnverified: Color.lerp(statusUnverified, other.statusUnverified, t)!,
      statusUnverifiedBg: Color.lerp(statusUnverifiedBg, other.statusUnverifiedBg, t)!,
      statusVerified: Color.lerp(statusVerified, other.statusVerified, t)!,
      statusVerifiedBg: Color.lerp(statusVerifiedBg, other.statusVerifiedBg, t)!,
      statusResolution: Color.lerp(statusResolution, other.statusResolution, t)!,
      statusResolutionBg: Color.lerp(statusResolutionBg, other.statusResolutionBg, t)!,
      statusResolved: Color.lerp(statusResolved, other.statusResolved, t)!,
      statusResolvedBg: Color.lerp(statusResolvedBg, other.statusResolvedBg, t)!,
      statusRejected: Color.lerp(statusRejected, other.statusRejected, t)!,
      statusRejectedBg: Color.lerp(statusRejectedBg, other.statusRejectedBg, t)!,
      surfaceCanvas: Color.lerp(surfaceCanvas, other.surfaceCanvas, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceTintIce: Color.lerp(surfaceTintIce, other.surfaceTintIce, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textHeader: Color.lerp(textHeader, other.textHeader, t)!,
      primaryBrand: Color.lerp(primaryBrand, other.primaryBrand, t)!,
      secondaryAccent: Color.lerp(secondaryAccent, other.secondaryAccent, t)!,
    );
  }
}

/// Convenience extension on [BuildContext] to access custom tokens easily:
/// `context.statusTheme.statusVerified`
extension StatusThemeContextExtension on BuildContext {
  AppStatusTheme get statusTheme =>
      Theme.of(this).extension<AppStatusTheme>() ?? AppStatusTheme.standard;
}
