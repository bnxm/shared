import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:meta/meta.dart';

import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i18n_parser.dart';
import 'language.dart';
import 'strings.dart';

typedef LanguageChangedCallback = void Function(Language language);

class I18n {
  const I18n._();

  static bool _isTest = false;
  static const String languageKey = 'LANGUAGE';
  static Future<SharedPreferences> get _preferences =>
      !_isTest ? SharedPreferences.getInstance() : null;

  static String dir = 'i18n';
  static bool inspectLocales = true;

  static Language _language;
  static Language get language => _language;
  static List<Language> _languages = [];
  static List<Language> get languages => List.from(_languages);

  static bool _isFollowingSystem = true;
  static bool get isFollowingSystem => _isFollowingSystem;
  static Language get defaultLanguage => _languages.first;

  static final Set<LanguageChangedCallback> _listeners = {};

  @visibleForTesting
  static Map<String, String> defaultTranslations = {};
  @visibleForTesting
  static Map<String, String> currentTranslations = {};

  static final placeholderRegex = RegExp(r'{(.*?)}');

  static Future<void> init(
    List<Language> languages,
  ) async {
    assert(languages.isNotEmpty);

    I18n._languages = languages;

    await _loadLanguage();
    await _inspectLocales();
    await Strings.init(languages );

    _subscribeToChangesInLocale();
  }

  static Future<void> test(dynamic languages) async {
    assert(languages is List<Language> || languages is Language);
    final langs = languages is List ? languages : [languages];

    _isTest = true;
    _language = langs.first;
    Strings.isTest = true;

    await init(langs);
  }

  static void _subscribeToChangesInLocale() {
    window.onLocaleChanged = () {
      if (isFollowingSystem) {
        setSystemLanguage();
      }
    };
  }

  /// Tries to match the `input` to a translation in the default language
  /// and then maps it over to the corresponding translation in the language
  /// of the app.
  static String of(String input) {
    String translationKey;

    final keys = defaultTranslations.keys.toList();
    final values = defaultTranslations.values.toList();
    for (var i = 0; i < keys.length; i++) {
      if (input == values[i] || input == keys[i]) {
        translationKey = keys[i];
        break;
      }
    }

    if (translationKey == null) {
      final rawInput = input.replaceAll(placeholderRegex, '');

      for (var i = 0; i < keys.length; i++) {
        final key = keys[i], translation = values[i];
        final rawTranslation = translation.replaceAll(placeholderRegex, '');

        // When the value is only a placeholder, as with
        // {1: Hour, else: Hours}
        // we wanna check whether a word from the input matches
        // the value in the else group.
        //
        // This way, an input of {10 Hours} would match the above translation.
        if (rawInput.trim().isEmpty && rawTranslation.trim().isEmpty) {
          final placeholder = Placeholder.match(translation);
          if (placeholder != null && placeholder.orElse != null) {
            final orElseValue = placeholder.orElse.replaceAll('\$i', '').removeWhitespace;
            final inputPlaceholders = placeholderRegex.allMatches(input);

            final hasMatch = inputPlaceholders.any(
              (match) => match.group(0).contains(orElseValue),
            );

            if (hasMatch) {
              translationKey = key;
              break;
            }
          }
        } else if (rawTranslation == rawInput) {
          translationKey = key;
          break;
        }
      }
    }

    assert(
      translationKey != null,
      "The string '$input' couldn't be matched to a key in the default's language (${defaultLanguage.code}) translation file!",
    );

    final translation = currentTranslations[translationKey];
    assert(
      translation != null,
      "The string '$input' couldn't be matched to a key in the ${language.code} translation file!",
    );

    if (translation == null) {
      return input;
    }

    final srcPlaceholders = Placeholder.matchAll(input);
    final targetPlaceholders = Placeholder.matchAll(translation);

    if (srcPlaceholders.isEmpty || targetPlaceholders.isEmpty) {
      return translation;
    } else {
      assert(
        srcPlaceholders.length == targetPlaceholders.length,
        "Input '$input' (in ${defaultLanguage.code}) and its translation '$translation' (in ${_language.code}) have a different amount of placeholders! This is not supported (yet).",
      );

      String result = translation;
      for (final i in targetPlaceholders.length.until(0)) {
        final src = _removeBrackets(srcPlaceholders[i].src);
        final placeholder = targetPlaceholders[i];
        final replacement = placeholder.let((it) {
          if (it.isPlural) {
            return _plural(it, src);
          }
        });

        result = result.replaceLast(
          placeholder.src,
          replacement ?? src,
        );
      }

      return result;
    }
  }

  static String ofKey(String key, {List placeholders = const []}) {
    String translation = currentTranslations[key];

    assert(
      translation != null,
      'No translation for key $key in language file ${language.code}',
    );

    for (final placeholder in placeholders) {
      translation = translation.replaceFirst(placeholderRegex, placeholder.toString());
    }

    return translation;
  }

  static String _plural(Placeholder placeholder, String input) {
    final onlyDigits = input.replaceAll(RegExp(r'[^0-9, ^\., ^\,]'), '');

    final number = num.tryParse(onlyDigits);
    assert(number != null, 'Plural placeholder was not given a valid number!');
    if (number == null) {
      return placeholder.src;
    }

    final keys = placeholder.keys.toList();
    final values = placeholder.values.toList();
    for (var i = 0; i < placeholder.length; i++) {
      final key = num.tryParse(keys[i].trim());
      final value = values[i].trim();

      if (keys[i] == 'else' || key == number) {
        final formatted = NumberFormat.decimalPattern(
          language.locale.scriptCode,
        ).format(number);

        return value.replaceAll('\$i', formatted);
      }
    }

    return null;
  }

