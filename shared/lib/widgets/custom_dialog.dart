import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

class CustomDialog extends StatelessWidget {
  final Widget? child;
  final dynamic title;
  final double maxHeight;
  final double maxWidth;
  final String? positiveAction;
  final String? negativeAction;
  final String? neutralAction;
  final double titleElevation;
  final VoidCallback? onPositive;
  final VoidCallback? onNegative;
  final VoidCallback? onNeutral;
  final Color? accent;
  final EdgeInsets padding;
  final BorderSide? border;
  final dynamic borderRadius;
  final Widget? header;
  final bool floatingButtons;
  const CustomDialog({
    Key? key,
    this.child,
    this.title,
    this.maxHeight = 800.0,
    this.maxWidth = 500.0,
    this.positiveAction,
    this.negativeAction,
    this.neutralAction,
    this.titleElevation = 0.0,
    this.onPositive,
    this.onNegative,
    this.onNeutral,
    this.accent,
    this.padding = const EdgeInsets.all(32),
    this.border,
    this.borderRadius = 16,
    this.header,
    this.floatingButtons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConfigurationBuilder(
      builder: (context, isPortrait, type, screenSize, size) {
        final width = size.width;
        final height = size.height;
        final constraints = BoxConstraints(
          maxHeight: (height * 0.75).atMost(isPortrait ? maxHeight : maxWidth),
          maxWidth: (width * 0.8).atMost(isPortrait ? maxWidth : maxHeight),
        );

        Widget content = NoOverscroll(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: <Widget>[
              if (isPortrait && header != null) header!,
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  padding.top,
                  padding.right,
                  0.0,
                ),
                child: Vertical(
                  children: <Widget?>[
                    if (title != null) _getTitle(context),
                    child,
                    if (!floatingButtons) _getButtons(context),
                  ],
                ),
              ),
            ],
          ),
        );

        if (!isPortrait) {
          content = Row(
            children: [
              if (header != null) header!,
              Expanded(child: content),
            ],
          );
        }

        if (floatingButtons) {
          content = Column(
            children: <Widget>[
              Expanded(child: content),
              _getButtons(context),
            ],
          );
        }

        final dialog = Dialog(
          insetAnimationCurve: Curves.easeInOut,
          insetAnimationDuration: const Duration(milliseconds: 375),
          child: Box(
            constraints: constraints,
            border: border != null ? Border.fromBorderSide(border!) : null,
            borderRadius: borderRadius,
            color: theme.dialogTheme.backgroundColor,
            child: content,
          ),
        );

        return dialog;
      },
    );
  }

  Widget _getTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Box(
      elevation: titleElevation,
      padding: const EdgeInsets.only(bottom: 8),
      child: title is Widget
          ? title
          : Text(
              title.toString(),
              style: theme.dialogTheme.titleTextStyle,
            ),
    );
  }

  Widget _getButtons(BuildContext context) {
    final hasPositive = positiveAction != null;
    final hasNeutral = neutralAction != null;
    final hasNegative = negativeAction != null;

    if (!hasPositive && !hasNeutral && !hasNegative) {
      return SizedBox(height: padding.bottom);
    }

    final isDense = hasPositive && hasNeutral && hasNegative;

    final theme = Theme.of(context);
    final shape = theme.buttonTheme.shape;
    final buttonRadius =
        shape is RoundedRectangleBorder ? shape.borderRadius : BorderRadius.zero;

    Color buttonColor = (accent ?? theme.accentColor).withOpacity(1.0);
    final dialogBackgroundColor = theme.dialogTheme.backgroundColor!;
    if ((dialogBackgroundColor.brightness - buttonColor.brightness).abs() < 0.1) {
      buttonColor = dialogBackgroundColor.toContrast();
    }

    final positive = Padding(
      padding: const EdgeInsets.only(left: 8),
      child: RaisedButton(
        color: buttonColor,
        splashColor: buttonColor.withOpacity(0.15),
        focusColor: buttonColor.withOpacity(0.2),
        hoverColor: buttonColor.withOpacity(0.2),
        highlightColor: buttonColor.withOpacity(0.2),
        disabledColor: buttonColor.withOpacity(.5),
        elevation: 2,
        focusElevation: 4,
        highlightElevation: 4,
        hoverElevation: 3,
        disabledElevation: 0,
        onPressed: onPositive,
        shape: RoundedRectangleBorder(
          borderRadius: buttonRadius,
          side: BorderSide.none,
        ),
        child: Text(
          positiveAction ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.button!.copyWith(
            color: buttonColor.toContrast(),
          ),
        ),
      ),
    );

    final neutral = OutlineButton(
      color: buttonColor,
      borderSide: BorderSide(
        color: buttonColor,
        width: 1.5,
      ),
      splashColor: buttonColor.withOpacity(0.15),
      focusColor: buttonColor.withOpacity(0.2),
      hoverColor: buttonColor.withOpacity(0.2),
      highlightColor: buttonColor.withOpacity(0.2),
      disabledBorderColor: buttonColor.withOpacity(.5),
      disabledTextColor: theme.textTheme.button!.color!.withOpacity(.5),
      highlightedBorderColor: buttonColor,
      onPressed: onNeutral,
      shape: RoundedRectangleBorder(
        borderRadius: buttonRadius,
        side: shape is RoundedRectangleBorder
            ? shape.side.copyWith(color: buttonColor)
            : BorderSide.none,
      ),
      child: Text(
        neutralAction ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.button!.copyWith(color: buttonColor),
      ),
    );

    final nt = Text(
      negativeAction ?? '',
      style: theme.textTheme.button!.copyWith(color: buttonColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final negative = neutralAction == null
        ? FlatButton(
            color: Colors.transparent,
            splashColor: buttonColor.withOpacity(0.15),
            focusColor: buttonColor.withOpacity(0.2),
            hoverColor: buttonColor.withOpacity(0.2),
            highlightColor: buttonColor.withOpacity(0.2),
            disabledColor: buttonColor.withOpacity(.5),
            onPressed: onNegative ?? () => Navigator.of(context).pop(),
            child: nt,
            shape: RoundedRectangleBorder(
              borderRadius: buttonRadius,
            ),
          )
        : GestureDetector(
            onTap: negativeAction != null ? () => Navigator.of(context).pop() : null,
            child: nt,
          );

    return SizeBuilder(
      builder: (context, width, height) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            floatingButtons ? padding.left : 0.0,
            padding.top * 0.625,
            floatingButtons ? padding.right : 0.0,
            padding.bottom * 0.625,
          ),
          child: ButtonTheme(
            padding: isDense ? const EdgeInsets.all(8) : null,
            child: Row(
              children: <Widget>[
                if (isDense)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: (width * (1 / 3)) - 16.0),
                    child: negative,
                  ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasNeutral || hasNegative)
                        Flexible(child: hasNeutral ? neutral : negative),
                      if (hasPositive) Flexible(child: positive),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}