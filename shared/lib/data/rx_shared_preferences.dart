import 'dart:async';

import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef PreferenceAdapter<T> = T Function(String json);

abstract class RxPreferencesInterface {
  Stream<Pair<String, dynamic>> get stream;

  bool getBool(String key, [bool defaultValue]);
  int getInt(String key, [int defaultValue]);
  double getDouble(String key, [double defaultValue]);
  String getString(String key, [String defaultValue]);
  List<String> getStringList(String key, [List<String> defaultValue]);
  T getObject<T>(String key, PreferenceAdapter<T> adapter, [T defaultValue]);
  List<T> getObjects<T>(String key, PreferenceAdapter<T> adapter, [List<T> defaultValue]);
  T getEnum<T>(String key, List<T> values, [T defaultValue]);

  Stream<bool> watchBool(String key, [bool defaultValue]);
  Stream<int> watchInt(String key, [int defaultValue]);
  Stream<double> watchDouble(String key, [double defaultValue]);
  Stream<String> watchString(String key, [String defaultValue]);
  Stream<List<String>> watchStringList(String key, [List<String> defaultValue]);
  Stream<T> watchObject<T>(String key, PreferenceAdapter<T> adapter, [T defaultValue]);
  Stream<List<T>> watchObjects<T>(String key, PreferenceAdapter<T> adapter,
      [List<T> defaultValue]);
  Stream<T> watchEnum<T>(String key, List<T> values, [T defaultValue]);

  Future<bool> setBool(String key, bool value);
  Future<bool> setInt(String key, int value);
  Future<bool> setDouble(String key, double value);
  Future<bool> setString(String key, String value);
  Future<bool> setStringList(String key, List<String> values);
  Future<bool> setObject<T>(String key, T value);
  Future<bool> setObjects<T>(String key, List<T> values);
  Future<bool> setEnum<T>(String key, T value);

  Future<bool> remove(String key);
}

class RxSharedPreferences implements RxPreferencesInterface {
  final SharedPreferences sharedPreferences;
  RxSharedPreferences._(this.sharedPreferences);

  static RxSharedPreferences _instance;
  static Future<RxSharedPreferences> get instance async =>
      _instance ??= RxSharedPreferences._(await SharedPreferences.getInstance());

  static bool cacheObjects = true;

  final StreamController<Pair<String, dynamic>> _controller =
      StreamController.broadcast();

  void _yield<T>(String key, T value) => _controller.add(Pair(key, value));

  @override
  Stream<Pair<String, dynamic>> get stream => _controller.stream;

  @override
  bool getBool(String key, [bool defaultValue]) =>
      getValue<bool>(key, defaultValue, const _BoolAdapter());

  @override
  int getInt(String key, [int defaultValue]) =>
      getValue<int>(key, defaultValue, const _IntAdapter());

  @override
  double getDouble(String key, [double defaultValue]) =>
      getValue<double>(key, defaultValue, const _DoubleAdapter());

  @override
  String getString(String key, [String defaultValue]) =>
      getValue<String>(key, defaultValue, const _StringAdapter());

  @override
  List<String> getStringList(String key, [List<String> defaultValue]) =>
      getValue<List<String>>(key, defaultValue, const _StringListAdapter());

  @override
  T getObject<T>(String key, PreferenceAdapter<T> adapter, [T defaultValue]) =>
      getValue<T>(key, defaultValue, _CustomAdapter(adapter));

  @override
  T getEnum<T>(String key, List<T> values, [T defaultValue]) =>
      getValue(key, defaultValue, _EnumAdapter(values));

  @override
  List<T> getObjects<T>(
    String key,
    PreferenceAdapter<T> adapter, [
    List<T> defaultValue,
  ]) =>
      getValue<List<T>>(key, defaultValue, _CustomListAdapter(adapter));

  T getValue<T>(String key, T defaultValue, _PreferenceAdapter<T> adapter) =>
      adapter.getValue(sharedPreferences, key) ?? defaultValue;

  @override
  Future<bool> setBool(String key, bool value) =>
      setValue<bool>(key, value, const _BoolAdapter());

  @override
  Future<bool> setInt(String key, int value) =>
      setValue<int>(key, value, const _IntAdapter());

  @override
  Future<bool> setDouble(String key, double value) =>
      setValue<double>(key, value, const _DoubleAdapter());

  @override
  Future<bool> setString(String key, String value) =>
      setValue<String>(key, value, const _StringAdapter());

  @override
  Future<bool> setStringList(String key, List<String> values) =>
      setValue<List<String>>(key, values, const _StringListAdapter());

  @override
  Future<bool> setObject<T>(String key, T value) =>
      setValue<T>(key, value, _CustomAdapter(null));

  @override
  Future<bool> setObjects<T>(String key, List<T> values) =>
      setValue<List<T>>(key, values, _CustomListAdapter(null));

  @override
  Future<bool> setEnum<T>(String key, T value) =>
      setValue(key, value, const _EnumAdapter(null));

  Future<bool> setValue<T>(
    String key,
    T value,
    _PreferenceAdapter adapter,
  ) async {
    final r = await adapter.setValue(sharedPreferences, key, value);
    if (r) _yield(key, value);
    return r;
  }

