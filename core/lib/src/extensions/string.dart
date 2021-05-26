import 'dart:core';

extension StringExtensions on String {
  bool get isBlank {
    for (var i = 0; i < length; i++) {
      if (this[i] != ' ') return false;
    }
    return true;
  }

  bool get isNotBlank => !isBlank;

  double? toDouble({double? defaultValue}) => double.tryParse(this) ?? defaultValue;

  int? toInt({int? defaultValue}) => int.tryParse(this) ?? defaultValue;

  String prefixWith(String prefix) {
    if (!trimLeft().startsWith(prefix)) {
      return '$prefix$this';
    } else {
      return this;
    }
  }

  String suffixWith(String suffix) {
    if (!trimRight().endsWith(suffix)) {
      return '${this}$suffix';
    } else {
      return this;
    }
  }

  String removePrefix(String prefix) =>
      startsWith(prefix) ? replaceFirst(prefix, '') : this;

  String removeSuffix(String suffix) => endsWith(suffix) ? replaceLast(suffix, '') : this;

  String get removeWhitespace => replaceAll(' ', '');

  String capitalize() {
    if (length > 1) {
      return substring(0, 1).toUpperCase() + substring(1, length);
    } else {
      return toUpperCase();
    }
  }

  String replaceLast(Pattern matcher, String replacement) {
    final matches = matcher.allMatches(this).toList();
    if (matches.isEmpty) {
      return this;
    }

    final match = matches.last;
    return replaceRange(match.start, match.end, replacement);
  }

  int count(Pattern match) {
    final regex = match is RegExp ? match : RegExp(match as String);
    return regex.allMatches(this).length;
  }

  /// Converts all backslashes to forward slashes.
  String get normalizedPath => replaceAll('\\', '/');

  List<String> get chars => runes.map((e) => String.fromCharCode(e)).toList();
}
