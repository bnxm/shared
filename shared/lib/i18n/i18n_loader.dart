import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';
import 'package:yaml/yaml.dart';

abstract class I18nMap extends DelegatingMap<String, String> {
  const I18nMap(Map<String, String> map) : super(map);

  static const List<String> supportedFormats = ['yaml', 'json'];

  factory I18nMap.parse(String file, String format) {
    switch (format) {
      case 'yaml':
        return I18nYamlMap(file);
      case 'json':
        return I18nJsonMap(file);
      default:
        return throw ArgumentError.value('No parser exists for .$format files!');
    }
  }

  static Future<I18nMap> load(String path, {bool inTestMode = false}) async {
    final result = await _loadFile(path, inTestMode);
    return I18nMap.parse(result.first, result.second);
  }
}

/// Tries to find the translation file with all possible
/// supported formats.
///
/// Returns the file content and its format.
Future<Pair<String, String>> _loadFile(String path, bool inTestMode) async {
  const formats = [...I18nMap.supportedFormats, ''];

  for (var format in formats) {
    try {
      final file = format.isEmpty ? path : '$path.$format';

      if (format.isEmpty) {
        format = path.substring(path.lastIndexOf('.') + 1);
      }

      if (inTestMode) {
        return Pair(await File(file).readAsString(), format);
      } else {
        return Pair(await rootBundle.loadString(file), format);
      }
    } catch (_) {}
  }

  throw ArgumentError.value('No language file exists for $path!');
}

class I18nYamlMap extends I18nMap {
  I18nYamlMap(String file) : super(parse(file));

  static Map<String, String> parse(String file) {
    return (loadYaml(file) as YamlMap).flatten();
  }
}

class I18nJsonMap extends I18nMap {
  I18nJsonMap(String file) : super(parse(file));

  static Map<String, String> parse(String file) {
    return (json.decode(file) as Map<String, dynamic>).flatten();
  }
}

extension _ on Map {
  Map<String, String> flatten() {
    Map<String, String> mapSubtree(Map map, {String parent = ''}) {
      final Map<String, String> result = {};

      for (final entry in map.entries) {
        final key = parent.isNotEmpty ? '${parent}_${entry.key}' : entry.key;

        if (entry.value is Map) {
          final subEntries = mapSubtree(entry.value, parent: key);
          result.addAll(subEntries);
        } else {
          result[key] = entry.value.toString();
        }
      }

      return result;
    }

    return mapSubtree(this);
  }
}
