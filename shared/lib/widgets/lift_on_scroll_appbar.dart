import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

class LiftOnScrollAppBar extends StatefulWidget {
  final Widget body;
  final Color shadowColor;
  final double maxElevation;
  final double minElevation;
  final Widget leading;
  final bool automaticallyImplyLeading;
  final Widget title;
  final List<Widget> actions;
  final Widget flexibleSpace;
  final PreferredSizeWidget bottom;
  final ShapeBorder shape;
  final Color backgroundColor;
  final IconThemeData iconTheme;
  final IconThemeData actionsIconTheme;
  final TextTheme textTheme;
  final bool primary;
  final bool centerTitle;
  final double titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final Brightness brightness;
  final bool showDivider;
  final Color colorOnScroll;
  final double onScrollThreshold;
  final bool expand;
  const LiftOnScrollAppBar({
    Key key,
    @required this.body,
    this.shadowColor,
    this.maxElevation = 6.0,
    this.minElevation = 0.0,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.shape,
    this.backgroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.brightness,
    this.showDivider = true,
    this.colorOnScroll,
    this.onScrollThreshold = 1.0,
    this.expand = false,
  }) : super(key: key);

  @override
  _LiftOnScrollAppBarState createState() => _LiftOnScrollAppBarState();
}

class _LiftOnScrollAppBarState extends State<LiftOnScrollAppBar> {
  bool isAtTop = true;

  @override
  Widget build(BuildContext context) {
    final height = context.mq.padding.top + kToolbarHeight;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis != Axis.vertical) {
          return false;
        }

        final offset = notification.metrics.pixels;
        final isAtTop = offset <= widget.onScrollThreshold;

        if (isAtTop != this.isAtTop) {
          setState(() => this.isAtTop = isAtTop);
        }

        return false;
      },
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: !widget.expand ? height : 0.0),
            child: widget.body,
          ),
          buildAppBar(height),
        ],
      ),
    );
  }

  Widget buildAppBar(double height) {
    return AnimatedValue(
      value: isAtTop ? 0.0 : 1.0,
      duration: const Millis(300),
      builder: (context, value) {
        final backgroundColor =
            widget.backgroundColor ?? theme.appBarTheme?.color ?? theme.accentColor;
        final colorOnScroll = widget.colorOnScroll ??
            backgroundColor.let((it) => it.isBright ? it.darken(0.1) : it.lighten(0.1));

        final isTransparent = backgroundColor.opacity == 0.0;

        final color = Color.lerp(
          backgroundColor,
          colorOnScroll,
          isTransparent ? interval(0.0, 0.5, value) : value,
        );

        final elevation = lerpDouble(
          widget.minElevation,
          widget.maxElevation,
          isTransparent ? interval(0.5, 1.0, value) : value,
        );

        final brightness = () {
          if (widget.brightness != null) {
            return widget.brightness;
          } else {
            return color.isBright ? Brightness.light : Brightness.dark;
          }
        }();

        return Box(
          height: height,
          color: color,
          elevation: elevation,
          shadowColor: widget.shadowColor ?? Colors.black.withOpacity(0.20),
          child: AppBar(
            backgroundColor: Colors.transparent,
            brightness: brightness,
            elevation: 0.0,
            shadowColor: widget.shadowColor,
            actions: widget.actions,
            actionsIconTheme: widget.actionsIconTheme,
            automaticallyImplyLeading: widget.automaticallyImplyLeading,
            bottom: widget.bottom,
            bottomOpacity: widget.bottomOpacity,
            centerTitle: widget.centerTitle,
            flexibleSpace: widget.flexibleSpace,
            iconTheme: widget.iconTheme,
            leading: widget.leading,
            primary: widget.primary,
            shape: widget.shape,
            textTheme: widget.textTheme,
            title: widget.title,
            titleSpacing: widget.titleSpacing,
            toolbarOpacity: widget.toolbarOpacity,
          ),
        );
      },
    );
  }
}