  @override
  Stream<bool> watchBool(String key, [bool defaultValue]) =>
      watchKey<bool>(key, defaultValue, const _BoolAdapter());

  @override
  Stream<int> watchInt(String key, [int defaultValue]) =>
      watchKey<int>(key, defaultValue, const _IntAdapter());

  @override
  Stream<double> watchDouble(String key, [double defaultValue]) =>
      watchKey<double>(key, defaultValue, const _DoubleAdapter());

  @override
  Stream<String> watchString(String key, [String defaultValue]) =>
      watchKey<String>(key, defaultValue, const _StringAdapter());

  @override
  Stream<List<String>> watchStringList(String key, [List<String> defaultValue]) =>
      watchKey<List<String>>(key, defaultValue, const _StringListAdapter());

  @override
  Stream<T> watchObject<T>(
    String key,
    PreferenceAdapter<T> adapter, [
    T defaultValue,
  ]) =>
      watchKey<T>(key, defaultValue, _CustomAdapter(adapter));

  @override
  Stream<List<T>> watchObjects<T>(
    String key,
    PreferenceAdapter<T> adapter, [
    List<T> defaultValue,
  ]) =>
      watchKey<List<T>>(key, defaultValue, _CustomListAdapter(adapter));

  @override
  Stream<T> watchEnum<T>(String key, List<T> values, [T defaultValue]) =>
      watchKey(key, defaultValue, _EnumAdapter(values));

  Stream<T> watchKey<T>(String key, T defaultValue, _PreferenceAdapter<T> adapter) {
    return stream.transform(
      _RxPreferenceTransformer<T>(key, () => getValue(key, defaultValue, adapter)),
    );
  }

  @override
  Future<bool> remove(String key) => sharedPreferences.remove(key);
}

class _RxPreferenceTransformer<T>
    extends StreamTransformerBase<Pair<String, dynamic>, T> {
  final String key;
  final T Function() getValue;
  _RxPreferenceTransformer(this.key, this.getValue);

  @override
  Stream<T> bind(Stream<Pair<String, dynamic>> stream) {
    return StreamTransformer<Pair<String, dynamic>, T>((input, cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
        sync: true,
        onListen: () {
          // When the stream is listened to, start with the current persisted
          // value.
          final value = getValue();
          controller.add(value);

          // Cache the last value. Caching is specific for each listener, so the
          // cached value exists inside the onListen() callback for a reason.
          T lastValue = value;

          // Whenever a key has been updated, fetch the current persisted value
          // and emit it.
          subscription = input
              .where((event) => event.first == key)
              .map(
                (_) => getValue(),
              )
              .listen(
            (value) {
              if (value != lastValue) {
                controller.add(value);
                lastValue = value;
              }
            },
            onDone: () => controller.close(),
          );
        },
        onPause: ([resumeSignal]) => subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel(),
      );

      return controller.stream.listen(null);
    }).bind(stream);
  }
}

// * --- Adapters --- *

abstract class _PreferenceAdapter<T> {
  Future<bool> setValue(SharedPreferences preferences, String key, T value);
  T getValue(SharedPreferences preferences, String key);
}

class _BoolAdapter implements _PreferenceAdapter<bool> {
  const _BoolAdapter();

  @override
  bool getValue(SharedPreferences preferences, String key) => preferences.getBool(key);

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, bool value) =>
      preferences.setBool(key, value);
}

class _IntAdapter implements _PreferenceAdapter<int> {
  const _IntAdapter();

  @override
  int getValue(SharedPreferences preferences, String key) => preferences.getInt(key);

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, int value) =>
      preferences.setInt(key, value);
}

class _DoubleAdapter implements _PreferenceAdapter<double> {
  const _DoubleAdapter();

  @override
  double getValue(SharedPreferences preferences, String key) =>
      preferences.getDouble(key);

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, double value) =>
      preferences.setDouble(key, value);
}

class _StringAdapter implements _PreferenceAdapter<String> {
  const _StringAdapter();

  @override
  String getValue(SharedPreferences preferences, String key) =>
      preferences.getString(key);

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, String value) =>
      preferences.setString(key, value);
}

class _StringListAdapter implements _PreferenceAdapter<List<String>> {
  const _StringListAdapter();

  @override
  List<String> getValue(SharedPreferences preferences, String key) =>
      preferences.getStringList(key);

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, List<String> values) =>
      preferences.setStringList(key, values);
}

class _CustomAdapter<T> implements _PreferenceAdapter<T> {
  final PreferenceAdapter<T> adapter;
  _CustomAdapter(this.adapter);

  static Map<String, dynamic> cache = {};

  @override
  T getValue(SharedPreferences preferences, String key) {
    T parse() => preferences.getString(key)?.let(adapter);
    return RxSharedPreferences.cacheObjects ? cache[key] ??= parse() : parse();
  }

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, T value) {
    if (RxSharedPreferences.cacheObjects) {
      cache[key] = value;
    }

    return preferences.setString(key, _toJson(value));
  }
}

