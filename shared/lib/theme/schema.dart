import 'package:flutter/material.dart';

import 'theme_builder.dart';

class Schema extends ColorScheme {
  final Color onSurfaceLight;
  final Color onSurfaceDark;
  final Color dividerColor;
  final Color splashColor;
  final Color focusColor;
  final Color hoverColor;
  final Color highlightColor;
  const Schema({
    required this.dividerColor,
    required this.onSurfaceLight,
    required this.onSurfaceDark,
    required this.splashColor,
    required this.focusColor,
    required this.hoverColor,
    required this.highlightColor,
    required Color primary,
    required Color primaryVariant,
    required Color secondary,
    required Color secondaryVariant,
    required Color surface,
    required Color background,
    required Color error,
    required Color onPrimary,
    required Color onSecondary,
    required Color onSurface,
    required Color onError,
    required Brightness brightness,
  }) : super(
          primary: primary,
          primaryVariant: primaryVariant,
          secondary: secondary,
          secondaryVariant: secondaryVariant,
          surface: surface,
          background: background,
          error: error,
          onPrimary: onPrimary,
          onSecondary: onSecondary,
          onSurface: onSurface,
          onBackground: onSurface,
          onError: onError,
          brightness: brightness,
        );

  static Schema of(BuildContext context) {
    return ThemeBuilder.theme(context)!.schema;
  }
}
