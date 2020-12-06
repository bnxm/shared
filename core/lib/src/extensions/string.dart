import 'dart:core';

extension StringExtensions on String {
  bool get isBlank {
    if (this == null) return true;
    for (var i = 0; i < length; i++) {
      if (this[i] != ' ') return false;
    }
    return true;
  }

  bool get isNotBlank => !isBlank;

  double toDouble({double defaultValue}) => double.tryParse(this) ?? defaultValue;

  int toInt({int defaultValue}) => int.tryParse(this) ?? defaultValue;

  String prefixWith(String prefix) {
    if (!trimLeft().startsWith(prefix)) {
      return '$prefix$this';
    }

    return this;
  }

  String suffixWith(String suffix) {
    if (!trimRight().endsWith(suffix)) {
      return '${this}$suffix';
    }

    return this;
  }

  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return replaceFirst(prefix, '');
    } else {
      return this;
    }
  }

  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return replaceLast(suffix, '');
    } else {
      return this;
    }
  }

  String get removeWhitespace => replaceAll(' ', '');

  String capitalize() {
    if (length > 1) {
      return substring(0, 1).toUpperCase() + substring(1, length);
    }

    return toUpperCase();
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
    final regex = match is RegExp ? match : RegExp(match);
    return regex.allMatches(this)?.length ?? 0;
  }
}


