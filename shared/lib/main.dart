import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: PlasmaIllustration(),
    );
  }
}

class PlasmaIllustration extends StatelessWidget {
  const PlasmaIllustration({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final illustration = _PlasmaIllustration.day1;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              tileMode: TileMode.mirror,
              begin: const Alignment(-0.8, -1.0),
              end: Alignment.bottomRight,
              colors: illustration.colors,
              stops: [
                for (var i = 0; i < illustration.colors.length; i++)
                  (1 / illustration.colors.length) * i,
              ],
            ),
            backgroundBlendMode: BlendMode.srcOver,
          ),
          child: PlasmaRenderer(
            type: PlasmaType.infinity,
            particles: illustration.count,
            color: illustration.color,
            blur: illustration.blur,
            size: illustration.size,
            speed: illustration.speed,
            rotation: illustration.rotation,
            blendMode: BlendMode.plus,
            particleType: ParticleType.atlas,
          ),
        )
      ],
    );
  }
}

class _PlasmaIllustration {
  final List<Color> colors;
  final Color color;
  final double blur;
  final double size;
  final double speed;
  final double rotation;
  final int count;
  final bool isDay;
  const _PlasmaIllustration({
    required this.colors,
    required this.color,
    this.blur = 0.2,
    this.size = 1.15,
    this.speed = 2.0,
    this.rotation = 0.0,
    this.count = 18,
    required this.isDay,
  });

  static const day1 = _PlasmaIllustration(
    isDay: true,
    blur: 0.7,
    speed: 3.0,
    size: 0.65,
    rotation: 3.14,
    color: Color(0x9d6f197c),
    colors: [
      Color(0xbe4da7f4),
      Color(0xff8fcef2),
      Color(0xff6df1e3),
    ],
  );

  static const day2 = _PlasmaIllustration(
    isDay: true,
    blur: 0.7,
    size: 0.7,
    color: Color(0xaf228786),
    colors: [
      Color(0xbe8ef3c8),
      Color(0xff589fe1),
    ],
  );

  static const night1 = _PlasmaIllustration(
    isDay: false,
    blur: 1,
    size: 0.55,
    color: Color(0xaf7626e1),
    colors: [
      Color(0xbe152045),
      Color(0xff1763aa),
    ],
  );

  static const cloudyDay = _PlasmaIllustration(
    isDay: true,
    blur: 1.0,
    size: 0.55,
    color: Color(0xaf2b2b2b),
    colors: [
      Color(0xbee5e5e5),
      Color(0xffcecece),
    ],
  );

  static const cloudyNight = _PlasmaIllustration(
    isDay: false,
    blur: 1.0,
    size: 0.55,
    color: Color(0xaf2b2b2b),
    colors: [
      Color(0xbec0c0c0),
      Color(0xff9f9f9f),
    ],
  );

  static const rain = _PlasmaIllustration(
    isDay: true,
    blur: 0.7,
    speed: 3.0,
    size: 0.65,
    rotation: 3.14,
    color: Color(0xaf103045),
    colors: [
      Color(0xbe4da7f4),
      Color(0xff8fcef2),
    ],
  );
}
