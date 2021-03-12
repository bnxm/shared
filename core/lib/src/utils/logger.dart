import 'package:logger/logger.dart';

final log = Logger();

DateTime? _time;

extension LoggerExtensions on Logger {
  void ellapsed([String? msg]) {
    _time ??= DateTime.now();

    final now = DateTime.now();
    final delta = now.difference(_time!).inMilliseconds;

    if (msg != null) {
      print('+$delta MS | $msg');
    } else {
      print('+$delta MS');
    }
  }

  void measure() => _time = DateTime.now();
}
