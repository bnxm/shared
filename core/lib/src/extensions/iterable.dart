import 'dart:math' as math;

import '../utils/utils.dart';
import 'num.dart';

typedef Predicate<T> = bool Function(T item);

extension MyIterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    try {
      return first;
    } catch (_) {
      return null;
    }
  }

  T? get lastOrNull {
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

  /// Returns the first occurance that matches the given [predicate].
  T? find(Predicate<T> predicate, {T? orElse}) {
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
    assert(isNotEmpty);

    T? maxResult;
    Comparable? max;

    T? minResult;
    Comparable? min;

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

    return Pair(minResult!, maxResult!);
  }

  T getMax(Comparable Function(T item) comparator) => getExtremas(comparator).second;
  T getMin(Comparable Function(T item) comparator) => getExtremas(comparator).first;

  List<List<T>> groupBy<E>(E Function(T item) key) {
    final Map<E, List<T>> result = {};

    for (final item in this) {
      final gkey = key(item);

      result[gkey] ??= [];
      result[gkey]!.add(item);
    }

    return result.values.toList();
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

extension MyNullableListExtensions<T> on List<T?> {
  List<T> removeNull() => where((element) => element != null).toList() as List<T>;
}

extension My2DimensionIterableExtenions<T> on Iterable<Iterable<T>> {
  List<T> flatten() => expand((iterable) => iterable).toList();
}

extension MyListExtension<T> on List<T> {
  T? getOrNull(dynamic index) {
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
    for (var i = 0; i < length; i += skip) {
      callback(this[i], i);
    }
  }

  T pickRandom() {
    assert(isNotEmpty);
    final index = (length * random()).floor();
    return this[index];
  }

  List<T> copy([T Function(T item)? copy]) => List.from(copy != null ? map(copy) : this);

  /// Removes the [item] if already present and inserts the [item] at the specified
  /// [index]. If [index] is null the [item] gets added to the list.
  bool upsert(T item, {int? index}) {
    final removed = remove(item);
    index == null ? add(item) : insert(index, item);
    return removed;
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

extension My2DimensionalListExtensions<T> on List<List<T>> {}

List<Pair<A, B>> zip<A, B>(List<A> first, List<B> second) {
  final List<Pair<A, B>> result = [];

  for (var i = 0; i < math.min(first.length, second.length); i++) {
    result.add(Pair(first[i], second[i]));
  }

  return result;
}

List<C> zipWith<A, B, C>(List<A> first, List<B> second, C Function(A a, B b) zipper) {
  return zip(first, second).map((pair) => zipper(pair.first, pair.second)).toList();
}

extension NumIterableX on Iterable<num> {
  double get avg => sumBy((v) => v) / length;
}
