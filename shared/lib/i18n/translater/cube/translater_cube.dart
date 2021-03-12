import 'package:shared_preferences/shared_preferences.dart';

import 'package:shared/i18n/internationalization.dart';
import 'package:shared/shared.dart';

import '../model/translater_state.dart';
import '../model/translation.dart';

class TranslaterCube extends Cube {
  TranslaterCube() {
    _load();
  }

  final _dao = _TranslationDao();

  bool get isLoading => language == null || translations == null || translations!.isEmpty;

  final _language = Rx<String>();
  String? get language => _language.value;

  final RxMap<String, Translation> _translations = <String, Translation>{}.rx;
  List<Translation>? get translations => _translations.values.toList();

  final _didChangeTranslations = Rx(false);
  bool? get didChangeTranslations => _didChangeTranslations.value;

  void _load() async {
    final cached = await _dao.getTranslations();

    if (cached != null) {
      _didChangeTranslations.value = true;
      _language.value = cached.language;
      _createTranslationsFromList(cached.translations);
    }
  }

  void onLanguageChoosen(Language language) async {
    _language.value = language.name;
    final map = await I18n.loadTranslations(language);
    _createTranslationsFromMap(map);
  }

  void onAddLanguage(String? language) async {
    // ignore: invalid_use_of_visible_for_testing_member
    final emptyMap = I18n.defaultTranslations.map((key, value) => MapEntry(key, ''));
    _createTranslationsFromMap(emptyMap);
  }

  void onTranslationSubmitted(Translation? translation) {
    final translations = List<Translation>.from(this.translations!);

    for (var i = 0; i < translations.length; i++) {
      final tr = translations[i];

      if (tr.key == translation!.key) {
        translations
          ..insert(i, translation)
          ..removeAt(i + 1);
        break;
      }
    }

    _createTranslationsFromList(translations);
  }

  void onSubmitAll() {
    _dao.reset();
    _dao.submitTranslation(_state);
  }

  void onSave() => _dao.saveTranslations(_state);

  LanguageTranslation get _state => LanguageTranslation(language!, translations!);

  void onReset() {
    _dao.reset();
    onAddLanguage(language);
  }

  void _createTranslationsFromMap(Map<String?, String> mapping) {
    // ignore: invalid_use_of_visible_for_testing_member
    final defaultMapping = I18n.defaultTranslations;

    _translations.value = mapping.map((key, value) {
      return MapEntry(
        key!,
        Translation(
          key: key,
          original: defaultMapping[key] ?? '',
          translation: value,
        ),
      );
    });
  }

  void _createTranslationsFromList(List<Translation> translations) {
    _translations.value = Map.fromIterable(
      translations,
      key: (t) => t.key,
    );
  }
}

class _TranslationDao {
  final prefs = SharedPreferences.getInstance();

  static const String activeKey = 'active_translation';
  static const String submittedKey = 'submitted_translations';

  Future<bool> saveTranslations(LanguageTranslation? translations) async {
    if (translations == null) return (await prefs).remove(activeKey);

    return (await prefs).setString(activeKey, translations.toJson());
  }

  Future<LanguageTranslation?> getTranslations() async =>
      _fromJson((await prefs).getString(activeKey));

  Future<void> submitTranslation(LanguageTranslation translations) async {
    final submitted = await getSubmittedTranslations();
    submitted.add(translations);
    (await prefs).setStringList(
      submittedKey,
      submitted.map((translation) => translation.toJson()).toList(),
    );
  }

  Future<List<LanguageTranslation>> getSubmittedTranslations() async {
    return (await prefs)
        .getStringList(submittedKey)!
        .map((json) => _fromJson(json)!)
        .toList();
  }

  LanguageTranslation? _fromJson(String? json) => LanguageTranslation.fromJson(json);

  Future<void> reset() => saveTranslations(null);
}
