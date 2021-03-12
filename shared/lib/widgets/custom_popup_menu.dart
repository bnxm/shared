import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class CustomPopUpMenuButton extends StatefulWidget {
  final Color dimColor;
  final EdgeInsets padding;
  final Widget? menu;
  final dynamic icon;
  final Color? color;
  final double iconSize;
  final VoidCallback? onDismiss;
  final Duration duration;
  const CustomPopUpMenuButton({
    Key? key,
    this.dimColor = Colors.transparent,
    this.onDismiss,
    this.padding = const EdgeInsets.all(8),
    this.menu,
    this.icon,
    this.iconSize = 24.0,
    this.color,
    this.duration = const Millis(200),
  }) : super(key: key);

  @override
  _CustomPopUpMenuButtonState createState() => _CustomPopUpMenuButtonState();
}

class _CustomPopUpMenuButtonState extends State<CustomPopUpMenuButton> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CircleButton(
      key: _key,
      icon: widget.icon,
      color: widget.color,
      size: widget.iconSize,
      padding: widget.padding,
      onTap: () async {
        final RenderBox? box = _key.currentContext?.findRenderObject() as RenderBox?;
        final anchor = box?.localToGlobal(Offset.zero) ?? Offset.zero;

        await Navigator.push(
          context,
          TransparentRoute(
            duration: widget.duration,
            builder: (context, animation) => _CustomPopUpMenu(
              anchor: Pair(
                Offset(anchor.dx, anchor.dy),
                Size(widget.iconSize, widget.iconSize),
              ),
              child: widget.menu,
              routeAnimation: animation,
              dimColor: widget.dimColor,
            ),
          ),
        );

        widget.onDismiss?.call();
      },
    );
  }
}

Future<T?> showCustomPopUpMenu<T>(
  BuildContext context, {
  required Widget child,
  Duration duration = const Millis(200),
  required Offset offset,
  Color dimColor = Colors.transparent,
}) {
  return Navigator.push(
    context,
    TransparentRoute(
      duration: duration,
      builder: (context, animation) => _CustomPopUpMenu(
        anchor: Pair(
          offset,
          Size.zero,
        ),
        child: child,
        routeAnimation: animation,
        dimColor: dimColor,
      ),
    ),
  );
}

class _CustomPopUpMenu extends StatefulWidget {
  final Color dimColor;
  final Widget? child;
  final Pair<Offset, Size> anchor;
  final Animation routeAnimation;
  const _CustomPopUpMenu({
    Key? key,
    required this.child,
    required this.anchor,
    required this.routeAnimation,
    this.dimColor = Colors.transparent,
  }) : super(key: key);

  @override
  _CustomPopUpMenuState createState() => _CustomPopUpMenuState();
}

class _CustomPopUpMenuState extends State<_CustomPopUpMenu>
    with SingleTickerProviderStateMixin {
  final _key = GlobalKey();

  Animation<double> get _animation => widget.routeAnimation as Animation<double>;

  bool showLeft = true;
  bool showDown = true;

  Offset? _position;
  late Rect _rect;

  @override
  void initState() {
    super.initState();
    postFrame(() => setState(() {}));
  }

  void calcPopUpPosition() {
    final appHeight = context.screenHeight;
    final appWidth = context.screenWidth;

    _rect = Rect.fromLTRB(
      8,
      8,
      appWidth - 8,
      appHeight - 8,
    );

    postFrame(() {
      final anchor = widget.anchor.first;
      final anchorWidth = widget.anchor.second.width;
      final anchorHeight = widget.anchor.second.height;

      final size = _key.currentContext!.size;
      if (size != null && anchor != null) {
        final width = size.width;
        final height = size.height;

        showLeft = anchor.dx >= (appWidth / 2);
        showDown = anchor.dy <= (appHeight / 2);

        _position = Offset(
          showLeft ? anchor.dx + anchorWidth - width : anchor.dx,
          showDown ? anchor.dy - 8 : anchor.dy + anchorHeight - height,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    calcPopUpPosition();

    final menu = FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _animation, curve: Curves.easeInOutCubic),
        alignment: Alignment(
          showLeft ? 1.0 : 1.0,
          showDown ? -1.0 : 1.0,
        ),
        child: Container(
          key: _key,
          child: widget.child,
        ),
      ),
    );

    final backDrop = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanEnd: (_) => Navigator.pop(context),
      onPanCancel: () => Navigator.pop(context),
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          color: widget.dimColor,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );

    return Stack(
      children: <Widget>[
        backDrop,
        Positioned.fromRect(
          rect: _rect,
          child: Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: _position ?? Offset.zero,
              child: menu,
            ),
          ),
        )
      ],
    );
  }
}
