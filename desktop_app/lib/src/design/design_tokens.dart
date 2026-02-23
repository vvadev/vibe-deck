import 'package:flutter/material.dart';

/// Single source of truth for all design decisions in Vibe Deck Desktop Host.
///
/// This class defines the complete design system including colors, spacing,
/// typography, border radius, and shadows for both light and dark modes.
///
/// Accent Color: Electric Blue (#3B82F6)
/// - Chosen for trust, reliability, and technical competence
/// - Excellent contrast in both light and dark modes
/// - Modern developer tool aesthetics
class AppTokens {
  AppTokens._();

  // =======================================================================
  // COLORS - Light Mode
  // =======================================================================

  /// Background color for the main scaffold
  static const Color background = Color(0xFFFAFAFA);

  /// Primary surface color for cards and dialogs
  static const Color surface = Color(0xFFFFFFFF);

  /// Variant surface color for card headers and inputs
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Border color for dividers and borders
  static const Color border = Color(0xFFE5E7EB);

  /// Primary accent color - Electric Blue
  static const Color primary = Color(0xFF3B82F6);

  /// Primary accent color with reduced opacity for hover states
  static const Color primaryHover = Color(0xFF2563EB);

  /// Primary accent color with reduced opacity for backgrounds
  static const Color primaryContainer = Color(0xFFDBEAFE);

  /// Primary text color - high contrast for headings and primary text
  static const Color textPrimary = Color(0xFF111827);

  /// Secondary text color - medium contrast for body text
  static const Color textSecondary = Color(0xFF6B7280);

  /// Tertiary text color - low contrast for captions and metadata
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// Success color for positive states
  static const Color success = Color(0xFF10B981);

  /// Warning color for warnings and shell mode indicators
  static const Color warning = Color(0xFFF59E0B);

  /// Danger color for errors and dangerous actions
  static const Color danger = Color(0xFFEF4444);

  /// Info color for informational messages
  static const Color info = Color(0xFF3B82F6);

  // =======================================================================
  // COLORS - Dark Mode
  // =======================================================================

  /// Background color for the main scaffold in dark mode
  static const Color backgroundDark = Color(0xFF0F0F0F);

  /// Primary surface color for cards and dialogs in dark mode
  static const Color surfaceDark = Color(0xFF1A1A1A);

  /// Variant surface color for card headers and inputs in dark mode
  static const Color surfaceVariantDark = Color(0xFF242424);

  /// Border color for dividers and borders in dark mode
  static const Color borderDark = Color(0xFF2A2A2A);

  /// Primary accent color with reduced opacity for hover states in dark mode
  static const Color primaryHoverDark = Color(0xFF60A5FA);

  /// Primary accent color with reduced opacity for backgrounds in dark mode
  static const Color primaryContainerDark = Color(0xFF1E3A8A);

  /// Primary text color in dark mode
  static const Color textPrimaryDark = Color(0xFFF9FAFB);

  /// Secondary text color in dark mode
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  /// Tertiary text color in dark mode
  static const Color textTertiaryDark = Color(0xFF6B7280);

  /// Glassmorphism overlay color for elevated elements in dark mode
  static const Color glassOverlayDark = Color(0x0AFFFFFF);

  // =======================================================================
  // SEMANTIC COLORS - Dark Mode
  // =======================================================================

  /// Success color with reduced opacity for dark mode backgrounds
  static const Color successContainerDark = Color(0xFF064E3B);

  /// Warning color with reduced opacity for dark mode backgrounds
  static const Color warningContainerDark = Color(0xFF78350F);

  /// Danger color with reduced opacity for dark mode backgrounds
  static const Color dangerContainerDark = Color(0xFF7F1D1D);

  // =======================================================================
  // SPACING (8px Grid System)
  // =======================================================================

  /// Extra small spacing - 4px - tight gaps, icon spacing
  static const double spacingXs = 4.0;

  /// Small spacing - 8px - default element gap
  static const double spacingSm = 8.0;

  /// Medium spacing - 16px - card padding, sections
  static const double spacingMd = 16.0;

  /// Large spacing - 24px - screen padding, large gaps
  static const double spacingLg = 24.0;

  /// Extra large spacing - 32px - major section spacing
  static const double spacingXl = 32.0;

  /// Extra extra large spacing - 48px - hero sections
  static const double spacingXxl = 48.0;

  // =======================================================================
  // TYPOGRAPHY
  // =======================================================================

  /// Extra small font size - 11px - labels, metadata
  static const double fontSizeXs = 11.0;

  /// Small font size - 12px - secondary text
  static const double fontSizeSm = 12.0;

  /// Medium font size - 14px - body text
  static const double fontSizeMd = 14.0;

  /// Large font size - 16px - card titles
  static const double fontSizeLg = 16.0;

  /// Extra large font size - 20px - page headers
  static const double fontSizeXl = 20.0;