  static Future<Language> setLanguage(dynamic language) async {
    assert(language is String || language is Language);

    final String code = language is Language ? language.code : language;
    final Language lang = _resolveLanguageForCode(code);

    await _saveLanguage(lang);
    await _loadLanguage();

    _callListeners();

    return lang;
  }

  static Future<Language> setSystemLanguage() => setLanguage('system');

  static void addListener(LanguageChangedCallback callback) => _listeners.add(callback);
  static void removeListener(LanguageChangedCallback callback) =>
      _listeners.remove(callback);

  static void _callListeners() {
    for (final listener in _listeners) {
      listener(language);
    }
  }

  static Future<void> _saveLanguage(Language lang) async {
    if (_isTest) {
      _language = lang;
    } else {
      (await _preferences)?.setString(languageKey, lang?.code);
    }
  }

  static Future<void> _loadLanguage() async {
    _language = await _getPersistedLanguage();
    currentTranslations = await loadTranslations(_language);
    defaultTranslations = await loadTranslations(defaultLanguage);
    Intl.defaultLocale = language.code;
  }

  static Future<Language> _getPersistedLanguage() async {
    if (_isTest) {
      return _language;
    } else {
      final stored = (await _preferences)?.getString(languageKey);
      _isFollowingSystem = stored == null;

      if (isFollowingSystem) {
        return supportedSystemLanguage;
      } else {
        return _resolveLanguageForCode(stored) ?? defaultLanguage;
      }
    }
  }

  static Future<Map<String, String>> loadTranslations(Language language) async {
    final fileName = '$dir/${language.code}.yaml';
    final file = await _loadFile(fileName, _isTest);
    return I18nParser(fileName).parse(file);
  }

  static Future<void> _inspectLocales() async {
    if (!kIsDebug || !inspectLocales) {
      return;
    }

    for (final lang in _languages) {
      final keys = (await loadTranslations(lang)).keys;
      final List<String> missingKeys = [];

      for (final key in defaultTranslations.keys) {
        if (!keys.contains(key)) {
          missingKeys.add(key);
        }
      }

      assert(
        missingKeys.isEmpty,
        '${lang.code} is missing the following keys:\n${missingKeys.join(',\n')}',
      );
    }
  }

  /// Returns the closest system language that the app supports.
  static Language get supportedSystemLanguage {
    for (final locale in window.locales ?? <Locale>[]) {
      final code = locale.toLanguageTag().replaceAll('-', '_');
      final language = _resolveLanguageForCode(code);
      if (language != null) {
        return language;
      }
    }

    return defaultLanguage;
  }

  /// Returns the best corresponding [Language] for the given `code`
  /// or null if no language can be matched to the `code`.
  static Language _resolveLanguageForCode(String code) {
    if (code == null || code == 'system') {
      return null;
    }

    // Check if there is a language with the exact
    // locale code.
    for (final lang in _languages) {
      if (lang.code == code) {
        return lang;
      }
    }

    // Check if there is a language with the same
    // language code. E.g. code == 'en' && lang.code == 'en_US'
    for (final lang in _languages) {
      if (lang.code.startsWith(code)) {
        return lang;
      }
    }

    // Check if there is a language with the same
    // language code. E.g. code == 'en_US' && lang.code == 'en'
    for (final lang in _languages) {
      if (code.startsWith(lang.code)) {
        return lang;
      }
    }

    return null;
  }

  static Future<String> _loadFile(String path, bool isTest) {
    if (isTest) {
      String dir = Directory.current.path;
      if (Platform.isWindows) {
        dir += '\\${path.replaceAll('/', '\\')}';
      } else {
        dir += '/$path';
      }

      return File(dir).readAsString();
    } else {
      return rootBundle.loadString(path);
    }
  }
}

extension I18nStringExtensions on String {
  String get i18n => I18n.of(this);
}

class Placeholder extends DelegatingMap<String, String> {
  final String src;
  Placeholder(
    this.src, {
    Map<String, String> cases = const {},
  }) : super(cases);

  static final RegExp pluralRegex = RegExp(r'(([0-9]:)+|(&i)+)');

  bool get isConditional => isNotEmpty;
  bool get isPlural => pluralRegex.hasMatch(_removeBrackets(src));

  static List<Placeholder> matchAll(String src) {
    return I18n.placeholderRegex
        .allMatches(src)
        .map((e) => Placeholder.match(e.group(0)))
        .toList()
          ..removeWhere((element) => element == null);
  }

  factory Placeholder.match(String src, {RegExp regex}) {
    regex ??= I18n.placeholderRegex;

    final matchesAll = regex.stringMatch(src) == src;
    if (matchesAll) {
      final formatted = _removeBrackets(src);
      final groups = formatted.split(',');
      final Map<String, String> cases = {};

      for (final group in groups) {
        final parts = group.split(':');
        final key = parts.first.trim();
        final value = parts.last.trim();

        cases[key] = value;
      }

      if (cases.isNotEmpty) {
        return Placeholder(src, cases: cases);
      }
    }

    return null;
  }

  String get orElse {
    final keys = this.keys.toList();

    for (final i in 0.until(keys.length)) {
      final key = keys[i];
      if (key == 'else') {
        return values.elementAt(i);
      }
    }

    return null;
  }

  @override
  String toString() => 'Placeholder(src: $src, cases: ${super.toString()})';
}

String _removeBrackets(String src) => src.removePrefix('{').removeSuffix('}');
