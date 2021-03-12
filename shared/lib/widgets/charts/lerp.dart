import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// A utility function to lerp between a [Series].
/// This function takes the job of determining which series
/// were removed ([outgoing]) or added ([incoming]) and which
/// were update ([staying]).
/// Most of the time you won't have to implement [incoming] or [outoging].
List<S> lerpSeries<S extends Series>(
  List<S> a,
  List<S> b,
  double v, {
  required S Function(S) copyWith,
  S Function(S)? incoming,
  required S Function(S? o, S n) staying,
  S Function(S)? outgoing,
}) {
  assert(copyWith != null && staying != null);
  a = List<S>.from(a)..removeWhere((s) => s.isOutgoing);
  b = List<S>.from(b);
  final List<S> result = [];

  for (var i = 0; i < b.length; i++) {
    final current = copyWith(b[i]);
    S? old = a.find((old) => old == current);
    if (old != null) old = copyWith(old);

    if (!current.hasId) {
      result.add(staying(null, current));
    } else if (old != null) {
      result.add(
        staying(
          old,
          current..state = AnimState.staying,
        ),
      );
    } else if (current.hasId && !a.contains(current)) {
      // A series has been added.
      current.state = AnimState.incoming;
      result.add(
        incoming?.call(current) ?? current,
      );
    }
  }

  for (final old in a) {
    // A series has been removed.
    if (old.hasId && !old.isOutgoing && !b.contains(old)) {
      final series = copyWith(old)..state = AnimState.outgoing;
      result.add(
        outgoing?.call(series) ?? series,
      );
    }
  }

  result.sort((sa, sb) {
    final ai = sa.isOutgoing ? a.indexOf(sa) : b.indexOf(sa);
    final bi = sb.isOutgoing ? a.indexOf(sb) : b.indexOf(sb);
    return bi.compareTo(ai);
  });

  return result.reversed.toList();
}
