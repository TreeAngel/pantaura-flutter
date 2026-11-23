import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_status_theme.dart';
import 'app_typography.dart';

/// Central theme provider and configuration for Pantaura.
/// Complies with Material 3 and DESIGN.md specifications.
abstract final class AppTheme {
  /// ColorScheme definition based on DESIGN.md
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    inversePrimary: AppColors.inversePrimary,

    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,

    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,

    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,

    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceDim: AppColors.surfaceDim,
    surfaceBright: AppColors.surfaceBright,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,

    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    surfaceTint: AppColors.surfaceTint,
  );

  /// Builds the complete light ThemeData
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: AppColors.surfaceCanvas,
      textTheme: textTheme,

      // Custom extensions
      extensions: const <ThemeExtension<dynamic>>[
        AppStatusTheme.standard,
      ],

      // AppBar Theme (Tertiary Dark / Oceanic Navy feel, authoritative)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceCard,
        foregroundColor: AppColors.textHeader,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: AppColors.shadowNavy.withValues(alpha: 0.08),
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMd,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textHeader,
          size: 24,
        ),
      ),

      // Card Theme (Level 1: Pure White, 1px border, 16dp radius)
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
          borderRadius: AppRadius.roundedLg,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.margin,
          vertical: AppSpacing.spaceXs,
        ),
      ),

      // Elevated / Primary Button Theme (CTA 56px height, rounded 12px)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrand,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.outlineVariant,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          minimumSize: const Size(double.infinity, AppSpacing.ctaButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
          ),
          textStyle: AppTypography.labelLg,
          elevation: 2,
          shadowColor: AppColors.shadowNavy.withValues(alpha: 0.16),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceXl),
        ),
      ),

      // Outlined Button Theme (Secondary button: 56px height, 2px border)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBrand,
          minimumSize: const Size(double.infinity, AppSpacing.ctaButtonHeight),
          side: const BorderSide(color: AppColors.primaryBrand, width: 2.0),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
          ),
          textStyle: AppTypography.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceXl),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBrand,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          textStyle: AppTypography.labelMd,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedStandard,
          ),
        ),
      ),

      // Floating Action Button Theme (Reporting FAB 64px, Accent color #1891AC)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryAccent,
        foregroundColor: Colors.white,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 10,
        shape: const CircleBorder(),
        sizeConstraints: const BoxConstraints.tightFor(
          width: AppSpacing.emergencyFabSize,
          height: AppSpacing.emergencyFabSize,
        ),
      ),

      // Input Decoration Theme (min 54px, 1.5px border, rounded 12px)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceMd,
        ),
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
        labelStyle: AppTypography.labelMd.copyWith(color: AppColors.textHeader),
        errorStyle: AppTypography.bodySm.copyWith(
          color: AppColors.statusVerified,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.primaryBrand, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.statusVerified, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: const BorderSide(color: AppColors.statusVerified, width: 2.0),
        ),
      ),

      // Chip Theme (Status chips: min 28px height, 8px radius)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        disabledColor: AppColors.surfaceDim,
        selectedColor: AppColors.surfaceTintIce,
        labelStyle: AppTypography.labelSm,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedStandard,
          side: const BorderSide(color: Colors.transparent),
        ),
      ),

      // Bottom Sheet Theme (24px top radius)
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheet,
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.outlineVariant,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedLg,
        ),
        elevation: 8,
        shadowColor: AppColors.shadowNavy.withValues(alpha: 0.16),
        titleTextStyle: AppTypography.headlineMd,
        contentTextStyle: AppTypography.bodyMd,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
