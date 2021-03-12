import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:core/core.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'dao.dart';

abstract class BaseSembastDao<T extends DBModel> implements Dao<T> {
  final String name;
  BaseSembastDao(this.name);

  DatabaseClient? _trx;

  StoreRef<int, Map<String, dynamic>>? _store;
  StoreRef<int, Map<String, dynamic>> get store =>
      _store ??= intMapStoreFactory.store(name);

  Completer<Database>? _dbOpenCompleter;
  Future<Database> get _db async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      _openDatabase();
    }

    return _dbOpenCompleter!.future;
  }

  Future _openDatabase() async {
    final path = join((await directory).path, name);
    final db = await databaseFactoryIo.openDatabase(path);
    _dbOpenCompleter?.complete(db);
  }

  Future<Directory> get directory;

  Pair<String, dynamic>? putFinder(T item) => null;
  Finder? getFinder() => null;

  Map<String, dynamic> toMap(T item);
  T fromMap(Map<String, dynamic> map);

  Finder _getFinder(T item) {
    final finder = putFinder(item);

    if (finder == null) {
      return Finder(
        filter: Filter.byKey(item.key),
      );
    } else {
      return Finder(
        filter: Filter.equals(finder.first, finder.second),
      );
    }
  }

  @override
  Future<int> add(T item) async {
    return store.add(
      _trx ?? await _db,
      toMap(item),
    );
  }

  @override
  Future<void> addAll(List<T> items) => transaction(items, add);

  @override
  Future<void> insert(int index, T item) async {
    final values = await this.values;
    final newItems = List<T>.from(
      values,
    )..insert(
        min(index, values.length),
        item,
      );

    await nuke(newItems);
  }

  Future<void> insertAll(int index, List<T> items) async {
    final values = await this.values;
    final newItems = List<T>.from(
      values,
    )..insertAll(
        min(index, values.length),
        items,
      );

    await nuke(newItems);
  }

  @override
  Future<int> update(T item) async {
    return store.update(
      _trx ?? await _db,
      toMap(item),
      finder: _getFinder(item),
    );
  }

  @override
  Future<void> updateAll(List<T> items) => transaction(items, update);

  @override
  Future<int> delete(T item) async {
    return store.delete(
      _trx ?? await _db,
      finder: _getFinder(item),
    );
  }

  @override
  Future<void> deleteAll(List<T> items) => transaction(items, delete);

  @override
  Future<List<T>> get values async =>
      mapSnapshots(await store.find(await _db, finder: getFinder()));

  @override
  Stream<List<T>> get stream async* {
    yield* store
        .query(finder: getFinder())
        .onSnapshots(await _db)
        .map((snapshots) => mapSnapshots(snapshots));
  }

  @override
  Future<void> nuke([List<T> replacement = const []]) async {
    return customTransaction((trx) async {
      for (final item in await values) {
        await delete(item);
      }

      for (final item in replacement) {
        await add(item);
      }
    });
  }

  Future<List<T>> find(Finder finder) async =>
      mapSnapshots(await store.find(await _db, finder: finder));

  Future<void> transaction(List<T> items, Future Function(T item) action) async {
    if (items.isEmpty) return;

    return customTransaction((trx) async {
      for (final item in items) {
        await action(item);
      }
    });
  }

  Future<void> customTransaction(
      Future<void> Function(Transaction trx) transaction) async {
    await (await _db).transaction((trx) async {
      _trx = trx;
      await transaction(trx);
    });

    _trx = null;
  }

  List<T> mapSnapshots(List<RecordSnapshot<int, Map<String, dynamic>>> snapshots) {
    return snapshots.map((s) => fromMap(s.value)..key = s.key).toList();
  }

  @override
  Future<int> get length async => store.count(await _db);
}
