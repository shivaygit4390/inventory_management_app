import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const Color ink = Color(0xFF17203D);
  static const Color mutedInk = Color(0xFF626B86);
  static const Color canvas = Color(0xFFF7F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color indigo = Color(0xFF5254D8);
  static const Color violet = Color(0xFF7A5AF8);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color teal = Color(0xFF16A6A1);
  static const Color amber = Color(0xFFF3A712);
  static const Color success = Color(0xFF168A67);
  static const Color border = Color(0xFFE7E8F2);
}

@immutable
class InventoryTheme extends ThemeExtension<InventoryTheme> {
  const InventoryTheme({
    required this.heroGradient,
    required this.accentGradient,
    required this.pageGradient,
    required this.success,
    required this.warning,
    required this.coral,
    required this.subtleBorder,
    required this.softShadow,
  });

  final Gradient heroGradient;
  final Gradient accentGradient;
  final Gradient pageGradient;
  final Color success;
  final Color warning;
  final Color coral;
  final Color subtleBorder;
  final List<BoxShadow> softShadow;

  @override
  InventoryTheme copyWith({
    Gradient? heroGradient,
    Gradient? accentGradient,
    Gradient? pageGradient,
    Color? success,
    Color? warning,
    Color? coral,
    Color? subtleBorder,
    List<BoxShadow>? softShadow,
  }) {
    return InventoryTheme(
      heroGradient: heroGradient ?? this.heroGradient,
      accentGradient: accentGradient ?? this.accentGradient,
      pageGradient: pageGradient ?? this.pageGradient,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      coral: coral ?? this.coral,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      softShadow: softShadow ?? this.softShadow,
    );
  }

  @override
  InventoryTheme lerp(InventoryTheme? other, double t) {
    if (other == null) {
      return this;
    }

    return InventoryTheme(
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
      accentGradient: Gradient.lerp(accentGradient, other.accentGradient, t)!,
      pageGradient: Gradient.lerp(pageGradient, other.pageGradient, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      softShadow: t < 0.5 ? softShadow : other.softShadow,
    );
  }
}

extension InventoryThemeContext on BuildContext {
  InventoryTheme get inventoryTheme =>
      Theme.of(this).extension<InventoryTheme>() ?? AppTheme.inventoryTheme;
}

abstract final class AppTheme {
  static const InventoryTheme inventoryTheme = InventoryTheme(
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF3435A9), AppPalette.indigo, AppPalette.violet],
      stops: <double>[0, 0.56, 1],
    ),
    accentGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[AppPalette.indigo, AppPalette.violet],
    ),
    pageGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xFFF1F0FF), AppPalette.canvas, AppPalette.canvas],
      stops: <double>[0, 0.3, 1],
    ),
    success: AppPalette.success,
    warning: AppPalette.amber,
    coral: AppPalette.coral,
    subtleBorder: AppPalette.border,
    softShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x1217203D),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
  );

  static ThemeData get light {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppPalette.indigo,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE8E8FF),
      onPrimaryContainer: Color(0xFF24246C),
      secondary: AppPalette.violet,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF0EBFF),
      onSecondaryContainer: Color(0xFF38236E),
      tertiary: AppPalette.teal,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD8F5F1),
      onTertiaryContainer: Color(0xFF064E4C),
      error: Color(0xFFC23B4A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFE8EA),
      onErrorContainer: Color(0xFF6D1622),
      surface: AppPalette.surface,
      onSurface: AppPalette.ink,
      onSurfaceVariant: AppPalette.mutedInk,
      outline: Color(0xFF8A91A8),
      outlineVariant: AppPalette.border,
      shadow: Color(0x1A17203D),
    );

    final TextTheme textTheme = Typography.material2021().black.apply(
      fontFamily: 'Inter',
      bodyColor: AppPalette.ink,
      displayColor: AppPalette.ink,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.canvas,
      extensions: const <ThemeExtension<dynamic>>[inventoryTheme],
      textTheme: textTheme.copyWith(
        displaySmall: textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.45),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
      ),
      cardTheme: const CardThemeData(
        color: AppPalette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: AppPalette.border),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppPalette.indigo, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFFC23B4A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFFC23B4A), width: 1.7),
        ),
        prefixIconColor: AppPalette.indigo,
        labelStyle: TextStyle(
          color: AppPalette.indigo,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          color: AppPalette.indigo,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppPalette.border),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: const ChipThemeData(
        side: BorderSide(color: AppPalette.border),
        shape: StadiumBorder(),
        labelStyle: TextStyle(fontWeight: FontWeight.w700),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      ),
      dividerTheme: const DividerThemeData(color: AppPalette.border, space: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.ink,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        insetPadding: EdgeInsets.fromLTRB(16, 0, 16, 18),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppPalette.indigo,
        linearTrackColor: Color(0xFFE8E8FF),
        circularTrackColor: Color(0xFFE8E8FF),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
