import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

extension SizedContext on BuildContext {
  /// Returns same as MediaQuery.of(context)
  MediaQueryData get mq => MediaQuery.of(this);

  /// Returns if Orientation is in landscape
  bool get isLandscape => mq.orientation == Orientation.landscape;
  bool get isLandscapeMobile => isLandscape && isMobile;

  /// Returns if Orientation is in portrait
  bool get isPortrait => mq.orientation == Orientation.portrait;

  LayoutPreferences? get layoutConfiguration => LayoutConfiguration.of(this);
  DeviceType get deviceType => layoutConfiguration!.getDeviceType(screenSize);
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Returns same as MediaQuery.of(context).size
  Size get screenSize => mq.size;

  /// Returns same as MediaQuery.of(context).size.width
  double get screenWidth => screenSize.width;

  /// Returns same as MediaQuery.of(context).height
  double get screenHeight => screenSize.height;

  /// Returns diagonal screen pixels
  double get screenDiagonal {
    final Size s = screenSize;
    return sqrt((s.width * s.width) + (s.height * s.height));
  }

  /// Returns pixel size in Inches
  Size get sizeInches {
    final Size pxSize = screenSize;
    return Size(pxSize.width / pixelsPerInch, pxSize.height / pixelsPerInch);
  }

  double get pixelsPerInch => Platform.isAndroid || Platform.isIOS ? 150 : 96;

  /// Returns screen width in Inches
  double get widthInches => sizeInches.width;

  /// Returns screen height in Inches
  double get heightInches => sizeInches.height;

  /// Returns screen diagonal in Inches
  double get diagonalInches => screenDiagonal / 96;

  /// Returns same as MediaQuery.of(context).viewPadding.top
  double get statusBarHeight => mq.viewPadding.top;
}

extension TextStyleX on TextStyle {
  double getHeight(BuildContext context) => context.mq.textScaleFactor * fontSize!;
}
