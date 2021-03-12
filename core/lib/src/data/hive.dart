import 'dart:async';

import 'package:core/core.dart';
import 'package:meta/meta.dart';
import 'package:hive/hive.dart';

import 'dao.dart';

abstract class HiveDao<T extends DBModel> implements Dao<T> {
  HiveDao(
    this.name,
  ) {
    _openBox();
    _controller.onListen = () => _emit();
  }

  final String name;
  late Future<Box<String>> _box;

  final Handler handler = Handler();
  final StreamController<List<T>> _controller = StreamController.broadcast();

  void _openBox() {
    _box = Hive.openBox<String>(name);
  }

  @protected
  T fromJson(String map);
  @protected
  String toJson(T item);

  @override
  Future<void> add(T item) async {
    final box = await _box;
    final key = await box.add(toJson(item));
    await box.put(key, toJson(item..key = key));
    _emit();
  }

  @override
  Future<void> addAll(List<T> items) async {
    for (final item in items) {
      await add(item);
    }
  }

  @override
  Future<void> insert(int index, T item) async {
    final items = List<T>.from(await values);
    await deleteAll(items);
    items.insert(index, item);
    await addAll(items);
  }

  @override
  Future<void> update(T item) async {
    if (item.key == null) {
      await add(item);
    } else {
      await (await _box).put(item.key, toJson(item));
    }
    _emit();
  }

  @override
  Future<void> updateAll(List<T> items) async {
    for (final item in items) {
      await update(item);
    }
  }

  @override
  Future<void> delete(T item) async {
    if (item.key == null) return;

    await (await _box).delete(item.key);
    _emit();
  }

  @override
  Future<void> deleteAll(List<T> items) async {
    for (final item in items) {
      await delete(item);
    }
  }

  @override
  Future<int> get length async => (await _box).length;

  @override
  Future<List<T>> get values async {
    return (await _box).values.map((item) => fromJson(item)).toList();
  }

  @override
  Stream<List<T>> get stream => _controller.stream;

  void _emit() {
    // Add a debounce effect to the stream so that when deleting
    // many items, there is only one event at the end.
    handler.post(
      100,
      () async => _controller.add(await values),
    );
  }

  @override
  Future<void> nuke([List<T>? replacement]) async {
    await (await _box).deleteFromDisk();
    _openBox();

    if (replacement != null) {
      await addAll(replacement);
    }
  }
}
