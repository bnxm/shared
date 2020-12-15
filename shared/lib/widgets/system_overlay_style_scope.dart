import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

class SystemOverlayStyleScope extends StatelessWidget {
  final SystemUiOverlayStyle style;

  /// The color of the system bottom navigation bar.
  ///
  /// Only honored in Android versions O and greater.
  final Color navigationBarColor;

  /// The color of the divider between the system's bottom navigation bar and the app's content.
  ///
  /// Only honored in Android versions P and greater.
  final Color navigationBarDividerColor;

  /// The brightness of the system navigation bar icons.
  ///
  /// Only honored in Android versions O and greater.
  final Brightness navigationBarIconBrightness;

  /// The color of top status bar.
  ///
  /// Only honored in Android version M and greater.
  final Color statusBarColor;

  /// The brightness of top status bar.
  ///
  /// Only honored in iOS.
  final Brightness statusBarBrightness;

  /// The brightness of the top status bar icons.
  ///
  /// Only honored in Android version M and greater.
  final Brightness statusBarIconBrightness;

  final Widget child;

  const SystemOverlayStyleScope({
    Key key,
    @required this.child,
    this.style,
    this.navigationBarColor,
    this.navigationBarDividerColor,
    this.navigationBarIconBrightness,
    this.statusBarColor,
    this.statusBarBrightness,
    this.statusBarIconBrightness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      child: child,
      value: style ??
          (AppTheme.of(context)?.uiOverlayStyle ?? const SystemUiOverlayStyle()).copyWith(
            systemNavigationBarColor: navigationBarColor,
            systemNavigationBarDividerColor: navigationBarDividerColor,
            systemNavigationBarIconBrightness: navigationBarIconBrightness,
            statusBarColor: statusBarColor,
            statusBarBrightness: statusBarBrightness,
            statusBarIconBrightness: statusBarIconBrightness ?? statusBarBrightness,
          ),
    );
  }
}
