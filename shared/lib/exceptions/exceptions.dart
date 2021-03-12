abstract class CustomException implements Exception {
  final String? message;
  const CustomException(
    dynamic message,
  ) : message = message != null ? '$message' : null;

  @override
  String toString() => message == null ? '$runtimeType' : '$runtimeType: $message';

  @override
  // ignore: hash_and_equals
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o.runtimeType == runtimeType;
  }
}

class IllegalArgumentException extends CustomException {
  const IllegalArgumentException([dynamic message]) : super(message);
}

class IllegalStateException extends CustomException {
  const IllegalStateException([dynamic message = 'Illegal State']) : super(message);
}
