import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initHive({String? dir}) {
  return Hive.initFlutter(dir);
}
