import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

export 'chart.dart';
export 'chart_data.dart';
export 'chart_painter.dart';
export 'interaction.dart';

abstract class Chart<T, S extends Series<T>> extends ImplicitAnimation {
  final List<S> data;
  final Legend legend;
  final double width;
  final double height;
  final EdgeInsets padding;
  const Chart({
    Key? key,
    required Duration duration,
    required Curve curve,
    required this.data,
    required this.width,
    required this.height,
    required this.padding,
    required this.legend,
  }) : super(
          key,
          duration,
          curve,
        );
}

abstract class ChartState<T, C extends Chart<T, Series<T>>, CD extends ChartData<T>?>
    extends ImplicitAnimationState<CD, C> {
  dynamic painter;
  dynamic oldPainter;

  List<Widget>? interActionWidgets;
  Interaction? lastInteraction;
  StreamController<Interaction>? _interaction;
  Stream<Interaction> get interactionStream => _interaction!.stream;

  @override
  void initState() {
    super.initState();
    _interaction = StreamController()..add(PointerEndInteraction());
  }

  @override
  void didUpdateWidget(C oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (painter != null) {
      oldPainter = painter;
    }
  }

  CD getChartData([CD? data]);

  ChartPainter getPainter(CD? data);

  @override
  CD get newValue => getChartData();

  @override
  CD lerp(CD? oldValue, CD newValue, double t) => oldValue!.scaleTo(newValue, t) as CD;

  void onInteraction(Interaction interaction) {
    if (interaction != lastInteraction) {
      lastInteraction = interaction;
      _interaction?.add(interaction);
    }
  }

  @override
  Widget builder(BuildContext context, CD? data) {
    return StreamBuilder(
      stream: interactionStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final tap = snapshot.data;

        // Assign the painter.
        painter = getPainter(data)
          ..v = v
          ..interaction = tap;

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(
              widget.width,
              widget.height ,
            );

            return AnimatedContainer(
              width: size.width,
              height: size.height,
              padding: widget.padding,
              curve: widget.curve,
              duration: widget.duration,
              child: GestureDetector(
                onTap: () => onInteraction(TapInteraction(lastInteraction!)),
                //onLongPress: () => onInteraction(LongPressInteraction(_lastInteraction)),
                onPanDown: (DragDownDetails details) =>
                    onInteraction(PointerDownInteraction(details)),
                onPanUpdate: (DragUpdateDetails details) =>
                    onInteraction(PointerMoveInteraction(details)),
                onPanEnd: (DragEndDetails details) =>
                    onInteraction(PointerEndInteraction()),
                child: Stack(
                  children: <Widget>[
                    // Specify container with the size to avoid weird
                    // Stack/Positioned.fill bug on interactions.
                    Container(
                      width: size.width,
                      height: size.height,
                      child: CustomPaint(
                        isComplex: true,
                        painter: painter,
                      ),
                    ),

                    // The interaction widgets displayed on top of the chart.
                    if (interActionWidgets != null) ...interActionWidgets!,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _interaction?.close();
    super.dispose();
  }
}
