import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

Future<Color?> showMaterialColorPicker(
  BuildContext context, {
  void Function(Color color)? onColorChange,
  bool? includeShades,
  bool? includeBW,
  List<Color>? colors,
  Color? selectedColor,
  double? circleSize,
  double? spacing,
  double? elevation,
  Color? backgroundColor,
  String? title,
  double maxWidth = 500.0,
  bool withAlpha = false,
  bool withHex = false,
}) async {
  final ValueNotifier<Color> choosenColor = ValueNotifier(selectedColor ?? Colors.white);
  bool didSelect = false;

  await openDialog(
    context,
    ValueListenableBuilder(
      valueListenable: choosenColor,
      builder: (context, dynamic value, _) {
        return AnimatedColor(
          color: value,
          duration: const Millis(500),
          builder: (context, _, color) {
            return CustomDialog(
              title: title,
              accent: color,
              positiveAction: MaterialLocalizations.of(context).okButtonLabel,
              negativeAction: MaterialLocalizations.of(context).cancelButtonLabel,
              onPositive: color != null
                  ? () {
                      didSelect = true;
                      Navigator.pop(context);
                    }
                  : null,
              maxWidth: maxWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: MaterialColorPicker(
                  onColorChange: (color) {
                    choosenColor.value = color;
                    onColorChange?.call(color);
                  },
                  includeShades: includeShades,
                  includeBW: includeBW,
                  colors: colors,
                  selectedColor: value,
                  lerpColor: color,
                  circleSize: circleSize,
                  elevation: elevation,
                  spacing: spacing,
                  withAlpha: withAlpha,
                  withHex: withHex,
                ),
              ),
            );
          },
        );
      },
    ),
  );

  return didSelect ? choosenColor.value : selectedColor;
}

class MaterialColorPicker extends StatefulWidget {
  final void Function(Color color)? onColorChange;
  final bool? includeShades;
  final bool? includeBW;
  final List<Color>? colors;
  final Color? selectedColor;
  final Color? lerpColor;
  final double? circleSize;
  final double? spacing;
  final double? elevation;
  final bool withAlpha;
  final bool withHex;
  const MaterialColorPicker({
    Key? key,
    this.onColorChange,
    this.includeShades = true,
    this.colors,
    this.selectedColor,
    this.lerpColor,
    this.circleSize = 24,
    this.spacing = 8,
    this.elevation = 4,
    this.includeBW = true,
    this.withAlpha = false,
    this.withHex = false,
  }) : super(key: key);

