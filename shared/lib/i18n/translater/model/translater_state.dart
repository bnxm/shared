import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'translation.dart';

class LanguageTranslation extends Equatable {
  final String language;
  final List<Translation> translations;
  const LanguageTranslation(
    this.language,
    this.translations,
  );

  LanguageTranslation copyWith({
    String? language,
    List<Translation>? translations,
  }) {
    return LanguageTranslation(
      language ?? this.language,
      translations ?? this.translations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'translations': translations.map((x) => x.toMap()).toList(),
    };
  }

  factory LanguageTranslation.fromMap(Map<String, dynamic> map) {
    return LanguageTranslation(
      map['language'] ?? '',
      List<Translation>.from(
        map['translations']?.map((x) => Translation.fromMap(x)) ?? const [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  static LanguageTranslation? fromJson(String? source) {
    if (source == null) return null;

    return LanguageTranslation.fromMap(json.decode(source));
  }

  @override
  List<Object?> get props => [language, translations];
}