  /// Extra extra large font size - 24px - large headers
  static const double fontSize2Xl = 24.0;

  /// Extra extra extra large font size - 32px - hero text
  static const double fontSize3Xl = 32.0;

  // Font weights
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  // Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // =======================================================================
  // BORDER RADIUS
  // =======================================================================

  /// Small border radius - 8px - small elements
  static const double radiusSm = 8.0;

  /// Medium border radius - 12px - cards (default)
  static const double radiusMd = 12.0;

  /// Large border radius - 16px - large cards
  static const double radiusLg = 16.0;

  /// Extra large border radius - 24px - hero cards
  static const double radiusXl = 24.0;

  /// Full border radius - circular elements
  static const double radiusFull = 999.0;

  // =======================================================================
  // SHADOWS - Light Mode
  // =======================================================================

  /// Card shadow - subtle elevation for cards
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,0.05)
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Elevated shadow - higher elevation for floating elements
  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,0.08)
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // =======================================================================
  // SHADOWS - Dark Mode
  // =======================================================================

  /// Card shadow for dark mode
  static const List<BoxShadow> shadowCardDark = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.10)
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Elevated shadow for dark mode
  static const List<BoxShadow> shadowElevatedDark = [
    BoxShadow(
      color: Color(0x33000000), // rgba(0,0,0,0.20)
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // =======================================================================
  // Z-INDEX LAYERS
  // =======================================================================

  /// Base z-index for normal content
  static const int zBase = 0;

  /// Z-index for dropdown menus and popups
  static const int zDropdown = 10;

  /// Z-index for sticky headers
  static const int zSticky = 20;

  /// Z-index for fixed overlays
  static const int zFixed = 30;

  /// Z-index for modal backdrops
  static const int zModalBackdrop = 40;

  /// Z-index for modal dialogs
  static const int zModal = 50;

  /// Z-index for tooltips
  static const int zTooltip = 60;

  /// Z-index for notifications/toasts
  static const int zNotification = 70;

  // =======================================================================
  // TRANSITIONS
  // =======================================================================

  /// Default duration for UI transitions
  static const Duration durationFast = Duration(milliseconds: 150);

  /// Standard duration for UI transitions
  static const Duration durationNormal = Duration(milliseconds: 250);

  /// Slow duration for complex transitions
  static const Duration durationSlow = Duration(milliseconds: 350);

  /// Default curve for transitions
  static const Curve curveDefault = Curves.easeInOut;

  /// Curve for elements entering the screen
  static const Curve curveEaseOut = Curves.easeOut;

  /// Curve for elements leaving the screen
  static const Curve curveEaseIn = Curves.easeIn;

  // =======================================================================
  // BREAKPOINTS
  // =======================================================================

  /// Minimum width for medium screens
  static const double breakpointMd = 1024.0;

  /// Minimum width for large screens
  static const double breakpointLg = 1280.0;

  /// Minimum width for extra large screens
  static const double breakpointXl = 1536.0;

  // =======================================================================
  // HELPER METHODS
  // =======================================================================

  /// Returns the appropriate shadow based on the current brightness
  static List<BoxShadow> getCardShadow(Brightness brightness) {
    return brightness == Brightness.dark ? shadowCardDark : shadowCard;
  }

  /// Returns the appropriate elevated shadow based on the current brightness
  static List<BoxShadow> getElevatedShadow(Brightness brightness) {
    return brightness == Brightness.dark ? shadowElevatedDark : shadowElevated;
  }

  /// Returns the appropriate background color based on the current brightness
  static Color getBackground(Brightness brightness) {
    return brightness == Brightness.dark ? backgroundDark : background;
  }

  /// Returns the appropriate surface color based on the current brightness
  static Color getSurface(Brightness brightness) {
    return brightness == Brightness.dark ? surfaceDark : surface;
  }

  /// Returns the appropriate surface variant color based on the current brightness
  static Color getSurfaceVariant(Brightness brightness) {
    return brightness == Brightness.dark ? surfaceVariantDark : surfaceVariant;
  }

  /// Returns the appropriate border color based on the current brightness
  static Color getBorder(Brightness brightness) {
    return brightness == Brightness.dark ? borderDark : border;
  }

  /// Returns the appropriate primary text color based on the current brightness
  static Color getTextPrimary(Brightness brightness) {
    return brightness == Brightness.dark ? textPrimaryDark : textPrimary;
  }

  /// Returns the appropriate secondary text color based on the current brightness
  static Color getTextSecondary(Brightness brightness) {
    return brightness == Brightness.dark ? textSecondaryDark : textSecondary;
  }

  /// Returns the appropriate tertiary text color based on the current brightness
  static Color getTextTertiary(Brightness brightness) {
    return brightness == Brightness.dark ? textTertiaryDark : textTertiary;
  }
}
