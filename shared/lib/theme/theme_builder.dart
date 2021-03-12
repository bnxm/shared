import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

class AppTheme {
  final String key;
  final ThemeData themeData;
  final Schema schema;
  final SystemUiOverlayStyle uiOverlayStyle;
  const AppTheme({
    required this.key,
    required this.themeData,
    required this.schema,
    required this.uiOverlayStyle,
  });

  static AppTheme? of(BuildContext context) => ThemeBuilder.theme(context);

  bool get isDark => themeData.isDark;
  bool get isLight => themeData.isLight;

  ThemeMode get mode => isLight ? ThemeMode.light : ThemeMode.dark;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AppTheme && o.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

class ThemeBuilder extends StatefulWidget {
  final Widget Function(
      BuildContext, AppTheme? lightTheme, AppTheme? darkTheme, ThemeMode) builder;
  final List<AppTheme> themes;
  final bool setUiOverlayStyle;
  ThemeBuilder({
    Key? key,
    required this.builder,
    required this.themes,
    this.setUiOverlayStyle = true,
  })  : assert(themes.isNotEmpty, 'At least one theme data has to be provided.'),
        super(key: key);

  @override
  ThemeBuilderState createState() => ThemeBuilderState();

  static AppTheme? theme(BuildContext context) => of(context)?.getTheme(context);

  static List<AppTheme> getThemes(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ThemeBuilder>()!.themes;
  }

  static ThemeBuilderState? of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeBuilderState>();
  }
}

class ThemeBuilderState extends State<ThemeBuilder> {
  late ThemePreferences _prefs;

  ThemeMode? themeMode;
  AppTheme? lightTheme;
  AppTheme? darkTheme;

  List<AppTheme> get themes => widget.themes;

  StreamSubscription? _lightThemeSubscription;
  StreamSubscription? _darkThemeSubscription;
  StreamSubscription? _themeModeSubscription;

  @override
  void initState() {
    super.initState();
    _observeThemeChanges();
  }

  @override
  void didUpdateWidget(ThemeBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.themes, oldWidget.themes)) {
      _cancelSubscriptions();
      _observeThemeChanges();
    }
  }

  void _observeThemeChanges() async {
    if (Platform.isWindows || Platform.isLinux) return;

    _assignDefaultThemes();

    _prefs = await ThemePreferences.init(themes);

    _lightThemeSubscription = _prefs.watchLightTheme().listen((theme) {
      if (_prefs.lightTheme != lightTheme) {
        lightTheme = _prefs.lightTheme;
        _themeChanged();
      }
    });

    _darkThemeSubscription = _prefs.watchDarkTheme().listen((theme) {
      if (_prefs.darkTheme != darkTheme) {
        darkTheme = _prefs.darkTheme;
        _themeChanged();
      }
    });

    _themeModeSubscription = _prefs.watchThemeMode().listen((mode) {
      themeMode = _prefs.themeMode;
      _themeChanged();
    });
  }

  void _assignDefaultThemes() {
    for (final theme in widget.themes) {
      if (theme.isLight) {
        lightTheme ??= theme;
      } else {
        darkTheme ??= theme;
      }
    }
  }

  AppTheme? getTheme(BuildContext context) {
    switch (themeMode ?? ThemeMode.system) {
      case ThemeMode.system:
        return Theme.of(context).isLight ? lightTheme : darkTheme;
      case ThemeMode.dark:
        return darkTheme;
      default:
        return lightTheme;
    }
  }

  void _themeChanged() {
    if (widget.setUiOverlayStyle) {
      SystemChrome.setSystemUIOverlayStyle(getTheme(context)!.uiOverlayStyle);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      lightTheme,
      darkTheme,
      themeMode ?? ThemeMode.system,
    );
  }

  void _cancelSubscriptions() {
    _lightThemeSubscription?.cancel();
    _darkThemeSubscription?.cancel();
    _themeModeSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}

/// A wrapper class around [RxSharedPreferences] with build in
/// theme persistence.
///
/// This allows the app to use and persist more than one light
/// and/or dark themes.
class ThemePreferences extends RxSharedPreferencesDelegate {
  final AppTheme? defaultLightTheme;
  final AppTheme? defaultDarkTheme;
  final List<AppTheme> themes;
  final Map<String, AppTheme> _themeMap;
  ThemePreferences._(
    RxSharedPreferences instance,
    this.themes,
    this.defaultLightTheme,
    this.defaultDarkTheme,
  )   : _themeMap = {for (final theme in themes) theme.key: theme},
        super(instance);

  static ThemePreferences? instance;
  static Future<ThemePreferences> init(List<AppTheme> themes) async {
    assert(themes.isNotEmpty);

    AppTheme? defaultLightTheme, defaultDarkTheme;

    for (final theme in themes) {
      theme.isLight ? defaultLightTheme ??= theme : defaultDarkTheme ??= theme;
    }

    return instance = ThemePreferences._(
      await RxSharedPreferences.instance,
      themes,
      defaultLightTheme,
      defaultDarkTheme,
    );
  }

  static const String _themeModeKey = 'THEME_MODE';
  static const String _darkThemeKey = 'DARK_THEME';
  static const String _lightThemeKey = 'LIGHT_THEME';

  set theme(AppTheme theme) {
    if (theme.isLight) {
      setString(_lightThemeKey, theme.key);
    } else {
      setString(_darkThemeKey, theme.key);
    }

    if (themeMode != ThemeMode.system) {
      themeMode = theme.isLight ? ThemeMode.light : ThemeMode.dark;
    }
  }

  AppTheme? get lightTheme {
    final key = getString(_lightThemeKey);
    return _themeMap.get(key) ?? defaultLightTheme;
  }

  Stream<AppTheme?> watchLightTheme() =>
      watchString(_lightThemeKey).map((_) => lightTheme);

  AppTheme? get darkTheme {
    final key = getString(_darkThemeKey);
    return _themeMap.get(key) ?? defaultDarkTheme;
  }

  Stream<AppTheme?> watchDarkTheme() => watchString(_darkThemeKey).map((_) => darkTheme);

  set themeMode(ThemeMode mode) {
    setInt(_themeModeKey, mode.index);
  }

  ThemeMode get themeMode {
    final index = getInt(_themeModeKey) ?? -1;
    return ThemeMode.values.getOrElse(index, ThemeMode.system);
  }

  Stream<ThemeMode> watchThemeMode() => watchInt(_themeModeKey).map((_) => themeMode);
}