class _CustomListAdapter<T> implements _PreferenceAdapter<List<T>> {
  final PreferenceAdapter<T> adapter;
  _CustomListAdapter(this.adapter);

  static Map<String, dynamic> cache = {};

  @override
  List<T> getValue(SharedPreferences preferences, String key) {
    List<T> parse() => preferences.getStringList(key)?.map(adapter)?.toList();
    return RxSharedPreferences.cacheObjects ? cache[key] ??= parse() : parse();
  }

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, List<T> values) {
    if (RxSharedPreferences.cacheObjects) {
      cache[key] = values;
    }

    return preferences.setStringList(key, values.map(_toJson).toList());
  }
}

class _EnumAdapter<T> implements _PreferenceAdapter<T> {
  final List<T> values;
  const _EnumAdapter(this.values);

  @override
  T getValue(SharedPreferences preferences, String key) =>
      values.getOrNull(preferences.getInt(key));

  @override
  Future<bool> setValue(SharedPreferences preferences, String key, T value) =>
      preferences.setInt(key, (value as dynamic).index);
}

String _toJson(dynamic value) {
  if (value == null) return null;

  try {
    return value.toJson();
  } on NoSuchMethodError {
    try {
      return value.json;
    } on NoSuchMethodError {
      try {
        return value.toJSON();
      } on NoSuchMethodError {
        throw ArgumentError(
          'The type ${value.runtimeType} has no toJson() implementation',
        );
      }
    }
  }
}

// * --- Delegate --- *

/// A wrapper class that implements [RxPreferencesInterface] and delegates
/// all calls to its [RxSharedPreferenecs] instance.
///
/// This is syntactic sugar for when you want to implement your own
/// Preference class and call methods on the [RxSharedPreferences] as
/// if it was a subclass of it.
class RxSharedPreferencesDelegate implements RxPreferencesInterface {
  final RxSharedPreferences preferences;
  const RxSharedPreferencesDelegate(this.preferences);

  @override
  Stream<Pair<String, dynamic>> get stream => throw UnimplementedError();

  @override
  bool getBool(String key, [bool defaultValue]) => preferences.getBool(key, defaultValue);

  @override
  int getInt(String key, [int defaultValue]) => preferences.getInt(key, defaultValue);

  @override
  double getDouble(String key, [double defaultValue]) =>
      preferences.getDouble(key, defaultValue);

  @override
  String getString(String key, [String defaultValue]) =>
      preferences.getString(key, defaultValue);

  @override
  List<String> getStringList(String key, [List<String> defaultValue]) =>
      preferences.getStringList(key, defaultValue);

  @override
  T getObject<T>(String key, PreferenceAdapter<T> adapter, [T defaultValue]) =>
      preferences.getObject<T>(key, adapter, defaultValue);

  @override
  List<T> getObjects<T>(String key, PreferenceAdapter<T> adapter,
          [List<T> defaultValue]) =>
      preferences.getObjects<T>(key, adapter, defaultValue);

  @override
  T getEnum<T>(String key, List<T> values, [T defaultValue]) =>
      preferences.getEnum(key, values, defaultValue);

  @override
  Future<bool> setBool(String key, bool value) => preferences.setBool(key, value);

  @override
  Future<bool> setInt(String key, int value) => preferences.setInt(key, value);

  @override
  Future<bool> setDouble(String key, double value) => preferences.setDouble(key, value);

  @override
  Future<bool> setString(String key, String value) => preferences.setString(key, value);

  @override
  Future<bool> setStringList(String key, List<String> values) =>
      preferences.setStringList(key, values);

  @override
  Future<bool> setObject<T>(String key, T value) => preferences.setObject(key, value);

  @override
  Future<bool> setObjects<T>(String key, List<T> values) =>
      preferences.setObjects(key, values);

  @override
  Future<bool> setEnum<T>(String key, T value) => preferences.setEnum(key, value);

  @override
  Stream<bool> watchBool(String key, [bool defaultValue]) =>
      preferences.watchBool(key, defaultValue);

  @override
  Stream<int> watchInt(String key, [int defaultValue]) =>
      preferences.watchInt(key, defaultValue);

  @override
  Stream<double> watchDouble(String key, [double defaultValue]) =>
      preferences.watchDouble(key, defaultValue);

  @override
  Stream<String> watchString(String key, [String defaultValue]) =>
      preferences.watchString(key, defaultValue);

  @override
  Stream<List<String>> watchStringList(String key, [List<String> defaultValue]) =>
      preferences.watchStringList(key, defaultValue);

  @override
  Stream<T> watchObject<T>(String key, PreferenceAdapter<T> adapter, [T defaultValue]) =>
      preferences.watchObject(key, adapter, defaultValue);

  @override
  Stream<List<T>> watchObjects<T>(String key, PreferenceAdapter<T> adapter,
          [List<T> defaultValues]) =>
      preferences.watchObjects(key, adapter, defaultValues);

  @override
  Future<bool> remove(String key) => preferences.remove(key);

  @override
  Stream<T> watchEnum<T>(String key, List<T> values, [T defaultValue]) =>
      preferences.watchEnum(key, values, defaultValue);
}
