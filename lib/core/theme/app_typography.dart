import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography definitions using GoogleFonts (Plus Jakarta Sans for headings, Inter for body/labels)
/// strictly conforming to DESIGN.md typography specs.
abstract final class AppTypography {
  // --- Headings: Plus Jakarta Sans ---

  /// display-hero: 28px, 700 bold, line-height 36px, letter-spacing -0.02em
  static TextStyle get displayHero => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        letterSpacing: -0.02 * 28,
        color: AppColors.textHeader,
      );

  /// headline-lg: 22px, 700 bold, line-height 28px, letter-spacing -0.01em
  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 28 / 22,
        letterSpacing: -0.01 * 22,
        color: AppColors.textHeader,
      );

  /// headline-md: 18px, 600 semi-bold, line-height 24px
  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        color: AppColors.textHeader,
      );

  /// headline-sm: 16px, 600 semi-bold, line-height 22px
  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: AppColors.textHeader,
      );

  // --- Body: Inter ---

  /// body-lg: 16px, 400 normal, line-height 24px
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.textPrimary,
      );

  /// body-md: 14px, 400 normal, line-height 20px
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.textPrimary,
      );

  /// body-sm: 13px, 400 normal, line-height 18px
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        color: AppColors.onSurfaceVariant,
      );

  // --- Labels & Actions: Inter ---

  /// label-lg: 16px, 600 semi-bold, line-height 24px, letter-spacing 0.02em
  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        letterSpacing: 0.02 * 16,
        color: AppColors.textPrimary,
      );

  /// label-md: 14px, 600 semi-bold, line-height 20px, letter-spacing 0.02em
  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.02 * 14,
        color: AppColors.textPrimary,
      );

  /// label-sm: 12px, 500 medium, line-height 16px, letter-spacing 0.01em
  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.01 * 12,
        color: AppColors.textPrimary,
      );

  /// caption: 12px, 400 regular, line-height 16px
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.onSurfaceVariant,
      );

  /// Builds a complete Flutter Material [TextTheme] based on GoogleFonts configuration.
  static TextTheme createTextTheme() {
    return TextTheme(
      // Display
      displayLarge: displayHero,
      displayMedium: displayHero.copyWith(fontSize: 26, height: 32 / 26),
      displaySmall: headlineLg,

      // Headline
      headlineLarge: headlineLg,
      headlineMedium: headlineMd,
      headlineSmall: headlineSm,

      // Title
      titleLarge: headlineMd,
      titleMedium: headlineSm,
      titleSmall: labelLg,

      // Body
      bodyLarge: bodyLg,
      bodyMedium: bodyMd,
      bodySmall: bodySm,

      // Label
      labelLarge: labelLg,
      labelMedium: labelMd,
      labelSmall: labelSm,
    );
  }
}
