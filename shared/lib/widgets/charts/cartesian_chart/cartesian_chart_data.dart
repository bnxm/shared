import 'package:shared/shared.dart';

abstract class CartesianSeries<T> extends Series<T> {
  /// The data for this series.
  List<T> data;

  CartesianSeries({
    required List<T> data,
    required dynamic id,
    String? label,
  })  : data = List<T>.from(data),
        super(
          id: id,
          label: label,
        );

  List<ChartValue> values = [];
}
