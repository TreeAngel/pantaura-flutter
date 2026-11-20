import 'package:material_ui/material_ui.dart';

/// Standard spacing and layout dimensions based on DESIGN.md
abstract final class AppSpacing {
  // Spacing scales (based on 1rem = 16dp)
  static const double space2xs = 4.0; // 0.25rem
  static const double spaceXs = 8.0; // 0.5rem
  static const double spaceSm = 12.0; // 0.75rem
  static const double spaceMd = 16.0; // 1.0rem
  static const double spaceLg = 20.0; // 1.25rem
  static const double spaceXl = 24.0; // 1.5rem
  static const double space2xl = 32.0; // 2.0rem

  // Gutters and Margins
  static const double gutterSm = 12.0; // 0.75rem
  static const double gutter = 16.0; // 1.0rem
  static const double margin = 16.0; // 1.0rem (mobile horizontal screen padding)
  static const double marginLg = 24.0; // 1.5rem (tablet screen padding)

  // Maximum content widths
  static const double maxFormWidth = 600.0;

  // Touch Target Constraints
  static const double minTouchTarget = 48.0;
  static const double ctaButtonHeight = 56.0;
  static const double emergencyFabSize = 64.0;
  static const double inputMinHeight = 54.0;
  static const double textAreaMinHeight = 120.0;
  static const double categoryCardMinHeight = 100.0;
  static const double statusChipMinHeight = 28.0;
}

/// Border Radii tokens defined in DESIGN.md
abstract final class AppRadius {
  static const double sm = 4.0; // 0.25rem
  static const double standard = 8.0; // 0.5rem (Chips, badges)
  static const double md = 12.0; // 0.75rem (Buttons, inputs, category selectors)
  static const double lg = 16.0; // 1.0rem (Cards, panels, containers)
  static const double xl = 24.0; // 1.5rem (Bottom sheets top radius)
  static const double full = 9999.0; // FAB & pill shapes

  // BorderRadius helpers
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedStandard = BorderRadius.all(Radius.circular(standard));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(full));

  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
}

/// Elevation and Box Shadow Architecture defined in DESIGN.md
abstract final class AppShadows {
  // Level 1: Cards & Content Blocks (0px 2px 4px rgba(37, 59, 110, 0.04))
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color.fromRGBO(37, 59, 110, 0.04),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  // Level 2: Floating Controls & Navigation (0px 4px 12px rgba(37, 59, 110, 0.08))
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color.fromRGBO(37, 59, 110, 0.08),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  // Level 3: Emergency Actions, FAB, Dialogs (0px 8px 24px rgba(37, 59, 110, 0.16))
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color.fromRGBO(37, 59, 110, 0.16),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  // Level 4: Sticky Full-Width CTAs (0px -4px 16px rgba(37, 59, 110, 0.06))
  static const List<BoxShadow> level4 = [
    BoxShadow(
      color: Color.fromRGBO(37, 59, 110, 0.06),
      offset: Offset(0, -4),
      blurRadius: 16,
    ),
  ];
}
