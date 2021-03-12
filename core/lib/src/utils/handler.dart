import 'dart:async';

/// A class that can schedule a function to run at a later time using Future.delayed.
/// Additionally it supports canceling the future by not invoking the callback function
/// if it was canceled before.
class Handler {
  Timer? _timer;

  void call(dynamic delay, void Function() callback) => post(delay, callback);

  void post(dynamic delay, void Function() callback) {
    assert(delay is num || delay is Duration);

    Duration duration;
    if (delay is num) {
      duration = Duration(milliseconds: delay.toInt());
    } else {
      duration = delay as Duration;
    }

    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void cancel() => _timer?.cancel();

  bool get isCanceled => _timer?.isActive == false;
}

Handler post(dynamic delay, void Function() callback) {
  return Handler()..post(delay, callback);
}
