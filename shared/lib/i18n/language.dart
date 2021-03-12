import 'dart:convert';

import 'package:flutter/material.dart';

class Language {
  final String name;
  final String? englishName;
  final String code;
  const Language({
    required this.name,
    this.englishName,
    required this.code,
  });

  String get langCode => code.split('_').first;
  String? get countryCode {
    final codes = code.split('_');
    return codes.length > 1 ? codes[1] : null;
  }

  Locale get locale => Locale(langCode, countryCode);

  static const Language english = Language(
    name: 'English',
    englishName: 'English',
    code: 'en',
  );

  static const Language german = Language(
    name: 'Deutsch',
    englishName: 'German',
    code: 'de',
  );

  static const Language french = Language(
    name: 'France',
    englishName: 'French',
    code: 'fr',
  );

  Language copyWith({
    String? name,
    String? englishName,
    String? code,
    Locale? locale,
  }) {
    return Language(
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      code: code ?? this.code,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'englishName': englishName,
      'code': code,
    };
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      name: map['name'] ?? '',
      englishName: map['englishName'] ?? '',
      code: map['code'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Language.fromJson(String source) => Language.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Language name: $name, englishName: $englishName, code: $code, locale: $locale';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Language &&
        o.name == name &&
        o.englishName == englishName &&
        o.code == code;
  }

  @override
  int get hashCode {
    return name.hashCode ^ englishName.hashCode ^ code.hashCode;
  }
}
