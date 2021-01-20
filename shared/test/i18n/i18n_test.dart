import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:shared/shared.dart';

void main() async {
  I18n.dir = '${Directory.current.path}\\test\\fixtures\\i18n';

  await I18n.test([
    Language.english,
    Language.german,
  ]);

  I18n.setLanguage(Language.german);

  test('Should match a string to the correct key', () async {
    expect('Settings'.i18n, equals('Einstellungen'));
    expect('You have {10 hours} left.'.i18n, equals('Dir verbleiben 10 Stunden.'));
    expect('{10 hours}'.i18n, '10 Stunden');
  });

  test('Should translate a key correctly', () async {
    expect(I18n.key('settings'), equals('Einstellungen'));
    expect(I18n.key('hours', [1]), equals('1 Stunde'));
    expect(I18n.key('remaining_time', 10), equals('Dir verbleiben 10 Stunden.'));
  });
}
