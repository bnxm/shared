import 'dart:math';

import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

enum DeviceType { mobile, tablet, desktop }

class LayoutPreferences {
  final double tabletThreshold;
  final double desktopThreshold;
  final double maxPageWidth;
  const LayoutPreferences({
    double? maxPageWidth,
    this.tabletThreshold = 600.0,
    this.desktopThreshold = 1200.0,
  })  : maxPageWidth = maxPageWidth ?? tabletThreshold,
        assert(tabletThreshold != null),
        assert(desktopThreshold != null),
        assert(tabletThreshold < desktopThreshold);

  DeviceType getDeviceType(Size size) {
    final width = size.shortestSide;
    
    if (width >= desktopThreshold) {
      return DeviceType.desktop;
    } else if (width >= tabletThreshold) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  @override
  String toString() =>
      'LayoutPreferences(tabletThreshold: $tabletThreshold, desktopThreshold: $desktopThreshold)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is LayoutPreferences &&
        o.tabletThreshold == tabletThreshold &&
        o.desktopThreshold == desktopThreshold;
  }

  @override
  int get hashCode => tabletThreshold.hashCode ^ desktopThreshold.hashCode;
}

class LayoutConfiguration extends StatelessWidget {
  final Widget child;
  final LayoutPreferences preferences;
  const LayoutConfiguration({
    Key? key,
    required this.child,
    this.preferences = const LayoutPreferences(),
  })  : assert(preferences != null),
        super(key: key);

  static LayoutPreferences? of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<LayoutConfiguration>()?.preferences;

  @override
  Widget build(BuildContext context) => child;
}

typedef _Builder = Widget Function(BuildContext _);

class ConfigurationBuilder extends StatelessWidget {
  final LayoutPreferences? preferences;
  final _Builder? mobile;
  final _Builder? mobileLandscape;
  final _Builder? tablet;
  final _Builder? tabletLandscape;
  final _Builder? desktop;
  final _Builder? desktopLandscape;
  final Widget Function(BuildContext context, bool isPortrait, DeviceType type,
      Size screenSize, Size size)? builder;
  const ConfigurationBuilder({
    Key? key,
    this.preferences,
    this.mobile,
    this.mobileLandscape,
    this.tablet,
    this.tabletLandscape,
    this.desktop,
    this.desktopLandscape,
    this.builder,
  })  : assert(builder != null || mobile != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final preferences = this.preferences ?? LayoutConfiguration.of(context)!;
    assert(preferences != null, 'No LayoutPreferences found in the widget tree!');

    final mq = MediaQuery.of(context);
    final orientation = mq.orientation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = orientation == Orientation.landscape;

        final type = preferences.getDeviceType(mq.size);
        if (builder != null) {
          return builder!(context, !isLandscape, type, mq.size, constraints.biggest);
        }

        if (type == DeviceType.desktop) {
          if (isLandscape && desktopLandscape != null) {
            return desktopLandscape!(context);
          }

          if (desktop != null) {
            return desktop!(context);
          }
        }

        if (type == DeviceType.tablet || type == DeviceType.desktop) {
          if (isLandscape && tabletLandscape != null) {
            return tabletLandscape!(context);
          }

          if (tablet != null) {
            return tablet!(context);
          }
        }

        if (isLandscape && mobileLandscape != null) {
          return mobileLandscape!(context);
        } else {
          return mobile!(context);
        }
      },
    );
  }
}

class ConstrainedWidth extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  const ConstrainedWidth({
    Key? key,
    required this.child,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = () {
      if (this.maxWidth != null) {
        return this.maxWidth;
      } else if (context.isPortrait) {
        return double.infinity;
      } else {
        return LayoutConfiguration.of(context)?.maxPageWidth ?? 600.0;
      }
    }()!;

    return ConstrainedBox(
      child: child,
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
    );
  }
}

class ConstrainedScrollable extends StatelessWidget {
  final double verticalInset;
  final double? maxWidth;
  final Widget Function(EdgeInsets padding) builder;
  const ConstrainedScrollable({
    Key? key,
    this.verticalInset = 0.0,
    this.maxWidth,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.isPortrait) {
      return builder(
        EdgeInsets.symmetric(vertical: verticalInset),
      );
    } else {
      return SizeBuilder(
        builder: (context, width, height) {
          final maxWidth =
              this.maxWidth ?? LayoutConfiguration.of(context)?.maxPageWidth ?? 600.0;

          final padding = EdgeInsets.symmetric(
            vertical: verticalInset,
            horizontal: ((width - maxWidth) / 2.0).atLeast(0.0),
          );

          return builder(padding);
        },
      );
    }
  }
}
