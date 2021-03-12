import 'package:flutter/material.dart';

import 'theme.dart';

class ThemeFactory {
  ThemeFactory._();

  static ThemeData create({
    required Schema schema,
    String? fontFamily,
  }) {
    assert(schema != null);

    return ThemeData(
      fontFamily: fontFamily,
      brightness: schema.brightness,
      colorScheme: schema,
      accentColor: schema.primary,
      accentColorBrightness: Brightness.light,
      primaryColor: schema.primary,
      primaryColorDark: schema.primaryVariant,
      primaryColorLight: schema.primary,
      primaryColorBrightness: Brightness.light,
      errorColor: schema.error,
      backgroundColor: schema.background,
      canvasColor: schema.background,
      scaffoldBackgroundColor: schema.background,
      cardColor: schema.surface,
      dialogBackgroundColor: schema.surface,
      bottomAppBarColor: schema.primary,

      // Splashes and touch effects
      splashFactory: InkRipple.splashFactory,
      splashColor: schema.splashColor,
      hoverColor: schema.hoverColor,
      focusColor: schema.focusColor,
      highlightColor: schema.highlightColor,
      toggleableActiveColor: schema.primary,

      // Fabs
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: schema.primary,
      ),

      // Icons
      iconTheme: IconThemeData(
        color: schema.onSurface,
        size: 24,
      ),

      // Text styles
      textTheme: TextTheme(
        bodyText1: TextStyle(
          fontSize: 15,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.w500,
        ),
        bodyText2: TextStyle(
          fontSize: 15,
          color: schema.onSurface,
          fontWeight: FontWeight.w500,
        ),
        headline1: TextStyle(
          fontSize: 36,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        headline2: TextStyle(
          fontSize: 26,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        headline3: TextStyle(
          fontSize: 22,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        headline4: TextStyle(
          fontSize: 20,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        headline5: TextStyle(
          fontSize: 18,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        headline6: TextStyle(
          fontSize: 16,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        subtitle1: TextStyle(
          fontSize: 15,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.w600,
        ),
        subtitle2: TextStyle(
          fontSize: 14,
          color: schema.onSurface,
          fontWeight: FontWeight.w500,
        ),
        overline: TextStyle(
          fontSize: 12,
          color: schema.onSurfaceLight,
          fontWeight: FontWeight.w500,
        ),
        caption: TextStyle(
          fontSize: 12,
          color: schema.onSurfaceLight,
          fontWeight: FontWeight.w500,
        ),
        button: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Buttons
      buttonColor: schema.primary,
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.normal,
        buttonColor: schema.primary,
        splashColor: schema.primary.withOpacity(0.15),
        focusColor: schema.primary.withOpacity(0.25),
        hoverColor: schema.primary.withOpacity(0.25),
        highlightColor: schema.primary.withOpacity(0.25),
        disabledColor: schema.primary.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        minWidth: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Dividers
      dividerColor: schema.dividerColor,
      dividerTheme: DividerThemeData(
        color: schema.dividerColor,
        indent: 0,
        endIndent: 0,
        space: 0,
        thickness: 0.5,
      ),

      // TextFields
      hintColor: schema.onSurfaceLight,
      cursorColor: schema.primary,
      indicatorColor: schema.primary,
      textSelectionHandleColor: schema.primary,
      textSelectionColor: schema.primary.withOpacity(schema.primary.opacity * 0.25),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: schema.onSurfaceLight,
        ),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: schema.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: schema.onSurfaceLight,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: schema.primary,
            width: 2,
          ),
        ),
        errorStyle: TextStyle(
          color: schema.error,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: schema.error,
            width: 2,
          ),
        ),
        hoverColor: schema.onSurfaceLight.withOpacity(0.10),
        focusColor: schema.onSurfaceLight.withOpacity(0.25),
      ),

      // Appbars
      appBarTheme: AppBarTheme(
        brightness: schema.brightness,
        color: schema.primary,
        elevation: 4,
        iconTheme: IconThemeData(color: schema.onPrimary),
        actionsIconTheme: IconThemeData(color: schema.onPrimary),
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 18,
            color: schema.onPrimary,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // TabBars
      tabBarTheme: TabBarTheme(
        labelStyle: TextStyle(
          fontSize: 14,
          color: schema.primary,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          color: schema.primary,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: schema.primary,
        thumbColor: schema.primary,
        trackHeight: 2,
        overlayColor: Colors.transparent,
        inactiveTrackColor: schema.dividerColor,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 8,
        ),
      ),

      // Dialogs
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 8,
        modalElevation: 8,
        backgroundColor: schema.surface,
        modalBackgroundColor: schema.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
      ),

      dialogTheme: DialogTheme(
        elevation: 16,
        backgroundColor: schema.surface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      timePickerTheme: TimePickerThemeData(
        helpTextStyle: TextStyle(
          fontSize: 16,
          color: schema.onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
