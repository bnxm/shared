import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:meta/meta.dart';

import 'package:shared/shared.dart';

import 'i18n_loader.dart';
import 'i18n_store.dart';
import 'language.dart';

typedef LanguageChangedCallback = void Function(Language? language);

class I18n {
  const I18n._();

  static bool _inTestMode = false;
  static bool get inTestMode => _inTestMode;

  static I18nStore store = I18nSharedPreferencesStore();

  @visibleForTesting
  static String dir = 'i18n';

  static bool _initalized = false;
  static bool get initialized => _initalized;

  static late Language language;
  static List<Language> _languages = [];
  static List<Language> get languages => List.from(_languages);
  static List<Locale> get locales => _languages.map((l) => l.locale).toList();

  static bool _isFollowingSystem = true;
  static bool get isFollowingSystem => _isFollowingSystem;
  static Language get defaultLanguage => _languages.first;

  static final Set<LanguageChangedCallback> _listeners = {};

  @visibleForTesting
  static Map<String?, String> defaultTranslations = {};
  @visibleForTesting
  static Map<String?, String> currentTranslations = {};

  static final placeholderRegex = RegExp(r'{(.*?)}');

  static Future<void> init(
    List<Language> languages,
  ) async {
    assert(languages.isNotEmpty);

    I18n._languages = languages;

    await _loadLanguage();

    _subscribeToChangesInLocale();
    
    I18n._initalized = true;
  }

