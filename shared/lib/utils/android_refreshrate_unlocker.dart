import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

Future<void> unlockRefreshRate() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final current = await FlutterDisplayMode.current;
    final modes = await FlutterDisplayMode.supported;

    DisplayMode bestMode = current;

    for (final mode in modes) {
      final isFaster = mode.refreshRate > bestMode.refreshRate;
      final isSameResolution =
          mode.width == bestMode.width && mode.height == bestMode.height;

      if (isFaster && isSameResolution) {
        bestMode = mode;
      }
    }

    FlutterDisplayMode.setMode(bestMode);
  } catch (e) {
    print(e);
  }
}
