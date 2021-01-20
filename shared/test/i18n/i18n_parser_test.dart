import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:shared/shared.dart';

Future<I18nMap> load(String name) => I18nMap.load(
      '${Directory.current.path}\\test\\fixtures\\i18n\\$name',
      inTestMode: true,
    );

void main() async {
  final yaml = await load('parser.yaml');
  final json = await load('parser.json');

  group('Parse chooser', () {
    test('Should choose the YamlParser for .yaml files', () async {
      // assert
      expect(yaml, isA<I18nYamlMap>());
    });
  });

  group('Parsing', () {
    const i18nMap = {
      'hello': '"Hello"',
      'hours': '{1: \$i Hour, else: \$i Hours}',
      'home_body_title': 'title',
      'home_hello': 'Hallo',
    };

    test(
      'Should correctly flatten a YAML file',
      () => expect(yaml, equals(i18nMap)),
    );

    test(
      'Should correctly flatten a JSON file',
      () => expect(json, equals(i18nMap)),
    );
  });
}
