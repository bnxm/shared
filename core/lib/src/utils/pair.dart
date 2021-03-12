class Pair<A, B> {
  final A first;
  final B second;
  const Pair(
    this.first,
    this.second,
  );

  Pair copyWith({
    A? first,
    B? second,
  }) {
    return Pair(
      first ?? this.first,
      second ?? this.second,
    );
  }

  @override
  String toString() => 'Pair first: $first, second: $second';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Pair<A, B> && o.first == first && o.second == second;
  }

  @override
  int get hashCode => first.hashCode ^ second.hashCode;
}

class Triplet<A, B, C> {
  final A first;
  final B second;
  final C third;
  const Triplet(
    this.first,
    this.second,
    this.third,
  );

  Triplet copyWith({
    A? first,
    B? second,
    C? third,
  }) {
    return Triplet(
      first ?? this.first,
      second ?? this.second,
      third ?? this.third,
    );
  }

  @override
  String toString() => 'Triple first: $first, second: $second, third: $third';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Triplet<A, B, C> &&
        o.first == first &&
        o.second == second &&
        o.third == third;
  }

  @override
  int get hashCode => first.hashCode ^ second.hashCode ^ third.hashCode;
}

class Quartet<A, B, C, D> {
  final A first;
  final B second;
  final C third;
  final D fourth;
  const Quartet(
    this.first,
    this.second,
    this.third,
    this.fourth,
  );

  Quartet copyWith({
    A? first,
    B? second,
    C? third,
    D? fourth,
  }) {
    return Quartet(
      first ?? this.first,
      second ?? this.second,
      third ?? this.third,
      fourth ?? this.fourth,
    );
  }

  @override
  String toString() {
    return 'Quartet first: $first, second: $second, third: $third, fourth: $fourth';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Quartet<A, B, C, D> &&
        o.first == first &&
        o.second == second &&
        o.third == third &&
        o.fourth == fourth;
  }

  @override
  int get hashCode {
    return first.hashCode ^ second.hashCode ^ third.hashCode ^ fourth.hashCode;
  }
}
