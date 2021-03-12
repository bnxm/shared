import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:shared/shared.dart';

class MyApp extends StatelessWidget {
  /// {@macro flutter.widgets.widgetsApp.navigatorKey}
  final GlobalKey<NavigatorState>? navigatorKey;

  /// {@macro flutter.widgets.widgetsApp.home}
  final Widget? home;

  /// The application's top-level routing table.
  ///
  /// When a named route is pushed with [Navigator.pushNamed], the route name is
  /// looked up in this map. If the name is present, the associated
  /// [WidgetBuilder] is used to construct a [MaterialPageRoute] that performs
  /// an appropriate transition, including [Hero] animations, to the new route.
  ///
  /// {@macro flutter.widgets.widgetsApp.routes}
  final Map<String, WidgetBuilder> routes;

  /// {@macro flutter.widgets.widgetsApp.initialRoute}
  final String? initialRoute;

  /// {@macro flutter.widgets.widgetsApp.onGenerateRoute}
  final Route<dynamic> Function(RouteSettings)? onGenerateRoute;

  /// {@macro flutter.widgets.widgetsApp.onUnknownRoute}
  final RouteFactory? onUnknownRoute;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  final List<NavigatorObserver> navigatorObservers;

  /// {@macro flutter.widgets.widgetsApp.builder}
  ///
  /// Material specific features such as [showDialog] and [showMenu], and widgets
  /// such as [Tooltip], [PopupMenuButton], also require a [Navigator] to properly
  /// function.
  final TransitionBuilder? builder;

  /// {@macro flutter.widgets.widgetsApp.title}
  ///
  /// This value is passed unmodified to [WidgetsApp.title].
  final String title;

  /// {@macro flutter.widgets.widgetsApp.onGenerateTitle}
  ///
  /// This value is passed unmodified to [WidgetsApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

  /// {@macro flutter.widgets.widgetsApp.color}
  final Color? color;

  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  ///
  /// It is passed along unmodified to the [WidgetsApp] built by this widget.
  ///
  /// See also:
  ///
  ///  * [localizationsDelegates], which must be specified for localized
  ///    applications.
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/tutorials/internationalization/>.
  final Iterable<Language>? languages;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/debugging/#performanceoverlay>
  final bool showPerformanceOverlay;

  /// Turns on checkerboarding of raster cache images.
  final bool checkerboardRasterCacheImages;

  /// Turns on checkerboarding of layers rendered to offscreen bitmaps.
  final bool checkerboardOffscreenLayers;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool showSemanticsDebugger;

  /// {@macro flutter.widgets.widgetsApp.debugShowCheckedModeBanner}
  final bool debugShowCheckedModeBanner;

  /// {@macro flutter.widgets.widgetsApp.shortcuts}
  /// {@tool sample}
  /// This example shows how to add a single shortcut for
  /// [LogicalKeyboardKey.select] to the default shortcuts without needing to
  /// add your own [Shortcuts] widget.
  ///
  /// Alternatively, you could insert a [Shortcuts] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     shortcuts: <LogicalKeySet, Intent>{
  ///       ... WidgetsApp.defaultShortcuts,
  ///       LogicalKeySet(LogicalKeyboardKey.select): const Intent(ActivateAction.key),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.shortcuts.seeAlso}
  final Map<LogicalKeySet, Intent>? shortcuts;

  /// {@macro flutter.widgets.widgetsApp.actions}
  /// {@tool sample}
  /// This example shows how to add a single action handling an
  /// [ActivateAction] to the default actions without needing to
  /// add your own [Actions] widget.
  ///
  /// Alternatively, you could insert a [Actions] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     actions: <LocalKey, ActionFactory>{
  ///       ... WidgetsApp.defaultActions,
  ///       ActivateAction.key: () => CallbackAction(
  ///         ActivateAction.key,
  ///         onInvoke: (FocusNode focusNode, Intent intent) {
  ///           // Do something here...
  ///         },
  ///       ),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.actions.seeAlso}
  final Map<Type, Action<Intent>>? actions;

  /// Turns on a [GridPaper] overlay that paints a baseline grid
  /// Material apps.
  ///
  /// Only available in checked mode.
  ///
  /// See also:
  ///
  ///  * <https://material.io/design/layout/spacing-methods.html>
  final bool debugShowMaterialGrid;

  final List<AppTheme>? themes;

  final bool setUiOverlayStyle;

  final Widget? splashScreen;

  final LayoutPreferences layout;
  const MyApp({
    Key? key,
    this.navigatorKey,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    required this.title,
    this.onGenerateTitle,
    this.color,
    this.languages,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = false,
    this.shortcuts,
    this.actions,
    this.debugShowMaterialGrid = false,
    this.themes,
    this.setUiOverlayStyle = false,
    this.splashScreen,
    this.layout = const LayoutPreferences(),
  }) : super(key: key);

  bool get useLocalizedBuilder => languages != null && languages!.isNotEmpty;

  Iterable<LocalizationsDelegate<dynamic>> get _localizationsDelegates sync* {
    if (useLocalizedBuilder) {
      yield GlobalMaterialLocalizations.delegate;
      yield GlobalCupertinoLocalizations.delegate;
    } else {
      yield DefaultMaterialLocalizations.delegate;
      yield DefaultCupertinoLocalizations.delegate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (useLocalizedBuilder) {
      return I18nBuilder(
        languages: languages as List<Language>,
        builder: (context, language, loaded) {
          return buildApp(language?.locale, loaded);
        },
      );
    } else {
      return buildApp(null, true);
    }
  }

  Widget buildApp(Locale? locale, bool isLoaded) {
    return ThemeBuilder(
      themes: themes!,
      builder: (context, lightTheme, darkTheme, mode) {
        return LayoutConfiguration(
          preferences: layout,
          child: MaterialApp(
            title: title,
            locale: locale,
            color: color,
            theme: lightTheme?.themeData,
            darkTheme: darkTheme?.themeData,
            themeMode: mode,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            debugShowMaterialGrid: debugShowMaterialGrid,
            initialRoute: initialRoute,
            onGenerateRoute: onGenerateRoute,
            onGenerateTitle: onGenerateTitle,
            onUnknownRoute: onUnknownRoute,
            routes: routes,
            shortcuts: shortcuts,
            showPerformanceOverlay: showPerformanceOverlay,
            showSemanticsDebugger: showSemanticsDebugger,
            localizationsDelegates: _localizationsDelegates,
            supportedLocales:
                languages?.map((lang) => lang.locale) ?? const [Locale('en')],
            navigatorKey: navigatorKey,
            navigatorObservers: navigatorObservers,
            checkerboardOffscreenLayers: checkerboardOffscreenLayers,
            checkerboardRasterCacheImages: checkerboardRasterCacheImages,
            actions: actions,
            builder: (context, child) => NoOverscroll(
              child: child,
            ),
            home: isLoaded
                ? home
                : (useLocalizedBuilder
                    ? splashScreen ?? Container()
                    : splashScreen ?? home),
          ),
        );
      },
    );
  }
}
