import '../utils/utils.dart';
import 'num.dart';

typedef Predicate<T> = bool Function(T item);

extension IterableExtension<T> on Iterable<T> {
  T get firstOrNull {
    try {
      return first;
    } catch (_) {
      return null;
    }
  }

  T get lastOrNull {
    try {
      return last;
    } catch (_) {
      return null;
    }
  }

  int get lastIndex => length - 1;

  List<E> imap<E>(E Function(int i, T item) mapper) {
    var i = 0;
    return map((e) => mapper(i++, e)).toList();
  }

  /// Counts the occurances of the given [predicate].
  int count(bool Function(T item) predicate) {
    int count = 0;

    for (final item in this) {
      if (predicate(item) == true) {
        count++;
      }
    }

    return count;
  }

  double sumBy(num Function(T item) callback) {
    double sum = 0.0;
    for (final item in this) {
      sum += callback(item);
    }
    return sum;
  }

  /// Returns a copy of this list.
  List<T> copy([T Function(T) copier]) => map((t) => copier?.call(t) ?? t).toList();

  /// Returns the first occurance that matches the given [predicate].
  T find(Predicate<T> predicate, {T orElse}) {
    for (final item in this) {
      if (predicate(item)) return item;
    }
    return orElse;
  }

  bool includes(Predicate<T> predicate) => find(predicate) != null;

  /// Returns a new list of items for which [predicate] equals true.
  List<T> filter(Predicate<T> predicate) {
    final List<T> result = [];
    for (final item in this) {
      if (predicate(item)) result.add(item);
    }
    return result;
  }

  /// Returns a new list with a length of <= `count` beggining
  /// at `start`.
  List<T> slice(int count, {int start = 0}) {
    if (start >= length) {
      return <T>[];
    }

    return toList().sublist(start, (start + count).atMost(length));
  }

  /// Returns the min and max values as a Pair(min, max)
  Pair<T, T> getExtremas(Comparable Function(T item) comparator) {
    T maxResult;
    Comparable max;

    T minResult;
    Comparable min;

    for (final element in this) {
      final item = comparator(element);

      max ??= item;
      min ??= item;

      maxResult ??= element;
      minResult ??= element;

      if (item.compareTo(max) > 0) {
        max = item;
        maxResult = element;
      } else if (item.compareTo(min) < 0) {
        min = item;
        minResult = element;
      }
    }

    return Pair(minResult, maxResult);
  }

  T getMax(Comparable Function(T item) comparator) => getExtremas(comparator).second;
  T getMin(Comparable Function(T item) comparator) => getExtremas(comparator).first;

  List<List<T>> groupBy<E>(E Function(T item) value) {
    final List<List<T>> result = [];

    for (final item in this) {
      final v = value(item);
      List<T> groupToAdd;
      for (final group in result) {
        if (value(group.first) == v) {
          groupToAdd = group;
          break;
        }
      }

      if (groupToAdd != null) {
        groupToAdd.add(item);
      } else {
        result.add([item]);
      }
    }

    return result;
  }

  /// Filters all duplicates from this [List].
  ///
  /// The type must implement value equality for this to work.
  List<T> distinct() => toSet().toList();

  /// Creates a new [List] with all elements that pass the [test].
  ///
  /// This is usefull for example for filtering duplicates that don't
  /// have strictly the same value equality.
  List<T> distinctBy(bool Function(List<T> result, T item) test) {
    final List<T> result = [];

    for (final item in this) {
      if (test(result, item)) {
        result.add(item);
      }
    }

    return result;
  }
}

extension My2DimensionIterableExtenions<T> on Iterable<Iterable<T>> {
  List<T> flatten() => expand((iterable) => iterable).toList();
}

extension MyListExtension<T> on List<T> {
  T getOrNull(dynamic index) {
    if (this == null) return null;

    try {
      return this[index];
    } catch (_) {
      return null;
    }
  }

  T getOrElse(dynamic index, T other) => getOrNull(index) ?? other;

  void removeAll(List<T> items) {
    for (final item in items) {
      remove(item);
    }
  }

  void forEachIndexed(void Function(T, int) callback, {int skip = 1}) {
    assert(skip != null);
    for (var i = 0; i < length; i += skip) {
      callback(this[i], i);
    }
  }

  T pickRandom() {
    assert(isNotEmpty);
    final index = (length * random()).floor();
    return this[index];
  }

  /// Removes the [item] if already present and inserts the [item] at the specified
  /// [index]. If [index] is null the [item] gets added to the list.
  bool upsert(T item, {int index}) {
    final contains = this.contains(item);
    if (contains) {
      remove(item);
    }

    index == null ? add(item) : insert(index, item);
    return contains;
  }

  void sortBy(List<Comparable Function(T item)> fields) {
    sort((a, b) {
      for (final field in fields) {
        final r = field(a).compareTo(field(b));
        if (r != 0) {
          return r;
        }
      }

      return 0;
    });
  }

  double avgOf(num Function(T item) value) {
    if (length == 0) return 0.0;
    return sumBy(value) / length;
  }
}

extension NumIterableX on Iterable<num> {
  double get avg => sumBy((v) => v) / length;
}
