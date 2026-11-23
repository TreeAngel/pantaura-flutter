import 'package:material_ui/material_ui.dart';

/// Semantic color palette for Pantaura.
/// Derived strictly from DESIGN.md tokens.
abstract final class AppColors {
  // Brand & Core Material 3 Colors
  static const Color primary = Color(0xFF00476E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1F5F8B);
  static const Color onPrimaryContainer = Color(0xFFADD7FF);
  static const Color inversePrimary = Color(0xFF94CCFE);

  static const Color secondary = Color(0xFF00677C);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF7FE2FF);
  static const Color onSecondaryContainer = Color(0xFF006478);

  static const Color tertiary = Color(0xFF2C4175);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF44598E);
  static const Color onTertiaryContainer = Color(0xFFC3D2FF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surface & Neutral tones
  static const Color background = Color(0xFFF8F9FF);
  static const Color onBackground = Color(0xFF0B1C30);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color onSurfaceVariant = Color(0xFF41474E);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  static const Color outline = Color(0xFF71787F);
  static const Color outlineVariant = Color(0xFFC1C7D0);
  static const Color surfaceTint = Color(0xFF24638F);

  // Fixed roles
  static const Color primaryFixed = Color(0xFFCDE5FF);
  static const Color primaryFixedDim = Color(0xFF94CCFE);
  static const Color onPrimaryFixed = Color(0xFF001D31);
  static const Color onPrimaryFixedVariant = Color(0xFF004B74);

  static const Color secondaryFixed = Color(0xFFB1ECFF);
  static const Color secondaryFixedDim = Color(0xFF70D4F1);
  static const Color onSecondaryFixed = Color(0xFF001F27);
  static const Color onSecondaryFixedVariant = Color(0xFF004E5E);

  static const Color tertiaryFixed = Color(0xFFDAE2FF);
  static const Color tertiaryFixedDim = Color(0xFFB1C5FF);
  static const Color onTertiaryFixed = Color(0xFF001947);
  static const Color onTertiaryFixedVariant = Color(0xFF304579);

  // Brand Semantic & Custom Tokens
  static const Color primaryBrand = Color(0xFF1F5F8B);
  static const Color secondaryAccent = Color(0xFF1891AC);
  static const Color tertiaryDark = Color(0xFF253B6E);
  static const Color surfaceCanvas = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceTintIce = Color(0xFFD2ECF9);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textHeader = Color(0xFF253B6E);

  // Incident Lifecycle Status Tokens
  static const Color statusUnverified = Color(0xFFD97706);
  static const Color statusUnverifiedBg = Color(0xFFFEF3C7);
  static const Color statusVerified = Color(0xFFDC2626);
  static const Color statusVerifiedBg = Color(0xFFFEE2E2);
  static const Color statusResolution = Color(0xFF1891AC);
  static const Color statusResolutionBg = Color(0xFFD2ECF9);
  static const Color statusResolved = Color(0xFF16A34A);
  static const Color statusResolvedBg = Color(0xFFDCFCE7);
  static const Color statusRejected = Color(0xFF64748B);
  static const Color statusRejectedBg = Color(0xFFF1F5F9);

  // Elevation Tint Shadow Base (rgba(37, 59, 110, ...))
  static const Color shadowNavy = Color(0xFF253B6E);
}