  @override
  _MaterialColorPickerState createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<MaterialColorPicker> {
  ColorSwatch? shadeColor;

  FocusNode? node;
  TextController? hexController;

  Color get selectedColor => widget.selectedColor ?? Colors.white;
  Color get lerpColor => (widget.lerpColor ?? selectedColor).withOpacity(1.0);
  double get opacity => selectedColor.opacity;
  double get circleSize => widget.circleSize ?? 24;
  double get spacing => widget.spacing ?? 8;
  double get elevation => widget.elevation ?? 4;
  bool get includeBW => widget.includeBW ?? true;
  bool get includeShades => widget.includeShades ?? true;

  bool isHexValid = true;

  @override
  void initState() {
    super.initState();

    node = FocusNode();
    hexController = TextController()
      ..text = selectedColor.value.hex.removePrefix('#')
      ..addListener(() {
        try {
          final color = HexColor(hexController!.text);
          isHexValid = true;

          if (color != selectedColor) {
            _onColorChanged(color);
          }
        } catch (_) {
          setState(() => isHexValid = false);
        }
      });
  }

  @override
  void didUpdateWidget(MaterialColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    setHexColor();
  }

  void _onColorChanged(Color color, [double? opacity]) =>
      widget.onColorChange?.call(color.withOpacity(opacity ?? this.opacity));

  List<Widget> _buildColors() {
    final colors = shadeColor != null ? _getShades(shadeColor!) : materialColors;

    Widget buildCircle(Color? color) {
      return GestureDetector(
        onTap: () {
          setState(() {
            if (includeShades && shadeColor == null && color is ColorSwatch) {
              shadeColor = color;
              if (color is MaterialColor) {
                _onColorChanged(color.shade500);
              } else if (color is MaterialAccentColor) {
                _onColorChanged(color.shade200);
              }
            } else {
              _onColorChanged(color!);
            }
          });
        },
        child: Box(
          elevation: elevation,
          width: circleSize,
          height: circleSize,
          padding: const EdgeInsets.all(0),
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          borderRadius: circleSize / 2,
          color: color!.withOpacity(opacity),
          shadowColor: Colors.black.withOpacity(0.12 * opacity),
          child: Visibility(
            visible: color == selectedColor.withOpacity(1),
            child: Icon(
              Icons.check,
              size: circleSize / 2.5,
              color: color.toContrast(),
            ),
          ),
        ),
      );
    }

    List<Widget> circles = colors.map(buildCircle).toList();

    if (shadeColor == null && includeBW) {
      circles = [
        buildCircle(Colors.white),
        ...circles,
        buildCircle(Colors.black),
      ];
    }

    if (shadeColor != null) {
      circles = [
        Box(
          borderRadius: circleSize / 2.5,
          padding: const EdgeInsets.all(0),
          onTap: () {
            setState(() {
              shadeColor = null;
            });
          },
          child: Icon(
            Icons.arrow_back,
            size: circleSize / 2.2,
          ),
        ),
        ...circles,
      ];
    }

    return circles;
  }

  List<Color?> _getShades(ColorSwatch color) {
    final List<Color?> colors = [];
    if (color[50] != null) colors.add(color[50]);
    if (color[100] != null) colors.add(color[100]);
    if (color[200] != null) colors.add(color[200]);
    if (color[300] != null) colors.add(color[300]);
    if (color[400] != null) colors.add(color[400]);
    if (color[500] != null) colors.add(color[500]);
    if (color[600] != null) colors.add(color[600]);
    if (color[700] != null) colors.add(color[700]);
    if (color[800] != null) colors.add(color[800]);
    if (color[900] != null) colors.add(color[900]);

    return colors;
  }

  void setHexColor() {
    if (!node!.hasFocus) {
      hexController!.text = selectedColor.value.hex.removePrefix('#');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final circles = (width / circleSize).floor();

        return AnimatedSizeChanges(
          duration: const Millis(400),
          curve: Curves.ease,
          alignment: shadeColor == null ? Alignment.bottomCenter : Alignment.topCenter,
          child: GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.all(elevation * 2),
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            crossAxisCount: circles,
            children: _buildColors(),
          ),
        );
      },
    );

    final alpha = Visibility(
      visible: widget.withAlpha,
      child: Vertical(
        children: <Widget>[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text('Opacity'),
          ),
          Slider(
            max: 1,
            min: 0,
            value: selectedColor.opacity,
            onChanged: (value) => _onColorChanged(selectedColor, value),
            activeColor: lerpColor,
          ),
        ],
      ),
    );

    final hex = Visibility(
      visible: widget.withHex,
      child: AnimatedSizeFade(
        show: shadeColor == null,
        duration: const Millis(300),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Vertical(
            children: <Widget>[
              const Text('Hex'),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 128,
                    child: TextField(
                      focusNode: node,
                      controller: hexController,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        prefixText: '# ',
                        prefixStyle:
                            textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w600),
                        focusColor: lerpColor,
                        border: theme.inputDecorationTheme.border,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: lerpColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedOpacity(
                    opacity: isHexValid ? 0.0 : 1.0,
                    duration: const Millis(250),
                    child: Icon(
                      Icons.error_outline,
                      color: schema.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        colors,
        alpha,
        hex,
      ],
    );
  }

  @override
  void dispose() {
    hexController?.dispose();
    node?.dispose();
    super.dispose();
  }
}

const List<ColorSwatch> materialColors = <ColorSwatch>[
  Colors.red,
  Colors.redAccent,
  Colors.pink,
  Colors.pinkAccent,
  Colors.purple,
  Colors.purpleAccent,
  Colors.deepPurple,
  Colors.deepPurpleAccent,
  Colors.indigo,
  Colors.indigoAccent,
  Colors.blue,
  Colors.blueAccent,
  Colors.lightBlue,
  Colors.lightBlueAccent,
  Colors.cyan,
  Colors.cyanAccent,
  Colors.teal,
  Colors.tealAccent,
  Colors.green,
  Colors.greenAccent,
  Colors.lightGreen,
  Colors.lightGreenAccent,
  Colors.lime,
  Colors.limeAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.amber,
  Colors.amberAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.deepOrange,
  Colors.deepOrangeAccent,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey
];
