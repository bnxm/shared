import 'package:flutter/material.dart';

import 'package:core/core.dart';

class HighlightText extends StatelessWidget {
  final TextStyle? activeStyle;
  final TextStyle? style;
  final String query;
  final String text;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int? maxLines;
  const HighlightText({
    Key? key,
    this.activeStyle,
    this.style,
    this.query = '',
    this.text = '',
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.ellipsis,
    this.textScaleFactor = 1.0,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final idxs = _getQueryHighlights(text, query);
    final style = this.style ?? Theme.of(context).textTheme.bodyText2;
    final activeStyle = this.activeStyle ?? style!.copyWith(fontWeight: FontWeight.bold);

    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      text: TextSpan(
        children: idxs.map((idx) {
          return TextSpan(
            text: text.substring(idx.first, idx.second),
            style: idx.third ? activeStyle : style,
          );
        }).toList(),
      ),
    );
  }
}

List<Triplet<int, int, bool>> _getQueryHighlights(String text, String query) {
  final t = text.toLowerCase();
  final q = query.toLowerCase();

  if (t.isEmpty || q.isEmpty || !t.contains(q)) return [Triplet(0, t.length, false)];

  List<Triplet<int, int, bool>> idxs = [];

  var w = t;
  do {
    final i = w.lastIndexOf(q);
    final e = i + q.length;
    if (i != -1) {
      w = w.replaceLast(q, '');
      idxs.insert(0, Triplet(i, e, true));
    }
  } while (w.contains(q));

  if (idxs.isEmpty) {
    idxs.add(Triplet(0, t.length, false));
  } else {
    final List<Triplet<int, int, bool>> result = [];

    Triplet<int, int, bool>? last;
    for (final idx in idxs) {
      final isLast = idx == idxs.last;
      if (last == null) {
        if (idx.first == 0) {
          result.add(idx);
        } else {
          result.add(Triplet(0, idx.first, false));
          result.add(idx);
        }
      } else if (last.second == idx.first) {
        result.add(idx);
      } else {
        result.add(Triplet(last.second, idx.first, false));
        result.add(idx);
      }

      if (isLast && idx.second != t.length) {
        result.add(Triplet(idx.second, t.length, false));
      }

      last = idx;
    }

    idxs = result;
  }

  return idxs;
}
