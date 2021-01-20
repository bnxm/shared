import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'package:shared/shared.dart';

class Translation {
  final String key;
  final String original;
  final String translation;
  final List<Placeholder> placeholders;
  Translation({
    @required this.key,
    @required this.original,
    this.translation = '',
  })  : assert(key != null),
        assert(original != null),
        placeholders = Placeholder.all(original);

  bool get hasPlaceholders => placeholders.isNotEmpty;
  bool get hasMissingPlaceholders =>
      hasPlaceholders && translatedPlaceholders < placeholders.length;

  int get translatedPlaceholders => Placeholder.all(translation).length;
  Placeholder get nextPlaceholder => placeholders.getOrNull(translatedPlaceholders);

  Translation copyWith({
    String key,
    String original,
    String translation,
  }) {
    return Translation(
      key: key ?? this.key,
      original: original ?? this.original,
      translation: translation ?? this.translation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'original': original,
      'translation': translation,
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Translation(
      key: map['key'] ?? '',
      original: map['original'] ?? '',
      translation: map['translation'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Translation.fromJson(String original) =>
      Translation.fromMap(json.decode(original));

  @override
  String toString() {
    return 'Translation(key: $key, original: $original, translation: $translation, placeholders: $placeholders)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Translation &&
        o.key == key &&
        o.original == original &&
        o.translation == translation;
  }

  @override
  int get hashCode {
    return key.hashCode ^ original.hashCode ^ translation.hashCode;
  }
}

extension ListTranslationExtensions on List<Translation> {}
