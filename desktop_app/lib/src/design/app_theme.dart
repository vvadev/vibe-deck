import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Complete theme configuration for Vibe Deck Desktop Host.
///
/// Provides light and dark theme data with consistent styling across
/// all components following the design system defined in AppTokens.
class AppTheme {
  AppTheme._();

  // =======================================================================
  // LIGHT THEME
  // =======================================================================

  /// Light theme data with electric blue accent color
  static ThemeData get lightTheme {
    final colorScheme = _lightColorScheme;

    return ThemeData(
      // Color scheme
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.background,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.surface,
        foregroundColor: AppTokens.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleSpacing: AppTokens.spacingMd,
        titleTextStyle: TextStyle(
          color: AppTokens.textPrimary,
          fontSize: AppTokens.fontSizeLg,
          fontWeight: AppTokens.weightSemibold,
          letterSpacing: AppTokens.letterSpacingTight,
        ),
        iconTheme: IconThemeData(
          color: AppTokens.textSecondary,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: AppTokens.textSecondary,
          size: 24,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppTokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingMd,
            vertical: AppTokens.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: AppTokens.weightMedium,
            letterSpacing: AppTokens.letterSpacingNormal,
          ),
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppTokens.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingMd,
            vertical: AppTokens.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: AppTokens.weightMedium,
            letterSpacing: AppTokens.letterSpacingNormal,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingMd,
            vertical: AppTokens.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: AppTokens.weightMedium,
            letterSpacing: AppTokens.letterSpacingNormal,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingMd,
            vertical: AppTokens.spacingSm,
          ),
          side: const BorderSide(
            color: AppTokens.border,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: AppTokens.weightMedium,
            letterSpacing: AppTokens.letterSpacingNormal,
          ),
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppTokens.textSecondary,
          padding: const EdgeInsets.all(AppTokens.spacingSm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingMd,
          vertical: AppTokens.spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.danger, width: 2),
        ),
        labelStyle: TextStyle(
          color: AppTokens.textSecondary,
          fontSize: AppTokens.fontSizeMd,
        ),
        hintStyle: TextStyle(
          color: AppTokens.textTertiary,
          fontSize: AppTokens.fontSizeMd,
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTokens.primary;
          }
          return AppTokens.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTokens.primaryContainer;
          }
          return AppTokens.surfaceVariant;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTokens.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppTokens.border, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppTokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        titleTextStyle: TextStyle(
          color: AppTokens.textPrimary,
          fontSize: AppTokens.fontSizeXl,
          fontWeight: AppTokens.weightSemibold,
        ),
        contentTextStyle: TextStyle(
          color: AppTokens.textSecondary,
          fontSize: AppTokens.fontSizeMd,
          height: AppTokens.lineHeightRelaxed,
        ),
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.surfaceDark,
        contentTextStyle: TextStyle(
          color: AppTokens.textPrimaryDark,
          fontSize: AppTokens.fontSizeMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppTokens.border,
        thickness: 1,
        space: AppTokens.spacingMd,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingMd,
          vertical: AppTokens.spacingSm,
        ),
        titleTextStyle: TextStyle(
          color: AppTokens.textPrimary,
          fontSize: AppTokens.fontSizeMd,
          fontWeight: AppTokens.weightRegular,
        ),
        subtitleTextStyle: TextStyle(
          color: AppTokens.textSecondary,
          fontSize: AppTokens.fontSizeSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
      ),

      // Popup menu theme
      popupMenuTheme: PopupMenuThemeData(
        color: AppTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        elevation: 8,
        textStyle: TextStyle(
          color: AppTokens.textPrimary,
          fontSize: AppTokens.fontSizeMd,
        ),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppTokens.surfaceDark,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingSm,
          vertical: AppTokens.spacingXs,
        ),
        textStyle: TextStyle(
          color: AppTokens.textPrimaryDark,
          fontSize: AppTokens.fontSizeXs,
        ),
      ),

      // Text theme
      textTheme: _textTheme,

      // Primary text theme
      primaryTextTheme: _textTheme,

      // Icon theme
      iconTheme: IconThemeData(
        color: AppTokens.textSecondary,
        size: 24,
      ),

      // Primary icon theme
      primaryIconTheme: IconThemeData(
        color: AppTokens.primary,
        size: 24,
      ),
    );
  }

  // =======================================================================
  // DARK THEME
  // =======================================================================

  /// Dark theme data with electric blue accent color
  static ThemeData get darkTheme {
    final colorScheme = _darkColorScheme;

    return ThemeData(
      // Color scheme
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.backgroundDark,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.surfaceDark,
        foregroundColor: AppTokens.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleSpacing: AppTokens.spacingMd,
        titleTextStyle: TextStyle(
          color: AppTokens.textPrimaryDark,
          fontSize: AppTokens.fontSizeLg,
          fontWeight: AppTokens.weightSemibold,
          letterSpacing: AppTokens.letterSpacingTight,
        ),
        iconTheme: IconThemeData(
          color: AppTokens.textSecondaryDark,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: AppTokens.textSecondaryDark,
          size: 24,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppTokens.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingMd,
            vertical: AppTokens.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: AppTokens.weightMedium,
            letterSpacing: AppTokens.letterSpacingNormal,
          ),
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppTokens.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingMd,
            vertical: AppTokens.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: AppTokens.weightMedium,
            letterSpacing: AppTokens.letterSpacingNormal,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.primaryHoverDark,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingMd,
            vertical: AppTokens.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: AppTokens.weightMedium,
            letterSpacing: AppTokens.letterSpacingNormal,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.textPrimaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingMd,
            vertical: AppTokens.spacingSm,
          ),
          side: const BorderSide(
            color: AppTokens.borderDark,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeMd,
            fontWeight: AppTokens.weightMedium,
            letterSpacing: AppTokens.letterSpacingNormal,
          ),
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppTokens.textSecondaryDark,
          padding: const EdgeInsets.all(AppTokens.spacingSm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surfaceVariantDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingMd,
          vertical: AppTokens.spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.primaryHoverDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          borderSide: const BorderSide(color: AppTokens.danger, width: 2),
        ),
        labelStyle: TextStyle(
          color: AppTokens.textSecondaryDark,
          fontSize: AppTokens.fontSizeMd,
        ),
        hintStyle: TextStyle(
          color: AppTokens.textTertiaryDark,
          fontSize: AppTokens.fontSizeMd,
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTokens.primaryHoverDark;
          }
          return AppTokens.textTertiaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTokens.primaryContainerDark;
          }
          return AppTokens.surfaceVariantDark;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTokens.primaryHoverDark;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppTokens.borderDark, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppTokens.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        titleTextStyle: TextStyle(
          color: AppTokens.textPrimaryDark,
          fontSize: AppTokens.fontSizeXl,
          fontWeight: AppTokens.weightSemibold,
        ),
        contentTextStyle: TextStyle(
          color: AppTokens.textSecondaryDark,
          fontSize: AppTokens.fontSizeMd,
          height: AppTokens.lineHeightRelaxed,
        ),
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.surface,
        contentTextStyle: TextStyle(
          color: AppTokens.textPrimary,
          fontSize: AppTokens.fontSizeMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppTokens.borderDark,
        thickness: 1,
        space: AppTokens.spacingMd,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingMd,
          vertical: AppTokens.spacingSm,
        ),
        titleTextStyle: TextStyle(
          color: AppTokens.textPrimaryDark,
          fontSize: AppTokens.fontSizeMd,
          fontWeight: AppTokens.weightRegular,
        ),
        subtitleTextStyle: TextStyle(
          color: AppTokens.textSecondaryDark,
          fontSize: AppTokens.fontSizeSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
      ),

      // Popup menu theme
      popupMenuTheme: PopupMenuThemeData(
        color: AppTokens.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        elevation: 8,
        textStyle: TextStyle(
          color: AppTokens.textPrimaryDark,
          fontSize: AppTokens.fontSizeMd,
        ),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppTokens.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingSm,
          vertical: AppTokens.spacingXs,
        ),
        textStyle: TextStyle(
          color: AppTokens.textPrimary,
          fontSize: AppTokens.fontSizeXs,
        ),
      ),

      // Text theme
      textTheme: _textThemeDark,

      // Primary text theme
      primaryTextTheme: _textThemeDark,

      // Icon theme
      iconTheme: IconThemeData(
        color: AppTokens.textSecondaryDark,
        size: 24,
      ),

      // Primary icon theme
      primaryIconTheme: IconThemeData(
        color: AppTokens.primaryHoverDark,
        size: 24,
      ),
    );
  }

  // =======================================================================
  // PRIVATE HELPERS
  // =======================================================================

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppTokens.primary,
    onPrimary: Colors.white,
    primaryContainer: AppTokens.primaryContainer,
    onPrimaryContainer: AppTokens.primary,
    secondary: AppTokens.textSecondary,
    onSecondary: AppTokens.surface,
    secondaryContainer: AppTokens.surfaceVariant,
    onSecondaryContainer: AppTokens.textPrimary,
    tertiary: AppTokens.info,
    onTertiary: Colors.white,
    tertiaryContainer: AppTokens.primaryContainer,
    onTertiaryContainer: AppTokens.primary,
    error: AppTokens.danger,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: AppTokens.danger,
    background: AppTokens.background,
    onBackground: AppTokens.textPrimary,
    surface: AppTokens.surface,
    onSurface: AppTokens.textPrimary,
    surfaceVariant: AppTokens.surfaceVariant,
    onSurfaceVariant: AppTokens.textSecondary,
    outline: AppTokens.border,
    outlineVariant: AppTokens.border,
    shadow: Color(0xFF000000),
    scrim: Color(0x80000000),
    inverseSurface: AppTokens.surfaceDark,
    onInverseSurface: AppTokens.textPrimaryDark,
    inversePrimary: AppTokens.primaryHoverDark,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppTokens.primaryHoverDark,
    onPrimary: Colors.white,
    primaryContainer: AppTokens.primaryContainerDark,
    onPrimaryContainer: AppTokens.primaryHoverDark,
    secondary: AppTokens.textSecondaryDark,
    onSecondary: AppTokens.surfaceDark,
    secondaryContainer: AppTokens.surfaceVariantDark,
    onSecondaryContainer: AppTokens.textPrimaryDark,
    tertiary: AppTokens.primaryHoverDark,
    onTertiary: Colors.white,
    tertiaryContainer: AppTokens.primaryContainerDark,
    onTertiaryContainer: AppTokens.primaryHoverDark,
    error: AppTokens.danger,
    onError: Colors.white,
    errorContainer: AppTokens.dangerContainerDark,
    onErrorContainer: AppTokens.danger,
    background: AppTokens.backgroundDark,
    onBackground: AppTokens.textPrimaryDark,
    surface: AppTokens.surfaceDark,
    onSurface: AppTokens.textPrimaryDark,
    surfaceVariant: AppTokens.surfaceVariantDark,
    onSurfaceVariant: AppTokens.textSecondaryDark,
    outline: AppTokens.borderDark,
    outlineVariant: AppTokens.borderDark,
    shadow: Color(0xFF000000),
    scrim: Color(0x80000000),
    inverseSurface: AppTokens.surface,
    onInverseSurface: AppTokens.textPrimary,
    inversePrimary: AppTokens.primary,
  );

  static const TextTheme _textTheme = TextTheme(
    // Display styles - for hero text
    displayLarge: TextStyle(
      fontSize: AppTokens.fontSize3Xl,
      fontWeight: AppTokens.weightBold,
      letterSpacing: AppTokens.letterSpacingTight,
      height: AppTokens.lineHeightTight,
    ),
    displayMedium: TextStyle(
      fontSize: AppTokens.fontSize2Xl,
      fontWeight: AppTokens.weightBold,
      letterSpacing: AppTokens.letterSpacingTight,
      height: AppTokens.lineHeightTight,
    ),
    displaySmall: TextStyle(
      fontSize: AppTokens.fontSizeXl,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),

    // Headline styles - for page headers
    headlineLarge: TextStyle(
      fontSize: AppTokens.fontSize2Xl,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),
    headlineMedium: TextStyle(
      fontSize: AppTokens.fontSizeXl,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),
    headlineSmall: TextStyle(
      fontSize: AppTokens.fontSizeLg,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),

    // Title styles - for card titles and section headers
    titleLarge: TextStyle(
      fontSize: AppTokens.fontSizeLg,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),
    titleMedium: TextStyle(
      fontSize: AppTokens.fontSizeMd,
      fontWeight: AppTokens.weightMedium,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),
    titleSmall: TextStyle(
      fontSize: AppTokens.fontSizeMd,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),

    // Body styles - for body text
    bodyLarge: TextStyle(
      fontSize: AppTokens.fontSizeMd,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightRelaxed,
    ),
    bodyMedium: TextStyle(
      fontSize: AppTokens.fontSizeMd,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightRelaxed,
    ),
    bodySmall: TextStyle(
      fontSize: AppTokens.fontSizeSm,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightRelaxed,
    ),

    // Label styles - for labels and metadata
    labelLarge: TextStyle(
      fontSize: AppTokens.fontSizeSm,
      fontWeight: AppTokens.weightMedium,
      letterSpacing: AppTokens.letterSpacingWide,
      height: AppTokens.lineHeightNormal,
    ),
    labelMedium: TextStyle(
      fontSize: AppTokens.fontSizeXs,
      fontWeight: AppTokens.weightMedium,
      letterSpacing: AppTokens.letterSpacingWide,
      height: AppTokens.lineHeightNormal,
    ),
    labelSmall: TextStyle(
      fontSize: AppTokens.fontSizeXs,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingWide,
      height: AppTokens.lineHeightNormal,
    ),
  );

  static const TextTheme _textThemeDark = TextTheme(
    // Display styles - for hero text
    displayLarge: TextStyle(
      fontSize: AppTokens.fontSize3Xl,
      fontWeight: AppTokens.weightBold,
      letterSpacing: AppTokens.letterSpacingTight,
      height: AppTokens.lineHeightTight,
    ),
    displayMedium: TextStyle(
      fontSize: AppTokens.fontSize2Xl,
      fontWeight: AppTokens.weightBold,
      letterSpacing: AppTokens.letterSpacingTight,
      height: AppTokens.lineHeightTight,
    ),
    displaySmall: TextStyle(
      fontSize: AppTokens.fontSizeXl,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),

    // Headline styles - for page headers
    headlineLarge: TextStyle(
      fontSize: AppTokens.fontSize2Xl,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),
    headlineMedium: TextStyle(
      fontSize: AppTokens.fontSizeXl,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),
    headlineSmall: TextStyle(
      fontSize: AppTokens.fontSizeLg,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),

    // Title styles - for card titles and section headers
    titleLarge: TextStyle(
      fontSize: AppTokens.fontSizeLg,
      fontWeight: AppTokens.weightSemibold,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),
    titleMedium: TextStyle(
      fontSize: AppTokens.fontSizeMd,
      fontWeight: AppTokens.weightMedium,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),
    titleSmall: TextStyle(
      fontSize: AppTokens.fontSizeMd,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightNormal,
    ),

    // Body styles - for body text
    bodyLarge: TextStyle(
      fontSize: AppTokens.fontSizeMd,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightRelaxed,
    ),
    bodyMedium: TextStyle(
      fontSize: AppTokens.fontSizeMd,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightRelaxed,
    ),
    bodySmall: TextStyle(
      fontSize: AppTokens.fontSizeSm,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingNormal,
      height: AppTokens.lineHeightRelaxed,
    ),

    // Label styles - for labels and metadata
    labelLarge: TextStyle(
      fontSize: AppTokens.fontSizeSm,
      fontWeight: AppTokens.weightMedium,
      letterSpacing: AppTokens.letterSpacingWide,
      height: AppTokens.lineHeightNormal,
    ),
    labelMedium: TextStyle(
      fontSize: AppTokens.fontSizeXs,
      fontWeight: AppTokens.weightMedium,
      letterSpacing: AppTokens.letterSpacingWide,
      height: AppTokens.lineHeightNormal,
    ),
    labelSmall: TextStyle(
      fontSize: AppTokens.fontSizeXs,
      fontWeight: AppTokens.weightRegular,
      letterSpacing: AppTokens.letterSpacingWide,
      height: AppTokens.lineHeightNormal,
    ),
  );
}
