abstract class DBModel {
  int? key;
}

abstract class Dao<T extends DBModel> {
  Future<void> add(T item);
  Future<void> addAll(List<T> items);

  Future<void> insert(int index, T item);

  Future<void> update(T item);
  Future<void> updateAll(List<T> items);

  Future<void> delete(T item);
  Future<void> deleteAll(List<T> items);

  Future<int> get length;

  Future<List<T>> get values;
  Stream<List<T>> get stream;

  Future<void> nuke([List<T> replacement]);
}