  static Future<void> test(dynamic languages) async {
    assert(languages is List<Language> || languages is Language);
    final langs = languages is List ? languages : <Language>[languages];

    _inTestMode = true;
    language = langs.first;

    await init(langs as List<Language>);
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
    if (input == null) return 'null';

    String? translationKey;

    // First check if there is a key (key or translation string)
    // that matches the input string.
    for (final entry in defaultTranslations.entries) {
      if (input == entry.value || input == entry.key) {
        translationKey = entry.key;
        break;
      }
    }

    // Otherwise, check without placeholders...
    if (translationKey == null) {
      String raw(String src) => src.replaceAll(placeholderRegex, '').trim();

      final inputNoPlaceholders = raw(input);

      for (final entry in defaultTranslations.entries) {
        final String? key = entry.key, translation = entry.value;

        final translationNoPlaceholders = raw(translation!);

        // When the value is only a placeholder, as with
        // {1: Hour, else: Hours}
        // we wanna check whether a word from the input matches
        // the value in the else group.
        //
        // This way, an input of {10 Hours} would match the above translation.
        if (inputNoPlaceholders.isEmpty && translationNoPlaceholders.isEmpty) {
          final placeholder = Placeholder.from(translation);

          if (placeholder?.orElse != null) {
            final orElseValue =
                placeholder!.orElse!.replaceAll('\$i', '').removeWhitespace;
            final inputPlaceholders = placeholderRegex.allMatches(input);

            final hasMatch = inputPlaceholders.any(
              (match) => match.group(0)!.contains(orElseValue),
            );

            if (hasMatch) {
              translationKey = key;
              break;
            }
          }
        } else if (translationNoPlaceholders == inputNoPlaceholders) {
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

    final srcPlaceholders = Placeholder.all(input);
    final targetPlaceholders = Placeholder.all(translation);

    if (srcPlaceholders.isEmpty || targetPlaceholders.isEmpty) {
      return translation;
    } else {
      assert(
        srcPlaceholders.length == targetPlaceholders.length,
        "Input '$input' (in ${defaultLanguage.code}) and its translation '$translation' (in ${language.code}) have a different amount of placeholders! This is not supported (yet).",
      );

      String result = translation;

      // for (var i = targetPlaceholders.length - 1; i >= 0; i--) {
      for (var i = 0; i < targetPlaceholders.length; i++) {
        final src = _removeBrackets(srcPlaceholders[i].src);
        final placeholder = targetPlaceholders[i];

        result = result.replaceLast(
          placeholder.src,
          placeholder.format(src),
        );
      }

      return result;
    }
  }

  static String key(String key, [dynamic placeholders = const []]) {
    String? translation = currentTranslations[key];

    if (translation == null) {
      assert(
        translation != null,
        'No translation for key $key in language file ${language.code}',
      );

      return key;
    }

    if (placeholders is! List) {
      placeholders = [placeholders];
    }

    final pairs = zip(
      Placeholder.all(translation),
      placeholders,
    );

    for (final pair in pairs) {
      translation = translation!.replaceFirst(
        placeholderRegex,
        pair.first.format(pair.second),
      );
    }

    return translation!;
  }

  /// Sets the given [language] and persists it to local storage.
  ///
  /// The app will use this language until a new language is set
  /// being set.
  static Future<Language?> setLanguage(dynamic language) async {
    assert(language is String || language is Language);

    final String? code =
        language != null && language is Language ? language.code : language;
    final Language? lang = _resolveLanguageForCode(code);

    await _saveLanguage(lang);
    await _loadLanguage();

    _callListeners();

    return lang;
  }

  /// Use the current system language as the apps language.
  ///
  /// If the system language is not in the supported [languages],
  /// the closest matching supported language or the default
  /// language will be selected.
  static Future<Language?> setSystemLanguage() => setLanguage(null);

  static void addListener(LanguageChangedCallback callback) => _listeners.add(callback);
  static void removeListener(LanguageChangedCallback callback) =>
      _listeners.remove(callback);

  static void _callListeners() {
    for (final listener in _listeners) {
      listener(language);
    }
  }

  static Future<void> _saveLanguage(Language? lang) async {
    if (_inTestMode) {
      language = lang ?? language;
    } else {
      await store.setLanguageCode(lang?.code);
    }
  }

  static Future<void> _loadLanguage() async {
    language = await _getPersistedLanguage();
    currentTranslations = await loadTranslations(language);
    defaultTranslations = await loadTranslations(defaultLanguage);
    _updateIntl();
  }

  static Future<Language> _getPersistedLanguage() async {
    if (inTestMode) {
      return language;
    }

    final code = await store.getLanguageCode();
    _isFollowingSystem = code == null;

    return isFollowingSystem
        ? _getBestLanguageBasedOnSystemLanguage()
        : _resolveLanguageForCode(code) ?? defaultLanguage;
  }

  static Future<I18nMap> loadTranslations(Language language) async {
    final path = '$dir/${language.code}';
    return I18nMap.load(path, inTestMode: inTestMode);
  }

  static void _updateIntl() {
    try {
      initializeDateFormatting(language.code);
      Intl.defaultLocale = language.code;
    } catch (_) {}
  }

  /// Returns the closest system language that the app supports.
  static Language _getBestLanguageBasedOnSystemLanguage() {
    var locales = window.locales;

    // locales might be empty when init() is invoked
    // in background or there is no window instance
    // established yet.
    if (locales.isEmpty) {
      // This method should give us the current locale
      // regardless of whether the app is in background or not.
      // observe: https://github.com/flutter/flutter/issues/73342

      // window.computePlatformResolvedLocale(I18n.locales)?.also((it) => locales = [it]);
    }

    for (final locale in locales) {
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
  static Language? _resolveLanguageForCode(String? code) {
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

  static final regex = RegExp(r'{(.*?)}');

  static List<Placeholder> all(String src) {
    return I18n.placeholderRegex
        .allMatches(src)
        .map((e) => Placeholder.from(e.group(0)!))
        .toList()
        .removeNull();
  }

  String format(dynamic value) {
    return src.replaceFirst(regex, value.toString());
  }

  static Placeholder? from(String src) {
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
        if (PluralPlaceholder.regex.hasMatch(src)) {
          return PluralPlaceholder(src, cases: cases);
        } else {
          return Placeholder(src, cases: cases);
        }
      }
    }

    return null;
  }

  String? get orElse {
    final List<String> keys = this.keys.toList();

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

class PluralPlaceholder extends Placeholder {
  PluralPlaceholder(
    String src, {
    Map<String, String> cases = const {},
  }) : super(src, cases: cases);

  static final regex = RegExp(r'(([0-9]:)+|(&i)+)');

  @override
  String format(dynamic value) {
    final onlyDigits = value.toString().replaceAll(RegExp(r'[^0-9, ^\., ^\,]'), '');

    final number = num.tryParse(onlyDigits)!;
    assert(number != null, 'Plural placeholder was not given a valid number!');

    if (number == null) {
      return src;
    }

    for (final entry in entries) {
      final key = num.tryParse(entry.key.trim());
      final value = entry.value.trim();

      if (entry.key == 'else' || key == number) {
        final formatted = NumberFormat.decimalPattern(
          I18n.language.locale.scriptCode,
        ).format(number);

        return value.replaceAll('\$i', formatted);
      }
    }

    assert(false, '$value couldn\'t be matched to a key in the placeholder!');

    return value.toString();
  }
}

String _removeBrackets(String src) => src.removePrefix('{').removeSuffix('}');
