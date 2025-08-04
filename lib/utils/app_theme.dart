import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flex_color_scheme/flex_color_scheme.dart';
import '../models/app_settings.dart';

class AppTheme {
  // Default themes
  static ThemeData defaultLightTheme() {
    return _createTheme(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF6366F1),
      accentColor: const Color(0xFFEC4899),
      fontFamily: 'Poppins',
    );
  }

  static ThemeData defaultDarkTheme() {
    return _createTheme(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF6366F1),
      accentColor: const Color(0xFFEC4899),
      fontFamily: 'Poppins',
    );
  }

  // Theme from settings
  static ThemeData lightTheme(AppSettings settings) {
    return _createTheme(
      brightness: Brightness.light,
      primaryColor: _parseColor(settings.primaryColor),
      accentColor: _parseColor(settings.accentColor),
      fontFamily: settings.fontFamily,
      useDynamicColors: settings.useDynamicColors,
    );
  }

  static ThemeData darkTheme(AppSettings settings) {
    return _createTheme(
      brightness: Brightness.dark,
      primaryColor: _parseColor(settings.primaryColor),
      accentColor: _parseColor(settings.accentColor),
      fontFamily: settings.fontFamily,
      useDynamicColors: settings.useDynamicColors,
    );
  }

  static ThemeData _createTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color accentColor,
    required String fontFamily,
    bool useDynamicColors = true,
  }) {
    final bool isDark = brightness == Brightness.dark;
    
    // Create color scheme
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      secondary: accentColor,
    );

    // Get text theme
    final TextTheme textTheme = _getTextTheme(fontFamily, isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: colorScheme.surface,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: colorScheme.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
        elevation: 8,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withOpacity(0.6),
          size: 24,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        labelStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.titleSmall,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 3,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return colorScheme.surfaceVariant;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primary.withOpacity(0.3),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.2),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withOpacity(0.3),
        circularTrackColor: colorScheme.primary.withOpacity(0.3),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // Primary Icon Theme
      primaryIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 24,
      ),

      // Scrollbar Theme
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(
          colorScheme.outline.withOpacity(0.5),
        ),
        trackColor: MaterialStateProperty.all(
          colorScheme.outline.withOpacity(0.1),
        ),
        radius: const Radius.circular(4),
        thickness: MaterialStateProperty.all(6),
      ),

      // Extensions
      extensions: [
        _CustomColors(
          success: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
          warning: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          info: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
          manga: const Color(0xFF6366F1),
          manhwa: const Color(0xFFEC4899),
          manhua: const Color(0xFFF59E0B),
          novel: const Color(0xFF10B981),
          webtoon: const Color(0xFF8B5CF6),
          lightNovel: const Color(0xFF06B6D4),
        ),
      ],
    );
  }

  static TextTheme _getTextTheme(String fontFamily, bool isDark) {
    // Use the system default text theme as base
    TextTheme baseTheme = ThemeData.light().textTheme;
    
    // Apply the selected font family
    baseTheme = baseTheme.apply(
      fontFamily: fontFamily,
    );

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        letterSpacing: 0.5,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        letterSpacing: 0.25,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        letterSpacing: 0.4,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
    );
  }

  static Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFF6366F1); // Default primary color
    }
  }

  // Predefined color schemes
  static const List<Map<String, dynamic>> colorSchemes = [
    {
      'name': 'Indigo',
      'primary': '#6366F1',
      'accent': '#EC4899',
    },
    {
      'name': 'Blue',
      'primary': '#3B82F6',
      'accent': '#10B981',
    },
    {
      'name': 'Purple',
      'primary': '#8B5CF6',
      'accent': '#F59E0B',
    },
    {
      'name': 'Pink',
      'primary': '#EC4899',
      'accent': '#06B6D4',
    },
    {
      'name': 'Green',
      'primary': '#10B981',
      'accent': '#F59E0B',
    },
    {
      'name': 'Orange',
      'primary': '#F59E0B',
      'accent': '#8B5CF6',
    },
    {
      'name': 'Red',
      'primary': '#EF4444',
      'accent': '#3B82F6',
    },
    {
      'name': 'Teal',
      'primary': '#14B8A6',
      'accent': '#EC4899',
    },
  ];

  // Available fonts
  static const List<String> availableFonts = [
    'Poppins',
    'Inter',
    'Roboto',
    'Open Sans',
    'Lato',
    'Nunito',
  ];
}

// Custom colors extension
@immutable
class _CustomColors extends ThemeExtension<_CustomColors> {
  const _CustomColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.manga,
    required this.manhwa,
    required this.manhua,
    required this.novel,
    required this.webtoon,
    required this.lightNovel,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color manga;
  final Color manhwa;
  final Color manhua;
  final Color novel;
  final Color webtoon;
  final Color lightNovel;

  @override
  _CustomColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? manga,
    Color? manhwa,
    Color? manhua,
    Color? novel,
    Color? webtoon,
    Color? lightNovel,
  }) {
    return _CustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      manga: manga ?? this.manga,
      manhwa: manhwa ?? this.manhwa,
      manhua: manhua ?? this.manhua,
      novel: novel ?? this.novel,
      webtoon: webtoon ?? this.webtoon,
      lightNovel: lightNovel ?? this.lightNovel,
    );
  }

  @override
  _CustomColors lerp(_CustomColors? other, double t) {
    if (other is! _CustomColors) {
      return this;
    }
    return _CustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      manga: Color.lerp(manga, other.manga, t)!,
      manhwa: Color.lerp(manhwa, other.manhwa, t)!,
      manhua: Color.lerp(manhua, other.manhua, t)!,
      novel: Color.lerp(novel, other.novel, t)!,
      webtoon: Color.lerp(webtoon, other.webtoon, t)!,
      lightNovel: Color.lerp(lightNovel, other.lightNovel, t)!,
    );
  }
}

// Extension to access custom colors
extension CustomColorsExtension on ThemeData {
  _CustomColors get customColors =>
      extension<_CustomColors>() ?? const _CustomColors(
        success: Color(0xFF16A34A),
        warning: Color(0xFFD97706),
        info: Color(0xFF2563EB),
        manga: Color(0xFF6366F1),
        manhwa: Color(0xFFEC4899),
        manhua: Color(0xFFF59E0B),
        novel: Color(0xFF10B981),
        webtoon: Color(0xFF8B5CF6),
        lightNovel: Color(0xFF06B6D4),
      );
}

